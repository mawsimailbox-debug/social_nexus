#!/usr/bin/env bash
# Local end-to-end rehearsal of the G3 auth journeys against the real API,
# real PostgreSQL, real cryptography and a local file mail sink.
# No container runtime, no provider credentials, no SMS anywhere.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
: "${NEXUS_E2E_DB:=nexus_e2e}"
REPORT="${1:-qa/reports/g3-auth-e2e.log}"
MAIL=$(mktemp /tmp/nexus-mail-XXXX.log)
KEY1=$(head -c32 /dev/urandom | base64 -w0)
KEY2=$(head -c32 /dev/urandom | base64 -w0)
KEY3=$(head -c32 /dev/urandom | base64 -w0)
DSN="postgres:///${NEXUS_E2E_DB}?host=/var/run/postgresql&sslmode=disable"
sudo -n -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${NEXUS_E2E_DB}'" | grep -q 1 \
  || sudo -n -u postgres createdb "${NEXUS_E2E_DB}"
export NEXUS_ENV=development NEXUS_DATABASE_URL="$DSN" \
       NEXUS_JWT_KEY="$KEY1" NEXUS_ENCRYPTION_KEY="$KEY2" NEXUS_LOOKUP_KEY="$KEY3" \
       NEXUS_EMAIL_FROM=no-reply@nexus.local NEXUS_EMAIL_SINK_FILE="$MAIL" \
       NEXUS_ADDR=127.0.0.1:18081
(cd backend-go && go run ./cmd/migrate up) >/tmp/e2e-migrate.log 2>&1
(cd backend-go && go build -o /tmp/nexus-api-e2e ./cmd/api)
/tmp/nexus-api-e2e >/tmp/e2e-api.log 2>&1 &
API_PID=$!
trap 'kill $API_PID 2>/dev/null || true' EXIT
for _ in $(seq 1 50); do curl -fsS http://127.0.0.1:18081/healthz >/dev/null 2>&1 && break; sleep 0.2; done
NEXUS_E2E_MAIL="$MAIL" python3 scripts/e2e-auth.py | tee "$REPORT"
