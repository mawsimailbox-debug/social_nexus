package store

import (
	"context"
	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
	"sync"
	"time"
)

// Memory implements AuthStore for deterministic tests; never wired into cmd/api.
type Memory struct {
	mu         sync.Mutex
	Key        []byte
	users      map[string]core.User
	challenges map[string]core.Challenge
	sessions   map[string]core.Session
	previous   map[string]string
	limits     map[string]limit
}
type limit struct {
	count int
	reset time.Time
}

func NewMemory(key []byte) *Memory {
	return &Memory{Key: key, users: map[string]core.User{}, challenges: map[string]core.Challenge{}, sessions: map[string]core.Session{}, previous: map[string]string{}, limits: map[string]limit{}}
}
func (m *Memory) Register(_ context.Context, u core.User) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, v := range m.users {
		if v.Phone == u.Phone || v.Email == u.Email {
			return core.ErrConflict
		}
	}
	m.users[u.ID] = u
	return nil
}
func (m *Memory) ByPhone(_ context.Context, h string) (core.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, u := range m.users {
		if auth.Lookup(m.Key, "phone:"+u.Phone) == h {
			return u, nil
		}
	}
	return core.User{}, core.ErrNotFound
}
func (m *Memory) Limit(_ context.Context, key string, max int, d time.Duration, now time.Time) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	l := m.limits[key]
	if !now.Before(l.reset) {
		l = limit{reset: now.Add(d)}
	}
	l.count++
	m.limits[key] = l
	if l.count > max {
		return core.ErrLimited
	}
	return nil
}
func (m *Memory) IssueChallenge(_ context.Context, c core.Challenge, _ time.Time) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	for k, v := range m.challenges {
		if v.UserID == c.UserID {
			v.Used = true
			m.challenges[k] = v
		}
	}
	m.challenges[c.Selector] = c
	return nil
}
func (m *Memory) CancelChallenge(_ context.Context, key string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	v, ok := m.challenges[key]
	if ok {
		v.Used = true
		m.challenges[key] = v
	}
	return nil
}
func (m *Memory) Grant(_ context.Context, g core.Grant) (core.User, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	var u core.User
	switch g.Mode {
	case "device":
		for _, v := range m.users {
			if auth.Lookup(m.Key, "phone:"+v.Phone) == g.PhoneHash {
				u = v
				break
			}
		}
		if u.ID == "" || !u.Verified || !equal(u.DeviceHash, g.DeviceHash) {
			return u, core.ErrUnauthorized
		}
	case "otp":
		c, ok := m.challenges[g.Selector]
		if !ok || c.Used || !g.Now.Before(c.Expires) || c.Attempts >= 5 {
			return u, core.ErrUnauthorized
		}
		if !equal(c.Hash, g.CodeHash) {
			c.Attempts++
			m.challenges[g.Selector] = c
			return u, core.ErrUnauthorized
		}
		u = m.users[c.UserID]
		u.DeviceHash = g.DeviceHash
		u.Verified = true
		m.users[u.ID] = u
		for k, v := range m.challenges {
			if v.UserID == u.ID {
				v.Used = true
				m.challenges[k] = v
			}
		}
		for k, v := range m.sessions {
			if v.UserID == u.ID {
				v.Revoked = true
				m.sessions[k] = v
			}
		}
	case "refresh":
		v, ok := m.sessions[g.Selector]
		if !ok || v.Revoked || !g.Now.Before(v.Expires) {
			return u, core.ErrUnauthorized
		}
		if !equal(v.Hash, g.RefreshHash) {
			if equal(m.previous[v.ID], g.RefreshHash) {
				v.Revoked = true
				m.sessions[v.ID] = v
			}
			return u, core.ErrUnauthorized
		}
		u = m.users[v.UserID]
		m.previous[v.ID] = v.Hash
		v.Hash = g.Session.Hash
		m.sessions[v.ID] = v
		return u, nil
	default:
		return u, core.ErrInvalid
	}
	g.Session.UserID = u.ID
	m.sessions[g.Session.ID] = g.Session
	return u, nil
}
func (m *Memory) Active(_ context.Context, uid, sid string, now time.Time) (bool, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	s, ok := m.sessions[sid]
	return ok && s.UserID == uid && !s.Revoked && now.Before(s.Expires), nil
}
func (m *Memory) Revoke(_ context.Context, uid, sid string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	v, ok := m.sessions[sid]
	if ok && v.UserID == uid {
		v.Revoked = true
		m.sessions[sid] = v
	}
	return nil
}

var _ core.AuthStore = (*Memory)(nil)
var _ core.AuthStore = (*Postgres)(nil)
var _ core.SocialStore = (*Postgres)(nil)
