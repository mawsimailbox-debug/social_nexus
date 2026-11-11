package auth

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"strings"
	"time"
)

// entropy is swappable so failure handling stays testable.
var entropy = rand.Read

func Random(n int) string {
	b := make([]byte, n)
	if _, err := entropy(b); err != nil {
		panic("operating system entropy unavailable")
	}
	return base64.RawURLEncoding.EncodeToString(b)
}
func Digest(s string) string { h := sha256.Sum256([]byte(s)); return hex.EncodeToString(h[:]) }
func Lookup(key []byte, s string) string {
	h := hmac.New(sha256.New, key)
	h.Write([]byte(s))
	return hex.EncodeToString(h.Sum(nil))
}
func Seal(key []byte, plain string) ([]byte, error) {
	b, e := aes.NewCipher(key)
	if e != nil {
		return nil, e
	}
	// AES block sizes are always valid, so NewGCM cannot fail here.
	a, _ := cipher.NewGCM(b)
	nonce := make([]byte, a.NonceSize())
	if _, e = entropy(nonce); e != nil {
		return nil, e
	}
	return a.Seal(nonce, nonce, []byte(plain), []byte("nexus-pii-v1")), nil
}
func Open(key, encrypted []byte) (string, error) {
	b, e := aes.NewCipher(key)
	if e != nil {
		return "", e
	}
	// AES block sizes are always valid, so NewGCM cannot fail here.
	a, _ := cipher.NewGCM(b)
	if len(encrypted) < a.NonceSize() {
		return "", errors.New("invalid ciphertext")
	}
	p, e := a.Open(nil, encrypted[:a.NonceSize()], encrypted[a.NonceSize():], []byte("nexus-pii-v1"))
	return string(p), e
}

type Claims struct {
	Subject  string `json:"sub"`
	Session  string `json:"sid"`
	Issuer   string `json:"iss"`
	Audience string `json:"aud"`
	Expiry   int64  `json:"exp"`
	Issued   int64  `json:"iat"`
}
type Tokens struct {
	Key []byte
	Now func() time.Time
}

func (t Tokens) Sign(uid, sid string) string {
	c := Claims{uid, sid, "nexus", "nexus-app", t.Now().Add(15 * time.Minute).Unix(), t.Now().Unix()}
	b, _ := json.Marshal(c)
	s := base64.RawURLEncoding.EncodeToString([]byte(`{"alg":"HS256","typ":"JWT"}`)) + "." + base64.RawURLEncoding.EncodeToString(b)
	h := hmac.New(sha256.New, t.Key)
	h.Write([]byte(s))
	return s + "." + base64.RawURLEncoding.EncodeToString(h.Sum(nil))
}
func (t Tokens) Verify(token string) (Claims, error) {
	var c Claims
	p := strings.Split(token, ".")
	if len(p) != 3 || len(token) > 2048 {
		return c, errors.New("invalid token")
	}
	head, e := base64.RawURLEncoding.DecodeString(p[0])
	if e != nil || string(head) != `{"alg":"HS256","typ":"JWT"}` {
		return c, errors.New("invalid algorithm")
	}
	sig, e := base64.RawURLEncoding.DecodeString(p[2])
	if e != nil {
		return c, e
	}
	h := hmac.New(sha256.New, t.Key)
	h.Write([]byte(p[0] + "." + p[1]))
	if !hmac.Equal(sig, h.Sum(nil)) {
		return c, errors.New("invalid signature")
	}
	b, e := base64.RawURLEncoding.DecodeString(p[1])
	if e != nil {
		return c, e
	}
	if e = json.Unmarshal(b, &c); e != nil {
		return c, e
	}
	now := t.Now().Unix()
	if c.Subject == "" || c.Session == "" || c.Issuer != "nexus" || c.Audience != "nexus-app" || c.Expiry <= now || c.Issued > now+30 || c.Expiry-c.Issued > 900 {
		return Claims{}, errors.New("invalid claims")
	}
	return c, nil
}
