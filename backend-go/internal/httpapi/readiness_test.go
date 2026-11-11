package httpapi

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"nexus/backend-go/internal/core"
	"testing"
	"time"
)

func TestReadinessAndRequestContext(t *testing.T) {
	a, _ := fixture()
	for _, ready := range []bool{true, false} {
		a.Ready = func(ctx context.Context) error {
			if core.RequestID(ctx) == "" {
				t.Fatal("request ID not propagated")
			}
			deadline, ok := ctx.Deadline()
			if !ok || time.Until(deadline) > 2*time.Second {
				t.Fatal("readiness timeout missing")
			}
			if !ready {
				return errors.New("database offline")
			}
			return nil
		}
		w := request(a.Handler(), "GET", "/readyz", "", "")
		expected := 503
		if ready {
			expected = 200
		}
		if w.Code != expected {
			t.Fatal(w.Code, w.Body.String())
		}
	}
	checked := false
	h := a.middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		checked = true
		id := core.RequestID(r.Context())
		if id == "" || id != w.Header().Get("X-Request-ID") {
			t.Fatal("request ID not propagated")
		}
		deadline, ok := r.Context().Deadline()
		remaining := time.Until(deadline)
		if !ok || remaining > 10*time.Second || remaining < 9*time.Second {
			t.Fatal("request deadline", remaining)
		}
	}))
	h.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest("GET", "/healthz", nil))
	if !checked {
		t.Fatal("handler not reached")
	}
}
