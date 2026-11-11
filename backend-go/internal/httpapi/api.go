package httpapi

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"

	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
)

type API struct {
	Auth     *auth.Service
	Social   core.SocialStore
	Logger   *slog.Logger
	Ready    func(context.Context) error
	Activity core.ActivityStore
}
type identity struct{ UID, SID string }
type ctxKey int

const identityKey ctxKey = 1

type authInput struct {
	Phone   string `json:"phone_number"`
	Email   string `json:"email"`
	Device  string `json:"device_id"`
	OTP     string `json:"otp"`
	Refresh string `json:"refresh"`
}

func (a *API) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) { a.write(w, 200, map[string]string{"status": "ok"}) })
	mux.HandleFunc("GET /readyz", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()
		if a.Ready == nil || a.Ready(ctx) != nil {
			a.write(w, 503, map[string]string{"status": "not_ready", "request_id": core.RequestID(r.Context())})
			return
		}
		a.write(w, 200, map[string]string{"status": "ready"})
	})
	for _, op := range []string{"register", "device-login", "email-verify", "otp/confirm", "refresh"} {
		mux.HandleFunc("POST /api/v1/auth/"+op, a.authHandler(op))
	}
	mux.Handle("POST /api/v1/auth/logout", a.protected(http.HandlerFunc(a.logout)))
	mux.Handle("GET /api/v1/users/me", a.protected(http.HandlerFunc(a.profile)))
	mux.Handle("PATCH /api/v1/users/me", a.protected(http.HandlerFunc(a.profile)))
	mux.Handle("DELETE /api/v1/users/me", a.protected(http.HandlerFunc(a.deleteUser)))
	for _, route := range []string{"GET /api/v1/notifications", "PATCH /api/v1/notifications/{id}/read", "PUT /api/v1/users/{user_id}/follow", "DELETE /api/v1/users/{user_id}/follow", "GET /api/v1/users/me/following", "POST /api/v1/items/{id}/shares", "GET /api/v1/cart", "PUT /api/v1/cart/{id}", "DELETE /api/v1/cart/{id}"} {
		mux.Handle(route, a.protected(http.HandlerFunc(a.activity)))
	}
	for _, path := range []string{"feed", "chat/threads", "shops", "groups"} {
		mux.Handle("GET /api/v1/"+path, a.protected(http.HandlerFunc(a.social)))
		mux.Handle("POST /api/v1/"+path, a.protected(http.HandlerFunc(a.social)))
	}
	mux.Handle("GET /api/v1/discover", a.protected(http.HandlerFunc(a.social)))
	for _, path := range []string{"shops/{id}", "groups/{id}"} {
		mux.Handle("GET /api/v1/"+path, a.protected(http.HandlerFunc(a.social)))
	}
	for _, path := range []string{"feed/{id}/comments", "chat/threads/{id}/messages", "shops/{id}/products", "groups/{id}/posts", "groups/{id}/members"} {
		mux.Handle("GET /api/v1/"+path, a.protected(http.HandlerFunc(a.social)))
		if !strings.HasSuffix(path, "members") {
			mux.Handle("POST /api/v1/"+path, a.protected(http.HandlerFunc(a.social)))
		}
	}
	mux.Handle("POST /api/v1/groups/{id}/join", a.protected(http.HandlerFunc(a.membership)))
	mux.Handle("DELETE /api/v1/groups/{id}/join", a.protected(http.HandlerFunc(a.membership)))
	mux.Handle("DELETE /api/v1/chat/threads/{id}/membership", a.protected(http.HandlerFunc(a.membership)))
	for _, op := range []string{"like", "save", "follow"} {
		mux.Handle("PUT /api/v1/items/{id}/"+op, a.protected(http.HandlerFunc(a.relation)))
		mux.Handle("DELETE /api/v1/items/{id}/"+op, a.protected(http.HandlerFunc(a.relation)))
	}
	return a.middleware(mux)
}
func (a *API) write(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if v != nil {
		_ = json.NewEncoder(w).Encode(v)
	}
}
func (a *API) fail(w http.ResponseWriter, err error) {
	status := 500
	code := "internal_error"
	switch {
	case errors.Is(err, core.ErrInvalid):
		status = 400
		code = "invalid_input"
	case errors.Is(err, core.ErrUnauthorized):
		status = 401
		code = "unauthorized"
	case errors.Is(err, core.ErrForbidden):
		status = 403
		code = "forbidden"
	case errors.Is(err, core.ErrNotFound):
		status = 404
		code = "not_found"
	case errors.Is(err, core.ErrConflict):
		status = 409
		code = "conflict"
	case errors.Is(err, core.ErrLimited):
		status = 429
		code = "rate_limited"
		w.Header().Set("Retry-After", "60")
	}
	a.write(w, status, map[string]string{"error": code, "request_id": w.Header().Get("X-Request-ID")})
}
func decode(w http.ResponseWriter, r *http.Request, v any) error {
	if ct := strings.Split(r.Header.Get("Content-Type"), ";")[0]; ct != "application/json" {
		return core.ErrInvalid
	}
	r.Body = http.MaxBytesReader(w, r.Body, 16<<10)
	d := json.NewDecoder(r.Body)
	d.DisallowUnknownFields()
	if d.Decode(v) != nil {
		return core.ErrInvalid
	}
	if d.Decode(new(any)) != io.EOF {
		return core.ErrInvalid
	}
	return nil
}
func (a *API) middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		id := auth.Random(18)
		w.Header().Set("X-Request-ID", id)
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("Cache-Control", "no-store")
		w.Header().Set("Referrer-Policy", "no-referrer")
		defer func() {
			if recover() != nil {
				a.fail(w, errors.New("panic"))
				a.Logger.Error("request panic", "request_id", id)
			}
			a.Logger.Info("request", "request_id", id, "method", r.Method, "latency_ms", time.Since(start).Milliseconds())
		}()
		ctx, cancel := context.WithTimeout(core.WithRequestID(r.Context(), id), 10*time.Second)
		defer cancel()
		r = r.WithContext(ctx)
		if strings.HasPrefix(r.URL.Path, "/api/") {
			// Trust only the transport peer. Proxy deployments must rate-limit at the trusted edge too.
			host, _, err := net.SplitHostPort(r.RemoteAddr)
			if err != nil {
				host = r.RemoteAddr
			}
			if err = a.Auth.Store.Limit(ctx, "ip:"+auth.Lookup(a.Auth.LookupKey, host), 120, time.Minute, a.Auth.Now()); err != nil {
				a.fail(w, err)
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}
func (a *API) authHandler(op string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		in, decodeErr := decodeAuth(w, r, op)
		if err := decodeErr; err != nil {
			a.fail(w, err)
			return
		}
		// Independent phone/device limits prevent one client cycling devices or IPs.
		for prefix, value := range map[string]string{"phone:": in.Phone, "device:": in.Device} {
			if value != "" {
				if e := a.Auth.Store.Limit(r.Context(), prefix+auth.Lookup(a.Auth.LookupKey, value), 20, time.Minute, a.Auth.Now()); e != nil {
					a.fail(w, e)
					return
				}
			}
		}
		var p auth.Pair
		var err error
		switch op {
		case "register":
			err = a.Auth.Register(r.Context(), in.Phone, in.Device, in.Email)
			if err == nil {
				a.write(w, 202, map[string]string{"action": "REQUIRE_EMAIL_VERIFICATION"})
				return
			}
		case "device-login":
			p, err = a.Auth.DeviceLogin(r.Context(), in.Phone, in.Device)
			if errors.Is(err, core.ErrUnauthorized) {
				a.write(w, 202, map[string]string{"action": "REQUIRE_EMAIL_VERIFICATION"})
				return
			}
		case "email-verify":
			err = a.Auth.EmailVerify(r.Context(), in.Phone, in.Email)
			if err == nil {
				a.write(w, 202, map[string]string{"action": "CHECK_EMAIL"})
				return
			}
		case "otp/confirm":
			p, err = a.Auth.Confirm(r.Context(), in.OTP, in.Device)
		case "refresh":
			p, err = a.Auth.Refresh(r.Context(), in.Refresh)
		}
		if err != nil {
			a.fail(w, err)
			return
		}
		a.write(w, 200, auth.ExternalRefresh(p, a.Auth.Tokens))
	}
}
func (a *API) protected(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := r.Header.Get("Authorization")
		if !strings.HasPrefix(h, "Bearer ") {
			a.fail(w, core.ErrUnauthorized)
			return
		}
		u, sid, e := a.Auth.Authenticate(r.Context(), strings.TrimPrefix(h, "Bearer "))
		if e != nil {
			a.fail(w, e)
			return
		}
		next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), identityKey, identity{u.ID, sid})))
	})
}
func who(r *http.Request) identity { return r.Context().Value(identityKey).(identity) }
func (a *API) logout(w http.ResponseWriter, r *http.Request) {
	i := who(r)
	if e := a.Auth.Store.Revoke(r.Context(), i.UID, i.SID); e != nil {
		a.fail(w, e)
		return
	}
	a.write(w, 204, nil)
}
func (a *API) profile(w http.ResponseWriter, r *http.Request) {
	var update *core.ProfilePatch
	if r.Method == http.MethodPatch {
		var input core.ProfilePatch
		if e := decode(w, r, &input); e != nil {
			a.fail(w, e)
			return
		}
		update = &input
	}
	u, e := a.Social.Profile(r.Context(), who(r).UID, update)
	if e != nil {
		a.fail(w, e)
		return
	}
	a.write(w, 200, u)
}
func (a *API) deleteUser(w http.ResponseWriter, r *http.Request) {
	if e := a.Social.DeleteUser(r.Context(), who(r).UID); e != nil {
		a.fail(w, e)
		return
	}
	a.write(w, 204, nil)
}
func page(r *http.Request) (int64, int, error) {
	n := 20
	var before int64
	var e error
	if s := r.URL.Query().Get("limit"); s != "" {
		n, e = strconv.Atoi(s)
		if e != nil || n < 1 || n > 100 {
			return 0, 0, core.ErrInvalid
		}
	}
	if c := r.URL.Query().Get("cursor"); c != "" {
		b, err := base64.RawURLEncoding.DecodeString(c)
		if err != nil {
			return 0, 0, core.ErrInvalid
		}
		before, e = strconv.ParseInt(string(b), 10, 64)
		if e != nil || before <= 0 {
			return 0, 0, core.ErrInvalid
		}
	}
	return before, n, nil
}
func pathID(r *http.Request) (int64, error) {
	id, e := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if e != nil || id < 1 {
		return 0, core.ErrInvalid
	}
	return id, nil
}
func (a *API) social(w http.ResponseWriter, r *http.Request) {
	uid := who(r).UID
	path := strings.TrimPrefix(r.URL.Path, "/api/v1/")
	kind := ""
	parentKind := ""
	var parent int64
	switch {
	case path == "feed":
		kind = "post"
	case path == "chat/threads":
		kind = "thread"
	case path == "shops":
		kind = "shop"
	case path == "groups":
		kind = "group"
	case path == "discover":
		typ := r.URL.Query().Get("type")
		if typ == "" {
			typ = "groups"
		}
		kind = map[string]string{"groups": "group", "business": "shop", "places": "shop", "people": "people"}[typ]
		if kind == "" {
			a.fail(w, core.ErrInvalid)
			return
		}
	case strings.HasSuffix(path, "/comments"):
		kind = "comment"
		parentKind = "post"
	case strings.HasSuffix(path, "/messages"):
		kind = "message"
		parentKind = "thread"
	case strings.HasSuffix(path, "/products"):
		kind = "product"
		parentKind = "shop"
	case strings.HasSuffix(path, "/posts"):
		kind = "post"
		parentKind = "group"
	case strings.HasSuffix(path, "/members"):
		kind = "member"
		parentKind = "group"
	case strings.HasPrefix(path, "shops/"):
		kind = "shop"
	case strings.HasPrefix(path, "groups/"):
		kind = "group"
	}
	if r.PathValue("id") != "" {
		id, e := pathID(r)
		if e != nil {
			a.fail(w, e)
			return
		}
		if parentKind == "" {
			i, e := a.Social.Get(r.Context(), uid, kind, id)
			if e != nil {
				a.fail(w, e)
				return
			}
			a.write(w, 200, i)
			return
		}
		parent = id
		if _, e = a.Social.Get(r.Context(), uid, parentKind, parent); e != nil {
			a.fail(w, e)
			return
		}
	}
	if r.Method == http.MethodPost {
		var input struct {
			Name       string   `json:"name"`
			Body       string   `json:"body"`
			Visibility string   `json:"visibility"`
			Price      int64    `json:"price_minor"`
			Currency   string   `json:"currency"`
			Members    []string `json:"member_ids"`
		}
		if e := decode(w, r, &input); e != nil {
			a.fail(w, e)
			return
		}
		i, e := a.Social.Create(r.Context(), uid, core.Item{Kind: kind, ParentID: parent, Name: input.Name, Body: input.Body, Visibility: input.Visibility, Price: input.Price, Currency: input.Currency}, input.Members)
		if e != nil {
			a.fail(w, e)
			return
		}
		a.write(w, 201, i)
		return
	}
	before, n, e := page(r)
	if e != nil {
		a.fail(w, e)
		return
	}
	search := r.URL.Query().Get("q")
	if len(search) > 120 {
		a.fail(w, core.ErrInvalid)
		return
	}
	items, e := a.Social.List(r.Context(), core.Query{Kind: kind, UserID: uid, ParentID: parent, Before: before, Limit: n + 1, Search: search})
	if e != nil {
		a.fail(w, e)
		return
	}
	next := ""
	if len(items) > n {
		items = items[:n]
		next = base64.RawURLEncoding.EncodeToString([]byte(strconv.FormatInt(items[n-1].ID, 10)))
	}
	a.write(w, 200, map[string]any{"items": items, "next_cursor": next})
}
func (a *API) membership(w http.ResponseWriter, r *http.Request) {
	id, e := pathID(r)
	if e != nil {
		a.fail(w, e)
		return
	}
	kind := "group"
	if strings.Contains(r.URL.Path, "threads") {
		kind = "thread"
	}
	e = a.Social.Membership(r.Context(), who(r).UID, kind, id, r.Method == http.MethodPost)
	if e != nil {
		a.fail(w, e)
		return
	}
	a.write(w, 204, nil)
}
func (a *API) relation(w http.ResponseWriter, r *http.Request) {
	id, e := pathID(r)
	if e != nil {
		a.fail(w, e)
		return
	}
	parts := strings.Split(r.URL.Path, "/")
	e = a.Social.Relation(r.Context(), who(r).UID, parts[len(parts)-1], id, r.Method == http.MethodPut)
	if e != nil {
		a.fail(w, e)
		return
	}
	a.write(w, 204, nil)
}
