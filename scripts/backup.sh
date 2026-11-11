#!/usr/bin/env bash
set -euo pipefail
umask 077
cd -- "$(dirname -- "$0")/.."
: "${NEXUS_BACKUP_DIR:?Set existing backup directory outside repo}"
: "${NEXUS_BACKUP_PASSPHRASE_FILE:?Set protected high-entropy backup passphrase file outside repo}"
command -v gpg >/dev/null
[[ -s "$NEXUS_BACKUP_PASSPHRASE_FILE" && ! -L "$NEXUS_BACKUP_PASSPHRASE_FILE" ]] || exit 2
[[ "$(stat -c %a "$NEXUS_BACKUP_PASSPHRASE_FILE")" == 600 ]] || exit 2
[[ -d "$NEXUS_BACKUP_DIR" && ! -L "$NEXUS_BACKUP_DIR" ]] || exit 2
out="$NEXUS_BACKUP_DIR/nexus-$(date -u +%Y%m%dT%H%M%SZ)-$$.dump.gpg"
tmp=$(mktemp "$NEXUS_BACKUP_DIR/.partial.XXXXXXXX")
trap 'rm -f -- "$tmp"' EXIT
# No plaintext dump ever written to disk. Pipefail rejects either process failure.
docker compose exec -T postgres sh -eu -c 'PGPASSWORD=$(cat /run/secrets/postgres_password); export PGPASSWORD; exec pg_dump -Fc -U "$POSTGRES_USER" -d "$POSTGRES_DB"' |
  gpg --batch --symmetric --cipher-algo AES256 --pinentry-mode loopback \
    --passphrase-file "$NEXUS_BACKUP_PASSPHRASE_FILE" --output - > "$tmp"
[[ -s "$tmp" ]] || exit 1
mv -n -- "$tmp" "$out"
sha256sum "$out" > "$out.sha256"
printf 'Encrypted backup: %s\n' "$out"
# Offsite replication, seven-day retention, WAL and restore drill are not implied.
