package email

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"nexus/backend-go/internal/core"
)

// SendGrid makes a real HTTPS delivery request. API errors never expose response PII.
type SendGrid struct {
	APIKey, From string
	Client       *http.Client
}

func (s *SendGrid) Send(ctx context.Context, to, code string) error {
	payload := map[string]any{"personalizations": []any{map[string]any{"to": []any{map[string]string{"email": to}}}}, "from": map[string]string{"email": s.From}, "subject": "Nexus email verification", "content": []any{map[string]string{"type": "text/plain", "value": "Your Nexus verification capability is:\n\n" + code + "\n\nExpires in 10 minutes. Paste the entire code into Nexus. Never share this code. If you did not request this, ignore this email."}}}
	b, e := json.Marshal(payload)
	if e != nil {
		return e
	}
	req, e := http.NewRequestWithContext(ctx, http.MethodPost, "https://api.sendgrid.com/v3/mail/send", bytes.NewReader(b))
	if e != nil {
		return e
	}
	req.Header.Set("Authorization", "Bearer "+s.APIKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Request-ID", core.RequestID(ctx))
	resp, e := s.Client.Do(req)
	if e != nil {
		return errors.New("email transport failed")
	}
	defer resp.Body.Close()
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
	if resp.StatusCode != http.StatusAccepted {
		return errors.New("email provider rejected request")
	}
	return nil
}
