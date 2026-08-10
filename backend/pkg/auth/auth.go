// Package auth 管理后台鉴权：bcrypt 密码校验 + HMAC 签名会话 cookie。
package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"strconv"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// HashPassword 生成 bcrypt 哈希（用于生成初始管理员密码哈希）。
func HashPassword(plain string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	return string(b), err
}

// VerifyPassword 校验明文密码与 bcrypt 哈希是否匹配。
func VerifyPassword(hashed, plain string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hashed), []byte(plain)) == nil
}

// SignSession 生成会话 token：base64(subject.expUnix).base64(hmac)。
func SignSession(secret, subject string, exp time.Time) string {
	payload := subject + "." + strconv.FormatInt(exp.Unix(), 10)
	enc := base64.RawURLEncoding.EncodeToString([]byte(payload))
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(enc))
	sig := base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
	return enc + "." + sig
}

// VerifySession 校验 token 签名与有效期，返回 subject。
func VerifySession(secret, token string) (string, bool) {
	enc, sig, ok := strings.Cut(token, ".")
	if !ok {
		return "", false
	}
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(enc))
	want := base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
	if !hmac.Equal([]byte(sig), []byte(want)) {
		return "", false
	}
	raw, err := base64.RawURLEncoding.DecodeString(enc)
	if err != nil {
		return "", false
	}
	// payload 形如 "<subject>.<expUnix>"。按 LAST "." 切分：subject 自身可能含 "."
	// （例如 "a.b"），按首个 "." 切会让 expiry 解析拿到 "b.<expUnix>" 从而失败。
	// expiry 是末段，因此 LastIndex 正确切分 subject 与 expiry。
	payload := string(raw)
	idx := strings.LastIndex(payload, ".")
	if idx < 0 {
		return "", false
	}
	sub := payload[:idx]
	expStr := payload[idx+1:]
	expUnix, err := strconv.ParseInt(expStr, 10, 64)
	if err != nil {
		return "", false
	}
	if time.Now().Unix() > expUnix {
		return "", false
	}
	return sub, true
}
