# New UAT plan — not supplied C-19, no outcomes recorded

For every row record commit/device/OS, steps, expected/actual, evidence URL/hash,
tester, UTC, bug severity and retest. PM+QA and 5–10 real beta users required.

| ID | Journey / expected |
|---|---|
| U01 | Register valid/invalid/duplicate email; phone/device mandatory; no SMS |
| U02 | Known device200→home; unknown/mismatch202→email; no false home transition |
| U03 | Real mailbox delivery; resend60s; wrong/expired/used OTP; atomic new-device login; refresh rotation/replay |
| U04 | All six navigation chips/tabbars/back paths; no orphan modal |
| U05 | For You score ordering; Nearby friend-first+distance; source nuance2.4km follower retained; correct reason labels |
| U06 | All six source posts and counts; react toggle/save persistence; hug once |
| U07 | Comments open/close, existing seed text, send/reply/like; author notification |
| U08 | Share link/copy/fallback/external destinations/QR/save; real action not toast-only |
| U09 | Repost attribution kept; own words; no silent original content mutation |
| U10 | Composer types, moods, trim minimum3/max200 counter, location change, submit/close/keyboard |
| U11 | Notifications panel/read/all-read and every action route; unread badge state |
| U12 | Chat initial text/send/Enter/read/typing; reject mock canned response as real |
| U13 | Profile stats/bio/grid Videos/Liked/Saved; edit/share/business navigation |
| U14 | Discover all4 tabs/text filter/business type; no results; join/follow labels and state |
| U15 | Shop contact/hours/products/exact prototype prices/gallery/reviews; call/directions/message/save/add behavior |
| U16 | Group rules/activity/members/public-private enforcement/join/leave |
| U17 | Loading/error/timeout/offline/permission denied/deletion/session expiration/refresh; accessibility and keyboard |
| U18 | Real-device source screenshots and auth baseline; token/spacing/content parity; QA+design |
| U19 | Fresh host README-only local run≤30m; APK/AAB/IPA install, launch/cold start |

All outcomes: NOT RUN. Source prototype issues are preserved for design review,
not silently repaired: later nearby handler includes followers outside2km, two
handlers exist; some actions only toast; profile grids are script-generated.
Full qa/fixtures/source-v3.json retains script and static screen content for review.
