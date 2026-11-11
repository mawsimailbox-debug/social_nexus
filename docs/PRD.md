# Product requirements — NEX-PRD-ZIP-001 implementation ledger

Status: scaffold / requirements, not delivery acceptance. Sources: guide v1.0
(2026-11-09), exact supplied v3 HTML; source hashes in BUILD_MANIFEST.txt.

## Scope and priorities

Must: Feed, Chat, Profile, Discover, Shop, Group plus authorized Device ID + email
recovery auth; PostgreSQL16/Redis7/Go API/Flutter; local reproducibility; G1–G8;
security, accessibility, privacy and operations. No SMS OTP. HTML is visual/content
truth; prototype toasts, auto replies, fake QR/call/map behavior are **not** live
capabilities. Real integrations or explicitly unavailable states must replace them.
Should: feedback, analytics and observability with consent and PII minimization.
Could: future additions through versioned API/RFC, not silent scope invention.

## Acceptance by epic

| Epic | Required acceptance |
|---|---|
| Auth | register phone/device/email mandatory; duplicate email rejected; matched device 200 JWT/refresh; mismatch/unknown 202 REQUIRE_EMAIL_VERIFICATION; real email OTP, wrong/expired/used rejected; atomic device rebinding; rotate refresh; no SMS |
| Feed | six prototype post types/content; ranking score and nearby/friend ordering; reaction/save counts; share/comments/repost attribution; composer types/moods/minimum trim/200 char; persistence and access control |
| Chat | initial source messages, send/receive, delivery/read/typing state; no canned automatic reply presented as real user |
| Profile | source identity, stats, business link, videos/liked/saved grid and edit/share behavior |
| Discover | groups/people/places/business tabs, text search and business filters; join/follow state persists |
| Shop | source contact/hours/products/prices/reviews/gallery/call/directions/message/save; source values are prototype test data only |
| Group | source cover/meta/members/rules/recent activity; join/leave persisted and private-group authorization |
| Platform | request_id per request, client5s/server10s, GET-only 2x backoff, cursors, shared Redis device limits, encrypted PII, deletion, safe migration/backups |

## Nonfunctional / release targets

G1 build/lint/test all green on tag SHA; G2 README-only fresh-machine start ≤30m;
G3 real auth chains; G4 six screens + separate new-auth baseline signatures;
G5 Go≥70% statement coverage, auth/recovery100% paths, no coverage drop and E2E;
G6 complete verified deploy/store/CI config; G7 zero red SAST/DAST and no secrets;
G8 docs and backend OpenAPI. Performance: device-login p95≤150ms,
email-verify≤400ms excluding SMTP, feed≤300ms at1000 RPS; cold-start≤2s;
12h soak at60% of peak; p95 regression≤20%; crash-free beta≥99.5%.

## Delivery process

Two-week sprints; planning, 15m daily, device demo review, retro≤3 actions;
board Backlog→Ready→In Progress→In Review→QA→Done, WIP3 per2 developers.
Ready requires acceptance/design anchor/API contract. Done requires tests, review,
device demo and docs. Prior source All-in-One C-01/C-19 and F-08 not supplied:
their text is NOT reconstructed; current traceability provides a substitute plan,
not a claim those documents were recovered.

## Open decisions

Legal owner/license, actual team identities, provider/region/domain/store IDs,
policy URLs, retention/legal deletion policy, external services and exact SMTP
timing instrumentation remain REQUIRED. Guide UAT wording conflicts between
High/Med=0 and Medium≤5 with workaround: use stricter Medium=0 unless PM explicitly
approves a signed exception with risk/workarounds. No fabricated waiver.
