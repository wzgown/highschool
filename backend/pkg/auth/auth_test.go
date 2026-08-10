package auth

import (
	"testing"
	"time"
)

func TestVerifyPassword(t *testing.T) {
	hashed, err := HashPassword("s3cret")
	if err != nil {
		t.Fatalf("hash: %v", err)
	}
	if !VerifyPassword(hashed, "s3cret") {
		t.Fatal("correct password should verify")
	}
	if VerifyPassword(hashed, "wrong") {
		t.Fatal("wrong password should not verify")
	}
}

func TestSessionTokenRoundTrip(t *testing.T) {
	secret := "super-secret-key"
	exp := time.Now().Add(1 * time.Hour)
	token := SignSession(secret, "admin", exp)
	sub, ok := VerifySession(secret, token)
	if !ok || sub != "admin" {
		t.Fatalf("round-trip failed: sub=%q ok=%v", sub, ok)
	}
}

func TestSessionTokenRejectsTamper(t *testing.T) {
	secret := "super-secret-key"
	exp := time.Now().Add(1 * time.Hour)
	token := SignSession(secret, "admin", exp)
	// 篡改 payload
	tampered := token[:len(token)-2] + "XX"
	if _, ok := VerifySession(secret, tampered); ok {
		t.Fatal("tampered token must not verify")
	}
}

func TestSessionTokenRejectsExpired(t *testing.T) {
	secret := "super-secret-key"
	exp := time.Now().Add(-1 * time.Hour) // 已过期
	token := SignSession(secret, "admin", exp)
	if _, ok := VerifySession(secret, token); ok {
		t.Fatal("expired token must not verify")
	}
}

func TestSessionTokenRejectsWrongSecret(t *testing.T) {
	exp := time.Now().Add(1 * time.Hour)
	token := SignSession("secret-A", "admin", exp)
	if _, ok := VerifySession("secret-B", token); ok {
		t.Fatal("wrong-secret token must not verify")
	}
}

// TestSessionTokenDotSubjectRoundTrip 验证 subject 含 "." 时仍能正确还原。
// 回归：旧实现按首个 "." 切分会把 "a.b.<exp>" 拆成 sub="a"、expStr="b.<exp>"，解析失败。
func TestSessionTokenDotSubjectRoundTrip(t *testing.T) {
	secret := "super-secret-key"
	exp := time.Now().Add(1 * time.Hour)
	token := SignSession(secret, "a.b", exp)
	sub, ok := VerifySession(secret, token)
	if !ok || sub != "a.b" {
		t.Fatalf("dot subject round-trip failed: sub=%q ok=%v", sub, ok)
	}
}
