package auth_test

import (
	"context"
	"errors"
	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
	"testing"
	"time"
)

type failedStore struct {
	core.AuthStore
	stage string
}

func (f failedStore) ByPhone(c context.Context, h string) (core.User, error) {
	if f.stage == "lookup" {
		return core.User{}, errors.New("offline")
	}
	return f.AuthStore.ByPhone(c, h)
}
func (f failedStore) IssueChallenge(c context.Context, v core.Challenge, t time.Time) error {
	if f.stage == "issue" {
		return errors.New("offline")
	}
	return f.AuthStore.IssueChallenge(c, v, t)
}
func (f failedStore) Active(context.Context, string, string, time.Time) (bool, error) {
	return false, errors.New("offline")
}
func TestFailClosedStoreErrors(t *testing.T) {
	for _, stage := range []string{"lookup", "issue"} {
		s, _, _ := setup(t)
		registered(t, s)
		s.Store = failedStore{s.Store, stage}
		if e := s.EmailVerify(context.Background(), phone, "owner@example.com"); e == nil {
			t.Fatal(stage)
		}
	}
	s, m, _ := setup(t)
	p := verified(t, s, m)
	s.Store = failedStore{s.Store, "active"}
	if _, _, e := s.Authenticate(context.Background(), p.JWT); e == nil {
		t.Fatal("store error authenticated")
	}
	s, _, _ = setup(t)
	if e := s.EmailVerify(context.Background(), "bad", "not email"); !errors.Is(e, core.ErrInvalid) {
		t.Fatal(e)
	}
	// An invalid token cannot be transformed into a selected refresh session.
	v := auth.ExternalRefresh(auth.Pair{JWT: "bad", Refresh: "secret"}, s.Tokens)
	if v.Refresh != "secret" {
		t.Fatal(v)
	}
}
