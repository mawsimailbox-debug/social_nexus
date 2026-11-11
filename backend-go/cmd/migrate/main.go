package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	_ "github.com/jackc/pgx/v5/stdlib"
	"nexus/backend-go/internal/config"
	"os"
	"time"
)

// All pending up migrations or all applied down migrations in one transaction.
func run() error {
	if len(os.Args) != 2 || (os.Args[1] != "up" && os.Args[1] != "down") {
		return errors.New("usage: migrate up|down (working directory backend-go)")
	}
	dsn, e := config.Secret("NEXUS_DATABASE_URL")
	if e != nil {
		return e
	}
	if dsn == "" {
		return errors.New("NEXUS_DATABASE_URL required")
	}
	db, e := sql.Open("pgx", dsn)
	if e != nil {
		return e
	}
	defer db.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	tx, e := db.BeginTx(ctx, nil)
	if e != nil {
		return e
	}
	defer tx.Rollback()
	if _, e = tx.ExecContext(ctx, `SELECT pg_advisory_xact_lock(73489612)`); e != nil {
		return e
	}
	if _, e = tx.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS schema_migrations(version bigint PRIMARY KEY)`); e != nil {
		return e
	}
	versions := []int{1, 2, 3}
	names := map[int]string{1: "init", 2: "activity", 3: "source_metadata"}
	up := os.Args[1] == "up"
	if !up {
		versions = []int{3, 2, 1}
	}
	for _, version := range versions {
		var applied bool
		if e = tx.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE version=$1)`, version).Scan(&applied); e != nil {
			return e
		}
		if up == applied {
			continue
		}
		b, e := os.ReadFile(fmt.Sprintf("migrations/%06d_%s.%s.sql", version, names[version], os.Args[1]))
		if e != nil {
			return e
		}
		if _, e = tx.ExecContext(ctx, string(b)); e != nil {
			return e
		}
		if up {
			_, e = tx.ExecContext(ctx, `INSERT INTO schema_migrations(version) VALUES($1)`, version)
		} else {
			_, e = tx.ExecContext(ctx, `DELETE FROM schema_migrations WHERE version=$1`, version)
		}
		if e != nil {
			return e
		}
	}
	return tx.Commit()
}
func main() {
	if e := run(); e != nil {
		fmt.Fprintln(os.Stderr, e)
		os.Exit(1)
	}
}
