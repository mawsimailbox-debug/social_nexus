package httpapi

import (
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
	"nexus/backend-go/internal/store"
	"strings"
	"sync"
	"testing"
	"time"
)

type fakeMail struct{ code string }

func (m *fakeMail) Send(_ context.Context, _ string, c string) error { m.code = c; return nil }

type fakeSocial struct {
	mu    sync.Mutex
	items []core.Item
}

func (f *fakeSocial) Profile(_ context.Context, id string, u *core.ProfilePatch) (core.User, error) {
	if u == nil {
		return core.User{ID: id}, nil
	}
	v := core.User{ID: id}
	if u.Name != nil {
		v.Name = *u.Name
	}
	if u.Bio != nil {
		v.Bio = *u.Bio
	}
	return v, nil
}
func (f *fakeSocial) List(_ context.Context, q core.Query) ([]core.Item, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := []core.Item{}
	for j := len(f.items) - 1; j >= 0; j-- {
		i := f.items[j]
		if i.Kind == q.Kind && (q.Before == 0 || i.ID < q.Before) && (q.ParentID == 0 || q.ParentID == i.ParentID) {
			out = append(out, i)
			if len(out) == q.Limit {
				break
			}
		}
	}
	return out, nil
}
func (f *fakeSocial) Get(_ context.Context, _ string, kind string, id int64) (core.Item, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, i := range f.items {
		if i.ID == id && i.Kind == kind {
			return i, nil
		}
	}
	return core.Item{}, core.ErrNotFound
}
func (f *fakeSocial) Create(_ context.Context, u string, i core.Item, _ []string) (core.Item, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	i.ID = int64(len(f.items) + 1)
	i.AuthorID = u
	f.items = append(f.items, i)
	return i, nil
}
func (f *fakeSocial) Membership(context.Context, string, string, int64, bool) error { return nil }
func (f *fakeSocial) Relation(context.Context, string, string, int64, bool) error   { return nil }
func (f *fakeSocial) DeleteUser(context.Context, string) error                      { return nil }
func fixture() (*API, *fakeMail) {
	key := []byte(strings.Repeat("l", 32))
	m := &fakeMail{}
	s := &auth.Service{Store: store.NewMemory(key), Mail: m, LookupKey: key, Now: time.Now, Tokens: auth.Tokens{Key: []byte(strings.Repeat("j", 32)), Now: time.Now}}
	return &API{Auth: s, Social: &fakeSocial{}, Logger: slog.New(slog.NewTextHandler(io.Discard, nil))}, m
}
func request(h http.Handler, method, path, body, token string) *httptest.ResponseRecorder {
	r := httptest.NewRequest(method, path, strings.NewReader(body))
	r.Header.Set("Content-Type", "application/json")
	if token != "" {
		r.Header.Set("Authorization", "Bearer "+token)
	}
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	return w
}
func login(t *testing.T, a *API, m *fakeMail) (http.Handler, auth.Pair) {
	t.Helper()
	h := a.Handler()
	for _, tc := range []struct {
		path, body string
		status     int
	}{{"register", `{"phone_number":"+959123456789","device_id":"device-012345678901","email":"owner@example.com"}`, 202}, {"device-login", `{"phone_number":"+959123456789","device_id":"device-012345678901"}`, 202}, {"email-verify", `{"phone_number":"+959123456789","email":"owner@example.com"}`, 202}} {
		w := request(h, "POST", "/api/v1/auth/"+tc.path, tc.body, "")
		if w.Code != tc.status {
			t.Fatal(tc.path, w.Code, w.Body.String())
		}
	}
	w := request(h, "POST", "/api/v1/auth/otp/confirm", `{"otp":"`+m.code+`","device_id":"new-device-012345678901"}`, "")
	if w.Code != 200 {
		t.Fatal(w.Code, w.Body.String())
	}
	var p auth.Pair
	_ = json.Unmarshal(w.Body.Bytes(), &p)
	if p.JWT == "" || p.Refresh == "" {
		t.Fatal("missing tokens")
	}
	return h, p
}
func TestHTTPAuthJourney(t *testing.T) {
	a, m := fixture()
	h, p := login(t, a, m)
	w := request(h, "GET", "/api/v1/users/me", "", p.JWT)
	if w.Code != 200 || w.Header().Get("X-Request-ID") == "" {
		t.Fatal(w.Code, w.Body.String())
	}
	for _, tc := range []struct {
		body   string
		status int
	}{{`{"phone_number":"+959123456789","device_id":"device-012345678901"}`, 202}, {`{"phone_number":"+959123456789","device_id":"new-device-012345678901"}`, 200}} {
		w = request(h, "POST", "/api/v1/auth/device-login", tc.body, "")
		if w.Code != tc.status {
			t.Fatal(w.Code, w.Body.String())
		}
	}
	w = request(h, "POST", "/api/v1/auth/refresh", `{"refresh":"`+p.Refresh+`"}`, "")
	if w.Code != 200 {
		t.Fatal(w.Code, w.Body.String())
	}
	var rotated auth.Pair
	_ = json.Unmarshal(w.Body.Bytes(), &rotated)
	w = request(h, "POST", "/api/v1/auth/logout", "", rotated.JWT)
	if w.Code != 204 {
		t.Fatal(w.Code)
	}
	if w = request(h, "GET", "/api/v1/users/me", "", rotated.JWT); w.Code != 401 {
		t.Fatal(w.Code)
	}
}
func TestHTTPValidationErrors(t *testing.T) {
	a, _ := fixture()
	h := a.Handler()
	for _, tc := range []struct {
		method, path, body string
		status             int
	}{{"GET", "/api/v1/feed", "", 401}, {"POST", "/api/v1/auth/register", `{"phone_number":"bad"}`, 400}, {"POST", "/api/v1/auth/register", `{"unexpected":true}`, 400}, {"POST", "/api/v1/auth/register", `{} {}`, 400}, {"POST", "/api/v1/auth/register", strings.Repeat("x", 17000), 400}, {"POST", "/api/v1/auth/otp/confirm", `{"otp":"123456","device_id":"device-012345678901"}`, 401}, {"POST", "/api/v1/auth/refresh", `{"refresh":"bad"}`, 401}} {
		w := request(h, tc.method, tc.path, tc.body, "")
		if w.Code != tc.status {
			t.Fatal(tc.path, w.Code, w.Body.String())
		}
		if w.Code >= 400 && !strings.Contains(w.Body.String(), "request_id") {
			t.Fatal("missing error request id")
		}
	}
	r := httptest.NewRequest("POST", "/api/v1/auth/register", strings.NewReader(`{}`))
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	if w.Code != 400 {
		t.Fatal(w.Code)
	}
}
func TestHTTPSocialPaginationAndRoutes(t *testing.T) {
	a, m := fixture()
	h, p := login(t, a, m)
	for _, tc := range []struct {
		method, path, body string
		status             int
	}{{"POST", "/api/v1/feed", `{"body":"first"}`, 201}, {"POST", "/api/v1/feed", `{"body":"second"}`, 201}, {"GET", "/api/v1/feed?limit=1", "", 200}, {"PATCH", "/api/v1/users/me", `{"name":"Sophie Jap","bio":"Editorial films"}`, 200}, {"POST", "/api/v1/shops", `{"name":"Coffee"}`, 201}, {"GET", "/api/v1/shops/3", "", 200}, {"POST", "/api/v1/shops/3/products", `{"name":"Mohinga","price_minor":2500,"currency":"MMK"}`, 201}, {"POST", "/api/v1/groups", `{"name":"Runners"}`, 201}, {"POST", "/api/v1/groups/5/join", `{}`, 204}, {"GET", "/api/v1/groups/5/members", "", 200}, {"POST", "/api/v1/groups/5/posts", `{"body":"Saturday route"}`, 201}, {"POST", "/api/v1/chat/threads", `{"member_ids":["peer"]}`, 201}, {"POST", "/api/v1/chat/threads/7/messages", `{"body":"Hello"}`, 201}, {"GET", "/api/v1/chat/threads/7/messages", "", 200}, {"POST", "/api/v1/feed/1/comments", `{"body":"Nice"}`, 201}, {"PUT", "/api/v1/items/1/like", `{}`, 204}, {"DELETE", "/api/v1/items/1/like", "", 204}, {"DELETE", "/api/v1/groups/5/join", "", 204}, {"GET", "/api/v1/discover?type=people", "", 200}, {"GET", "/api/v1/feed?limit=0", "", 400}, {"GET", "/api/v1/feed?cursor=bad", "", 400}, {"GET", "/api/v1/groups/nope", "", 400}, {"GET", "/api/v1/groups/900", "", 404}, {"DELETE", "/api/v1/users/me", "", 204}} {
		w := request(h, tc.method, tc.path, tc.body, p.JWT)
		if w.Code != tc.status {
			t.Fatalf("%s %s: %d %s", tc.method, tc.path, w.Code, w.Body.String())
		}
	}
	w := request(h, "GET", "/api/v1/feed?limit=1", "", p.JWT)
	var result struct {
		Items []core.Item `json:"items"`
		Next  string      `json:"next_cursor"`
	}
	_ = json.Unmarshal(w.Body.Bytes(), &result)
	if len(result.Items) != 1 || result.Next == "" {
		t.Fatal(w.Body.String())
	}
	w = request(h, "GET", "/api/v1/feed?limit=1&cursor="+result.Next, "", p.JWT)
	if w.Code != 200 {
		t.Fatal(w.Code)
	}
}
func TestHTTPLimits(t *testing.T) {
	a, _ := fixture()
	h := a.Handler()
	for i := 0; i < 2; i++ {
		w := request(h, "POST", "/api/v1/auth/email-verify", `{"phone_number":"+959123456789","email":"owner@example.com"}`, "")
		if i == 0 && w.Code != 202 || i == 1 && w.Code != 429 {
			t.Fatal(i, w.Code)
		}
	}
}
func TestPageValidation(t *testing.T) {
	for _, q := range []string{"?limit=101", "?limit=no", "?cursor=MA", "?cursor=LTE"} {
		r := httptest.NewRequest("GET", "/"+q, nil)
		if _, _, e := page(r); e == nil {
			t.Fatal(q)
		}
	}
}
