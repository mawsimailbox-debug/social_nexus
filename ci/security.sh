#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
python3 ci/check-pins.py --runtime
for t in gitleaks gosec staticcheck semgrep govulncheck syft jscpd; do command -v "$t" >/dev/null; done
mkdir -p qa/reports
gitleaks detect --source . --redact --report-format json --report-path qa/reports/gitleaks.json
(cd backend-go && gosec -fmt=json -out=../qa/reports/gosec.json ./... && staticcheck ./... && govulncheck ./...)
semgrep scan --config ci/semgrep.yml --error --json --output qa/reports/semgrep.json backend-go app-flutter
jscpd backend-go app-flutter/lib --threshold 3 --reporters json --output qa/reports/duplication
syft dir:backend-go -o cyclonedx-json=qa/reports/sbom-api.json
syft dir:app-flutter -o cyclonedx-json=qa/reports/sbom-mobile.json
# Explicitly do not infer DAST, dependency vulnerability clearance, OWASP or Dart
# security clearance from these scans. Release gate requires their separate reports.
