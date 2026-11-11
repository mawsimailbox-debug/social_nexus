#!/bin/sh
set -eu
# Compatibility adapter: backend may read env instead of *_FILE. Never log secrets.
NEXUS_DATABASE_URL=$(cat "${NEXUS_DATABASE_URL_FILE:?Required}")
NEXUS_REDIS_URL=$(cat "${NEXUS_REDIS_URL_FILE:?Required}")
NEXUS_JWT_KEY=$(cat "${NEXUS_JWT_KEY_FILE:?Required}")
NEXUS_ENCRYPTION_KEY=$(cat "${NEXUS_ENCRYPTION_KEY_FILE:?Required}")
NEXUS_LOOKUP_KEY=$(cat "${NEXUS_LOOKUP_KEY_FILE:?Required}")
NEXUS_SENDGRID_API_KEY=$(cat "${NEXUS_SENDGRID_API_KEY_FILE:?Required}")
test -n "$NEXUS_DATABASE_URL" && test -n "$NEXUS_REDIS_URL"
test -n "$NEXUS_JWT_KEY" && test -n "$NEXUS_ENCRYPTION_KEY" && test -n "$NEXUS_LOOKUP_KEY" && test -n "$NEXUS_SENDGRID_API_KEY"
export NEXUS_DATABASE_URL NEXUS_REDIS_URL NEXUS_JWT_KEY NEXUS_ENCRYPTION_KEY NEXUS_LOOKUP_KEY NEXUS_SENDGRID_API_KEY
# Only one source reaches the backend. Native config.Secret deliberately rejects
# ambiguous direct values plus file pointers; the adapter already read the files.
unset NEXUS_DATABASE_URL_FILE NEXUS_REDIS_URL_FILE NEXUS_JWT_KEY_FILE
unset NEXUS_ENCRYPTION_KEY_FILE NEXUS_LOOKUP_KEY_FILE NEXUS_SENDGRID_API_KEY_FILE
if [ "$#" -gt 0 ]; then exec "$@"; fi
exec /app/api
