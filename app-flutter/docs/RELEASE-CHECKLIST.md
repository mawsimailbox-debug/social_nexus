# Release checklist — no approval implied

1. [ ] G1 CI build/test/lint on reviewed release commit (local results are not CI).
2. [ ] G2 fresh-machine onboarding and runnable native install.
3. [ ] G3 real device 200 + 202/email/OTP end-to-end; no SMS dependency.
4. [ ] G4 six-screen baseline design parity QA signatures; NEW auth design reviewed separately.
5. [ ] G5 coverage and performance thresholds, critical journey E2E.
6. [ ] G6 deployment, stores, CI and platform signing coordinated by owning teams.
7. [ ] G7 SBOM, vulnerability/secret scans and security review.
8. [ ] G8 full monorepo documentation bundle owned by team.
9. [ ] Baseline HTML hash unchanged (local integrity check recorded, release copy independently checked).
10. [ ] Release manifest, SHA-256 and release distribution verified by release owner; not performed here.
11. [ ] **Separate Team Lead signoff**: name, date, commit, accepted exceptions and explicit release approval. Never inferred from tests or any other checkbox.
