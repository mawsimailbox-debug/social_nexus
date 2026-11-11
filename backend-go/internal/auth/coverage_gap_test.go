package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"strings"
	"testing"
	"time"
)

func swapEntropy(t *testing.T, fail bool) {
	t.Helper()
	original := entropy
	if fail {
		entropy = func([]byte) (int, error) { return 0, errors.New("entropy unavailable") }
	}
	t.Cleanup(func() { entropy = original })
}

func TestRandomPanicsWithoutEntropy(t *testing.T) {
	swapEntropy(t, true)
	defer func() {
		if recover() == nil {
			t.Fatal("expected panic when OS entropy is unavailable")
		}
	}()
	Random(8)
}

func TestSealPropagatesEntropyFailure(t *testing.T) {
	swapEntropy(t, true)
	if _, err := Seal([]byte("0123456789abcdef"), "secret"); err == nil {
		t.Fatal("expected entropy error")
	}
}

func TestSealRejectsInvalidKeyLength(t *testing.T) {
	if _, err := Seal([]byte("short"), "secret"); err == nil {
		t.Fatal("expected error for invalid key length")
	}
}

func TestOpenErrorPaths(t *testing.T) {
	key := []byte("0123456789abcdef0123456789abcdef")
	if _, err := Open([]byte("short"), []byte("x")); err == nil {
		t.Fatal("expected error for invalid key length")
	}
	if _, err := Open(key, []byte("tiny")); err == nil {
		t.Fatal("expected error for short ciphertext")
	}
	sealed, err := Seal(key, "value")
	if err != nil {
		t.Fatalf("seal: %v", err)
	}
	sealed[len(sealed)-1] ^= 0xff
	if _, err := Open(key, sealed); err == nil {
		t.Fatal("expected authentication failure for tampered ciphertext")
	}
}

func token(key []byte, header, payload string) string {
	s := header + "." + payload
	h := hmac.New(sha256.New, key)
	h.Write([]byte(s))
	return s + "." + base64.RawURLEncoding.EncodeToString(h.Sum(nil))
}

func payloadFor(t *testing.T, c Claims) string {
	t.Helper()
	b, err := json.Marshal(c)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	return base64.RawURLEncoding.EncodeToString(b)
}

func TestVerifyRejectsMalformedTokens(t *testing.T) {
	key := []byte("verify-key")
	now := time.Unix(1_700_000_000, 0)
	tok := Tokens{Key: key, Now: func() time.Time { return now }}
	hdr := base64.RawURLEncoding.EncodeToString([]byte(`{"alg":"HS256","typ":"JWT"}`))
	good := Claims{Subject: "u1", Session: "s1", Issuer: "nexus", Audience: "nexus-app", Issued: now.Unix(), Expiry: now.Unix() + 60}
	goodPayload := payloadFor(t, good)

	cases := []struct{ name, token string }{
		{"two segments", "a.b"},
		{"oversized", "a." + strings.Repeat("b", 2050) + ".c"},
		{"undecodable header", "!!!." + goodPayload + ".sig"},
		{"wrong algorithm", token(key, base64.RawURLEncoding.EncodeToString([]byte(`{"alg":"none"}`)), goodPayload)},
		{"undecodable signature", hdr + "." + goodPayload + ".!!!"},
		{"bad signature", token([]byte("other-key"), hdr, goodPayload)},
		{"undecodable payload", token(key, hdr, "!!!")},
		{"invalid payload json", token(key, hdr, base64.RawURLEncoding.EncodeToString([]byte("not-json")))},
		{"expired", token(key, hdr, payloadFor(t, Claims{Subject: "u", Session: "s", Issuer: "nexus", Audience: "nexus-app", Issued: now.Unix() - 120, Expiry: now.Unix() - 60}))},
		{"missing subject", token(key, hdr, payloadFor(t, Claims{Session: "s", Issuer: "nexus", Audience: "nexus-app", Issued: now.Unix(), Expiry: now.Unix() + 60}))},
		{"wrong issuer", token(key, hdr, payloadFor(t, Claims{Subject: "u", Session: "s", Issuer: "other", Audience: "nexus-app", Issued: now.Unix(), Expiry: now.Unix() + 60}))},
		{"issued in future", token(key, hdr, payloadFor(t, Claims{Subject: "u", Session: "s", Issuer: "nexus", Audience: "nexus-app", Issued: now.Unix() + 120, Expiry: now.Unix() + 600}))},
		{"overlong lifetime", token(key, hdr, payloadFor(t, Claims{Subject: "u", Session: "s", Issuer: "nexus", Audience: "nexus-app", Issued: now.Unix(), Expiry: now.Unix() + 901}))},
	}
	for _, tc := range cases {
		if _, err := tok.Verify(tc.token); err == nil {
			t.Fatalf("%s: expected rejection", tc.name)
		}
	}
	if c, err := tok.Verify(token(key, hdr, goodPayload)); err != nil || c.Subject != "u1" {
		t.Fatalf("valid token rejected: %v", err)
	}
}
