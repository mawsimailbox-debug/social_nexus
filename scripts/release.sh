#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
printf '%s\n' 'Evidence gate only: no ZIP creation, release publication or deployment is performed.' >&2
python3 scripts/release-gate.py "$@"
printf '%s\n' 'Requested evidence phase validated. No ZIP created; separate approved packaging/publication required.'
