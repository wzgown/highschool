package v1

import (
	"net/http"
	"testing"
	"time"

	"highschool-backend/pkg/auth"
)

// TestAuthInterceptor_NoCookie 验证无 cookie 请求被拒。
func TestAuthInterceptor_NoCookie(t *testing.T) {
	// 确保 newAdminAuthInterceptor 也存在并能构造。
	ic := newAdminAuthInterceptor("k")
	if ic == nil {
		t.Fatal("newAdminAuthInterceptor returned nil")
	}
	if _, ok := checkAdminCookie("k", http.Header{}); ok {
		t.Fatal("missing cookie must fail")
	}
}

// TestAuthInterceptor_ValidCookie 验证合法 token 放行并返回 subject。
func TestAuthInterceptor_ValidCookie(t *testing.T) {
	tok := auth.SignSession("k", "admin", time.Now().Add(time.Hour))
	h := http.Header{}
	h.Set("Cookie", "admin_sess="+tok)
	if sub, ok := checkAdminCookie("k", h); !ok || sub != "admin" {
		t.Fatalf("valid cookie must pass: sub=%q ok=%v", sub, ok)
	}
}

// TestAuthInterceptor_BadCookie 验证篡改/垃圾 token 被拒。
func TestAuthInterceptor_BadCookie(t *testing.T) {
	h := http.Header{}
	h.Set("Cookie", "admin_sess=garbage")
	if _, ok := checkAdminCookie("k", h); ok {
		t.Fatal("garbage cookie must fail")
	}
}
