#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/../.."
: "${NEXUS_BASE_URL:?Required authorized staging}"
: "${NEXUS_LOAD_AUTHORIZED:?Set staging-only after authorization}"
: "${NEXUS_AUTH_FIXTURES:?External reviewed unique preverified phone/device fixture file required}"
[[ "$NEXUS_LOAD_AUTHORIZED" == staging-only ]] || exit 2
mkdir -p qa/reports
NEXUS_SOAK=12h NEXUS_LOAD_MODE=feed k6 run --summary-export qa/reports/k6-soak-12h.json qa/k6/load.js
# Separately archive 12h RSS/heap/DB/Redis telemetry; success alone cannot prove no leak.
