# Independent parent verification notes

These checks do not authorize production packaging.

- Original HTML MD5 `a8fafd493261eda3876d79039c564e10`; byte-for-byte equality to the design copy verified.
- Original HTML SHA-256 `caaceacf58f265cd24cc7423abe9b4fbee980b5ff771d442d68d7e63122d5040`.
- Docker and Compose installed; Compose configuration validated using temporary nonsecret test values, exit 0. No deployment inferred.
- Docker `hello-world` downloaded, then container creation failed with `OCI runtime create failed ... operation not permitted`. This sandbox cannot substantiate the fresh-machine Compose gate.
- PostgreSQL 16 cluster observed online. Backend owner runs direct database integration independently; this is not testcontainers evidence.
- Go 1.27.3 and Flutter 3.47.9 / Dart 3.13.7 observed. Android SDK unavailable; no signed mobile artifact verified. Linux cannot substantiate the required macOS signing run.
- A first gitleaks 8.30.1 snapshot detected one prose false-positive in ERD. The exact location was examined, reworded by the operations owner; final scan must be rerun after changes settle.
- A first Redocly 2.77.0 snapshot reported 20 missing-operation-summary errors and 34 documentation warnings. Backend owner was notified; final validation must be rerun.
- GitHub connection discovery found no connected GitHub binding. No project Git repository, signed release tag, external CI run or release URL has been supplied or created.
- Four workflow action references resolved to full upstream commit SHAs using GitHub ref and commit APIs, with dates prior to the requested cutoff and upstream signature verification flags true. This is provenance, not Nexus team approval.
- A subsequent `ci/check-pins.py` run no longer reports mutable action refs; it still exits 1 because the owner-approved runtime tool lock is incomplete. No approval names or signatures were invented.
- Secret adapter exports exactly one source per setting: after consuming file inputs it clears matching file-pointer variables. Tested with nonsecret fixtures, exit 0, no values printed.
- Compose API healthcheck now uses dependency-aware `/readyz`, not liveness-only `/healthz`.
- Source scan found no SMS implementation references; one auth explanatory UI sentence says no SMS code is sent. This is not a complete dependency or supply-chain audit.

## Release decision

BLOCKED until all actual G1–G8 evidence and the eleven sign-offs are verified.
No production ZIP or replacement nonrelease source archive is authorized by these notes.

## Original screenshot references

Baseline-only captures, not app screenshots or parity acceptance:

- Feed: https://www.genspark.ai/api/files/s/DhuJffW0
- Chat: https://www.genspark.ai/api/files/s/tMxxTR1t
- Profile: https://www.genspark.ai/api/files/s/hBvymrIm
- Discover: https://www.genspark.ai/api/files/s/JV3ehcrt
- Shop: https://www.genspark.ai/api/files/s/nSC0Tkt3
- Group: https://www.genspark.ai/api/files/s/7W80slTO

The five non-feed captures used scratch copies preserving every original byte and appending a navigation click after the original closing HTML. The source and delivered design baseline were never modified.
