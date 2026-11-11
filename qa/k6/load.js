import http from 'k6/http';
import { check, fail } from 'k6';
import { Trend } from 'k6/metrics';
import exec from 'k6/execution';

const base = __ENV.NEXUS_BASE_URL;
if (!base || __ENV.NEXUS_LOAD_AUTHORIZED !== 'staging-only') {
  throw new Error('BLOCKED: explicit staging-only authorization and base URL required');
}
const mode = __ENV.NEXUS_LOAD_MODE || 'feed';
if (!['feed', 'device-login', 'email-verify'].includes(mode)) throw new Error('Unknown mode');
if (!__ENV.NEXUS_AUTH_FIXTURES) throw new Error('BLOCKED: external reviewed test-account fixture file required');
const fixtures = JSON.parse(open(__ENV.NEXUS_AUTH_FIXTURES));
const soak = __ENV.NEXUS_SOAK === '12h';
const maxVUs = Number(__ENV.NEXUS_MAX_VUS || 100);
const rate = mode === 'feed' ? (soak ? 600 : 1000) : Number(__ENV.NEXUS_AUTH_RPS || 1);
const refreshMs = 10 * 60 * 1000; // Renew before current backend 15-minute access expiry.
if (!Array.isArray(fixtures) || !fixtures.length || !Number.isInteger(maxVUs) || maxVUs < 1 || !Number.isFinite(rate) || rate <= 0) {
  throw new Error('BLOCKED: invalid fixture pool or capacity');
}
if (mode === 'feed' && fixtures.length < maxVUs) {
  throw new Error('BLOCKED: one unique preverified account/device per possible VU required; no shared refresh sessions');
}
if (mode === 'email-verify') {
  if (__ENV.NEXUS_EMAIL_TIMING_INSTRUMENTATION !== 'reviewed-server-header-v1') {
    throw new Error('BLOCKED MEASUREMENT: backend SMTP-excluded timing header not established; not a latency-target failure');
  }
  if (rate > fixtures.length / 61) {
    throw new Error('BLOCKED: email fixture pool cannot respect per-phone 60-second cooldown at requested rate');
  }
  const phones = new Set(fixtures.map(f => f.phone_number));
  if (phones.size !== fixtures.length || fixtures.some(f => !f.phone_number || !f.email)) {
    throw new Error('BLOCKED: email fixtures must have distinct phones and approved recipient emails');
  }
}
if (mode !== 'email-verify') {
  const accounts = new Set(fixtures.map(f => f.phone_number));
  if (accounts.size !== fixtures.length || fixtures.some(f => !f.phone_number || !f.device_id)) {
    throw new Error('BLOCKED: unique preverified phone/device fixtures required');
  }
}
const latency = new Trend('nexus_target_latency', true);
const limits = { feed: 300, 'device-login': 150, 'email-verify': 400 };
export const options = {
  scenarios: { target: {
    executor: 'constant-arrival-rate', rate, timeUnit: '1s',
    duration: soak ? '12h' : '5m', preAllocatedVUs: Math.min(100, maxVUs), maxVUs,
  } },
  thresholds: {
    http_req_failed: ['rate<0.01'], checks: ['rate==1'],
    dropped_iterations: ['count==0'], nexus_target_latency: [`p(95)<=${limits[mode]}`],
  },
};

export function setup() {
  // setup output is immutable shared metadata only. Never distribute one mutable
  // rotating session/token to all VUs. Credentials stay in the external fixture.
  return { fixtureCount: fixtures.length };
}

// k6 module globals are VU-local. A VU serializes login/refresh and owns its session.
let session = null;
let renewedAt = 0;
function authenticate(fixture) {
  const refresh = session !== null;
  const payload = refresh ? { refresh: session.refresh } : {
    phone_number: fixture.phone_number, device_id: fixture.device_id,
  };
  const r = http.post(`${base}/api/v1/auth/${refresh ? 'refresh' : 'device-login'}`,
    JSON.stringify(payload), { headers: {'Content-Type': 'application/json'},
      timeout: '5s', tags: {purpose: 'session-maintenance'} });
  if (!check(r, {'session maintenance 200': x => x.status === 200})) {
    // Auth POST is never automatically retried. Lost rotation response needs
    // operator investigation; fail rather than repeatedly invalidating sessions.
    exec.test.abort('BLOCKED SESSION: login/refresh rejected; inspect redacted status/limiter telemetry');
  }
  const body = r.json();
  if (!body.jwt || !body.refresh) exec.test.abort('BLOCKED SESSION: token contract mismatch');
  session = {jwt: body.jwt, refresh: body.refresh};
  renewedAt = Date.now();
}

export default function (data) {
  if (data.fixtureCount !== fixtures.length) fail('Fixture pool changed');
  let r;
  if (mode === 'feed') {
    // idInTest is globally unique. Distributed workers need a coordinated single
    // fixture pool/global VU budget; never independently reuse accounts per worker.
    const index = exec.vu.idInTest - 1;
    if (index >= fixtures.length) exec.test.abort('BLOCKED: fixture pool exhausted');
    if (!session || Date.now() - renewedAt >= refreshMs) authenticate(fixtures[index]);
    r = http.get(`${base}/api/v1/feed`, {headers: {Authorization: `Bearer ${session.jwt}`},
      timeout: '5s', tags: {purpose: 'target'} });
    check(r, {'feed 200': x => x.status === 200});
    latency.add(r.timings.duration);
  } else {
    // Global iteration round-robin prevents hot VUs repeatedly sending email to
    // the same account. Pool/rate guard gives >=61s reuse at constant arrival rate.
    const fixture = fixtures[exec.scenario.iterationInTest % fixtures.length];
    const payload = mode === 'email-verify' ? {phone_number: fixture.phone_number, email: fixture.email}
      : {phone_number: fixture.phone_number, device_id: fixture.device_id};
    r = http.post(`${base}/api/v1/auth/${mode}`, JSON.stringify(payload),
      {headers: {'Content-Type': 'application/json'}, timeout: '5s'});
    check(r, {'expected auth status': x => x.status === (mode === 'email-verify' ? 202 : 200)});
    if (mode === 'email-verify') {
      const ms = Number(r.headers['X-Nexus-Processing-Ms']);
      if (!Number.isFinite(ms) || ms <= 0) {
        exec.test.abort('BLOCKED MEASUREMENT: missing/invalid SMTP-excluded timing instrumentation; no p95 conclusion');
      }
      latency.add(ms);
    } else latency.add(r.timings.duration);
  }
}
