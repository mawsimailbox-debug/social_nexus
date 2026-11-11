#!/usr/bin/env python3
"""Drive the real Nexus API through the G3 auth journeys and assert each step."""
import json
import os
import sys
import time
import urllib.error
import urllib.request

BASE = "http://127.0.0.1:18081"
MAIL = os.environ["NEXUS_E2E_MAIL"]
PHONE = "+959123456789"
EMAIL = "e2e@example.com"
rows = []
DA = "device-a-000000000001"
DB = "device-b-000000000002"
DC = "device-c-000000000003"


def call(path, payload, expect):
    data = json.dumps(payload).encode()
    req = urllib.request.Request(BASE + path, data=data, method="POST",
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            status, body = r.status, r.read().decode()
    except urllib.error.HTTPError as exc:
        status, body = exc.code, exc.read().decode()
    ok = status == expect
    rows.append((path, expect, status, "PASS" if ok else "FAIL"))
    print(f"{'PASS' if ok else 'FAIL'}  POST {path} -> {status} (expected {expect}) {body[:160]}")
    if not ok:
        raise SystemExit(1)
    return json.loads(body) if body.strip().startswith("{") else {}


def read_code():
    for _ in range(100):
        if os.path.exists(MAIL):
            for line in open(MAIL):
                if line.startswith("to=" + EMAIL):
                    return line.split("code=")[1].split()[0]
        time.sleep(0.05)
    raise SystemExit("FAIL  verification email never reached the local sink")


health = urllib.request.urlopen(BASE + "/healthz", timeout=5).status
ready = urllib.request.urlopen(BASE + "/readyz", timeout=5).status
print(f"INFO  /healthz={health} /readyz={ready}")

print("STEP 1 register a pending account (email capability required before device binding)")
call("/api/v1/auth/register", {"phone_number": PHONE, "device_id": DA, "email": EMAIL}, 202)
print("STEP 2 device-login on an unbound device must return 202")
call("/api/v1/auth/device-login", {"phone_number": PHONE, "device_id": DA}, 202)
print("STEP 3 email-verify issues the recovery capability")
call("/api/v1/auth/email-verify", {"phone_number": PHONE, "email": EMAIL}, 202)
code = read_code()
print(f"INFO  capability captured from local mail sink (len {len(code)})")
print("STEP 4 otp/confirm binds device A to the account")
out = call("/api/v1/auth/otp/confirm", {"otp": code, "device_id": DA}, 200)
print(f"INFO  jwt issued: {bool(out.get('jwt'))} refresh issued: {bool(out.get('refresh'))}")
print("STEP 5 device A (now known) device-login returns 200")
call("/api/v1/auth/device-login", {"phone_number": PHONE, "device_id": DA}, 200)
print("STEP 6 device B (new installation) returns 202")
call("/api/v1/auth/device-login", {"phone_number": PHONE, "device_id": DB}, 202)
print("STEP 7 replaying a consumed capability must be rejected")
call("/api/v1/auth/otp/confirm", {"otp": code, "device_id": DC}, 401)
print("\nSUMMARY")
print(f"  steps: {len(rows)}  pass: {sum(1 for r in rows if r[3] == 'PASS')}  fail: {sum(1 for r in rows if r[3] == 'FAIL')}")
print("  SMS OTP dependency: NONE (no SMS endpoint or provider in the router)")
sys.exit(0 if all(r[3] == "PASS" for r in rows) else 1)
