# Nexus — operations and release scaffold

**INCOMPLETE IMPLEMENTATION; NOT a production-ready release.** G1–G8 and all human approvals are BLOCKED until
verified on the release commit. This scaffold does not claim a signed tag, CI run,
deployment, UI parity, UAT, performance, security clearance or store acceptance.
No ZIP has been generated. The Go and Flutter modules are owned by separate agents.

## Source of truth

- `design/Social Suite v3 — Business & Community.html`: unchanged source HTML.
- MD5: `a8fafd493261eda3876d79039c564e10`; MD5 is reference identity only, not a signature.
- `design/tokens.css`: exact first `:root{...}` bytes, including embedded `--photo`.
- Guide: NEX-PRD-ZIP-001, 1.0, 2026-11-09; extraction ledger: `docs/SOURCE_GUIDE.md`.
- `backend-go/openapi.yaml`: API contract, maintained by backend owner.
- Auth screens are an explicitly authorized **new baseline**, not present in HTML.
  See `design/AUTH-BASELINE.md`; their QA/design signatures remain blank.

## Repository

`backend-go/` Go API and migrations; `app-flutter/` mobile app; `design/` immutable
reference/extractions; `ci/` build adapters; `.github/workflows/` active workflows;
`scripts/` safe operations; `qa/` source fixtures/load/security recipes; `docs/` plans,
architecture, runbook, metadata and unsigned release evidence requirements.

## Local start (target: ≤30 minutes on a provisioned developer machine)

Prerequisites: Docker Engine + Compose v2, Git, Python 3 + PyYAML, Go matching
`backend-go/go.mod`, Flutter SDK matching the mobile module. Signed iOS builds need
macOS/Xcode and real developer credentials. Internet and registry access required.
**The 30-minute target has not been measured.**

1. Review `docs/INTEGRATION.md`. Obtain required values from a secret manager. Use
   `.env.example` only for non-secret configuration; empty values must be completed.
   Create secret files outside the repository with mode 0600. Do not commit `.env`.
2. Export required `NEXUS_*` variables to your shell, including absolute secret-file
   paths. PostgreSQL and Redis ports are not exposed. API binds loopback by default.
3. `docker compose config --quiet`, `docker compose build api`, then
   `docker compose up -d --wait postgres redis`. API requires migrations first.
4. Apply backend migrations using its documented runner (the image includes
   `/app/migrate`; reviewed initial apply command:
   `docker compose run --rm --no-deps api /app/migrate up`).
   Then `docker compose up -d --wait api`. The opt-in partial fixture is
   `backend-go/seed.sql`. First obtain an existing VERIFIED local demo account ID
   through the real registration/email-verification flow; seed creates no account
   or credentials. With `NEXUS_ENV=development` (or `test`) exported, run:
   `NEXUS_SEED_SQL=backend-go/seed.sql NEXUS_SEED_OWNER_ID="$VERIFIED_DEMO_OWNER_ID" NEXUS_ALLOW_SEED=local-test bash scripts/seed.sh`.
   Set `VERIFIED_DEMO_OWNER_ID` to that actual account ID, never an invented value.
   SQL owns BEGIN/COMMIT; do not add an outer single-transaction wrapper.
   This seeds only partial demonstration content, not all source fixtures/parity.
   Re-running inserts duplicates; use a disposable local/test database, never production.
5. `NEXUS_HEALTH_URL=http://127.0.0.1:8080/healthz bash scripts/healthcheck.sh`.
   Observed backend `/healthz` is liveness only; DB/Redis readiness is still missing.
6. Follow mobile README for `flutter pub get`, `flutter run`, API base URL and
   platform setup. A physical device cannot use host loopback; use an approved
   development tunnel and environment-specific TLS configuration.
7. Current registration returns202 and grants no session. Run register → real
   email verification → confirm the full emailed opaque capability with device_id
   → device-login200. Then change device → device-login202 → email-verify202
   CHECK_EMAIL → confirm → changed-device200. Do not use a six-digit-only OTP
   assumption or expect login200 before email ownership is verified. Use test
   accounts and a real approved mailbox; never use production PII.
8. Stop with `docker compose down` (preserves data). Never add `-v` casually.

## Checks

```sh
python3 scripts/validate-ops.py
bash ci/check-go.sh
bash ci/check-flutter.sh
bash ci/security.sh
python3 scripts/release-gate.py --evidence /absolute/path/to/evidence
```

The last command is a configurable evidence gate, not a packager. It can pass only
with commit/tag-bound signed reports, trusted reviewers and a pinned external
semantic validator's signed matching verdict. Missing setup/evidence blocks
naturally; no unconditional failure or green-boolean bypass remains.
`scripts/release.sh` invokes the gate and never creates/publishes a ZIP.
`docs/RELEASE-GATES.md` explains pre/post-package gates and circularity handling.
Packaging/publication remains separate unimplemented work, not a completed feature.
Installed tools have been rechecked. Parent reports Docker daemon startup but
container execution fails with exit126 / `operation not permitted` in this sandbox;
no Docker build or Compose E2E success is claimed. Parent's Compose configuration
validation returned exit0 using transient dummy non-secret values; this does not
test startup or real credentials. Parent's initial gitleaks scan reported one
documentation false positive; prose was rephrased without global suppression.
The final rescan remains pending, not security clearance. See `docs/VALIDATION.md`.
`docs/BUILD_MANIFEST.txt` is an earlier scoped snapshot, NOT the final
multi-agent manifest; regenerate only after all agents and parent evidence settle.

## Ownership, review and deployment

Real owner identities and signing trust must be supplied by the project owner.
`.github/CODEOWNERS.required` is intentionally not an active CODEOWNERS file with
invented handles. Configure branch protections externally: main no force push or
deletion, required checks, two reviewers (three for auth/security), signed tags,
push protection. Use squash merge and Conventional Commits, ≤72-character subjects,
≤400-line PRs, feature branches ≤3 days; reviewers respond within 24 hours.

Production requires the manual infra checklist, trusted CI tool/image pins, TLS,
secret manager, tested backup/restore, monitoring, staged canary and actual approval.
See `docs/Runbook.md`, `docs/TestPlan.md` and `docs/BUILD_MANIFEST.txt` for gaps.
