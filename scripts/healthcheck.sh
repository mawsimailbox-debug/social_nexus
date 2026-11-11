#!/usr/bin/env bash
set -euo pipefail
: "${NEXUS_HEALTH_URL:?Set exact readiness URL}"
[[ "$NEXUS_HEALTH_URL" =~ ^https?:// ]] || { printf '%s\n' 'Invalid health URL' >&2; exit 2; }
curl --fail --silent --show-error --connect-timeout 2 --max-time 5 --retry 2 --retry-delay 1 "$NEXUS_HEALTH_URL"
