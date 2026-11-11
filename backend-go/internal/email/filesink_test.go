package email

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestFileSinkWritesVerificationMail(t *testing.T) {
	p := filepath.Join(t.TempDir(), "mail.log")
	s, err := NewFileSink(p)
	if err != nil {
		t.Fatalf("sink: %v", err)
	}
	if err := s.Send(context.Background(), "a@b.co", "sel.code"); err != nil {
		t.Fatalf("send: %v", err)
	}
	b, err := os.ReadFile(p)
	if err != nil {
		t.Fatalf("read: %v", err)
	}
	if !strings.Contains(string(b), "to=a@b.co") || !strings.Contains(string(b), "code=sel.code") {
		t.Fatalf("unexpected sink content: %s", b)
	}
	info, err := os.Stat(p)
	if err != nil || info.Mode().Perm() != 0o600 {
		t.Fatalf("sink permissions must be 0600, got %v (%v)", info.Mode().Perm(), err)
	}
}

func TestFileSinkRejectsRelativePath(t *testing.T) {
	if _, err := NewFileSink("mail.log"); err == nil {
		t.Fatal("relative sink path accepted")
	}
}
