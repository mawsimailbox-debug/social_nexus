package auth_test

import (
	"context"
	"errors"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
	"nexus/backend-go/internal/store"
)

type mailbox struct {
	mu   sync.Mutex
	code string
	fail bool
}

func (m *mailbox) Send(_ context.Context, _ string, code string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.code = code
	if m.fail {
		return errors.New("provider unavailable")
	}
	return nil
}
func setup(t *testing.T) (*auth.Service, *mailbox, *time.Time) {
	t.Helper()
	now := time.Date(2026, 11, 9, 12, 0, 0, 0, time.UTC)
	key := []byte(strings.Repeat("l", 32))
	m := &mailbox{}
	s := &auth.Service{Store: store.NewMemory(key), Mail: m, Tokens: auth.Tokens{Key: []byte(strings.Repeat("j", 32)), Now: func() time.Time { return now }}, LookupKey: key, Now: func() time.Time { return now }}
	return s, m, &now
}

const phone = "+959123456789"
const device = "original-device-0123456789"
const nextDevice = "replacement-device-012345"

func registered(t *testing.T, s *auth.Service) {
	t.Helper()
	if e := s.Register(context.Background(), phone, device, "owner@example.com"); e != nil {
		t.Fatal(e)
	}
}
func verified(t *testing.T, s *auth.Service, m *mailbox) auth.Pair {
	t.Helper()
	registered(t, s)
	if e := s.EmailVerify(context.Background(), phone, "owner@example.com"); e != nil {
		t.Fatal(e)
	}
	p, e := s.Confirm(context.Background(), m.code, device)
	if e != nil {
		t.Fatal(e)
	}
	return auth.ExternalRefresh(p, s.Tokens)
}
func TestRecoveryAndRotation(t *testing.T) {
	s, m, _ := setup(t)
	ctx := context.Background()
	p := verified(t, s, m)
	if _, _, e := s.Authenticate(ctx, p.JWT); e != nil {
		t.Fatal(e)
	}
	if _, e := s.DeviceLogin(ctx, phone, device); e != nil {
		t.Fatal(e)
	}
	if _, e := s.DeviceLogin(ctx, phone, nextDevice); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal(e)
	}
	rotated, e := s.Refresh(ctx, p.Refresh)
	if e != nil {
		t.Fatal(e)
	}
	rotated = auth.ExternalRefresh(rotated, s.Tokens)
	if rotated.Refresh == p.Refresh {
		t.Fatal("refresh not rotated")
	}
	if _, e = s.Refresh(ctx, p.Refresh); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("replay accepted", e)
	}
	if _, _, e = s.Authenticate(ctx, rotated.JWT); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("family not revoked", e)
	}
	if _, e = s.Refresh(ctx, rotated.Refresh); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("revoked refresh accepted", e)
	}
}
func TestRegistrationValidationAndUniqueness(t *testing.T) {
	for _, tc := range []struct{ p, d, e string }{{"123", device, "a@example.com"}, {phone, "short", "a@example.com"}, {phone, device, "not email"}, {phone, device, "Name <a@example.com>"}, {phone, device, ""}} {
		s, _, _ := setup(t)
		if !errors.Is(s.Register(context.Background(), tc.p, tc.d, tc.e), core.ErrInvalid) {
			t.Fatal(tc)
		}
	}
	s, _, _ := setup(t)
	registered(t, s)
	for _, tc := range []struct{ p, e string }{{phone, "other@example.com"}, {"+959987654321", "OWNER@EXAMPLE.COM"}} {
		if e := s.Register(context.Background(), tc.p, device, tc.e); !errors.Is(e, core.ErrConflict) {
			t.Fatal(e)
		}
	}
}
func TestUnknownUnverifiedAndMismatch(t *testing.T) {
	s, m, _ := setup(t)
	ctx := context.Background()
	if _, e := s.DeviceLogin(ctx, phone, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal(e)
	}
	registered(t, s)
	if _, e := s.DeviceLogin(ctx, phone, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal(e)
	}
	if e := s.EmailVerify(ctx, phone, "wrong@example.com"); e != nil {
		t.Fatal(e)
	}
	if m.code != "" {
		t.Fatal("email sent for mismatch")
	}
	if e := s.EmailVerify(ctx, "+959999999999", "owner@example.com"); e != nil {
		t.Fatal(e)
	}
	if _, e := s.DeviceLogin(ctx, "bad", device); !errors.Is(e, core.ErrInvalid) {
		t.Fatal(e)
	}
}
func TestOTPFailuresAndLockout(t *testing.T) {
	s, m, _ := setup(t)
	ctx := context.Background()
	registered(t, s)
	if e := s.EmailVerify(ctx, phone, "owner@example.com"); e != nil {
		t.Fatal(e)
	}
	for _, v := range []string{"", "123456", "x.y", strings.Repeat("x", 22) + "." + strings.Repeat("y", 43)} {
		if _, e := s.Confirm(ctx, v, device); !errors.Is(e, core.ErrUnauthorized) {
			t.Fatal(v, e)
		}
	}
	parts := strings.Split(m.code, ".")
	wrong := parts[0] + "." + strings.Repeat("x", 43)
	for i := 0; i < 5; i++ {
		if _, e := s.Confirm(ctx, wrong, device); !errors.Is(e, core.ErrUnauthorized) {
			t.Fatal(e)
		}
	}
	if _, e := s.Confirm(ctx, m.code, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("locked code accepted", e)
	}
	if _, e := s.Confirm(ctx, m.code, "bad"); !errors.Is(e, core.ErrInvalid) {
		t.Fatal(e)
	}
}
func TestExpiryResendAndUsed(t *testing.T) {
	s, m, now := setup(t)
	ctx := context.Background()
	registered(t, s)
	_ = s.EmailVerify(ctx, phone, "owner@example.com")
	first := m.code
	if e := s.EmailVerify(ctx, phone, "owner@example.com"); !errors.Is(e, core.ErrLimited) {
		t.Fatal(e)
	}
	*now = now.Add(time.Minute)
	if e := s.EmailVerify(ctx, phone, "owner@example.com"); e != nil {
		t.Fatal(e)
	}
	if _, e := s.Confirm(ctx, first, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("superseded code accepted")
	}
	*now = now.Add(10 * time.Minute)
	if _, e := s.Confirm(ctx, m.code, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("expired code accepted")
	}
	_ = s.EmailVerify(ctx, phone, "owner@example.com")
	if _, e := s.Confirm(ctx, m.code, nextDevice); e != nil {
		t.Fatal(e)
	}
	if _, e := s.Confirm(ctx, m.code, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("used code accepted")
	}
	if _, e := s.DeviceLogin(ctx, phone, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("old device accepted")
	}
	if _, e := s.DeviceLogin(ctx, phone, nextDevice); e != nil {
		t.Fatal(e)
	}
}
func TestDeliveryFailureInvalidatesCode(t *testing.T) {
	s, m, _ := setup(t)
	registered(t, s)
	m.fail = true
	if e := s.EmailVerify(context.Background(), phone, "owner@example.com"); e == nil {
		t.Fatal("expected send failure")
	}
	if _, e := s.Confirm(context.Background(), m.code, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("failed delivery code usable")
	}
}
func TestOTPConcurrentSingleWinner(t *testing.T) {
	s, m, _ := setup(t)
	ctx := context.Background()
	registered(t, s)
	_ = s.EmailVerify(ctx, phone, "owner@example.com")
	var wins atomic.Int32
	var wg sync.WaitGroup
	for i := 0; i < 40; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if _, e := s.Confirm(ctx, m.code, nextDevice); e == nil {
				wins.Add(1)
			}
		}()
	}
	wg.Wait()
	if wins.Load() != 1 {
		t.Fatal("wins", wins.Load())
	}
}
func TestRefreshConcurrentSingleWinner(t *testing.T) {
	s, m, _ := setup(t)
	p := verified(t, s, m)
	var wins atomic.Int32
	var wg sync.WaitGroup
	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if _, e := s.Refresh(context.Background(), p.Refresh); e == nil {
				wins.Add(1)
			}
		}()
	}
	wg.Wait()
	if wins.Load() != 1 {
		t.Fatal(wins.Load())
	}
}
func TestTokenExpiryLogoutAndMalformed(t *testing.T) {
	s, m, now := setup(t)
	ctx := context.Background()
	p := verified(t, s, m)
	u, sid, e := s.Authenticate(ctx, p.JWT)
	if e != nil {
		t.Fatal(e)
	}
	if e = s.Store.Revoke(ctx, u.ID, sid); e != nil {
		t.Fatal(e)
	}
	if _, _, e = s.Authenticate(ctx, p.JWT); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal(e)
	}
	for _, token := range []string{"", p.JWT + "x", "eyJhbGciOiJub25lIn0.e30.", strings.Repeat("x", 3000)} {
		if _, _, e = s.Authenticate(ctx, token); !errors.Is(e, core.ErrUnauthorized) {
			t.Fatal(token)
		}
	}
	*now = now.Add(16 * time.Minute)
	if _, e = s.Tokens.Verify(p.JWT); e == nil {
		t.Fatal("expired JWT accepted")
	}
	for _, r := range []string{"", "abc.def", strings.Repeat("a", 24) + "." + strings.Repeat("b", 43)} {
		if _, e = s.Refresh(ctx, r); !errors.Is(e, core.ErrUnauthorized) {
			t.Fatal(e)
		}
	}
}
func TestRateLimitConcurrent(t *testing.T) {
	s, _, _ := setup(t)
	var wins atomic.Int32
	var wg sync.WaitGroup
	for i := 0; i < 50; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if s.Store.Limit(context.Background(), "test", 1, time.Minute, s.Now()) == nil {
				wins.Add(1)
			}
		}()
	}
	wg.Wait()
	if wins.Load() != 1 {
		t.Fatal(wins.Load())
	}
}
func TestEncryption(t *testing.T) {
	key := []byte(strings.Repeat("k", 32))
	c, e := auth.Seal(key, "private@example.com")
	if e != nil {
		t.Fatal(e)
	}
	v, e := auth.Open(key, c)
	if e != nil || v != "private@example.com" {
		t.Fatal(v, e)
	}
	c[len(c)-1] ^= 1
	if _, e = auth.Open(key, c); e == nil {
		t.Fatal("tampered ciphertext accepted")
	}
	if _, e = auth.Open(key, []byte("short")); e == nil {
		t.Fatal("short ciphertext accepted")
	}
	if _, e = auth.Seal([]byte("bad"), "x"); e == nil {
		t.Fatal("bad key")
	}
}
