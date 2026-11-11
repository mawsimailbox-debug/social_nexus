#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
: "${NEXUS_PREVIOUS_API_IMAGE:?Set previously verified immutable image@sha256 reference}"
[[ "$NEXUS_PREVIOUS_API_IMAGE" =~ @sha256:[0-9a-f]{64}$ ]] || exit 2
if [[ "${1:-}" != --apply ]]; then
  printf 'PLAN ONLY: replace API with %s; preserve PostgreSQL/Redis volumes.\n' "$NEXUS_PREVIOUS_API_IMAGE"
  printf '%s\n' 'Requires approved compatibility report and operator confirmation; no DB down-migration.'
  exit 0
fi
[[ "${NEXUS_ROLLBACK_CONFIRM:-}" == api-only-no-data-loss ]] || exit 2
: "${NEXUS_ROLLBACK_APPROVAL_FILE:?Set verified change approval file}"
: "${NEXUS_SCHEMA_COMPATIBILITY_FILE:?Set verified backwards-compatibility report}"
[[ -s "$NEXUS_ROLLBACK_APPROVAL_FILE" && -s "$NEXUS_SCHEMA_COMPATIBILITY_FILE" ]] || exit 2
printf '%s\n' 'BLOCKED: approval signature verifier and traffic-switch adapter not configured. No changes made.' >&2
exit 1
