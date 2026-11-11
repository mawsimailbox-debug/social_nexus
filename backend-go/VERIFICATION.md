# Executed backend verification

Scope: `/home/user/workspace/nexus/backend-go` only for application changes.
Both provided source documents were read, not modified. No ZIP, publication,
git commit, tag or push was performed. Go was installed at the agreed shared
path `/home/user/workspace/toolchains/go` after checking official go.dev metadata
and verifying archive SHA256:
`65efbc80fdc1fa2cd2631cad5b481777a68e8725f34e89f50fc6ac714e379b40`.
Reported version: `go version go1.27.3 linux/amd64`.

## Actual commands and results

All commands ran from backend-go; `go` below refers to the shared toolchain.

```sh
go mod tidy
gofmt -w cmd internal
gofmt -l cmd internal
NEXUS_TEST_DATABASE_URL='postgres:///nexus_backend_test?host=/var/run/postgresql&sslmode=disable' go test -race -cover ./...
NEXUS_TEST_DATABASE_URL='postgres:///nexus_backend_test?host=/var/run/postgresql&sslmode=disable' go test -race -coverpkg=./... -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
NEXUS_TEST_DATABASE_URL='postgres:///nexus_backend_test?host=/var/run/postgresql&sslmode=disable' go test -race -count=5 ./internal/auth ./internal/store ./internal/httpapi
go vet ./...
go build ./...
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/api
go mod verify
```

Results: all passed, no race reports; gofmt list empty; vet/build successful;
`all modules verified`. Repeated auth/store/HTTP suites passed five times.
PostgreSQL 16 was actually installed and started; integration tests did not skip
in the reported run. Test schema cleanup confirmed zero leftover `test%` schemas.

Ordinary package coverage (`go test -race -cover ./...`):

| Package | Statement coverage |
| --- | ---: |
| cmd/api | 57.5% |
| cmd/migrate | 30.4% |
| internal/auth | 93.8% |
| internal/config | 100.0% |
| internal/core | 100.0% |
| internal/email | 88.9% |
| internal/httpapi | 69.8% |
| internal/store | 66.2% |

Cross-package instrumentation (`-coverpkg=./...`) measured **81.8% total**.
This legitimately records the memory adapter exercised by auth/HTTP tests;
ordinary store-only coverage does not record calls made by other test packages.
The total includes test-double code; it is not a production-only coverage claim.
All functions in `internal/auth/service.go` measured 100% statement coverage in
the combined profile, but **full auth package is not 100%**. Crypto error branches
and many database/network failure branches remain uncovered. No claim of full
branch coverage or all acceptance gates is made. `coverage.out` remains local.

## Cases actually executed

* Required auth shape and 200/202 transitions, required email, normalization,
  uniqueness, invalid input, unknown device/phone, mismatched email/device,
  unverified accounts, expired/used/wrong OTP, resend invalidation, five-attempt
  lockout, failed delivery invalidation, malformed/expired/tampered JWT, logout,
  refresh rotation and immediately previous-token replay revocation.
* Forty simultaneous confirmations on the race-safe memory adapter: one winner.
  Twenty simultaneous confirmations on PostgreSQL: one winner. Twenty concurrent
  refreshes on both memory and PostgreSQL: one winner. Persistent limiter one-slot
  reservation under twenty competing database transactions: one winner.
* Real database register -> device-login 202 -> email-verify -> confirm ->
  replacement-device login 200 through the actual HTTP router, persistent feed
  write, encrypted contact roundtrip, private thread denial, nonmember message
  denial, left-member denial, nested private-group comment/post denial, membership
  rules, shop ownership, immutable-keyset pagination, public discovery, relations,
  cascading account deletion and invalid domain inputs.
* Real SendGrid adapter tested through intercepted HTTP transport for 202, 401,
  429, 500 and transport failure. No live provider request/mailbox delivery tested.
* `openapi.yaml` parsed and validated with kin-openapi; actual auth journey/feed
  request and response payloads validated against it. Extra auth fields rejected.
  This is not exhaustive contract coverage for every endpoint/status.

## Standalone migration and process smoke

In disposable `nexus_backend_migration_test`, using the same unix-socket DSN:

```sh
go run ./cmd/migrate up
go run ./cmd/migrate up
go run ./cmd/migrate down
go run ./cmd/migrate up
```

All exited successfully. SQL verification returned migration version `1` and
eight public tables (seven application tables plus schema_migrations).
Integration tests independently executed migration SQL up/down/up in their
isolated schema. This is not a golang-migrate CLI/testcontainers execution claim.

The statically built `./api` was started against that real database with ephemeral
random keys generated in process memory, development mode, loopback port 18081,
and an unused fake provider key. Verified live `GET /healthz` -> 200, unknown-device
login -> exact 202 action, generated request ID, and graceful SIGTERM exit code 0.
No email endpoint was called during this standalone smoke.

## Limitations and earlier failures

Initial package install was blocked by another process's apt lock, then default
package lists lacked PostgreSQL. A shared installation subsequently supplied
PostgreSQL 16; no claim is made that the first install succeeded. First database
test failed with SQLSTATE 3F000 due to mixed-case schema names in the test harness;
lowercase generated schema names fixed that test issue and later real runs passed.

Production acceptance is outstanding: live email delivery, independent security
review/scanners, SLO/load/soak, frontend generation/parity, UAT, CI/deployment,
backup/restore, monitoring and key rotation. See README for functional/API gaps.
Dockerfile was authored but no container build is claimed. Redis was not needed
or used. No testcontainers/Pact, app-store acceptance or zero-error claim.

## Follow-up hardening and shared Compose coordination

Read root `docker-compose.yml` without changing it. API `:8080` matches Compose.
Added bounded `_FILE` secret support for database URL, JWT/encryption/lookup keys
and SendGrid API key in cmd/api and the database URL in cmd/migrate. Conflicting
direct/file sources fail closed. File-source config tests measure 100% statement
coverage. Redis Compose settings are not consumed by this backend.

Registration now stores an empty device hash, not even a pending installation
binding. Confirmation is the only operation that establishes that binding.
Added regressions proving registration cannot overwrite an existing verified
account's email/device or revoke its sessions. Recovery always checks the stored
email, never changes the destination to the caller's supplied email, and sends
only to that stored address. Initial signup necessarily verifies a pending email
through possession of its emailed capability; it grants no access beforehand.
Phone ownership / new-phone squatting remains explicitly unverified.

Follow-up ordinary race coverage and final cross-package coverage both passed
against real PostgreSQL. Parallel verification initially hit 120-second and
300-second shell deadlines during shared compilation; isolated tests passed,
then this bounded-resource command completed successfully:

```sh
NEXUS_TEST_DATABASE_URL='postgres:///nexus_backend_test?host=/var/run/postgresql&sslmode=disable' GOMAXPROCS=2 go test -p=1 -race -timeout=30s -coverpkg=./... -coverprofile=coverage.out ./...
GOMAXPROCS=2 go vet -p=1 ./...
GOMAXPROCS=2 go build -p=1 ./...
CGO_ENABLED=0 GOMAXPROCS=2 go build -p=1 ./cmd/api
```

The official download JSON was rechecked and still returned Go 1.27.3 and the
same checksum. That JSON does not expose a release timestamp; a release-date
cutoff of 2026-11-09 is therefore not independently proven by this metadata.
No future release date is asserted.

## Readiness and context follow-up

Added `/readyz` wired to real `sql.DB.PingContext`, capped at two seconds; 503 on
dependency failure, separate from `/healthz` process liveness. Tests verify ready
and failed-ready statuses, generated request-ID propagation through context,
matching response header, the ten-second application context, and propagation to
the intercepted SendGrid HTTP request. Full real PostgreSQL race suite, combined
coverage, vet and static build passed again. Re-ran standalone migration down/up;
version query returned 1. No long-running API process is left on port 8080.

## Independent-audit fixes and persistent activity extensions

Fixed confirmed PATCH data loss with pointer-field ProfilePatch and SQL COALESCE:
omitted/null fields remain unchanged; explicit empty strings clear. Real HTTP ->
PostgreSQL regression verifies changing bio preserves name and clearing name
preserves bio. Updated the authoritative contract accordingly.

Added migration version 2 and real ActivityStore adapter for private notifications
and read state, user-to-user follows, public top-level share intent, and private
product carts. HTTP/database regression covers duplicate-follow notification
deduplication, owner-only notification reads, share idempotency, cart quantity/
privacy/deletion, nonproduct rejection, private sharing rejection and self-follow
rejection. All new activity routes use actual persistent interfaces, not static
fixtures. Native PostgreSQL is used; testcontainers not claimed (parent reported
OCI operation not permitted).

Real concurrent refresh test now verifies its security postcondition: exactly one
rotation succeeds, but competing replay intentionally revokes the winner's family;
both winner JWT authentication and winner refresh must fail after all contenders
finish. This behavior requires serialized client refresh and is documented in
API-CONTRACT-NOTES.md for Flutter.

Full race/coverage/vet/build/static build passed after these changes. Standalone
migration runner up/down/up passed and SQL returned versions 1 and 2. Ordinary
HTTP-only instrumentation is now 69.8% because new HTTP activity handlers are
exercised in real store integration tests; combined instrumentation records those
executions. Total is 81.8%, including test doubles. Runtime authorization error and
infrastructure-failure branches are not exhaustive.

## OpenAPI lint audit follow-up

Each of 47 operations now has a unique operationId and summary. Operation-level
aliases use explicit per-route overrides, so IDs are not shared. Documented
applicable validation/auth/access/missing/conflict responses and middleware 429/
500 failures, including profile and discovery. Added a local licensing-status
reference; owner licensing approval remains pending (not silently granted).

Executed pinned validator, with no custom configuration, ignores or disabled rules:

```sh
npm exec --yes --package=@redocly/cli@2.31.1 -- redocly lint openapi.yaml
GOMAXPROCS=2 go test -p=1 -race -timeout=30s ./internal/httpapi
```

Final result: Redocly validated successfully with **0 errors and 0 warnings**;
HTTP contract/race regression passed. An intermediate lint had one license-url
warning, resolved with the local LICENSE reference. Lint success is not G1 or
production acceptance; auth package coverage remains 93.8%, not 100%.
