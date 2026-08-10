package v1

import (
	"context"
	"net/http"
	"testing"
	"time"

	"connectrpc.com/connect"
	highschoolv1 "highschool-backend/gen/highschool/v1"
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

// TestAuthInterceptor_WrapUnary_RejectNoCookie 验证 WrapUnary 的拒绝接线：
// 无有效 cookie 时调用包装后的 UnaryFunc 返回 CodeUnauthenticated，
// 且下游 next 永不被调用（拒绝而非穿透）。
func TestAuthInterceptor_WrapUnary_RejectNoCookie(t *testing.T) {
	ic := newAdminAuthInterceptor("test-secret")

	var called bool
	sentinel := connect.UnaryFunc(func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		called = true
		return nil, nil
	})
	wrapped := ic.WrapUnary(sentinel)

	req := connect.NewRequest(&highschoolv1.GetDistrictsRequest{})
	_, err := wrapped(context.Background(), req)

	if called {
		t.Fatal("downstream handler must NOT be invoked on reject")
	}
	if got := connect.CodeOf(err); got != connect.CodeUnauthenticated {
		t.Fatalf("expected CodeUnauthenticated, got %v (err=%v)", got, err)
	}
}

// TestAuthInterceptor_WrapUnary_AllowValidCookie 验证 WrapUnary 的放行接线：
// 携带合法 admin_sess cookie 时调用包装后的 UnaryFunc 不返回 Unauthenticated，
// 且下游 next 确实被调用。
func TestAuthInterceptor_WrapUnary_AllowValidCookie(t *testing.T) {
	ic := newAdminAuthInterceptor("test-secret")

	var called bool
	sentinel := connect.UnaryFunc(func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		called = true
		return nil, nil
	})
	wrapped := ic.WrapUnary(sentinel)

	tok := auth.SignSession("test-secret", "admin", time.Now().Add(time.Hour))
	req := connect.NewRequest(&highschoolv1.GetDistrictsRequest{})
	req.Header().Set("Cookie", "admin_sess="+tok)

	_, err := wrapped(context.Background(), req)

	if !called {
		t.Fatal("downstream handler MUST be invoked on valid cookie")
	}
	if err != nil {
		t.Fatalf("downstream returned unexpected error: %v", err)
	}
}
