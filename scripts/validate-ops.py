#!/usr/bin/env python3
"""Real offline structural checks; explicitly not production validation."""
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]


def run():
    raw = (ROOT / 'design/Social Suite v3 — Business & Community.html').read_bytes()
    digest = hashlib.md5(raw).hexdigest()
    assert digest == 'a8fafd493261eda3876d79039c564e10'
    for file in ('MD5.txt', 'HTML-MD5.txt'):
        assert (ROOT / 'design' / file).read_text().strip() == digest
    assert (ROOT / 'design/tokens.css').read_bytes() == re.search(rb':root\s*\{.*?\}', raw, re.S).group(0)
    data = json.loads((ROOT / 'qa/fixtures/source-v3.json').read_text())
    assert data['source_md5'] == digest
    assert data['source_sha256'] == hashlib.sha256(raw).hexdigest()
    assert set(data['screens']) == {'feed', 'chat', 'profile', 'discover', 'business', 'group'}
    assert len(data['interaction_elements']) == 183
    for name, fragment in data['screens'].items():
        assert fragment in raw.decode('utf-8'), f'Fixture fragment altered: {name}'
    assert data['script_source'] == re.search(r'<script>(.*?)</script>', raw.decode(), re.S).group(1)
    ymls = [ROOT / 'docker-compose.yml', *sorted((ROOT / '.github').rglob('*.yml')),
            *sorted((ROOT / 'ci').glob('*.yml'))]
    for file in ymls:
        with file.open() as f:
            assert isinstance(yaml.safe_load(f), dict), file
    for name in ('ci.yml', 'release.yml'):
        assert (ROOT / 'ci' / name).read_bytes() == (ROOT / '.github/workflows' / name).read_bytes()
    for directory in ('scripts', 'ci', 'qa'):
        for file in sorted((ROOT / directory).rglob('*.sh')):
            subprocess.run(['bash', '-n', str(file)], check=True)
    for directory in ('scripts', 'ci', 'qa'):
        for file in sorted((ROOT / directory).rglob('*.py')):
            compile(file.read_text(), str(file), 'exec')
    # Negative tests could fail if a future change accidentally authorizes packaging.
    r = subprocess.run([sys.executable, str(ROOT / 'scripts/release-gate.py'),
                        '--evidence', '/nonexistent/nexus-evidence'], capture_output=True, text=True)
    assert r.returncode != 0 and 'BLOCKED' in r.stderr, 'Release gate failed open'
    r = subprocess.run(['bash', str(ROOT / 'scripts/release.sh'),
                        '--evidence', '/nonexistent/nexus-evidence'], capture_output=True, text=True)
    assert r.returncode != 0 and 'BLOCKED' in r.stderr, 'Release wrapper failed open'
    assert 'Evidence gate only' in r.stderr, 'Release wrapper hides non-packaging scope'
    pins = json.loads((ROOT / 'ci/approved-tools.json').read_text())
    if pins.get('status') != 'APPROVED':
        r = subprocess.run([sys.executable, str(ROOT / 'ci/check-pins.py')],
                           capture_output=True, text=True)
        assert r.returncode != 0 and 'BLOCKED' in r.stderr, 'Missing pins failed open'
    env = dict(__import__('os').environ)
    for key in ('NEXUS_ALLOW_SEED', 'NEXUS_PREVIOUS_API_IMAGE'):
        env.pop(key, None)
    for script in ('seed.sh', 'rollback.sh'):
        r = subprocess.run(['bash', str(ROOT / 'scripts' / script)], env=env,
                           capture_output=True, text=True)
        assert r.returncode != 0, f'{script} unsafe default'
    print(f'PASS offline ops checks: MD5={digest}; tokens exact including photo; '
          f'6 fixtures/183 elements; {len(ymls)} YAML files; shell/Python syntax; '
          'workflow mirrors; release/seed/rollback refusal tests.')
    print('NOT CHECKED: Docker runtime, CI, Go/Flutter, signing, parity, UAT, perf, security, deployment.')


if __name__ == '__main__':
    run()
