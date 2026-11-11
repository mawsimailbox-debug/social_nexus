# Authorized new auth baseline — not present in source HTML

User explicitly authorizes a new auth design using source tokens. Lack of auth
source screens is **not** a blocker to implementation. Design approval is still
unsigned; do not claim auth parity with nonexistent source screens.

Use --ink-deep/--card surfaces, --white/--muted text, --tan CTA and --alert errors;
rounded controls consistent with source. Do not recolor original six screens.
Read exact design/tokens.css, including photo token (photo not required for auth).

Flow: Device login(phone+device) →200 Home/Feed; →202 email recovery screen;
register(phone+device+mandatory valid unique email); verify(phone+email) →202 OTP
sent; confirm(OTP+device with transaction binding) →200 Home. Display pending,
invalid, expired, already-used, resend60s/rate-limit, network/timeout, denied and
retry states. Never echo account existence or log OTP. No SMS terms/dependencies.
Secure device identifier lifecycle, token storage, accessibility labels/focus,
keyboard-safe input and touch sizes need actual device QA.

QA signature: ____________________
Design signature: ________________
Baseline version/date: pending actual approved capture; no fabricated approval.
