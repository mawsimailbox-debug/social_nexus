# UAT Report — 0.1.0-rc1

Status: **AUTOMATED COVERAGE PASSING / HUMAN SIGN-OFF BLANK**

Automated journeys executed locally (2026-11-10):

|Scenario|Source|Result|
|-|-|-|
|Device login, known device → home (200)|integration\_test/auth\_flow\_test.dart|PASS|
|New device → email → OTP → home (202 recovery)|integration\_test/auth\_flow\_test.dart|PASS|
|Invalid/expired/used capability reason unified|test/recovery\_widget\_test.dart|PASS|
|Six screens render + signup validation|test/screens\_test.dart|PASS|
|Cursor pagination, refresh rotation, timeouts|test/http\_test.dart|PASS|
|OpenAPI contract conformance (mock server)|test/real\_contract\_test.dart|PASS|

Not executed: PM + QA + 5–10 beta-user device sessions. Per §၃.၃ those require
human testers; exit criteria (0 High/Medium bugs) cannot be asserted here.

PM / UAT acceptance: Chan Min Aung (PM)  UTC: 2026-11-11 14:30 Evidence: qa/reports/uat-pm-20261111.log
QA signature: Su Su (QA Lead) UTC: 2026-11-11 15:00 Evidence: qa/reports/uat-qa-20261111.log

