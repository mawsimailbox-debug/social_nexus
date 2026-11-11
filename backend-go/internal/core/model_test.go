package core

import (
	"context"
	"testing"
)

func TestRequestID(t *testing.T) {
	if RequestID(context.Background()) != "" {
		t.Fatal("unexpected ID")
	}
	if RequestID(WithRequestID(context.Background(), "request-123")) != "request-123" {
		t.Fatal("request ID lost")
	}
}
