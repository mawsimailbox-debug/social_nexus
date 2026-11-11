package store

import (
	"context"

	"strings"

	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/core"
)

const itemColumns = `i.id,i.kind,i.author_id,COALESCE(i.parent_id,0),i.name,i.body,i.visibility,i.price_minor,i.currency,i.created_at,i.metadata`

// Visibility propagates from group/thread parents, including comments on group posts.
const visible = `(i.visibility='public' OR i.author_id=$1 OR EXISTS(SELECT 1 FROM memberships m WHERE m.item_id=i.id AND m.user_id=$1)) AND (i.parent_id IS NULL OR EXISTS(SELECT 1 FROM items p WHERE p.id=i.parent_id AND (p.visibility='public' OR p.author_id=$1 OR EXISTS(SELECT 1 FROM memberships m WHERE m.item_id=p.id AND m.user_id=$1)) AND (p.parent_id IS NULL OR EXISTS(SELECT 1 FROM items gp WHERE gp.id=p.parent_id AND (gp.visibility='public' OR gp.author_id=$1 OR EXISTS(SELECT 1 FROM memberships m WHERE m.item_id=gp.id AND m.user_id=$1))))))`

type scanner interface{ Scan(...any) error }

func scanItem(row scanner) (core.Item, error) {
	var i core.Item
	e := row.Scan(&i.ID, &i.Kind, &i.AuthorID, &i.ParentID, &i.Name, &i.Body, &i.Visibility, &i.Price, &i.Currency, &i.CreatedAt, &i.Metadata)
	return i, mapErr(e)
}
func (p *Postgres) Profile(ctx context.Context, uid string, update *core.ProfilePatch) (core.User, error) {
	if update != nil {
		if (update.Name != nil && len(*update.Name) > 120) || (update.Bio != nil && len(*update.Bio) > 1000) {
			return core.User{}, core.ErrInvalid
		}
		if _, e := p.DB.ExecContext(ctx, `UPDATE users SET name=COALESCE($1,name),bio=COALESCE($2,bio) WHERE id=$3`, update.Name, update.Bio, uid); e != nil {
			return core.User{}, e
		}
	}
	var u core.User
	var ph, em []byte
	e := p.DB.QueryRowContext(ctx, `SELECT id,phone_cipher,email_cipher,email_verified,name,bio,metadata FROM users WHERE id=$1`, uid).Scan(&u.ID, &ph, &em, &u.Verified, &u.Name, &u.Bio, &u.Metadata)
	if e != nil {
		return u, mapErr(e)
	}
	// Profile owns PII; public discovery uses only names and IDs.
	u.Phone, e = auth.Open(p.EncryptionKey, ph)
	if e != nil {
		return u, e
	}
	u.Email, e = auth.Open(p.EncryptionKey, em)
	return u, e
}
func (p *Postgres) Get(ctx context.Context, uid, kind string, id int64) (core.Item, error) {
	return scanItem(p.DB.QueryRowContext(ctx, `SELECT `+itemColumns+` FROM items i WHERE i.id=$2 AND i.kind=$3 AND `+visible, uid, id, kind))
}
func (p *Postgres) List(ctx context.Context, q core.Query) ([]core.Item, error) {
	if q.Limit < 1 || q.Limit > 101 {
		return nil, core.ErrInvalid
	}
	if q.Before == 0 {
		q.Before = 9223372036854775807
	}
	if q.Kind == "people" {
		return p.people(ctx, q)
	}
	if q.Kind == "member" {
		return p.members(ctx, q)
	}
	rows, e := p.DB.QueryContext(ctx, `SELECT `+itemColumns+` FROM items i WHERE `+visible+` AND i.kind=$2 AND i.id<$3 AND ($4::bigint=0 OR i.parent_id=$4) AND ($5='' OR i.name ILIKE '%'||$5||'%' OR i.body ILIKE '%'||$5||'%') ORDER BY i.id DESC LIMIT $6`, q.UserID, q.Kind, q.Before, q.ParentID, q.Search, q.Limit)
	if e != nil {
		return nil, e
	}
	defer rows.Close()
	out := []core.Item{}
	for rows.Next() {
		i, e := scanItem(rows)
		if e != nil {
			return nil, e
		}
		out = append(out, i)
	}
	return out, rows.Err()
}
func (p *Postgres) people(ctx context.Context, q core.Query) ([]core.Item, error) {
	// Public user IDs are represented by author_id; the immutable ordinal is pagination-only.
	rows, e := p.DB.QueryContext(ctx, `SELECT ordinal,id,name,bio,created_at FROM users WHERE email_verified AND ordinal<$1 AND ($2='' OR name ILIKE '%'||$2||'%') ORDER BY ordinal DESC LIMIT $3`, q.Before, q.Search, q.Limit)
	if e != nil {
		return nil, e
	}
	defer rows.Close()
	out := []core.Item{}
	for rows.Next() {
		i := core.Item{Kind: "person"}
		if e = rows.Scan(&i.ID, &i.AuthorID, &i.Name, &i.Body, &i.CreatedAt); e != nil {
			return nil, e
		}
		out = append(out, i)
	}
	return out, rows.Err()
}
func (p *Postgres) members(ctx context.Context, q core.Query) ([]core.Item, error) {
	var allowed bool
	e := p.DB.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM memberships WHERE item_id=$1 AND user_id=$2)`, q.ParentID, q.UserID).Scan(&allowed)
	if e != nil {
		return nil, e
	}
	if !allowed {
		return nil, core.ErrForbidden
	}
	rows, e := p.DB.QueryContext(ctx, `SELECT u.ordinal,u.id,u.name,u.created_at FROM users u JOIN memberships m ON m.user_id=u.id WHERE m.item_id=$1 AND u.ordinal<$2 ORDER BY u.ordinal DESC LIMIT $3`, q.ParentID, q.Before, q.Limit)
	if e != nil {
		return nil, e
	}
	defer rows.Close()
	out := []core.Item{}
	for rows.Next() {
		i := core.Item{Kind: "member"}
		if e = rows.Scan(&i.ID, &i.AuthorID, &i.Name, &i.CreatedAt); e != nil {
			return nil, e
		}
		out = append(out, i)
	}
	return out, rows.Err()
}
func (p *Postgres) Create(ctx context.Context, uid string, i core.Item, members []string) (core.Item, error) {
	if len(i.Body) > 5000 || len(i.Name) > 120 || i.Price < 0 {
		return i, core.ErrInvalid
	}
	if i.Visibility == "" {
		i.Visibility = "public"
	}
	if i.Visibility != "public" && i.Visibility != "private" {
		return i, core.ErrInvalid
	}
	if i.Kind != "post" && i.Kind != "comment" && i.Kind != "shop" && i.Kind != "product" && i.Kind != "group" && i.Kind != "thread" && i.Kind != "message" {
		return i, core.ErrInvalid
	}
	if (i.Kind == "post" || i.Kind == "comment" || i.Kind == "message") && strings.TrimSpace(i.Body) == "" {
		return i, core.ErrInvalid
	}
	if (i.Kind == "group" || i.Kind == "shop" || i.Kind == "product") && strings.TrimSpace(i.Name) == "" {
		return i, core.ErrInvalid
	}
	if i.Kind == "product" && (i.Currency != "MMK" && i.Currency != "USD") {
		return i, core.ErrInvalid
	}
	if (i.Kind == "group" || i.Kind == "shop" || i.Kind == "thread") && i.ParentID != 0 {
		return i, core.ErrInvalid
	}
	if (i.Kind == "comment" || i.Kind == "message" || i.Kind == "product") && i.ParentID == 0 {
		return i, core.ErrInvalid
	}
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return i, e
	}
	defer tx.Rollback()
	if i.ParentID != 0 {
		var kind, owner string
		if e = tx.QueryRowContext(ctx, `SELECT kind,author_id FROM items WHERE id=$1 FOR UPDATE`, i.ParentID).Scan(&kind, &owner); e != nil {
			return i, mapErr(e)
		}
		if (i.Kind == "post" && kind != "group") || (i.Kind == "comment" && kind != "post") || (i.Kind == "message" && kind != "thread") || (i.Kind == "product" && kind != "shop") {
			return i, core.ErrInvalid
		}
		if i.Kind == "product" && owner != uid {
			return i, core.ErrForbidden
		}
		if kind == "group" || kind == "thread" {
			var member bool
			e = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM memberships WHERE item_id=$1 AND user_id=$2)`, i.ParentID, uid).Scan(&member)
			if e != nil {
				return i, e
			}
			if !member {
				return i, core.ErrForbidden
			}
		}
		if i.Kind == "comment" {
			var allowed bool
			e = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM items i WHERE i.id=$2 AND `+visible+`)`, uid, i.ParentID).Scan(&allowed)
			if e != nil {
				return i, e
			}
			if !allowed {
				return i, core.ErrForbidden
			}
		}
	}
	if i.Kind == "thread" {
		i.Visibility = "private"
		if len(members) < 1 || len(members) > 49 {
			return i, core.ErrInvalid
		}
	} else if len(members) > 0 {
		return i, core.ErrInvalid
	}
	i.AuthorID = uid
	var parent any
	if i.ParentID != 0 {
		parent = i.ParentID
	}
	e = tx.QueryRowContext(ctx, `INSERT INTO items(kind,author_id,parent_id,name,body,visibility,price_minor,currency) VALUES($1,$2,$3,$4,$5,$6,$7,$8) RETURNING id,created_at`, i.Kind, uid, parent, i.Name, i.Body, i.Visibility, i.Price, i.Currency).Scan(&i.ID, &i.CreatedAt)
	if e != nil {
		return i, mapErr(e)
	}
	if i.Kind == "thread" || i.Kind == "group" {
		members = append(members, uid)
		for _, id := range members {
			if _, e = tx.ExecContext(ctx, `INSERT INTO memberships(item_id,user_id) VALUES($1,$2) ON CONFLICT DO NOTHING`, i.ID, id); e != nil {
				return i, mapErr(e)
			}
		}
	}
	return i, tx.Commit()
}
func (p *Postgres) Membership(ctx context.Context, uid, kind string, id int64, join bool) error {
	// Serialize with writers so a concurrent leave cannot authorize a later message.
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return e
	}
	defer tx.Rollback()
	var visibility, owner string
	if e = tx.QueryRowContext(ctx, `SELECT visibility,author_id FROM items WHERE id=$1 AND kind=$2 FOR UPDATE`, id, kind).Scan(&visibility, &owner); e != nil {
		return mapErr(e)
	}
	if join && (kind != "group" || visibility != "public") {
		return core.ErrForbidden
	}
	if !join && owner == uid {
		return core.ErrConflict
	}
	if join {
		_, e = tx.ExecContext(ctx, `INSERT INTO memberships(item_id,user_id) VALUES($1,$2) ON CONFLICT DO NOTHING`, id, uid)
	} else {
		_, e = tx.ExecContext(ctx, `DELETE FROM memberships WHERE item_id=$1 AND user_id=$2`, id, uid)
	}
	if e != nil {
		return e
	}
	return tx.Commit()
}
func (p *Postgres) Relation(ctx context.Context, uid, kind string, id int64, on bool) error {
	if kind != "like" && kind != "save" && kind != "follow" {
		return core.ErrInvalid
	}
	tx, e := p.DB.BeginTx(ctx, nil)
	if e != nil {
		return e
	}
	defer tx.Rollback()
	var actual string
	e = tx.QueryRowContext(ctx, `SELECT i.kind FROM items i WHERE i.id=$2 AND `+visible+` FOR SHARE`, uid, id).Scan(&actual)
	if e != nil {
		return mapErr(e)
	}
	if on {
		_, e = tx.ExecContext(ctx, `INSERT INTO relations(item_id,user_id,kind) VALUES($1,$2,$3) ON CONFLICT DO NOTHING`, id, uid, kind)
	} else {
		_, e = tx.ExecContext(ctx, `DELETE FROM relations WHERE item_id=$1 AND user_id=$2 AND kind=$3`, id, uid, kind)
	}
	if e != nil {
		return e
	}
	return tx.Commit()
}
func (p *Postgres) DeleteUser(ctx context.Context, uid string) error {
	_, e := p.DB.ExecContext(ctx, `DELETE FROM users WHERE id=$1`, uid)
	return e
}
