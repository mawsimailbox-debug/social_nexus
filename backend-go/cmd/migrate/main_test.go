package main

import (
	"os"
	"testing"
)

func TestMigrationArguments(t *testing.T) {
	old := os.Args
	t.Cleanup(func() { os.Args = old })
	for _, a := range [][]string{{"migrate"}, {"migrate", "bad"}, {"migrate", "up", "extra"}} {
		os.Args = a
		if run() == nil {
			t.Fatal(a)
		}
	}
	os.Args = []string{"migrate", "up"}
	t.Setenv("NEXUS_DATABASE_URL", "")
	if run() == nil {
		t.Fatal("missing DSN")
	}
	t.Setenv("NEXUS_DATABASE_URL", "postgres://127.0.0.1:1/test?sslmode=disable")
	if run() == nil {
		t.Fatal("offline database accepted")
	}
}
