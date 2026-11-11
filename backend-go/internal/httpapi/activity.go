package httpapi

import (
	"encoding/base64"
	"net/http"
	"nexus/backend-go/internal/core"
	"strconv"
	"strings"
)

func (a *API) activity(w http.ResponseWriter, r *http.Request) {
	if a.Activity == nil {
		a.fail(w, core.ErrNotFound)
		return
	}
	uid := who(r).UID
	path := strings.TrimPrefix(r.URL.Path, "/api/v1/")
	if r.Method == http.MethodGet {
		kind := "notification"
		if path == "cart" {
			kind = "cart"
		}
		if strings.HasSuffix(path, "following") {
			kind = "following"
		}
		before, n, e := page(r)
		if e != nil {
			a.fail(w, e)
			return
		}
		items, e := a.Activity.Activities(r.Context(), uid, kind, before, n+1)
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
		return
	}
	if target := r.PathValue("user_id"); target != "" {
		e := a.Activity.FollowUser(r.Context(), uid, target, r.Method == http.MethodPut)
		if e != nil {
			a.fail(w, e)
			return
		}
		a.write(w, 204, nil)
		return
	}
	id, e := pathID(r)
	if e != nil {
		a.fail(w, e)
		return
	}
	switch {
	case strings.HasPrefix(path, "notifications/"):
		e = a.Activity.ReadNotification(r.Context(), uid, id)
	case strings.HasSuffix(path, "/shares"):
		v, err := a.Activity.Share(r.Context(), uid, id)
		if err != nil {
			a.fail(w, err)
			return
		}
		a.write(w, 200, v)
		return
	case strings.HasPrefix(path, "cart/"):
		quantity := 0
		if r.Method == http.MethodPut {
			var input struct {
				Quantity int `json:"quantity"`
			}
			if e = decode(w, r, &input); e != nil {
				a.fail(w, e)
				return
			}
			if input.Quantity < 1 || input.Quantity > 99 {
				a.fail(w, core.ErrInvalid)
				return
			}
			quantity = input.Quantity
		}
		e = a.Activity.Cart(r.Context(), uid, id, quantity)
	}
	if e != nil {
		a.fail(w, e)
		return
	}
	a.write(w, 204, nil)
}
