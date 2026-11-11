#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/../.."
: "${NEXUS_ZAP_TARGET:?Set explicitly authorized staging URL}"
: "${NEXUS_ZAP_IMAGE:?Set approved ZAP image pinned by sha256}"
[[ "${NEXUS_ZAP_AUTHORIZED:-}" == staging-only ]] || exit 2
[[ "$NEXUS_ZAP_IMAGE" =~ @sha256:[0-9a-f]{64}$ ]] || exit 2
mkdir -p qa/reports
# Tool exit 1/2/3 all fail; do not swallow warnings or scanner failures.
docker run --rm -v "$PWD/qa/reports:/zap/wrk:rw" "$NEXUS_ZAP_IMAGE" \
  zap-baseline.py -t "$NEXUS_ZAP_TARGET" -J zap-baseline.json -r zap-baseline.html
