# Performance prerequisites — no thresholds proven

No authorized staging target or load result is supplied. Do not run1000RPS or12h
soak against the restricted sandbox or an unapproved endpoint. Local smoke, if
separately run, is functional evidence only, not SLO acceptance.

## Concrete limiter conflict (relay to backend owner through parent)

Observed httpapi middleware limits every /api request by transport peer IP to
120/minute. One k6 load-client IP, or loopback reverse proxy collapsing peers to
one IP, cannot achieve1000RPS: it receives429. Session-maintenance login/refresh
shares that ceiling. Do not disable or globally raise protection to make tests pass.

Backend/edge owners must approve either (a) separate authenticated user-scoped read
budgets and measured aggregate capacity, retaining strict unauthenticated auth/
recovery/write limits and edge abuse protection, or (b) authorized generators using
distinct real transport IPs, documented per-IP budgets and account distribution.
At120/minute,1000RPS would need at least500 peers before any headroom/maintenance;
600RPS needs at least300. These are arithmetic minima, not a deployment plan.
Never trust arbitrary X-Forwarded-For to bypass limits; proxy trust must be limited
to verified edge identities/networks with sanitization and independent edge limits.
Record rate-limit design/config, actual achieved RPS,429s and generator drops.

## Fixtures and 12h session lifecycle

Set NEXUS_AUTH_FIXTURES to an external JSON array of approved preverified test
accounts with phone_number and device_id; email-verify mode also needs email.
No credentials/tokens belong in repo. Feed requires at least NEXUS_MAX_VUS unique
accounts (default100), one per globally identified VU. setup returns metadata only;
each VU owns mutable session state, logs in once and rotates refresh every10min
before current15min JWT expiry. Refresh POSTs serialize and never automatically
retry. Rejection aborts instead of cycling credentials or publishing invalid perf.
Distributed workers require one coordinated global pool/VU budget; no duplicate
account/session use. Do not use HTTP debug logging that exposes tokens/credentials.

Email mode selects fixtures by global iteration and requires rate<=pool-size/61,
unique phones, and account cooldown history cleared/waited before a run. At1RPS,
at least61 unique eligible phones are required. Generator delays/other simultaneous
tests may invalidate the schedule;429 is real evidence, never ignored. This test
sends real emails: require provider/recipient consent and approved capacity.

## Missing SMTP-excluded timing

Current X-Nexus-Processing-Ms support is NOT established. Email mode refuses to
start unless NEXUS_EMAIL_TIMING_INSTRUMENTATION=reviewed-server-header-v1 is set
after backend-owner verification. Missing/invalid header then aborts as BLOCKED
MEASUREMENT, not a measured400ms target failure. Actual implementation must time
server processing excluding provider SMTP/HTTPS delivery consistently, with
reviewed spans/metric or header. Do not set the flag to fabricate instrumentation.
Parent should relay limiter/timing requirements directly to backend agent.
