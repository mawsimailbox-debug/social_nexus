package email

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"nexus/backend-go/internal/core"
	"strings"
	"testing"
)

type roundTrip func(*http.Request) (*http.Response, error)

func (f roundTrip) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }
func TestSendGridAdapter(t *testing.T) {
	for _, status := range []int{202, 401, 429, 500} {
		t.Run(http.StatusText(status), func(t *testing.T) {
			s := SendGrid{APIKey: "test-only", From: "sender@example.com", Client: &http.Client{Transport: roundTrip(func(r *http.Request) (*http.Response, error) {
				if r.URL.String() != "https://api.sendgrid.com/v3/mail/send" || r.Header.Get("Authorization") != "Bearer test-only" {
					t.Fatal("invalid request")
				}
				if r.Header.Get("X-Request-ID") != "email-request-123" {
					t.Fatal("request ID missing at email adapter")
				}
				var v map[string]any
				if json.NewDecoder(r.Body).Decode(&v) != nil {
					t.Fatal("invalid JSON")
				}
				if v["subject"] != "Nexus email verification" {
					t.Fatal(v)
				}
				return &http.Response{StatusCode: status, Body: io.NopCloser(strings.NewReader("")), Header: http.Header{}}, nil
			})}}
			e := s.Send(core.WithRequestID(context.Background(), "email-request-123"), "owner@example.com", "test-code")
			if (e == nil) != (status == 202) {
				t.Fatal(status, e)
			}
		})
	}
	s := SendGrid{Client: &http.Client{Transport: roundTrip(func(*http.Request) (*http.Response, error) { return nil, errors.New("offline") })}}
	if s.Send(context.Background(), "a@example.com", "code") == nil {
		t.Fatal("transport error ignored")
	}
}
