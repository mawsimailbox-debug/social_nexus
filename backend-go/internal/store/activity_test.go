package store_test

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http/httptest"
	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
	"nexus/backend-go/internal/httpapi"
	"strconv"
	"strings"
	"testing"
	"time"
)

func idstr(id int64) string { return strconv.FormatInt(id, 10) }

func TestPostgresProfilePatchAndActivitiesHTTP(t *testing.T) {
	p := database(t)
	ctx := context.Background()
	now := time.Now()
	m := &mailCapture{}
	svc := &auth.Service{Store: p, Mail: m, LookupKey: p.LookupKey, Now: func() time.Time { return now }, Tokens: auth.Tokens{Key: []byte(strings.Repeat("j", 32)), Now: func() time.Time { return now }}}
	tokens := map[string]string{}
	for _, v := range []struct{ phone, email string }{{"+959123456789", "owner@example.com"}, {"+959123456788", "peer@example.com"}} {
		if e := svc.Register(ctx, v.phone, "device-012345678901", v.email); e != nil {
			t.Fatal(e)
		}
		if e := svc.EmailVerify(ctx, v.phone, v.email); e != nil {
			t.Fatal(e)
		}
		pair, e := svc.Confirm(ctx, m.code, "device-012345678901")
		if e != nil {
			t.Fatal(e)
		}
		u, _, e := svc.Authenticate(ctx, pair.JWT)
		if e != nil {
			t.Fatal(e)
		}
		tokens[u.ID] = pair.JWT
	}
	var owner, peer string
	for uid := range tokens {
		u, e := p.Profile(ctx, uid, nil)
		if e != nil {
			t.Fatal(e)
		}
		if u.Email == "owner@example.com" {
			owner = uid
		} else {
			peer = uid
		}
	}
	a := &httpapi.API{Auth: svc, Social: p, Activity: p, Ready: p.DB.PingContext, Logger: slog.New(slog.NewTextHandler(io.Discard, nil))}
	h := a.Handler()
	call := func(uid, method, path, body string, status int) *httptest.ResponseRecorder {
		t.Helper()
		r := httptest.NewRequest(method, "/api/v1/"+path, strings.NewReader(body))
		r.Header.Set("Authorization", "Bearer "+tokens[uid])
		r.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		if w.Code != status {
			t.Fatalf("%s %s -> %d %s", method, path, w.Code, w.Body.String())
		}
		return w
	}
	call(owner, "PATCH", "users/me", `{"name":"Sophie Jap","bio":"Original bio"}`, 200)
	w := call(owner, "PATCH", "users/me", `{"bio":"Changed bio"}`, 200)
	var profile core.User
	_ = json.Unmarshal(w.Body.Bytes(), &profile)
	if profile.Name != "Sophie Jap" || profile.Bio != "Changed bio" {
		t.Fatal("omitted name overwritten", profile)
	}
	w = call(owner, "PATCH", "users/me", `{"name":""}`, 200)
	_ = json.Unmarshal(w.Body.Bytes(), &profile)
	if profile.Name != "" || profile.Bio != "Changed bio" {
		t.Fatal("explicit clearing lost", profile)
	}
	call(peer, "PUT", "users/"+owner+"/follow", "", 204)
	call(peer, "PUT", "users/"+owner+"/follow", "", 204)
	w = call(owner, "GET", "notifications", "", 200)
	var page struct {
		Items []core.Activity `json:"items"`
	}
	_ = json.Unmarshal(w.Body.Bytes(), &page)
	if len(page.Items) != 1 || page.Items[0].Kind != "follow" {
		t.Fatal(w.Body.String())
	}
	note := page.Items[0].ID
	call(peer, "PATCH", "notifications/"+idstr(note)+"/read", "", 404)
	call(owner, "PATCH", "notifications/"+idstr(note)+"/read", "", 204)
	call(peer, "GET", "users/me/following", "", 200)
	call(peer, "DELETE", "users/"+owner+"/follow", "", 204)
	post, e := p.Create(ctx, owner, core.Item{Kind: "post", Body: "Public post"}, nil)
	if e != nil {
		t.Fatal(e)
	}
	call(peer, "POST", "items/"+idstr(post.ID)+"/shares", "", 200)
	call(peer, "POST", "items/"+idstr(post.ID)+"/shares", "", 200)
	shop, e := p.Create(ctx, owner, core.Item{Kind: "shop", Name: "Coffee"}, nil)
	if e != nil {
		t.Fatal(e)
	}
	product, e := p.Create(ctx, owner, core.Item{Kind: "product", ParentID: shop.ID, Name: "Mohinga", Currency: "MMK", Price: 2500}, nil)
	if e != nil {
		t.Fatal(e)
	}
	call(peer, "PUT", "cart/"+idstr(product.ID), `{"quantity":2}`, 204)
	w = call(peer, "GET", "cart", "", 200)
	_ = json.Unmarshal(w.Body.Bytes(), &page)
	if len(page.Items) != 1 || page.Items[0].Quantity != 2 || page.Items[0].ItemID != product.ID {
		t.Fatal(w.Body.String())
	}
	w = call(owner, "GET", "cart", "", 200)
	_ = json.Unmarshal(w.Body.Bytes(), &page)
	if len(page.Items) != 0 {
		t.Fatal("cart leaked")
	}
	call(peer, "PUT", "cart/"+idstr(product.ID), `{"quantity":0}`, 400)
	call(peer, "DELETE", "cart/"+idstr(product.ID), "", 204)
	if e = p.FollowUser(ctx, owner, owner, true); !errors.Is(e, core.ErrInvalid) {
		t.Fatal(e)
	}
	private, e := p.Create(ctx, owner, core.Item{Kind: "post", Body: "Private", Visibility: "private"}, nil)
	if e != nil {
		t.Fatal(e)
	}
	if _, e = p.Share(ctx, owner, private.ID); !errors.Is(e, core.ErrForbidden) {
		t.Fatal(e)
	}
	if e = p.Cart(ctx, peer, post.ID, 1); !errors.Is(e, core.ErrNotFound) {
		t.Fatal("nonproduct cart", e)
	}
	if e = p.Cart(ctx, peer, product.ID, 100); !errors.Is(e, core.ErrInvalid) {
		t.Fatal(e)
	}
}
