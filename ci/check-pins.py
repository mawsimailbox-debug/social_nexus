#!/usr/bin/env python3
"""Fail explicitly until real approved action SHAs and runtime tool pins exist."""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMMANDS = {
    'go': ['go', 'version'], 'flutter': ['flutter', '--version'],
    'golangci-lint': ['golangci-lint', 'version'], 'goimports': ['go', 'version', '-m'],
    'staticcheck': ['staticcheck', '-version'], 'gitleaks': ['gitleaks', 'version'],
    'gosec': ['gosec', '-version'], 'semgrep': ['semgrep', '--version'],
    'govulncheck': ['govulncheck', '-version'], 'syft': ['syft', 'version'],
    'jscpd': ['jscpd', '--version'], 'k6': ['k6', 'version'],
}


def main():
    errors = []
    for file in (ROOT / '.github/workflows').glob('*.yml'):
        for ref in re.findall(r'uses:\s*([^\s]+)', file.read_text()):
            if not re.fullmatch(r'[^@]+@[0-9a-f]{40}', ref):
                errors.append(f'{file.name}: unapproved mutable action ref {ref}')
    lock = json.loads((ROOT / 'ci/approved-tools.json').read_text())
    if lock.get('schema') != 1 or lock.get('status') != 'APPROVED':
        errors.append('Tool lock not approved; ci/TOOLCHAIN.md has provisioning instructions')
    pins = lock.get('tools', {})
    for name in COMMANDS:
        pin = pins.get(name, {})
        if not (pin.get('version') and re.fullmatch(r'[0-9a-f]{64}', pin.get('binary_sha256', ''))
                and pin.get('source') and pin.get('approved_by')):
            errors.append(f'Missing real approved version/binary digest/provenance: {name}')
    # Runtime verification is opt-in for the provisioned security runner; static
    # provisioning validation above always runs and cannot pass on an empty lock.
    if '--runtime' in sys.argv and not errors:
        import hashlib
        import shutil
        for name, command in COMMANDS.items():
            binary = shutil.which(name)
            if not binary or hashlib.sha256(Path(binary).resolve().read_bytes()).hexdigest() != pins[name]['binary_sha256']:
                errors.append(f'Binary missing/digest mismatch: {name}')
                continue
            if name == 'goimports':
                command = ['go', 'version', '-m', binary]
            p = subprocess.run(command, text=True, capture_output=True)
            if p.returncode or pins[name]['version'] not in p.stdout + p.stderr:
                errors.append(f'Installed version mismatch: {name}')
    for error in errors:
        print('BLOCKED: ' + error, file=sys.stderr)
    return bool(errors)


if __name__ == '__main__':
    sys.exit(main())
