# Nexus native Flutter client — audited revision

Native widgets, Riverpod controllers, Freezed immutable models, data/domain/presentation layers. No WebView. HTML and DOCX inputs remain read-only. `tool/extract_sources.py` extracts the original photo/content and records hashes.

## Run / verify

Flutter 3.47.9 / Dart 3.13.7. Real mode is the default and requires an HTTPS URL. Demo is explicit, never a fallback.

```sh
flutter pub get
dart run build_runner build
flutter run --dart-define=NEXUS_MOCK=true
flutter run --dart-define=NEXUS_API_URL=https://YOUR_API_HOST
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --concurrency=1 --coverage
```

For this 4 GB shared sandbox, invoke the Flutter tool snapshot using Dart `--old_gen_heap_size=512` if the regular launcher exhausts memory. Android/iOS scaffold exists; Android SDK and Xcode are unavailable here.

## Exact Go contract

`docs/openapi.yaml` is a read-only snapshot of `backend-go/openapi.yaml`, not a competing frontend proposal. Refresh with `python tool/build_contract.py`. See `docs/BACKEND-COORDINATION.md` for source reconciliation and Go-owner follow-ups.

- email-verify sends `{phone_number,email}` and expects 202 CHECK_EMAIL, no challenge.
- OTP confirm sends `{otp,device_id}`. Paste the complete 66-character selector.secret email capability; no six-digit restriction. Demo-only capability is 22 `a` characters, dot, 43 `b` characters (`MockRepository.demoOtp`).
- Refresh sends `{refresh}` only; single-flight rotation, GET-only replay/retries, 5-second timeout. Errors preserve backend `error` and `request_id`.
- Explicit Go DTO mapping converts numeric item IDs, names/author IDs, person public user IDs and message direction. Root shops/groups and separate products endpoint; Discover refetches type/q. Relations/join/actions match current Go handlers.
- Logout/account login invalidates Nexus state, ignores stale completions and invalidates token responses; secure session writes/deletion are serialized. Logical cancellation does not abort bytes already sent to the server.
- Current Go source includes notification/share/cart activity endpoints and presence-aware profile patch. Their live deployment is NOT verified; failures surface instead of pretending demo success.

## Honest release blockers

Certificate/public-key pinning NOT implemented; HTTPS OS trust only. Live Go/database/email E2E and native-device secure-storage/share plugins unverified. Parent reported OCI runtime permission failure, not successful compose runtime.

Baseline parity NOT approved. Go generic Item lacks many baseline fields: post type/mood/location/media/repost attribution, author display names, counts and relation/membership state, shop contact/hours/reviews, group rules and profile media. Unsupported real media/repost publishing is explicitly blocked. Profile demo grid is not shown as real backend data; its baseline scale parameters are used. Some static prototype chrome (e.g. status/read-receipt/member displays) still requires full real-data treatment. Pagination consumes first page only. Remaining presentation-side orchestration should move fully to controllers. No production-ready, visual-parity, coverage-gate or Team Lead approval claim.

Tests include source-serialized Go DTO fixtures, not live HTTP captures. Provenance is in `docs/go-shapes-provenance.json`. Latest actual results are in `docs/VERIFICATION.md`. No ZIP/publication/commit/tag/push.
