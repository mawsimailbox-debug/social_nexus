-- Run via an approved scheduler, in bounded batches at scale.
DELETE FROM rate_limits WHERE reset_at < now() - interval '1 day';
DELETE FROM challenges WHERE expires_at < now() - interval '1 day';
DELETE FROM sessions WHERE expires_at < now() - interval '7 days';
