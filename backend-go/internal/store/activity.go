package store

import (
	"context"
	"database/sql"
	"nexus/backend-go/internal/core"
)

func (p *Postgres) Activities(ctx context.Context, uid, kind string, before int64, limit int) ([]core.Activity, error) {
	if limit < 1 || limit > 101 {
		return nil, core.ErrInvalid
	}
	if before == 0 {
		before = 9223372036854775807
	}
	var query string
	switch kind {
	case "notification":
		query = `SELECT id,actor_id,''::text,COALESCE(item_id,0),kind,''::text,0,read,created_at FROM notifications WHERE user_id=$1 AND id<$2 ORDER BY id DESC LIMIT $3`
	case "following":
		query = `SELECT id,follower_id,followed_id,0,'follow','',0,false,created_at FROM user_follows WHERE follower_id=$1 AND id<$2 ORDER BY id DESC LIMIT $3`
	case "cart":
		query = `SELECT c.id,c.user_id,''::text,c.product_id,'cart',i.name,c.quantity,false,c.created_at FROM cart_entries c JOIN items i ON i.id=c.product_id WHERE c.user_id=$1 AND c.id<$2 AND ` + visible + ` ORDER BY c.id DESC LIMIT $3`
	default:
		return nil, core.ErrInvalid
	}
	rows, e := p.DB.QueryContext(ctx, query, uid, before, limit)
	if e != nil {
		return nil, e
	}
	defer rows.Close()
	out := []core.Activity{}
	for rows.Next() {
		var a core.Activity
		if e = rows.Scan(&a.ID, &a.ActorID, &a.TargetID, &a.ItemID, &a.Kind, &a.Body, &a.Quantity, &a.Read, &a.CreatedAt); e != nil {
			return nil, e
		}
		out = append(out, a)
	}
	return out, rows.Err()
}
func (p *Postgres) FollowUser(ctx context.Context, uid, target string, on bool) error {
	if target == "" || len(target) > 128 || uid == target {
		return core.ErrInvalid
	}
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return e
	}
	defer tx.Rollback()
	var found string
	if e = tx.QueryRowContext(ctx, `SELECT id FROM users WHERE id=$1 AND email_verified FOR SHARE`, target).Scan(&found); e != nil {
		return mapErr(e)
	}
	if on {
		result, e := tx.ExecContext(ctx, `INSERT INTO user_follows(follower_id,followed_id) VALUES($1,$2) ON CONFLICT DO NOTHING`, uid, target)
		if e != nil {
			return mapErr(e)
		}
		n, e := result.RowsAffected()
		if e != nil {
			return e
		}
		if n > 0 {
			if _, e = tx.ExecContext(ctx, `INSERT INTO notifications(user_id,actor_id,kind) VALUES($1,$2,'follow')`, target, uid); e != nil {
				return e
			}
		}
	} else {
		if _, e = tx.ExecContext(ctx, `DELETE FROM user_follows WHERE follower_id=$1 AND followed_id=$2`, uid, target); e != nil {
			return e
		}
	}
	return tx.Commit()
}
func (p *Postgres) Share(ctx context.Context, uid string, id int64) (core.Activity, error) {
	var a core.Activity
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return a, e
	}
	defer tx.Rollback()
	var owner, visibility string
	// Sharing never exports private or nested-group content. No arbitrary recipient.
	e = tx.QueryRowContext(ctx, `SELECT i.author_id,i.visibility FROM items i WHERE i.id=$2 AND i.parent_id IS NULL AND i.kind IN ('post','shop','group') AND `+visible+` FOR SHARE`, uid, id).Scan(&owner, &visibility)
	if e != nil {
		return a, mapErr(e)
	}
	if visibility != "public" {
		return a, core.ErrForbidden
	}
	a = core.Activity{ActorID: uid, ItemID: id, Kind: "share"}
	e = tx.QueryRowContext(ctx, `INSERT INTO shares(user_id,item_id) VALUES($1,$2) ON CONFLICT(user_id,item_id) DO NOTHING RETURNING id,created_at`, uid, id).Scan(&a.ID, &a.CreatedAt)
	if e == sql.ErrNoRows {
		e = tx.QueryRowContext(ctx, `SELECT id,created_at FROM shares WHERE user_id=$1 AND item_id=$2`, uid, id).Scan(&a.ID, &a.CreatedAt)
	} else if e == nil && owner != uid {
		_, e = tx.ExecContext(ctx, `INSERT INTO notifications(user_id,actor_id,item_id,kind) VALUES($1,$2,$3,'share')`, owner, uid, id)
	}
	if e != nil {
		return a, e
	}
	return a, tx.Commit()
}
func (p *Postgres) Cart(ctx context.Context, uid string, id int64, quantity int) error {
	if quantity < 0 || quantity > 99 {
		return core.ErrInvalid
	}
	if quantity == 0 {
		_, e := p.DB.ExecContext(ctx, `DELETE FROM cart_entries WHERE user_id=$1 AND product_id=$2`, uid, id)
		return e
	}
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return e
	}
	defer tx.Rollback()
	var allowed bool
	e = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM items i WHERE i.id=$2 AND i.kind='product' AND `+visible+`)`, uid, id).Scan(&allowed)
	if e != nil {
		return e
	}
	if !allowed {
		return core.ErrNotFound
	}
	_, e = tx.ExecContext(ctx, `INSERT INTO cart_entries(user_id,product_id,quantity) VALUES($1,$2,$3) ON CONFLICT(user_id,product_id) DO UPDATE SET quantity=EXCLUDED.quantity`, uid, id, quantity)
	if e != nil {
		return mapErr(e)
	}
	return tx.Commit()
}
func (p *Postgres) ReadNotification(ctx context.Context, uid string, id int64) error {
	r, e := p.DB.ExecContext(ctx, `UPDATE notifications SET read=true WHERE id=$1 AND user_id=$2`, id, uid)
	if e != nil {
		return e
	}
	n, e := r.RowsAffected()
	if e != nil {
		return e
	}
	if n == 0 {
		return core.ErrNotFound
	}
	return nil
}

var _ core.ActivityStore = (*Postgres)(nil)
