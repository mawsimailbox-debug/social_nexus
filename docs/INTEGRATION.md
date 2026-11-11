# Cross-agent integration contract — pending runtime confirmation

Scope: root/ci/.github/docs/scripts/qa/design only. Do not edit backend-go or
app-flutter from this ownership lane. Backend go.mod observed: Go1.25.0,
module nexus/backend-go. Build entrypoint `./cmd/api`; runtime TCP :8080.

## Backend handoff

Compose requires PostgreSQL16 (`postgres:5432`), Redis7 (`redis:6379`). Mount
secret files, then ci/api-entrypoint.sh exports the following canonical names:
`NEXUS_DATABASE_URL`, `NEXUS_REDIS_URL`, `NEXUS_JWT_KEY`, `NEXUS_ENCRYPTION_KEY`,
`NEXUS_LOOKUP_KEY`, `NEXUS_SENDGRID_API_KEY`. Read actual cmd/api/main.go:
three independent keys must each encode exactly32 random bytes in standard base64.
Backend uses SendGrid HTTPS, not SMTP. Non-secret config: NEXUS_ENV, NEXUS_ADDR,
NEXUS_EMAIL_FROM (valid verified sender). Local NEXUS_ENV must be `development`;
otherwise database URL must contain sslmode=verify-full. Real email error/delivery
must be tested; no log-only email mode in release. Redis URL currently not consumed
by observed main.go; this is an integration blocker, not proof of shared limits.

Observed `/healthz` is liveness; current `/readyz` is wired to db.PingContext.
Database readiness now exists in source; final runtime verification remains pending.
Redis readiness is not supplied by this DB probe. Secret mounts must be readable by uid 10001 without
making source secret files world readable; Compose implementations vary. Test it.

Redis ACL source must disable default user, create a high-entropy authenticated
API user with least-privilege approved commands/keys, and `user health on nopass
~__health__ +ping` for internal PING-only health checks. No Redis host publication.
Redis internal traffic is local plaintext; production requires encryption/network
controls and confirmation of provider ACL/TLS support. Persistent data and backup
encryption need separate infrastructure controls.

Backend owner supplies: migration runner/up/down safety, deterministic local
seed.sql adapter from qa/fixtures/source-v3.json, integration testcontainers,
explicit auth/recovery coverage inventory, contract validator, refresh rotation,
request_id, 10s timeout, cursor pagination, Redis limits, encryption/deletion.
Never infer these capabilities merely because configuration exists.

## Mobile handoff

Use exact source tokens/content/six screens; fixtures retain whole HTML fragments
and script behavior. Auth is a newly authorized token-based baseline (not missing
source). Actual parity still requires designer + QA signatures/screenshots.
Client timeout 5s, GET-only retry/backoff 2x, propagate request_id, JWT refresh
rotation, secure token storage, TLS certificate pinning and offline/error states.
No SMS OTP dependency. New-device 202 must route to email verification, never home.
Android signing/iOS bundle and signing identities are owner-provided blockers.

## Unresolved agreements (release-blocking)

- Redis integration required by guide remains absent; current shared limits are
  PostgreSQL-backed (not missing shared state). DB readiness is now implemented
  in source; final verification and any Redis requirement exception need approval.
- SendGrid live delivery and three independent base64 key files now adapter-aligned.
- Schema seed adapter and migration execution commands.
- API DTO alignment and real-device addressing/TLS setup.
- Go patched builder/Flutter toolchain/image digest approvals.
- Redis requirement alignment; current PostgreSQL counters already provide shared state.
- Production traffic switch, signing/evidence verifier, report semantic evaluators.

## Concrete current schema/CLI alignment and gaps

- go.mod re-read: go1.25.0; port8080 via NEXUS_ADDR=:8080 matches Compose.
- Root secret adapter now matches exact backend names, not obsolete SMTP vars.
- migrate CLI requires `up|down`, no default action. Image working directory /app
  and copied migrations match its relative path. README explicitly uses `up`.
- OpenAPI register returns202 (verification required), not immediate tokens; mobile
  registration must handle that. Device-login returns200/202 as specified.
- OTP is currently selector.secret, pattern22 base64url characters + dot +43;
  six-digit-only keyboard/validation would be a schema mismatch. Confirm email flow
  allows pasting the full opaque capability. No six-digit OTP assumption in ops.
- email-verify success action is CHECK_EMAIL; device-login202 action is separate.
- Current k6 email timing expects X-Nexus-Processing-Ms; backend support is not
  established, so the test deliberately fails rather than faking SMTP exclusion.
- Seed adapter must match actual backend SQL; no schema-generic production seed.
- Redis7 is configured but current API main does not consume NEXUS_REDIS_URL.
  /healthz remains liveness; /readyz now checks PostgreSQL. Do not conflate them.

## Latest activity/schema reconciliation — implementing, final verification pending

- Migration runner now applies1 then2, and down reverses2 then1. Migration2 adds
  user_follows, notifications, shares and cart_entries. Actual ERD is updated;
  no version1-only/eight-table inventory should be treated as current.
- Source routes now include GET notifications, PATCH notifications/{id}/read,
  PUT/DELETE users/{user_id}/follow, GET users/me/following, POST items/{id}/shares,
  and GET/PUT/DELETE cart (write paths use cart/{id}), all below /api/v1.
  These are present implementations, not proof of final API/mobile acceptance.
- core.ProfilePatch uses *string fields for name/bio; omitted fields can be
  distinguished from explicit empty strings. Mobile PATCH DTO must preserve this.
- API startup now checks sessions and notifications exist; migrations1+2 must run
  before API start. cmd/api wires Activity to PostgreSQL and Ready to db.PingContext.
- Parent reports four action SHAs pinned in mirrored CI and observed-pin docs,
  secret adapter FILE variables unset after export/test, and Compose readiness
  changes. Those parent-owned changes are not edited or reverted by this docs pass.
  Pinning observations do not establish a green CI run or deployment approval.
