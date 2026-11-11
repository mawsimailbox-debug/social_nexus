package core

import (
	"context"
	"encoding/json"
	"errors"
	"time"
)

var (
	ErrUnauthorized = errors.New("unauthorized")
	ErrConflict     = errors.New("conflict")
	ErrLimited      = errors.New("rate_limited")
	ErrInvalid      = errors.New("invalid_input")
	ErrNotFound     = errors.New("not_found")
	ErrForbidden    = errors.New("forbidden")
)

type requestIDKey struct{}

func WithRequestID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, requestIDKey{}, id)
}
func RequestID(ctx context.Context) string { id, _ := ctx.Value(requestIDKey{}).(string); return id }

type User struct {
	ID         string          `json:"id"`
	Phone      string          `json:"phone_number,omitempty"`
	Email      string          `json:"email,omitempty"`
	DeviceHash string          `json:"-"`
	Verified   bool            `json:"email_verified"`
	Name       string          `json:"name"`
	Bio        string          `json:"bio"`
	Metadata   json.RawMessage `json:"metadata,omitempty"`
}
type Challenge struct {
	Selector, Hash, UserID string
	Expires                time.Time
	Attempts               int
	Used                   bool
}
type Session struct {
	ID, UserID, Hash string
	Expires          time.Time
	Revoked          bool
}
type Grant struct {
	Mode, PhoneHash, DeviceHash, Selector, CodeHash, RefreshHash string
	Session                                                      Session
	Now                                                          time.Time
}

// AuthStore operations that mutate identity and sessions MUST be atomic.
// SQLStore is the production implementation; MemoryStore is a race-safe test double.
type AuthStore interface {
	Register(context.Context, User) error
	ByPhone(context.Context, string) (User, error)
	IssueChallenge(context.Context, Challenge, time.Time) error
	CancelChallenge(context.Context, string) error
	Grant(context.Context, Grant) (User, error)
	Active(context.Context, string, string, time.Time) (bool, error)
	Revoke(context.Context, string, string) error
	Limit(context.Context, string, int, time.Duration, time.Time) error
}

type EmailSender interface {
	Send(context.Context, string, string) error
}

type Item struct {
	ID         int64           `json:"id"`
	Kind       string          `json:"kind"`
	AuthorID   string          `json:"author_id,omitempty"`
	ParentID   int64           `json:"parent_id,omitempty"`
	Name       string          `json:"name,omitempty"`
	Body       string          `json:"body,omitempty"`
	Visibility string          `json:"visibility,omitempty"`
	Price      int64           `json:"price_minor,omitempty"`
	Currency   string          `json:"currency,omitempty"`
	CreatedAt  time.Time       `json:"created_at"`
	Metadata   json.RawMessage `json:"metadata,omitempty"`
}
type Query struct {
	Kind, UserID, Search string
	ParentID, Before     int64
	Limit                int
}
type ProfilePatch struct {
	Name *string `json:"name,omitempty"`
	Bio  *string `json:"bio,omitempty"`
}
type Activity struct {
	ID        int64     `json:"id"`
	ActorID   string    `json:"actor_id,omitempty"`
	TargetID  string    `json:"target_id,omitempty"`
	ItemID    int64     `json:"item_id,omitempty"`
	Kind      string    `json:"kind"`
	Body      string    `json:"body,omitempty"`
	Quantity  int       `json:"quantity,omitempty"`
	Read      bool      `json:"read"`
	CreatedAt time.Time `json:"created_at"`
}
type ActivityStore interface {
	Activities(context.Context, string, string, int64, int) ([]Activity, error)
	FollowUser(context.Context, string, string, bool) error
	Share(context.Context, string, int64) (Activity, error)
	Cart(context.Context, string, int64, int) error
	ReadNotification(context.Context, string, int64) error
}
type SocialStore interface {
	Profile(context.Context, string, *ProfilePatch) (User, error)
	List(context.Context, Query) ([]Item, error)
	Get(context.Context, string, string, int64) (Item, error)
	Create(context.Context, string, Item, []string) (Item, error)
	Membership(context.Context, string, string, int64, bool) error
	Relation(context.Context, string, string, int64, bool) error
	DeleteUser(context.Context, string) error
}
