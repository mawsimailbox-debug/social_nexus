package httpapi

import (
	"net/http/httptest"
	"strings"
	"testing"
)

func decodeBody(t *testing.T, op, body string) error {
	t.Helper()
	req := httptest.NewRequest("POST", "/", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	_, err := decodeAuth(httptest.NewRecorder(), req, op)
	return err
}

func TestDecodeAuthAcceptsEveryOperationShape(t *testing.T) {
	cases := []struct{ op, body string }{
		{"register", `{"phone_number":"+9591","device_id":"d","email":"a@b.co"}`},
		{"device-login", `{"phone_number":"+9591","device_id":"d"}`},
		{"email-verify", `{"phone_number":"+9591","email":"a@b.co"}`},
		{"otp/confirm", `{"otp":"123456","device_id":"d"}`},
		{"refresh", `{"refresh":"r"}`},
	}
	for _, tc := range cases {
		if err := decodeBody(t, tc.op, tc.body); err != nil {
			t.Fatalf("%s: valid shape rejected: %v", tc.op, err)
		}
	}
}

func TestDecodeAuthRejectsBadShapes(t *testing.T) {
	if err := decodeBody(t, "device-login", `{"phone_number":"+9591","device_id":"d","extra":"x"}`); err == nil {
		t.Fatal("extra field accepted")
	}
	if err := decodeBody(t, "device-login", `{"phone_number":"+9591"}`); err == nil {
		t.Fatal("missing field accepted")
	}
	if err := decodeBody(t, "device-login", `{"phone_number":"","device_id":"d"}`); err == nil {
		t.Fatal("empty field value accepted")
	}
	if err := decodeBody(t, "device-login", `{`); err == nil {
		t.Fatal("malformed body accepted")
	}
	req := httptest.NewRequest("POST", "/", strings.NewReader(`{"phone_number":"+9591","device_id":"d"}`))
	if _, err := decodeAuth(httptest.NewRecorder(), req, "device-login"); err == nil {
		t.Fatal("missing content type accepted")
	}
}
