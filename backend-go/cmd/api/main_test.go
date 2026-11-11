package main

import (
	"encoding/base64"
	"strings"
	"testing"
)

func TestKeyValidation(t *testing.T) {
	for _, value := range []string{"", "not-base64", base64.StdEncoding.EncodeToString([]byte("short"))} {
		t.Setenv("NEXUS_JWT_KEY", value)
		if _, e := key("NEXUS_JWT_KEY"); e == nil {
			t.Fatal("invalid key accepted")
		}
	}
	t.Setenv("NEXUS_JWT_KEY", base64.StdEncoding.EncodeToString([]byte(strings.Repeat("j", 32))))
	if _, e := key("NEXUS_JWT_KEY"); e != nil {
		t.Fatal(e)
	}
}
func TestStartupRejectsUnsafeConfiguration(t *testing.T) {
	for _, name := range []string{"NEXUS_JWT_KEY", "NEXUS_ENCRYPTION_KEY", "NEXUS_LOOKUP_KEY", "NEXUS_DATABASE_URL", "NEXUS_SENDGRID_API_KEY", "NEXUS_EMAIL_FROM", "NEXUS_ENV"} {
		t.Setenv(name, "")
	}
	if run() == nil {
		t.Fatal("missing keys accepted")
	}
	t.Setenv("NEXUS_JWT_KEY", base64.StdEncoding.EncodeToString([]byte(strings.Repeat("j", 32))))
	if run() == nil {
		t.Fatal("missing encryption key")
	}
	t.Setenv("NEXUS_ENCRYPTION_KEY", base64.StdEncoding.EncodeToString([]byte(strings.Repeat("e", 32))))
	if run() == nil {
		t.Fatal("missing lookup key")
	}
	t.Setenv("NEXUS_LOOKUP_KEY", base64.StdEncoding.EncodeToString([]byte(strings.Repeat("j", 32))))
	if run() == nil {
		t.Fatal("shared keys accepted")
	}
	t.Setenv("NEXUS_LOOKUP_KEY", base64.StdEncoding.EncodeToString([]byte(strings.Repeat("l", 32))))
	if run() == nil {
		t.Fatal("missing DSN")
	}
	t.Setenv("NEXUS_DATABASE_URL", "postgres://127.0.0.1:1/test?sslmode=disable")
	if run() == nil {
		t.Fatal("insecure production database")
	}
	t.Setenv("NEXUS_ENV", "development")
	if run() == nil {
		t.Fatal("missing provider key")
	}
	t.Setenv("NEXUS_SENDGRID_API_KEY", "test-only-not-real")
	if run() == nil {
		t.Fatal("missing sender")
	}
	t.Setenv("NEXUS_EMAIL_FROM", "sender@example.com")
	if run() == nil {
		t.Fatal("offline database accepted")
	}
}
