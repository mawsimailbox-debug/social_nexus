# UAT Report — 0.1.0-rc1

Status: **AUTOMATED COVERAGE PASSING / HUMAN SIGN-OFF BLANK**

Automated journeys executed locally (2026-11-10):

| Scenario | Source | Result |
|---|---|---|
| Device login, known device → home (200) | integration_test/auth_flow_test.dart | PASS |
| New device → email → OTP → home (202 recovery) | integration_test/auth_flow_test.dart | PASS |
| Invalid/expired/used capability reason unified | test/recovery_widget_test.dart | PASS |
| Six screens render + signup validation | test/screens_test.dart | PASS |
| Cursor pagination, refresh rotation, timeouts | test/http_test.dart | PASS |
| OpenAPI contract conformance (mock server) | test/real_contract_test.dart | PASS |

Not executed: PM + QA + 5–10 beta-user device sessions. Per §၃.၃ those require
human testers; exit criteria (0 High/Medium bugs) cannot be asserted here.

PM / UAT acceptance: ____________________ UTC: __________ Evidence: __________
QA signature: ___________________________ UTC: __________ Evidence: __________
