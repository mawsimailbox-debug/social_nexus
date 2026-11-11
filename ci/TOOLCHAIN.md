# Toolchain/pinning ledger

Official `https://go.dev/dl/?mode=json` queried 2026-11-09 returned stable
`go1.27.3` and `go1.26.10`. This is metadata, NOT verification that a matching
Docker image exists. Prefer the backend's actual `go.mod` after coordination;
the guide's Go1.22 image is a historical reference, not an approved deployment pin.
The backend go.mod read during coordination declares `go 1.25.0`; CI reads that
file directly. Selecting a newer patched builder requires backend-owner validation.
`setup-go` uses `go-version-file` to avoid inventing the backend version.

Compose requires explicit PostgreSQL16 and Redis7 images, Go builder and Alpine
runtime references. Registry digests, compatibility and vulnerability review are
still REQUIRED. No invented image SHA or action SHA is included.

Actions currently use readable version refs: actions/checkout@v4,
actions/setup-go@v5, actions/upload-artifact@v4, subosito/flutter-action@v2.
These are deliberately **UNVERIFIED MUTABLE REFS**; resolve actual upstream
commits, review them and replace refs with approved full SHAs before release.
Flutter version is required through repository variable NEXUS_FLUTTER_VERSION.
Security tools must be preinstalled on a controlled runner and versions recorded;
missing tools fail, rather than auto-installing unreviewed latest binaries.

## Runtime provisioning procedure — required, not completed

1. Use an isolated administrative provisioning session. Resolve each action tag
   with `git ls-remote <official-upstream-repository> refs/tags/<version>`; annotated
   tags require resolving the peeled commit. Review upstream code and signatures;
   replace the uses ref with that reviewed40-hex commit in BOTH workflow copies.
   A returned SHA alone is not a security approval. No actual SHAs are supplied yet.
2. Select compatible exact tool versions on the approved runner OS/architecture.
   Obtain releases from official upstream, verify release checksum/signature, then
   install through the controlled runner image build (not PR-time latest installs).
3. Record each tool in `ci/approved-tools.json`: version (literal version output
   fragment), binary_sha256 (actual installed executable bytes), source (actual
   reviewed release URL), approved_by (real accountable reviewer). Required tool
   names are in check-pins.py COMMANDS. Empty records fail; never invent digests.
4. Use `sha256sum "$(command -v TOOL)"` on resolved executable files and run the
   listed version commands. For Go-built goimports, inspect `go version -m PATH`.
   Script wrappers need their dependency/runtime integrity recorded separately.
5. Set lock status APPROVED only after review; `python3 ci/check-pins.py` validates
   static pin completeness. `python3 ci/check-pins.py --runtime` also checks actual
   binary hashes and version output on the controlled runner. Sign the runner/tool
   inventory in external release evidence. Mutable/transitive dependencies still
   need image attestations; this check alone does not clear supply-chain risk.

Current lock is intentionally empty and CI pins-prerequisite FAILS. It is not a
silent placeholder pass. Provision Flutter on the combined security runner too,
or split approved per-runner locks in a reviewed follow-up; no current runner is
asserted configured. Do not send untrusted PR code to credentialed release runners.
