package v1

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"highschool-backend/pkg/auth"
	"highschool-backend/pkg/config"
)

// adminLoginCfg 构造一个启用了登录的 config（password_hash + cookie_secret 均已配置）。
func adminLoginCfg(t *testing.T, plain string) *config.Config {
	t.Helper()
	hash, err := auth.HashPassword(plain)
	if err != nil {
		t.Fatalf("HashPassword: %v", err)
	}
	return &config.Config{
		Admin: config.AdminConfig{
			PasswordHash:    hash,
			CookieSecret:    "test-cookie-secret",
			SessionTTLHours: 12,
		},
	}
}

// TestAdminLoginHandler 表驱动覆盖登录 handler 的所有分支：
// secrets 未配置 → 503；方法错误 → 405；请求体非法 → 400；
// 密码错误 → 401；密码正确 → 200 且下发 admin_sess cookie。
func TestAdminLoginHandler(t *testing.T) {
	const correct = "correct-horse-battery"

	tests := []struct {
		name       string
		cfg        *config.Config
		method     string
		body       string
		wantStatus int
		wantCookie bool
	}{
		{
			name:       "secrets empty -> 503",
			cfg:        &config.Config{},
			method:     http.MethodPost,
			body:       `{"password":"x"}`,
			wantStatus: http.StatusServiceUnavailable,
		},
		{
			name:       "wrong method GET -> 405",
			cfg:        adminLoginCfg(t, correct),
			method:     http.MethodGet,
			body:       `{"password":"x"}`,
			wantStatus: http.StatusMethodNotAllowed,
		},
		{
			name:       "malformed body -> 400",
			cfg:        adminLoginCfg(t, correct),
			method:     http.MethodPost,
			body:       `{not-json`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "wrong password -> 401",
			cfg:        adminLoginCfg(t, correct),
			method:     http.MethodPost,
			body:       `{"password":"nope"}`,
			wantStatus: http.StatusUnauthorized,
		},
		{
			name:       "correct password -> 200 + Set-Cookie",
			cfg:        adminLoginCfg(t, correct),
			method:     http.MethodPost,
			body:       `{"password":"` + correct + `"}`,
			wantStatus: http.StatusOK,
			wantCookie: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			h := NewAdminLoginHandler(tt.cfg)
			req := httptest.NewRequest(tt.method, "/admin/api/login", strings.NewReader(tt.body))
			req.Header.Set("Content-Type", "application/json")
			rec := httptest.NewRecorder()
			h.ServeHTTP(rec, req)

			if rec.Code != tt.wantStatus {
				t.Fatalf("status = %d, want %d (body=%q)", rec.Code, tt.wantStatus, rec.Body.String())
			}
			if tt.wantCookie {
				setCookie := rec.Header().Get("Set-Cookie")
				if !strings.Contains(setCookie, adminCookieName+"=") {
					t.Fatalf("expected Set-Cookie to contain %s=, got %q", adminCookieName, setCookie)
				}
			}
		})
	}
}
