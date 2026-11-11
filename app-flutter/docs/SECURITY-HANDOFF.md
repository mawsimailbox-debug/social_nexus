# Security handoff — current contract

The client is not an authorization boundary. Go must enforce account identity, membership, object visibility and field validation server-side.

Email recovery uses an opaque selector.secret capability: 22 base64url selector characters + dot + 43 secret characters. Go source sets 10-minute expiry, single-use and five incorrect-secret attempts per selector. Unauthorized, expired, used and locked capabilities all return 401; the UI intentionally groups these states rather than inventing a reason. Email resend client countdown is 60 seconds; server limits remain authoritative. No SMS.

Auth operation keys are exact and validated by Go's operation-specific decoder. Device ID is random install-scoped data held in secure storage, not proof of identity alone. Refresh is an opaque capability, sent alone and rotated through one shared flight. Only GET failures retry (200ms, 400ms); non-GET requests never auto-replay after refresh. 429 preserves Retry-After. Request errors preserve server request_id for support, never log credentials.

Logout clears/invalidate state before network revocation completes, rejects stale account-scoped results and old token responses. Secure storage save/delete operations serialize so logout deletion follows an already-started save. Logical cancellation cannot undo server mutations or abort in-flight transport; failed server revocation remains visible. Backend ownership checks and revocation are indispensable.

**Release blocker: certificate/public-key pinning is absent.** OS certificate validation and HTTPS-only transport are used; no validation bypass. Production requires reviewed pinset, rotation/fallback strategy, native-device validation and integration testing.

Backend current source has activity endpoints; ActivityStore nil/not deployed returns 404 and client surfaces it. Real media/repost publishing is blocked until backend has lossless persistence. Server totals/prices/visibility are authoritative; local presentation counts/cart quantities are not checkout proof. No full pagination, SAST/DAST, dependency security review or native secure-storage validation is claimed. Parent's OCI permission block prevents claiming container runtime/E2E success.
