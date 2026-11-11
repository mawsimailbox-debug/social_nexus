#!/usr/bin/env python3
"""Record actual observed hashes, never fabricate release identities or gates."""
import hashlib
import argparse
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description='Observed source inventory, not release approval')
parser.add_argument('--aggregate', action='store_true', help='Include backend/mobile source after all agents settle')
args = parser.parse_args()


def git(*args):
    r = subprocess.run(['git', '-C', str(ROOT), *args], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else 'UNAVAILABLE (no verified repository identity)'


lines = ['Nexus BUILD_MANIFEST — OPERATIONS SCAFFOLD, NOT A RELEASE',
         'Generated UTC: ' + datetime.now(timezone.utc).isoformat(),
         'Release tag: NOT CREATED / NOT VERIFIED', 'Observed HEAD: ' + git('rev-parse', 'HEAD'),
         'Working tree state: ' + git('status', '--porcelain'),
         'ZIP: NOT GENERATED; no signed tag, review, CI, deployment or UAT claimed.',
         'Design HTML MD5: a8fafd493261eda3876d79039c564e10',
         'Auth baseline: authorized NEW token-based baseline; approval unsigned.',
         'DoD: original10 retained plus separate11 Team Lead authorization.',
         *[f'G{i}: BLOCKED — actual release evidence/signatures required' for i in range(1, 9)],
         'QA signature: BLANK', 'Design signature: BLANK', 'Team Lead signature: BLANK',
         'Inventory scope: ' + ('aggregate source; generated artifacts and secrets excluded' if args.aggregate else 'owned operations source only'),
         'Actual SHA256 inventory (manifest excludes itself):']
sources = [ROOT.parent / 'nexus-guide.docx', ROOT.parent / 'social-suite-v3.html']
owned = [p for p in ROOT.iterdir() if p.is_file()]
for directory in ('ci', '.github', 'docs', 'scripts', 'qa', 'design'):
    owned.extend((ROOT / directory).rglob('*'))
if args.aggregate:
    for directory in ('backend-go', 'app-flutter'):
        owned.extend((ROOT / directory).rglob('*'))
excluded_dirs = {'.git', '.dart_tool', '.gradle', '.idea', '.symlinks', 'node_modules',
                 '__pycache__', 'build', 'dist', 'coverage', 'secrets', 'evidence', 'backups',
                 'Pods', 'ephemeral', '.pub-cache'}
excluded_suffixes = {'.zip', '.pem', '.key', '.p12', '.jks', '.keystore', '.gpg', '.age',
                     '.dump', '.log', '.pyc', '.ipa', '.apk', '.aab', '.out'}
for p in sorted(sources + owned):
    if not p.is_file() or p.is_symlink() or p.name == 'BUILD_MANIFEST.txt':
        continue
    if set(p.relative_to(ROOT).parts if p.is_relative_to(ROOT) else ()) & excluded_dirs:
        continue
    if p.suffix.lower() in excluded_suffixes or (p.name.startswith('.env') and p.name != '.env.example'):
        continue
    if p.name in ('local.properties', 'key.properties', '.flutter-plugins-dependencies'):
        continue
    if p.is_relative_to(ROOT) and 'reports' in p.relative_to(ROOT).parts and p.name != 'README.md':
        continue
    label = str(p.relative_to(ROOT)) if p.is_relative_to(ROOT) else 'source-input/' + p.name
    lines.append(hashlib.sha256(p.read_bytes()).hexdigest() + '  ' + label)
(ROOT / 'docs/BUILD_MANIFEST.txt').write_text('\n'.join(lines) + '\n')
print(f'Recorded {len(lines)} manifest lines with actual hashes; release BLOCKED')
