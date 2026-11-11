package auth

import (
	"context"
	"errors"
	"net/mail"
	"nexus/backend-go/internal/core"
	"regexp"
	"strings"
	"time"
)

type Service struct {
	Store     core.AuthStore
	Mail      core.EmailSender
	Tokens    Tokens
	LookupKey []byte
	Now       func() time.Time
}
type Pair struct {
	JWT     string `json:"jwt"`
	Refresh string `json:"refresh"`
}

var phoneRE = regexp.MustCompile(`^\+[1-9][0-9]{7,14}$`)
var deviceRE = regexp.MustCompile(`^[A-Za-z0-9_-]{16,128}$`)

func ValidPhone(p string) bool  { return phoneRE.MatchString(p) }
func ValidDevice(d string) bool { return deviceRE.MatchString(d) }
func NormalizeEmail(e string) (string, error) {
	e = strings.ToLower(strings.TrimSpace(e))
	a, err := mail.ParseAddress(e)
	if err != nil || a.Address != e || len(e) > 254 || !strings.Contains(e, ".") {
		return "", core.ErrInvalid
	}
	return e, nil
}
func (s *Service) Register(ctx context.Context, p, d, e string) error {
	e, err := NormalizeEmail(e)
	if err != nil || !ValidPhone(p) || !ValidDevice(d) {
		return core.ErrInvalid
	}
	// Pending registration reserves contact uniqueness but does not bind a device.
	// Only possession of the email capability may establish the installation secret.
	return s.Store.Register(ctx, core.User{ID: Random(18), Phone: p, Email: e})
}
func (s *Service) grant(ctx context.Context, g core.Grant) (Pair, error) {
	refresh := Random(32)
	g.Session = core.Session{ID: Random(18), Hash: Digest(refresh), Expires: s.Now().Add(30 * 24 * time.Hour)}
	g.Now = s.Now()
	u, err := s.Store.Grant(ctx, g)
	if err != nil {
		return Pair{}, err
	}
	// Rotation keeps its existing session ID; stores return it through g's mode-independent lookup below.
	sid := g.Session.ID
	if g.Mode == "refresh" {
		sid = g.Selector
	}
	return Pair{s.Tokens.Sign(u.ID, sid), refresh}, nil
}
func (s *Service) DeviceLogin(ctx context.Context, p, d string) (Pair, error) {
	if !ValidPhone(p) || !ValidDevice(d) {
		return Pair{}, core.ErrInvalid
	}
	return s.grant(ctx, core.Grant{Mode: "device", PhoneHash: Lookup(s.LookupKey, "phone:"+p), DeviceHash: Lookup(s.LookupKey, "device:"+d)})
}
func (s *Service) EmailVerify(ctx context.Context, p, e string) error {
	e, err := NormalizeEmail(e)
	if err != nil || !ValidPhone(p) {
		return core.ErrInvalid
	}
	// Reserve the same persistent limiter even for unknown/mismatched identities.
	if err = s.Store.Limit(ctx, "email:"+Lookup(s.LookupKey, p), 1, time.Minute, s.Now()); err != nil {
		return err
	}
	u, err := s.Store.ByPhone(ctx, Lookup(s.LookupKey, "phone:"+p))
	if errors.Is(err, core.ErrNotFound) {
		return nil
	}
	if err != nil {
		return err
	}
	if !strings.EqualFold(u.Email, e) {
		return nil
	}
	selector := Random(16)
	code := selector + "." + Random(32)
	c := core.Challenge{Selector: Digest(selector), Hash: Digest(code), UserID: u.ID, Expires: s.Now().Add(10 * time.Minute)}
	if err = s.Store.IssueChallenge(ctx, c, s.Now()); err != nil {
		return err
	}
	if err = s.Mail.Send(ctx, u.Email, code); err != nil {
		cancelCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 2*time.Second)
		defer cancel()
		_ = s.Store.CancelChallenge(cancelCtx, c.Selector)
		return errors.New("email delivery unavailable")
	}
	return nil
}
func (s *Service) Confirm(ctx context.Context, otp, d string) (Pair, error) {
	if !ValidDevice(d) {
		return Pair{}, core.ErrInvalid
	}
	parts := strings.Split(otp, ".")
	if len(parts) != 2 || len(parts[0]) != 22 || len(parts[1]) != 43 {
		return Pair{}, core.ErrUnauthorized
	}
	return s.grant(ctx, core.Grant{Mode: "otp", Selector: Digest(parts[0]), CodeHash: Digest(otp), DeviceHash: Lookup(s.LookupKey, "device:"+d)})
}
func (s *Service) Refresh(ctx context.Context, token string) (Pair, error) {
	// Refresh capability is session-id.random-secret so lookup never scans all sessions.
	parts := strings.Split(token, ".")
	if len(parts) != 2 || len(parts[0]) != 24 || len(parts[1]) != 43 {
		return Pair{}, core.ErrUnauthorized
	}
	return s.grant(ctx, core.Grant{Mode: "refresh", Selector: parts[0], RefreshHash: Digest(parts[1])})
}

// ExternalRefresh adds the nonsecret selector without changing the hashed secret.
func ExternalRefresh(p Pair, t Tokens) Pair {
	c, e := t.Verify(p.JWT)
	if e == nil {
		p.Refresh = c.Session + "." + p.Refresh
	}
	return p
}
func (s *Service) Authenticate(ctx context.Context, raw string) (core.User, string, error) {
	c, e := s.Tokens.Verify(raw)
	if e != nil {
		return core.User{}, "", core.ErrUnauthorized
	}
	ok, e := s.Store.Active(ctx, c.Subject, c.Session, s.Now())
	if e != nil {
		return core.User{}, "", e
	}
	if !ok {
		return core.User{}, "", core.ErrUnauthorized
	}
	return core.User{ID: c.Subject}, c.Session, nil
}
