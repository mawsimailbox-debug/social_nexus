# Nexus Go backend — production candidate, not production acceptance

Sources read: `../nexus-guide.docx` (provided outside this directory) and
`../social-suite-v3.html` (read-only design reference). No source HTML was changed.
`openapi.yaml` is the **single API contract**; no competing spec is generated.

## Run

Go >=1.25, PostgreSQL >=16. Shared sandbox Go installation:
`/home/user/workspace/toolchains/go/bin/go` (official Go 1.27.3, SHA256 checked).

Supply environment variables through a secret manager; no real secrets belong
in source control. All three keys must be distinct base64-encoded 32 random bytes:

* `NEXUS_JWT_KEY` — HS256 signing key
* `NEXUS_ENCRYPTION_KEY` — AES-256-GCM encryption for phone/email
* `NEXUS_LOOKUP_KEY` — HMAC-SHA256 lookup indexes and installation credentials
* `NEXUS_DATABASE_URL` — PostgreSQL DSN, production `sslmode=verify-full`
* `NEXUS_SENDGRID_API_KEY`, `NEXUS_EMAIL_FROM` — real SendGrid credentials and verified sender
* `NEXUS_ADDR` — optional, defaults to `:8080`
* `NEXUS_ENV=development` — explicitly permits a non-TLS local database only

Database URL, signing/encryption/lookup keys, and SendGrid API key also accept
`NEXUS_<NAME>_FILE` paths for Docker Compose secrets. Direct and file values
cannot both be set. Secret files are capped at 8 KiB and never logged. The root
Compose API port `8080` matches the backend default. Redis settings are unused.

From this directory:

```sh
go run ./cmd/migrate up
go run ./cmd/api
go test -race -cover ./...
NEXUS_TEST_DATABASE_URL='postgres://.../disposable_db?sslmode=disable' go test -race -cover ./...
go vet ./...
go build ./...
```

Integration tests create and delete an isolated random schema. They skip explicitly
without `NEXUS_TEST_DATABASE_URL`. Migration `down` destroys application data:
`go run ./cmd/migrate down`. The runner serializes migrations with an advisory lock
and tracks version 1 transactionally. Files also follow golang-migrate naming.
Never run down on production without an approved recovery plan. The runner now
applies versions 1 and 2 and reverses ALL applied versions on down; it is not a
single-step rollback command. Version 2 persists notifications, people follows,
shares and private carts. See `API-CONTRACT-NOTES.md` for client coordination.

## Authentication decisions

* Registration reserves an unverified email but binds **no device** and grants
  **no session** until email ownership is
  verified. This prevents an attacker registering a victim's phone and using an
  unverified device immediately. Phone ownership is not verified; SMS is absent.
* Required device login returns exactly `200 {jwt,refresh}` or
  `202 {action:"REQUIRE_EMAIL_VERIFICATION"}` for valid input. A device credential
  is a secret installation token, not a public hardware identifier. Client apps
  must generate >=128 random bits and keep it in OS secure storage. This contract
  cannot safely authenticate public/predictable device IDs; attestation/passkeys
  require a future API design. Phone/email matching is not phone ownership proof.
* `email-verify` has a PostgreSQL-backed 60-second reservation per phone, a global
  per-peer rate limit and per-phone/per-device limits. Unknown phones and mismatched
  emails receive uniform 202 and consume the same cooldown. Timing may still reveal
  provider latency; use edge anti-abuse and monitoring. Reservation persists on
  provider failure. No secret code, PII, token, or request body is logged.
* The fixed `{otp,device_id}` contract has no challenge identifier. `otp` therefore
  contains `base64url(16 random bytes).base64url(32 random bytes)` and is emailed in
  full. The selector and full capability are SHA256-hashed in storage. This is a
  cryptographically bound bearer capability, **not** a six-digit OTP. Five wrong
  secrets for a known selector lock it; ten-minute expiry; resend invalidates all
  older challenges. Unknown selectors cannot mutate another challenge. No SMS.
* Confirmation locks the user first, then the challenge: consume all challenges,
  verify email, replace device, revoke all sessions and create the new session in
  one transaction. Concurrent confirmations yield at most one successful grant.
* Fixed HS256 only; authenticated signature, issuer, audience, subject, session,
  issued-at and expiry checks. Access lasts 15 minutes. Every protected request
  checks its persistent session, so logout/recovery/deletion take immediate effect.
* Refresh is `session-id.random-secret`, stored as a digest. Rotation is atomic,
  absolute expiry 30 days. Reuse of the immediately previous token revokes the
  session; all older tokens remain invalid but only one prior digest is retained.
  Clients must serialize refresh and must not automatically retry auth POSTs.
* AES-GCM phone/email ciphertext uses fresh random nonces and authenticated version
  context. Separate keyed lookup indexes enforce normalized email/phone uniqueness.
  Key rotation/backfill and secret-manager provisioning remain deployment work.

## Persistent social scope

Feed posts/comments, chat threads/messages, own profile, group metadata/posts/
memberships, shops/products, discovery (groups/people/business/places), idempotent
like/save/follow relations and account deletion are implemented. All list routes
use descending immutable ID keysets, capped at 100, with `next_cursor`.
Private parent/grandparent visibility is inherited by messages, posts and comments.
Thread creation fixes visibility private; participants are explicit existing user
IDs. Messages require current membership. Group writes require membership; public
groups can be joined idempotently; private groups cannot self-admit. Group member
lists require membership. Shop product writes require ownership. Membership writes
and parent-content creation share row locks. Public discovery exposes no contacts.
Author/parent/kind are server-derived, never trusted from JSON input.

Test doubles implement the same `core.AuthStore`, `core.EmailSender`, and
`core.SocialStore` interfaces as real adapters. Production cmd/api never selects an
in-memory store or a fake email sender. PostgreSQL handles shared limits; Redis is
not required for correctness. SQL values use placeholders; dynamic SQL fragments
are constants. JSON is size-limited and rejects unknown properties and trailing
documents. Responses contain plain text, not trusted HTML. TLS terminates at a
trusted ingress; do not expose this plaintext listener publicly without it.

## Operational / acceptance gaps — explicit

This is a substantial backend candidate, **not** an assertion of production-ready,
zero-error, G1–G8 completion, 100% auth coverage, or source-design parity acceptance.

* No real email was sent without supplied credentials; adapter tests intercept
  HTTP transport. SendGrid sender setup, deliverability, bounce webhooks and real
  end-to-end mailbox acceptance remain required. No SES adapter (SendGrid chosen).
* No media uploads/transcoding, nearby geospatial ranking, personalized feed scoring,
  realtime WebSocket/push, message read receipts, voice/video calls, product ordering,
  reviews, reporting/moderation or private
  group invitation workflow. HTML mock counts/distances are not fabricated as real.
* Seed fixture is explicit opt-in demo data, not automatically loaded by API.
* Registration has no proof of phone ownership and can reserve unverified identities.
  Expiring unverified registrations and anti-squatting policy need product decisions.
* Persistent limiter counters/expired challenges/sessions need scheduled retention;
  sample maintenance SQL is included. Trusted edge distributed abuse defenses and
  CAPTCHA/attestation remain deployment work. IP peer limiting ignores forwarded
  headers intentionally; configure your ingress rather than trusting attacker input.
* Social content is plain text with a generic item DTO; no rich media/content-type
  parity claim. Contacts/hours/rules/review DTOs and detailed HTML semantic mappings
  require further contract extension and generated client acceptance.
  Persistent people following, follow/share notifications with read state, public
  share intent and per-user product carts are implemented. Cart is not checkout;
  share intent is not a claim of off-platform delivery. Profile PATCH preserves
  omitted/null fields and permits explicit empty-string clearing.
* Rate-limit responses use conservative 60-second Retry-After; limits can reset
  earlier. Provider latency may distinguish actual sends. Email sending is synchronous
  and bounded to 5 seconds; durable encrypted outbox/retry/DLQ is not implemented.
* JWT key rotation with overlapping keys, full refresh reuse-history storage,
  per-request audit trails, metrics/tracing exporters, policy-based CORS,
  backup/restore drills, deployment infrastructure and CI gates remain.
  `GET /healthz` is process liveness; `GET /readyz` checks PostgreSQL with a
  two-second deadline and returns 503 if unavailable. Application request context
  is capped at ten seconds; request IDs propagate through context to email HTTP.
* No performance/SLO/load/soak tests, external penetration review, SAST/DAST acceptance,
  UAT, app-store signoff or production deployment is claimed.
* Test coverage must be measured, not inferred. Read `VERIFICATION.md` for actual
  executed commands, results and skipped checks. cmd/api and cmd/migrate startup
  branches are not comprehensively unit-tested.
