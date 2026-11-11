#!/usr/bin/env bash
set -euo pipefail
: "${NEXUS_ZAP_TARGET:?Set staging target}"
[[ "${NEXUS_ZAP_AUTHORIZED:-}" == staging-only ]] || exit 2
printf '%s\n' 'BLOCKED: authenticated active DAST requires security-owner-approved context, scope, exclusions, test accounts and isolated data. No scan started.' >&2
exit 1
# Deliberate safety stop: do not run an unscoped destructive active scan.
