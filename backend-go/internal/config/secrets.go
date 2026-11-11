package config

import (
	"errors"
	"fmt"
	"io"
	"os"
	"strings"
)

// Secret supports Docker secrets without logging their contents. Conflicting
// sources fail closed rather than silently overriding operator configuration.
func Secret(name string) (string, error) {
	value, path := os.Getenv(name), os.Getenv(name+"_FILE")
	if value != "" && path != "" {
		return "", fmt.Errorf("%s: direct and file sources conflict", name)
	}
	if path == "" {
		return value, nil
	}
	f, e := os.Open(path)
	if e != nil {
		return "", fmt.Errorf("%s: secret file unavailable", name)
	}
	defer f.Close()
	b, e := io.ReadAll(io.LimitReader(f, 8193))
	if e != nil || len(b) == 0 || len(b) > 8192 {
		return "", fmt.Errorf("%s: invalid secret file", name)
	}
	value = strings.TrimSpace(string(b))
	if value == "" {
		return "", errors.New("empty secret file")
	}
	return value, nil
}
