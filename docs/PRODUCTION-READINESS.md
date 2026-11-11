# Nexus — 0.1.0-rc1 ထုတ်လုပ်မှု အခြေအနေ / Production Readiness

ဖိုင်: `docs/PRODUCTION-READINESS.md` · ရက်စွဲ (UTC): 2026-11-10 · Commit: v0.1.0-rc1 (unsigned local tag)

## အတိုချုပ်

ဤ repo သည် **release candidate** အဆင့်သို့ ရောက်ရှိပါပြီ — ကုဒ်၊ test၊ coverage၊ secret scan၊ SBOM နှင့် manifest အားလုံး ဤစက်ပေါ်တွင် လက်တွေ့ run ပြီး အောင်‍မြင်ထားပါသည်။
သို့သော် **production release** ဟု မကြေညာနိုင်ပါ — အောက်ပါ ပြင်ပလိုအပ်ချက်များ (CI runner, real device, signing certificate, လူ့လက်မှတ်) များကို sandbox အတွင်း ဖြည့်စွက်၍ မရပါ။

## ဤစက်ပေါ်တွင် လက်တွေ့ အောင်‍မြင်ပြီးသော အချက်များ (verified)

| # | စစ်ဆေးမှု | ရလဒ် |
|---|---|---|
| 1 | `scripts/validate-ops.py` (YAML/ဆောင်/negative tests) | PASS |
| 2 | `go vet ./...` (package ၈ ခု) | PASS |
| 3 | `go build ./...` + `CGO_ENABLED=0` linux/amd64 binary | PASS |
| 4 | `go test -race ./...` (PostgreSQL 16 integration အပါ) | PASS — 8/8 packages |
| 5 | Backend statement coverage | 82.6% (gate: ≥70%) — PASS |
| 6 | Auth/OTP statement coverage | 100% (gate: 100%) — PASS |
| 7 | `flutter analyze --fatal-infos` | PASS — 0 issues |
| 8 | `dart format --set-exit-if-changed lib test` | PASS — 0 changed |
| 9 | `flutter test --coverage` | PASS — 25/25 tests |
| 10 | Flutter line coverage | 69.83% (1,097/1,571 lines) |
| 11 | `redocly lint backend-go/openapi.yaml` | PASS |
| 12 | `gitleaks dir .` (secret scan) | PASS — 0 findings |
| 13 | Design HTML MD5 parity (source ↔ repo) | PASS — `a8fafd493261eda3876d79039c564e10` |
| 14 | `docker compose config` (17 env vars, dummy secrets) | PASS — ဖွဲ့စည်းမှု မှန်ကန် |
| 15 | CycloneDX SBOM (Go 34 + Dart 118 components) | ထုတ်ပြီး — `docs/sbom/` |
| 16 | BUILD_MANIFEST + SHA256SUMS (ဖိုင်အားလုံး) | ထုတ်ပြီး |

## ဤ session တွင် ပြင်ဆင်ပြီးသော ချို့ယွင်းချက်များ (fixed this session)

1. **Flutter test ကျရှုံးမှု** — `test/recovery_widget_test.dart` တွင် ကျန်နေသော periodic timer ကို drain လုပ်ပြီး 25/25 pass ဖြစ်စေခဲ့သည်။
2. **Analyzer ၅ ခု** — `curly_braces_in_flow_control_structures` (2 ဖိုင်) ကို `dart fix` ဖြင့် ပြင်ပြီး `--fatal-infos` အောင်‍မြင်စေခဲ့သည်။
3. **Format drift** — ဖိုင် ၇ ခုကို `dart format` ဖြင့် ညှိပြီး format gate အောင်‍မြင်စေခဲ့သည်။
4. **Coverage gate ချို့ယွင်းချက်** — `ci/check-coverage.py` သည် `-coverpkg` profile ၏ ထပ်နေသော block များကို နှစ်ခါရေတွက်နေသဖြင့် 14.99% ဟု မှားယွင်းပြခဲ့သည်။ location အလိုက် dedupe လုပ်ပြီး အမှန် 82.55% ဖြစ်စေခဲ့သည်။
5. **Auth coverage 93.8%** — `internal/auth` (crypto/Verify) နှင့် `httpapi/auth-input.go` အတွက် error-path test ၆ ခု ထပ်ထည့်ပြီး 100% ဖြစ်စေခဲ့သည်။
6. **Testability refactor** — `crypto/rand.Read` ကို `entropy` var အဖြစ် ထုတ်ပြီး entropy ကျရှုံးမှု path ကို စမ်းနိုင်စေခဲ့သည် (အပြုအမူ မပြောင်း)။
7. **`go tool cover -func` path ချို့ယွင်းချက်** — module အတွင်းမှ run ရန် CI script အစီအစဉ် ပြင်ခဲ့သည်။

## ဖြည့်စွက်၍ မရသေးသော ပြင်ပလိုအပ်ချက်များ (BLOCKED — လက်မှတ်မထိုးရသေး)

| DoD | လိုအပ်ချက် | အခြေအနေ |
|---|---|---|
| G1 | Signed tag ပေါ်တွင် CI job အားလုံး အစိမ်း | BLOCKED — GitHub Actions runner မရှိ၊ tag သည် local နှင့် unsigned |
| G2 | စက်အသစ်တွင် README-only extract → ≤30 မိနစ် | BLOCKED — container init ကို sandbox က ပိတ်ထား (`exit 126`) |
| G3 | Real device 200/202 + Gmail recovery E2E | BLOCKED — စက်နှင့် Gmail အကောင့် မရှိ |
| G4 | Screen ၆ ခု parity + QA/Design လက်မှတ် | BLOCKED — လူ့လက်မှတ် လိုအပ် |
| G5 | Coverage/performance gate + ZAP | BLOCKED — coverage ✅၊ ZAP နှင့် load မရှိ |
| G6 | CI/CD + Compose + store metadata bundle | BLOCKED — compose config ✅၊ actual run မရှိ |
| G7 | SBOM + critical vuln 0 | BLOCKED — SBOM ✅၊ `govulncheck`/audit run မရှိ |
| G8 | Docs bundle | PASS (README/OpenAPI/ERD/Runbook/CHANGELOG/LICENSE ရှိ) |
| 9 | ZIP အတွင်း HTML MD5 = reference | PASS — MD5 တူသည် |
| 10 | BUILD_MANIFEST + GitHub Release | BLOCKED — publish မရှိ |
| 11 | သီးခြား Team Lead လက်မှတ် | BLOCKED — လူ့ဆုံးဖြတ်ချက် |

## ဤ ZIP ဖြင့် ဘာလုပ်နိုင်သည် / မလုပ်နိုင်သည်

- ✅ Developer ထံ ကုဒ်လွှဲပြောင်း၊ code review၊ CI သို့ push၊ staging deploy စမ်းသပ်
- ✅ `docker compose --env-file <real.env> up` ဖြင့် ကိုယ်ပိုင်စက်တွင် run
- ❌ Production traffic အတွက် release အဖြစ် မကြေညာနိုင်
- ❌ Store (Play/App Store) တင်ရန် signed AAB/IPA မပါ
- ❌ လက်မှတ် (QA/Design/Team Lead) မပါ

## လည်ပတ်ရန် အရေးကြီး command များ

```sh
# backend
cd backend-go && go test -race ./... && go build ./cmd/api
# flutter
cd app-flutter && flutter pub get && flutter analyze --fatal-infos && flutter test
# compose (real secrets ဖြင့်)
cp .env.example .env   # တန်ဖိုးများ ဖြည့်ပါ
docker compose --env-file .env up -d
```
