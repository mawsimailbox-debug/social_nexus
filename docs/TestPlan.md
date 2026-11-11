# Test plan and evidence map

All outcomes initially NOT RUN/BLOCKED. Evidence must include tool/version,
environment, commit, command, times, raw reports and trusted signatures.

| Suite | Tests / exit requirements | Evidence |
|---|---|---|
| Go unit | `go test ./... -race -cover`; device match/mismatch/unknown202; OTP wrong/expired/used; atomic device update; unique email; limits; JWT expiry/rotation; email format | coverage-backend, coverage-auth, go-tests |
| Flutter | login200 home; login202 email; signup validation; logic/widgets; source fixture content | flutter-tests |
| Integration | real router+httptest+PG/Redis testcontainers; register→login→email verify→confirm→new device200; OTP provider delivery; concurrency | integration-testcontainers, auth-real-email-e2e |
| DB/contract | up/down/up in disposable DB, no live rollback; OpenAPI validator/Pact mobile DTO errors/cursors | migration-up-down, contract-validation |
| Coverage | backend≥70%, auth/recovery100% **paths**, no coverage drop vs trusted baseline | coverage files + branch/path matrix + regression |
| Parity | all six screens, source interactions and new auth baseline; capture devices/viewports; exact tokens/content; loading/error/accessibility | parity-six-screens, parity-auth-baseline, QA+design |
| UAT | PM+QA+5–10 beta users; all source interactions +2 auth flows; raw scenarios/issues/workarounds | uat-report, actual UAT-SIGNOFF.pdf |
| Performance | login≤150ms; email verify≤400ms excluding SMTP; feed≤300ms@1000RPS; cold start≤2s mid-device; DB pgbench/EXPLAIN | k6-load, cold-start, db-explain |
| Soak/regression |12h@600RPS (=60%1000 peak), no leak measured via RSS/heap/DB/Redis; p95≤20% regression | k6-soak-12h, perf-regression + telemetry |
| Security | gosec/staticcheck/Semgrep/Dart lint, gitleaks, govulncheck/dependency review, ZAP baseline+authorized auth scan, OWASP10 | raw scans, SBOM API/mobile, zero red/critical |
| Release ops | README-only clean host≤30m; seed; signed tag verification; backup isolated restore; staging/canary rollback; store/beta | signed operational reports |

Use stricter UAT exit High=0, Medium=0 because source has contradictory Medium
wording. Relaxing to Medium≤5 needs a signed PM/QA risk decision, no silent waiver.
C-19 document was not supplied; `qa/UAT-SCENARIOS.md` is a new traceable plan,
not a claim to reproduce C-19. A fake placeholder PDF is never generated.

Load test safety: explicit authorized disposable staging environment; no production
traffic by default; test accounts only; no secrets in summary export. At1000RPS
verify generator dropped iterations=0 and achieved throughput before claiming pass.
SMTP timing requires server span/metric, not subtracting an invented duration.
Run baseline versus candidate on equivalent infra/data and archive raw samples.

Security criteria: fail on scanner errors as well as findings; missing tool/report
is BLOCKED, never green. A small local Semgrep ruleset is supplementary, not an
OWASP assessment or comprehensive Dart security review. Syft source inventories
must be reconciled with actual APK/AAB/IPA/container dependency manifests.
