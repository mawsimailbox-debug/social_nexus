package store

import (
	"context"
	"crypto/subtle"
	"database/sql"
	"errors"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
	_ "github.com/jackc/pgx/v5/stdlib"
	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
)

type Postgres struct {
	DB                       *sql.DB
	EncryptionKey, LookupKey []byte
}

func mapErr(err error) error {
	if errors.Is(err, sql.ErrNoRows) {
		return core.ErrNotFound
	}
	var pg *pgconn.PgError
	if errors.As(err, &pg) {
		if pg.Code == "23505" {
			return core.ErrConflict
		}
		if pg.Code == "23503" {
			return core.ErrNotFound
		}
	}
	return err
}
func equal(a, b string) bool { return subtle.ConstantTimeCompare([]byte(a), []byte(b)) == 1 }
func (p *Postgres) Register(ctx context.Context, u core.User) error {
	phone, e := auth.Seal(p.EncryptionKey, u.Phone)
	if e != nil {
		return e
	}
	email, e := auth.Seal(p.EncryptionKey, u.Email)
	if e != nil {
		return e
	}
	_, e = p.DB.ExecContext(ctx, `INSERT INTO users(id,phone_hash,email_hash,phone_cipher,email_cipher,device_hash) VALUES($1,$2,$3,$4,$5,$6)`, u.ID, auth.Lookup(p.LookupKey, "phone:"+u.Phone), auth.Lookup(p.LookupKey, "email:"+u.Email), phone, email, u.DeviceHash)
	return mapErr(e)
}
func (p *Postgres) ByPhone(ctx context.Context, h string) (core.User, error) {
	var u core.User
	var ph, em []byte
	e := p.DB.QueryRowContext(ctx, `SELECT id,phone_cipher,email_cipher,device_hash,email_verified,name,bio FROM users WHERE phone_hash=$1`, h).Scan(&u.ID, &ph, &em, &u.DeviceHash, &u.Verified, &u.Name, &u.Bio)
	if e != nil {
		return u, mapErr(e)
	}
	u.Phone, e = auth.Open(p.EncryptionKey, ph)
	if e != nil {
		return u, e
	}
	u.Email, e = auth.Open(p.EncryptionKey, em)
	return u, e
}
func (p *Postgres) Limit(ctx context.Context, key string, max int, window time.Duration, now time.Time) error {
	var count int
	e := p.DB.QueryRowContext(ctx, `INSERT INTO rate_limits(key,count,reset_at) VALUES($1,1,$2) ON CONFLICT(key) DO UPDATE SET count=CASE WHEN rate_limits.reset_at <= $3 THEN 1 ELSE rate_limits.count+1 END, reset_at=CASE WHEN rate_limits.reset_at <= $3 THEN $2 ELSE rate_limits.reset_at END RETURNING count`, key, now.Add(window), now).Scan(&count)
	if e != nil {
		return e
	}
	if count > max {
		return core.ErrLimited
	}
	return nil
}
func (p *Postgres) IssueChallenge(ctx context.Context, c core.Challenge, now time.Time) error {
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return e
	}
	defer tx.Rollback()
	var id string
	if e = tx.QueryRowContext(ctx, `SELECT id FROM users WHERE id=$1 FOR UPDATE`, c.UserID).Scan(&id); e != nil {
		return mapErr(e)
	}
	if _, e = tx.ExecContext(ctx, `UPDATE challenges SET used=true WHERE user_id=$1 AND NOT used`, c.UserID); e != nil {
		return e
	}
	if _, e = tx.ExecContext(ctx, `INSERT INTO challenges(selector,code_hash,user_id,expires_at) VALUES($1,$2,$3,$4)`, c.Selector, c.Hash, c.UserID, c.Expires); e != nil {
		return e
	}
	return tx.Commit()
}
func (p *Postgres) CancelChallenge(ctx context.Context, selector string) error {
	_, e := p.DB.ExecContext(ctx, `UPDATE challenges SET used=true WHERE selector=$1`, selector)
	return e
}
func (p *Postgres) Grant(ctx context.Context, g core.Grant) (core.User, error) {
	var u core.User
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return u, e
	}
	defer tx.Rollback()
	var uid string
	switch g.Mode {
	case "device":
		e = tx.QueryRowContext(ctx, `SELECT id FROM users WHERE phone_hash=$1`, g.PhoneHash).Scan(&uid)
	case "otp":
		e = tx.QueryRowContext(ctx, `SELECT user_id FROM challenges WHERE selector=$1`, g.Selector).Scan(&uid)
	case "refresh":
		e = tx.QueryRowContext(ctx, `SELECT user_id FROM sessions WHERE id=$1`, g.Selector).Scan(&uid)
	default:
		return u, core.ErrInvalid
	}
	if errors.Is(e, sql.ErrNoRows) {
		return u, core.ErrUnauthorized
	}
	if e != nil {
		return u, e
	}
	e = tx.QueryRowContext(ctx, `SELECT id,device_hash,email_verified FROM users WHERE id=$1 FOR UPDATE`, uid).Scan(&u.ID, &u.DeviceHash, &u.Verified)
	if e != nil {
		return u, mapErr(e)
	}
	switch g.Mode {
	case "device":
		if !u.Verified || !equal(u.DeviceHash, g.DeviceHash) {
			return u, core.ErrUnauthorized
		}
	case "otp":
		var c core.Challenge
		e = tx.QueryRowContext(ctx, `SELECT code_hash,expires_at,attempts,used FROM challenges WHERE selector=$1 FOR UPDATE`, g.Selector).Scan(&c.Hash, &c.Expires, &c.Attempts, &c.Used)
		if e != nil {
			return u, mapErr(e)
		}
		if c.Used || !g.Now.Before(c.Expires) || c.Attempts >= 5 {
			return u, core.ErrUnauthorized
		}
		if !equal(c.Hash, g.CodeHash) {
			if _, e = tx.ExecContext(ctx, `UPDATE challenges SET attempts=attempts+1 WHERE selector=$1`, g.Selector); e != nil {
				return u, e
			}
			if e = tx.Commit(); e != nil {
				return u, e
			}
			return u, core.ErrUnauthorized
		}
		if _, e = tx.ExecContext(ctx, `UPDATE challenges SET used=true WHERE user_id=$1`, uid); e != nil {
			return u, e
		}
		if _, e = tx.ExecContext(ctx, `UPDATE users SET device_hash=$1,email_verified=true WHERE id=$2`, g.DeviceHash, uid); e != nil {
			return u, e
		}
		if _, e = tx.ExecContext(ctx, `UPDATE sessions SET revoked=true WHERE user_id=$1`, uid); e != nil {
			return u, e
		}
		u.Verified = true
	case "refresh":
		var hash, previous string
		var expires time.Time
		var revoked bool
		e = tx.QueryRowContext(ctx, `SELECT refresh_hash,previous_hash,expires_at,revoked FROM sessions WHERE id=$1 FOR UPDATE`, g.Selector).Scan(&hash, &previous, &expires, &revoked)
		if e != nil {
			return u, mapErr(e)
		}
		if revoked || !g.Now.Before(expires) {
			return u, core.ErrUnauthorized
		}
		if !equal(hash, g.RefreshHash) {
			// Reuse of the immediately previous rotated token revokes its token family.
			if equal(previous, g.RefreshHash) {
				if _, e = tx.ExecContext(ctx, `UPDATE sessions SET revoked=true WHERE id=$1`, g.Selector); e != nil {
					return u, e
				}
				if e = tx.Commit(); e != nil {
					return u, e
				}
			}
			return u, core.ErrUnauthorized
		}
		_, e = tx.ExecContext(ctx, `UPDATE sessions SET previous_hash=refresh_hash,refresh_hash=$1 WHERE id=$2`, g.Session.Hash, g.Selector)
		if e != nil {
			return u, e
		}
		return u, tx.Commit()
	}
	_, e = tx.ExecContext(ctx, `INSERT INTO sessions(id,user_id,refresh_hash,expires_at) VALUES($1,$2,$3,$4)`, g.Session.ID, uid, g.Session.Hash, g.Session.Expires)
	if e != nil {
		return u, e
	}
	return u, tx.Commit()
}
func (p *Postgres) Active(ctx context.Context, uid, sid string, now time.Time) (bool, error) {
	var ok bool
	e := p.DB.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM sessions WHERE id=$1 AND user_id=$2 AND NOT revoked AND expires_at>$3)`, sid, uid, now).Scan(&ok)
	return ok, e
}
func (p *Postgres) Revoke(ctx context.Context, uid, sid string) error {
	_, e := p.DB.ExecContext(ctx, `UPDATE sessions SET revoked=true WHERE id=$1 AND user_id=$2`, sid, uid)
	return e
}
