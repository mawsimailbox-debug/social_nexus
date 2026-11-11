# Actual local verification — 2026-11-09

## Passed

- Official stable metadata selected Flutter 3.47.9 (2026-10-29), Dart 3.13.7. Download SHA-256 matched `25ed8c3c29d51a7353f2a944310b478af8214920639524b19c50a19e6c044c5a`.
- `flutter create --no-pub --platforms=android,ios --org app.nexus --project-name nexus .`: exit 0.
- `flutter pub get`: exit 0. Lockfile retained. Freezed 4.0.3 resolves Dart 3.13 generation compatibility; annotation 3.1.0 is the published compatible annotation.
- `dart run build_runner build`: exit 0; three generated outputs.
- Heap-bounded Flutter CLI `analyze`: exit 0, `No issues found! (ran in 64.1s)`.
- Heap-bounded Flutter CLI `test --concurrency=1 --coverage --reporter=expanded`: exit 0; 15 tests passed in 36 seconds.
- `dart format --output=none --set-exit-if-changed lib test`: exit 0; 35 files, zero changes.
- `python tool/build_contract.py`: exit 0; 24 paths, 28 operations. Internal references checked, not a full third-party OpenAPI conformance validation.
- `python tool/verify_integrity.py`: exit 0; original HTML/DOCX and photo hashes match, all 18 screen/widget files <=200 lines (largest 193).
- LCOV: 834/1268 reported executable lines hit = 65.77%. This is not an auth-100% or >=70% production gate pass.

## Failed / unavailable checks, retained honestly

- Initial metadata URL returned HTTP 404; official alternate metadata URL succeeded.
- Initial Freezed 3.2.5 generated invalid final parameters for this Dart version. Updating generator to 4.0.3 corrected generation. Attempting annotation 4.0.0 failed dependency resolution; retained 3.1.0.
- Initial analysis exposed one const-for compile error and six brace lints; corrected. A subsequent test-file brace lint was corrected.
- Core regression test caught composer using stale derived enable state; controller now validates its current draft directly. Full suite passed after that correction.
- Analyzer once exited -9 under shared memory pressure. Earlier full test invocations timed out during compilation; they are not passes. Reducing Dart heap to 512 MB and serial testing produced the passing results above.
- Final format/integrity/analyze chained rerun passed format and integrity but timed out at 180 seconds before analyzer completion. Earlier analysis pass remains valid evidence, not a fresh final-run pass. Only source change since that successful analysis was the composer guard correction (compiled and covered by the subsequently passing full tests), followed by formatting and verification documentation/scripts.
- `flutter build apk --debug --dart-define=NEXUS_MOCK=true`: failed, no Android SDK. No APK exists. Android SDK was not downloaded.
- No iOS compile/signing/device tests: Linux environment lacks Xcode.

## Not claimed

No pixel parity, design QA, Team Lead signoff, production readiness, live Go integration, server OTP/security correctness, store readiness, pinning, native-device plugin validation, 100% auth coverage or complete interaction parity. See README gaps and SECURITY-HANDOFF. Widgets contain presentation event dispatch; most state mutations and validation are controllers, but further cleanup is needed to move remaining share/platform orchestration and category-action decisions fully out of widgets.

All authored project outputs remain inside app-flutter; optional Flutter installation is inside toolchains/flutter. No other agent directory was modified. No ZIP, publication, commit, tag or push.
