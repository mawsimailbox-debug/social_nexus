#!/usr/bin/env python3
"""Fail-closed preflight, not a packager. No green-boolean bypass."""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARTIFACTS = (
    'ci-run', 'go-tests', 'flutter-tests', 'coverage-backend', 'coverage-auth',
    'coverage-regression', 'android-aab', 'android-apk', 'ios-ipa',
    'integration-testcontainers', 'migration-up-down', 'contract-validation',
    'auth-real-email-e2e', 'sms-absence-audit', 'fresh-machine-rehearsal',
    'parity-six-screens', 'parity-auth-baseline', 'uat-report', 'UAT-SIGNOFF.pdf',
    'k6-load', 'k6-soak-12h', 'perf-regression', 'cold-start', 'db-explain',
    'gitleaks', 'gosec', 'staticcheck', 'semgrep', 'dart-security', 'govulncheck',
    'zap-baseline', 'zap-auth', 'owasp-top10', 'sbom-api', 'sbom-mobile',
    'dependency-review', 'backup-restore-drill', 'staging-smoke',
    'canary-rollback-rehearsal', 'store-metadata-approved', 'beta-crash-free',
    'legal-license-review', 'review-approvals', 'branch-protection-export',
    'toolchain-pins', 'infra-tls-monitoring', 'secrets-inventory-review',
)
REQUIRED_FILES = (
    'README.md', 'CHANGELOG.md', 'LICENSE', 'docker-compose.yml', '.env.example',
    'backend-go/openapi.yaml', 'backend-go/go.mod', 'app-flutter/pubspec.yaml',
    'docs/PRD.md', 'docs/SAD-C4.md', 'docs/ERD.md', 'docs/Runbook.md',
    'docs/TestPlan.md', 'docs/RELEASE-NOTES.md', 'docs/BUILD_MANIFEST.txt',
)


def cmd(*args):
    return subprocess.check_output(args, cwd=ROOT, text=True, stderr=subprocess.STDOUT).strip()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def signed(path, sig, trusted):
    # Trust is caller-provisioned outside the repo; import no key from evidence.
    p = subprocess.run(['gpg', '--batch', '--status-fd=1', '--verify', str(sig), str(path)],
                       text=True, capture_output=True)
    require(p.returncode == 0, f'Invalid detached signature: {sig.name}')
    fingerprints = re.findall(r'\[GNUPG:\] VALIDSIG ([A-F0-9]+)', p.stdout)
    require(len(fingerprints) == 1 and fingerprints[0] in trusted,
            f'Untrusted signer: {sig.name}')
    return fingerprints[0]


def safe_file(base, rel):
    require(isinstance(rel, str), 'Artifact path must be a string')
    p = (base / rel).resolve()
    require(p.is_relative_to(base) and not Path(rel).is_absolute(), 'Evidence path escape')
    require(p.is_file() and p.stat().st_size > 0, f'Missing/empty evidence: {rel}')
    return p


def protected_file(value, label, executable=False):
    require(isinstance(value, str) and Path(value).is_absolute(), f'{label} must be absolute')
    p = Path(value).resolve()
    require(p.is_file() and not p.is_relative_to(ROOT), f'{label} must be outside repository')
    info = p.stat()
    require(info.st_uid in (0, os.getuid()) and not info.st_mode & 0o022,
            f'{label} must be controlled by runner administrator and not group/world writable')
    if executable:
        require(os.access(p, os.X_OK), f'{label} not executable')
    return p


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--evidence', required=True, type=Path)
    ap.add_argument('--phase', choices=('candidate', 'final'), default='candidate')
    a = ap.parse_args()
    base = a.evidence.resolve()
    require(base.is_dir(), 'Evidence directory missing; no package authorized')
    policy_path = protected_file(os.environ.get('NEXUS_RELEASE_TRUST_POLICY'), 'Trust policy')
    policy = json.loads(policy_path.read_text())
    require(policy.get('schema') == 1, 'Unknown trust policy schema')
    validator = protected_file(policy.get('validator_path'), 'Semantic validator', executable=True)
    require(hashlib.sha256(validator.read_bytes()).hexdigest() == policy.get('validator_sha256'),
            'Semantic validator digest mismatch')
    manifest = safe_file(base, 'evidence.json')
    signed(manifest, safe_file(base, 'evidence.json.asc'), policy['ci_signers'])
    evidence = json.loads(manifest.read_text())
    sha = cmd('git', 'rev-parse', 'HEAD')
    require(not cmd('git', 'status', '--porcelain', '--untracked-files=all'), 'Working tree not clean')
    require(evidence.get('commit') == sha, 'Evidence commit does not match HEAD')
    tag = evidence.get('tag', '')
    require(re.fullmatch(r'v\d+\.\d+\.\d+', tag), 'Real semver tag required')
    require(cmd('git', 'rev-parse', tag + '^{commit}') == sha, 'Tag commit mismatch')
    tag_status = cmd('git', 'verify-tag', '--raw', tag)
    require(any('[GNUPG:] VALIDSIG ' + f + ' ' in tag_status for f in policy['tag_signers']),
            'Tag signer not trusted')
    for rel in REQUIRED_FILES:
        require((ROOT / rel).is_file() and (ROOT / rel).stat().st_size, f'Missing required file: {rel}')
    raw = (ROOT / 'design/Social Suite v3 — Business & Community.html').read_bytes()
    require(hashlib.md5(raw).hexdigest() == 'a8fafd493261eda3876d79039c564e10', 'Design MD5 mismatch')
    artifacts = evidence.get('artifacts', {})
    for key in ARTIFACTS:
        entry = artifacts.get(key)
        require(isinstance(entry, dict), f'Missing artifact record: {key}')
        file = safe_file(base, entry.get('path'))
        require(hashlib.sha256(file.read_bytes()).hexdigest() == entry.get('sha256'),
                f'Artifact digest mismatch: {key}')
        require(entry.get('commit') == sha and entry.get('producer_run'), f'Unbound artifact: {key}')
        # Report semantics must be evaluated by trusted CI, then signed. An unsigned
        # local JSON or a bare true/green flag is not accepted as a report.
        require(entry.get('media_type') and entry.get('producer_tool'), f'No provenance: {key}')
    decisions = evidence.get('gate_decisions', {})
    for grade in [f'G{i}' for i in range(1, 9)]:
        d = decisions.get(grade, {})
        require(d.get('decision') == 'PASS' and d.get('artifact_ids') and
                all(k in ARTIFACTS for k in d['artifact_ids']), f'Gate evidence incomplete: {grade}')
    require(evidence.get('phase') == a.phase, 'Evidence phase mismatch')
    # Candidate authorization is not post-package/publication acceptance.
    used = set()
    for role in ('qa', 'design', 'team_lead'):
        approval = safe_file(base, f'{role}.json')
        signer = signed(approval, safe_file(base, f'{role}.json.asc'), policy[f'{role}_signers'])
        require(signer not in used, 'QA, design and team lead must be distinct signers')
        used.add(signer)
        data = json.loads(approval.read_text())
        require(data.get('commit') == sha and data.get('evidence_sha256') ==
                hashlib.sha256(manifest.read_bytes()).hexdigest(), f'Stale approval: {role}')
        expected = list(range(1, 12)) if a.phase == 'final' else [1, 2, 3, 4, 5, 6, 7, 8, 11]
        require(data.get('role') == role and data.get('signed_at') and data.get('phase') == a.phase
                and data.get('approved_dod') == expected, f'Incomplete DoD signature: {role}')
    # Snapshot all bytes verified above to detect concurrent report replacement.
    snapshot = {p: hashlib.sha256(p.read_bytes()).hexdigest() for p in base.rglob('*') if p.is_file()}
    evidence_digest = hashlib.sha256(manifest.read_bytes()).hexdigest()
    policy_digest = hashlib.sha256(policy_path.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory(prefix='nexus-verdict-') as temporary:
        verdict = Path(temporary) / 'decision.json'
        # Fixed argv, no shell, no user-supplied command fragments. Administrator
        # must protect executable dependencies, parent directories and GPG store.
        p = subprocess.run([str(validator), '--repository', str(ROOT), '--evidence', str(base),
                            '--commit', sha, '--tag', tag, '--phase', a.phase,
                            '--evidence-sha256', evidence_digest, '--policy-sha256', policy_digest,
                            '--output', str(verdict)], cwd=ROOT, timeout=300,
                           env={'PATH': '/usr/bin:/bin', 'HOME': os.path.expanduser('~'),
                                'GNUPGHOME': os.environ.get('GNUPGHOME', os.path.expanduser('~/.gnupg'))})
        require(p.returncode == 0, 'Trusted semantic validator rejected evidence or failed')
        require(verdict.is_file(), 'Trusted validator produced no decision')
        signed(verdict, Path(str(verdict) + '.asc'), policy['validator_signers'])
        decision = json.loads(verdict.read_text())
        require(decision.get('schema') == 1 and decision.get('decision') == 'PASS'
                and decision.get('commit') == sha and decision.get('tag') == tag
                and decision.get('phase') == a.phase
                and decision.get('evidence_sha256') == evidence_digest
                and decision.get('policy_sha256') == policy_digest,
                'Trusted signed verdict does not bind this candidate/policy/phase')
    require(all(p.is_file() and hashlib.sha256(p.read_bytes()).hexdigest() == h
                for p, h in snapshot.items()), 'Evidence changed during validation')
    require(cmd('git', 'rev-parse', 'HEAD') == sha and
            not cmd('git', 'status', '--porcelain', '--untracked-files=all'), 'Repository changed during validation')
    print(json.dumps({'decision': 'PASS', 'phase': a.phase, 'commit': sha, 'tag': tag,
                      'evidence_sha256': evidence_digest, 'packaged': False}))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError, subprocess.SubprocessError) as exc:
        print(f'BLOCKED: {exc}', file=sys.stderr)
        sys.exit(1)
