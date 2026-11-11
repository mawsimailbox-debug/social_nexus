package email

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"

	"nexus/backend-go/internal/core"
)

// FileSink writes verification mail to a local file instead of a provider.
// It exists only for local end-to-end rehearsal; main refuses to build it
// unless NEXUS_ENV=development, so production cannot silently drop mail.
type FileSink struct {
	Path string
}

func NewFileSink(path string) (*FileSink, error) {
	if path == "" || !filepath.IsAbs(path) {
		return nil, errors.New("email sink path must be absolute")
	}
	return &FileSink{Path: path}, nil
}

func (f *FileSink) Send(ctx context.Context, to, code string) error {
	h, err := os.OpenFile(f.Path, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o600)
	if err != nil {
		return errors.New("email sink unavailable")
	}
	defer h.Close()
	if _, err = fmt.Fprintf(h, "to=%s code=%s request_id=%s\n", to, code, core.RequestID(ctx)); err != nil {
		return errors.New("email sink write failed")
	}
	return nil
}
