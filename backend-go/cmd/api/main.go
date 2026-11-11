package main

import (
	"context"
	"database/sql"
	"encoding/base64"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"nexus/backend-go/internal/auth"
	"nexus/backend-go/internal/config"
	"nexus/backend-go/internal/core"
	"nexus/backend-go/internal/email"
	"nexus/backend-go/internal/httpapi"
	"nexus/backend-go/internal/store"
)

func key(name string) ([]byte, error) {
	value, e := config.Secret(name)
	if e != nil {
		return nil, e
	}
	b, e := base64.StdEncoding.DecodeString(value)
	if e != nil || len(b) != 32 {
		return nil, fmt.Errorf("%s must encode exactly 32 random bytes", name)
	}
	return b, nil
}
func run() error {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	jwt, e := key("NEXUS_JWT_KEY")
	if e != nil {
		return e
	}
	enc, e := key("NEXUS_ENCRYPTION_KEY")
	if e != nil {
		return e
	}
	lookup, e := key("NEXUS_LOOKUP_KEY")
	if e != nil {
		return e
	}
	if string(jwt) == string(enc) || string(jwt) == string(lookup) || string(enc) == string(lookup) {
		return errors.New("cryptographic keys must be independent")
	}
	dsn, e := config.Secret("NEXUS_DATABASE_URL")
	if e != nil {
		return e
	}
	if dsn == "" {
		return errors.New("NEXUS_DATABASE_URL required")
	}
	if os.Getenv("NEXUS_ENV") != "development" && !strings.Contains(dsn, "sslmode=verify-full") {
		return errors.New("production database requires sslmode=verify-full")
	}
	apiKey, e := config.Secret("NEXUS_SENDGRID_API_KEY")
	if e != nil {
		return e
	}
	from := os.Getenv("NEXUS_EMAIL_FROM")
	sinkPath := os.Getenv("NEXUS_EMAIL_SINK_FILE")
	if sinkPath != "" && os.Getenv("NEXUS_ENV") != "development" {
		return errors.New("NEXUS_EMAIL_SINK_FILE is development-only")
	}
	if apiKey == "" && sinkPath == "" {
		return errors.New("NEXUS_SENDGRID_API_KEY required")
	}
	if _, e = auth.NormalizeEmail(from); e != nil {
		return errors.New("valid NEXUS_EMAIL_FROM required")
	}
	db, e := sql.Open("pgx", dsn)
	if e != nil {
		return e
	}
	defer db.Close()
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(30 * time.Minute)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	e = db.PingContext(ctx)
	cancel()
	if e != nil {
		return errors.New("database unavailable")
	}
	var exists bool
	if e = db.QueryRow(`SELECT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='items' AND column_name='metadata') AND to_regclass('public.notifications') IS NOT NULL`).Scan(&exists); e != nil || !exists {
		return errors.New("database migrations required")
	}
	pg := &store.Postgres{DB: db, EncryptionKey: enc, LookupKey: lookup}
	var sender core.EmailSender = &email.SendGrid{APIKey: apiKey, From: from, Client: &http.Client{Timeout: 5 * time.Second, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}}
	if sinkPath != "" {
		sink, err := email.NewFileSink(sinkPath)
		if err != nil {
			return err
		}
		sender = sink
	}
	svc := &auth.Service{Store: pg, Mail: sender, Tokens: auth.Tokens{Key: jwt, Now: time.Now}, LookupKey: lookup, Now: time.Now}
	api := &httpapi.API{Auth: svc, Social: pg, Activity: pg, Logger: logger, Ready: db.PingContext}
	addr := os.Getenv("NEXUS_ADDR")
	if addr == "" {
		addr = ":8080"
	}
	server := &http.Server{Addr: addr, Handler: api.Handler(), ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 10 * time.Second, WriteTimeout: 10 * time.Second, IdleTimeout: 60 * time.Second, MaxHeaderBytes: 16 << 10}
	stop, cancelStop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancelStop()
	done := make(chan error, 1)
	go func() { done <- server.ListenAndServe() }()
	logger.Info("api listening", "address", addr)
	select {
	case e = <-done:
		if errors.Is(e, http.ErrServerClosed) {
			return nil
		}
		return e
	case <-stop.Done():
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		return server.Shutdown(ctx)
	}
}
func main() {
	if e := run(); e != nil {
		slog.Error("startup failed", "error", e)
		os.Exit(1)
	}
}
