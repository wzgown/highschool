package v1

import (
	"context"
	"errors"
	"net/http"

	"connectrpc.com/connect"
	"highschool-backend/pkg/auth"
)

const adminCookieName = "admin_sess"

var errAdminUnauthenticated = errors.New("admin: unauthenticated")

// Compile-time assertion: adminAuthInterceptor satisfies connect.Interceptor.
var _ connect.Interceptor = (*adminAuthInterceptor)(nil)

// checkAdminCookie 从请求头解析 admin cookie 并校验 HMAC 签名。
// 返回 (subject, true) 表示放行；否则 (..., false)。
// 注意：不使用 cookie 解析后的分支差异（签名校验在 auth.VerifySession 内部
// 使用 hmac.Equal 做常量时间比较），这里不引入额外时序侧信道。
func checkAdminCookie(secret string, h http.Header) (string, bool) {
	req := &http.Request{Header: h}
	c, err := req.Cookie(adminCookieName)
	if err != nil {
		return "", false
	}
	return auth.VerifySession(secret, c.Value)
}

// newAdminAuthInterceptor 返回包裹 AdminService 的鉴权拦截器：
// 无有效 admin_sess cookie → connect.CodeUnauthenticated。
// streaming 路径直通（AdminService 仅暴露 unary 方法）。
func newAdminAuthInterceptor(secret string) connect.Interceptor {
	return &adminAuthInterceptor{secret: secret}
}

type adminAuthInterceptor struct{ secret string }

// WrapUnary 实现 connect.Interceptor：在调用下游 handler 前校验 cookie。
// 失败时返回 CodeUnauthenticated，不向下传递 context。
func (a *adminAuthInterceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		if _, ok := checkAdminCookie(a.secret, req.Header()); !ok {
			return nil, connect.NewError(connect.CodeUnauthenticated, errAdminUnauthenticated)
		}
		return next(ctx, req)
	}
}

// WrapStreamingClient 实现 connect.Interceptor：客户端侧 streaming 直通。
// （本服务不会作为客户端调用 streaming Admin RPC。）
func (a *adminAuthInterceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return next
}

// WrapStreamingHandler 实现 connect.Interceptor：服务端侧 streaming 一律拒绝。
// AdminService 为 unary-only；任何 streaming 调用都视为非法（防止未来新增 streaming
// admin RPC 时 WrapUnary 鉴权被绕过——因为 streaming 路径不走 WrapUnary）。
// 新增合法 streaming RPC 时需在此显式放开并复用 checkAdminCookie。
func (a *adminAuthInterceptor) WrapStreamingHandler(next connect.StreamingHandlerFunc) connect.StreamingHandlerFunc {
	return func(ctx context.Context, conn connect.StreamingHandlerConn) error {
		_ = next
		_ = conn
		return connect.NewError(connect.CodeUnauthenticated, errAdminUnauthenticated)
	}
}
