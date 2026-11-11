# Configurable evidence gate — no packaging/publication

`scripts/release.sh --phase candidate --evidence PATH` runs actual validation.
No unconditional failure remains: legitimate trusted signed evidence and a signed
semantic verdict can return0. Missing setup or rejected evidence blocks naturally.
No ZIP is created; packaging/publication remains separate unimplemented work.

## Administrator-provided trust

NEXUS_RELEASE_TRUST_POLICY must be an absolute protected JSON file outside repo,
schema1, with full-fingerprint arrays ci_signers,tag_signers,qa_signers,
design_signers,team_lead_signers,validator_signers; validator_path is an absolute
external executable, validator_sha256 its approved actual digest. Files must be
root/current-UID owned and not group/world writable. Administrator must protect
parent directories, binary dependencies and GPG public/private key stores too.
No sample approvals or keys are supplied. Do not use a repo script or /bin/true.

## Signed inputs

evidence.json and evidence.json.asc bind phase, clean HEAD commit, real signed
semver tag and all ARTIFACTS IDs in release-gate.py. Each artifact needs nonempty
file,path,sha256,commit,producer_run,producer_tool,media_type. G1–G8 decisions
reference those reports. Manual flags alone are not sufficient: the validator
must independently evaluate report semantics and external producer identity.

qa/design/team_lead JSON and .asc signatures require distinct trusted signers,
role,signed_at,phase,commit,evidence_sha256 and approved_dod. Candidate phase uses
[1,2,3,4,5,6,7,8,11]; final uses [1,2,3,4,5,6,7,8,9,10,11]. Candidate lead
authorization is not final signoff; original item10 and separate item11 remain.

## Trusted semantic validator protocol

Fixed argv, never a shell command string:

```
VALIDATOR --repository PATH --evidence PATH --commit SHA --tag TAG
          --phase candidate|final --evidence-sha256 HASH --policy-sha256 HASH
          --output PATH
```

The pinned administrator-provided validator MUST check upstream CI identity/run
conclusions/SHA/tag and normalized raw reports: Go>=70%, auth100% paths, coverage
regression, E2E, actual RPS/load12h/telemetry/p95/cold-start, parity/UAT signatures,
scanner failures and zero red/critical findings, SBOM contents, legal/store/infra,
branch protection/reviews and reviewer authority/freshness/revocations. Reject
unsupported formats or missing reports. This repo does not pretend to implement
all vendor parsers; deploying/reviewing that trusted validator is required setup.

Validator returns0 only on acceptance, writing output JSON plus output.asc signed
by validator_signers. Required fields: schema1,decision PASS,commit,tag,phase,
evidence_sha256,policy_sha256 matching invocation. Missing/malformed/untrusted
verdict, nonzero exit or timeout300s blocks. Gate verifies the signed result and
rechecks evidence bytes/clean HEAD after validation. Signed booleans from an
unreviewed validator do not replace a substantive semantic policy.

## Candidate versus final

Candidate pass authorizes proceeding, not ZIP/publication or DoD9/10 completion.
Separately reviewed future packaging must consume exact approved source, exclude
secrets/.git/build artifacts, re-extract/check digests, and collect final archive,
download/extract/publication proof and approvals. Final validator must verify all
these before final PASS. No packager is implemented or executed in this lane.

## Workflows/signing

Readiness invokes candidate gate on protected externally provisioned evidence at
NEXUS_EVIDENCE_DIR, with NEXUS_RELEASE_TRUST_POLICY. Provision evidence for the
same checked-out commit; downloading arbitrary artifacts does not confer trust.
Ordinary non-tag PRs cannot satisfy release-tag approval; build jobs are separate.
Current action/tool pins still require real approval and are not bypassed.

iOS uses protected ios-signing environment secrets NEXUS_IOS_CERTIFICATE_BASE64,
NEXUS_IOS_CERTIFICATE_PASSWORD,NEXUS_IOS_PROFILE_BASE64,
NEXUS_IOS_EXPORT_OPTIONS_BASE64,NEXUS_IOS_KEYCHAIN_PASSWORD. ci/build-ios.sh creates
temporary keychain/profile setup, invokes flutter build ipa with owner-supplied
ExportOptions, checks nonempty IPA and cleans up signing material/search-list.
Missing inputs fail naturally. Real project team/bundle/entitlements and signing
assets must match; extensions may require additional reviewed profile support.
No signed IPA or successful protected workflow is claimed from this Linux sandbox.
