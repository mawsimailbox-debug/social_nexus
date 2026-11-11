package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/getkin/kin-openapi/openapi3"
	"github.com/getkin/kin-openapi/openapi3filter"
	"github.com/getkin/kin-openapi/routers/legacy"
)

func TestOpenAPIContract(t *testing.T) {
	loader := openapi3.NewLoader()
	doc, e := loader.LoadFromFile("../../openapi.yaml")
	if e != nil {
		t.Fatal(e)
	}
	if e = doc.Validate(context.Background()); e != nil {
		t.Fatal(e)
	}
	router, e := legacy.NewRouter(doc)
	if e != nil {
		t.Fatal(e)
	}
	a, m := fixture()
	h := a.Handler()
	validate := func(method, path, body, token string) *httptest.ResponseRecorder {
		t.Helper()
		r := httptest.NewRequest(method, path, strings.NewReader(body))
		r.Header.Set("Content-Type", "application/json")
		if token != "" {
			r.Header.Set("Authorization", "Bearer "+token)
		}
		route, params, e := router.FindRoute(r)
		if e != nil {
			t.Fatal(e)
		}
		input := &openapi3filter.RequestValidationInput{Request: r, PathParams: params, Route: route, Options: &openapi3filter.Options{AuthenticationFunc: openapi3filter.NoopAuthenticationFunc}}
		if e = openapi3filter.ValidateRequest(context.Background(), input); e != nil {
			t.Fatal("request", e)
		}
		r.Body.Close()
		r.Body = ioBody(body)
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		resp := &openapi3filter.ResponseValidationInput{RequestValidationInput: input, Status: w.Code, Header: w.Header(), Body: ioBody(w.Body.String())}
		if e = openapi3filter.ValidateResponse(context.Background(), resp); e != nil {
			t.Fatal("response", w.Code, w.Body.String(), e)
		}
		return w
	}
	validate("POST", "/api/v1/auth/register", `{"phone_number":"+959123456789","device_id":"random-device-0123456789","email":"owner@example.com"}`, "")
	validate("POST", "/api/v1/auth/device-login", `{"phone_number":"+959123456789","device_id":"random-device-0123456789"}`, "")
	validate("POST", "/api/v1/auth/email-verify", `{"phone_number":"+959123456789","email":"owner@example.com"}`, "")
	w := validate("POST", "/api/v1/auth/otp/confirm", `{"otp":"`+m.code+`","device_id":"replacement-device-0123456789"}`, "")
	var pair map[string]string
	_ = json.Unmarshal(w.Body.Bytes(), &pair)
	validate("GET", "/api/v1/feed?limit=20", "", pair["jwt"])
	validate("POST", "/api/v1/feed", `{"body":"contract validated post"}`, pair["jwt"])
	validate("POST", "/api/v1/auth/refresh", `{"refresh":"`+pair["refresh"]+`"}`, "")
	// Shape enforcement: the exact device-login contract cannot accept email.
	w = request(h, http.MethodPost, "/api/v1/auth/device-login", `{"phone_number":"+959123456789","device_id":"random-device-0123456789","email":"owner@example.com"}`, "")
	if w.Code != 400 {
		t.Fatal(w.Code)
	}
}

type readCloser struct{ *bytes.Reader }

func (readCloser) Close() error  { return nil }
func ioBody(s string) readCloser { return readCloser{bytes.NewReader([]byte(s))} }
