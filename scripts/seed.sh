#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
[[ "${NEXUS_ALLOW_SEED:-}" == local-test ]] || { printf '%s\n' 'BLOCKED: explicit local-test opt-in required' >&2; exit 2; }
[[ "${NEXUS_ENV:-}" == development || "${NEXUS_ENV:-}" == test ]] || { printf '%s\n' 'BLOCKED: production seeding forbidden' >&2; exit 2; }
: "${NEXUS_SEED_SQL:?Set reviewed schema-compatible SQL adapter; source fixture is qa/fixtures/source-v3.json}"
: "${NEXUS_SEED_OWNER_ID:?Set an existing verified local demonstration account ID}"
[[ -s "$NEXUS_SEED_SQL" ]] || exit 2
# The reviewed SQL adapter owns its transaction. No schema guessing or credentials
# are created here; owner_id is a psql variable, never interpolated into shell code.
docker compose exec -T postgres sh -eu -c 'PGPASSWORD=$(cat /run/secrets/postgres_password); export PGPASSWORD; exec psql -X -v ON_ERROR_STOP=1 -v owner_id="$1" -U "$POSTGRES_USER" -d "$POSTGRES_DB"' sh "$NEXUS_SEED_OWNER_ID" < "$NEXUS_SEED_SQL"
