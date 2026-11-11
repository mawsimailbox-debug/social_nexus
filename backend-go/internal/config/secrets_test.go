package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestSecretSources(t *testing.T) {
	const name = "NEXUS_TEST_SECRET"
	t.Setenv(name, "")
	t.Setenv(name+"_FILE", "")
	if v, e := Secret(name); e != nil || v != "" {
		t.Fatal(v, e)
	}
	t.Setenv(name, "direct")
	if v, e := Secret(name); e != nil || v != "direct" {
		t.Fatal(v, e)
	}
	path := filepath.Join(t.TempDir(), "secret")
	t.Setenv(name+"_FILE", path)
	if _, e := Secret(name); e == nil {
		t.Fatal("ambiguous secret accepted")
	}
	t.Setenv(name, "")
	if _, e := Secret(name); e == nil {
		t.Fatal("missing file accepted")
	}
	for _, v := range []string{"", "   ", strings.Repeat("x", 8193), "mounted-value\n"} {
		if e := os.WriteFile(path, []byte(v), 0600); e != nil {
			t.Fatal(e)
		}
		got, e := Secret(name)
		if v == "mounted-value\n" {
			if e != nil || got != "mounted-value" {
				t.Fatal(got, e)
			}
		} else if e == nil {
			t.Fatal("invalid secret accepted")
		}
	}
}
