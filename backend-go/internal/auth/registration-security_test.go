package auth_test

import (
	"context"
	"errors"
	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
	"testing"
)

func TestRegistrationCannotReplaceExistingRecoveryIdentity(t *testing.T) {
	s, m, _ := setup(t)
	ctx := context.Background()
	original := verified(t, s, m)
	if e := s.Register(ctx, phone, nextDevice, "attacker@example.com"); !errors.Is(e, core.ErrConflict) {
		t.Fatal("existing phone replaced", e)
	}
	u, e := s.Store.ByPhone(ctx, auth.Lookup(s.LookupKey, "phone:"+phone))
	if e != nil || u.Email != "owner@example.com" || !u.Verified {
		t.Fatal("recovery identity modified", u, e)
	}
	if _, _, e = s.Authenticate(ctx, original.JWT); e != nil {
		t.Fatal("registration revoked existing account", e)
	}
	if _, e = s.DeviceLogin(ctx, phone, nextDevice); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal("attacker device accepted", e)
	}
	if e = s.EmailVerify(ctx, phone, "attacker@example.com"); !errors.Is(e, core.ErrLimited) {
		t.Fatal("existing cooldown expected", e)
	}
}
func TestPendingRegistrationDoesNotBindDevice(t *testing.T) {
	s, _, _ := setup(t)
	registered(t, s)
	u, e := s.Store.ByPhone(context.Background(), auth.Lookup(s.LookupKey, "phone:"+phone))
	if e != nil || u.Verified || u.DeviceHash != "" {
		t.Fatal("pending identity acquired trusted device", u, e)
	}
	if _, e = s.DeviceLogin(context.Background(), phone, device); !errors.Is(e, core.ErrUnauthorized) {
		t.Fatal(e)
	}
}
