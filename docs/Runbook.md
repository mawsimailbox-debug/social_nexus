# Runbook — explicit safe operations

Status: NOT deployed. Real service owners/on-call contacts, provider/account/region,
DNS, certificate and signing trust inventories are REQUIRED (no invented IDs).

## Provisioning checklist (manual infra alternative)

1. Owner approves isolated staging/prod accounts, network/VPC/firewall and regions.
2. Provision encrypted PG16 storage + WAL, Redis7 protected network/ACL/TLS,
   encrypted offsite backup destination and least-privilege service identities.
3. Secret manager holds PII key, JWT key, SMTP credentials, DB/Redis credentials,
   store signing keys; rotation quarterly; no .env production secret distribution.
4. TLS≥1.2 termination/HSTS, automatic renewal + expiry alerts; egress allow-list
   email provider, backup and monitoring. Verify API non-public data services.
5. Install Prometheus/Grafana/Loki, metrics and masked JSON request_id logging;
   real alert routing and SLO dashboards. No checked-in config alone proves this.
6. Stage with exact immutable image digests; verify migrations in a restore clone.
   Use expand/contract schema changes; back up before migration; run smoke chain.
7. Establish protected CI runners. Never execute untrusted fork PR code on a
   long-lived runner with secrets. Isolate ephemeral PR runners from release trust.
8. Document resource sizing, capacity plan, retention/access/deletion policy and
   cost approvals. Record actual commands/results in signed infrastructure report.

## Deployment and rollback

Target pipeline: lint/test→build→security/SBOM→staging registry pull→migrate→smoke
register/login/email/confirm→human approval→shadow→5%→25%→100%. Traffic switch
adapter is not implemented; production deployment is BLOCKED. Canary observation
windows and abort thresholds must be approved using baseline measurements.
Alert/abort: 5xx>1%, p95>500ms, disk>80%, email failure>5%; perf p95 regression>20%.
Mobile beta crash-free≥99.5%; define denominator and period in actual beta report.

On regression freeze rollout, preserve logs/request IDs and assess schema
compatibility. `scripts/rollback.sh` plans only by default; even --apply refuses
without the unimplemented signature/traffic adapter. Never blindly restore a DB
over live data or run down migrations. Restore to an isolated new DB, verify,
reconcile writes and seek owner approval before a controlled switch.

## Backup/restore

`scripts/backup.sh` streams pg_dump custom format through GPG AES256 encryption;
requires protected passphrase file (0600) and existing external backup directory.
No plaintext dump is saved. Verify digest, decrypt to a pipe and run pg_restore
`--list` on isolated infrastructure; actual restore test must validate row counts,
constraints and auth/social journeys. AES256 algorithm selection alone is not a
restore proof. Offsite daily scheduling, seven-day retention and WAL shipping are
REQUIRED infrastructure tasks; this sandbox does not schedule them. Quarterly
restore drill records measured RPO/RTO; no invented recovery objective achieved.

## Opt-in partial demonstration seed — local/test only

Actual SQL adapter: `backend-go/seed.sql`. It requires an existing VERIFIED local
demonstration account via psql owner_id; it does not create accounts/credentials
or establish phone ownership. Complete real registration/email verification first,
then set VERIFIED_DEMO_OWNER_ID to the actual account ID. With NEXUS_ENV exported
as development or test, from project root:

```sh
NEXUS_SEED_SQL=backend-go/seed.sql \
NEXUS_SEED_OWNER_ID="$VERIFIED_DEMO_OWNER_ID" \
NEXUS_ALLOW_SEED=local-test bash scripts/seed.sh
```

The wrapper passes owner_id as a safe positional argument to psql. SQL already
contains BEGIN/COMMIT; no outer --single-transaction should be added. It inserts
one demo shop, three products, a group, two posts and membership—not complete
source-v3 data or UI parity. Repeated execution can duplicate content. Restrict
to a disposable local/test database and verify intended account/environment before
execution. Parent has not executed this against production; no seed-run success
or full-parity result is claimed here.

## Maintenance/incident response

Triage within24h; S0 crash/lockout target4h hotfix→canary; S1 current sprint;
S2/S3 backlog. Every fix adds regression test. Security critical dependency update
target≤7d, emergency CVEs use hotfix. Weekly vacuum/analyze, top10 slow query review,
capacity forecast and email bounce/spam/provider health. Quarterly keys/certs.
Biweekly patch window, sprint-end feature releases; mandatory security vs soft
feature update policy. Weekly feedback digest and monthly D1/D7/login200:202/
recovery/feed KPI report, with consent and minimized identifiers.

Evidence retention/audit location, incident escalation and actual contacts remain
REQUIRED. Never include phone/email/OTP/token in operational logs or CI artifacts.
