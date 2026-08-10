package v1

import (
	"encoding/json"
	"net/http"
	"time"

	"highschool-backend/pkg/auth"
	"highschool-backend/pkg/config"
)

// NewAdminLoginHandler POST /admin/api/login {password} → 设 admin_sess cookie。
// 未配置 password_hash/cookie_secret 时返回 503。
func NewAdminLoginHandler(cfg *config.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		if cfg.Admin.PasswordHash == "" || cfg.Admin.CookieSecret == "" {
			http.Error(w, "admin disabled", http.StatusServiceUnavailable)
			return
		}
		var body struct {
			Password string `json:"password"`
		}
		r.Body = http.MaxBytesReader(w, r.Body, 4096)
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}
		if !auth.VerifyPassword(cfg.Admin.PasswordHash, body.Password) {
			http.Error(w, "invalid credentials", http.StatusUnauthorized)
			return
		}
		ttl := time.Duration(cfg.Admin.SessionTTLHours) * time.Hour
		if ttl == 0 {
			ttl = 12 * time.Hour
		}
		token := auth.SignSession(cfg.Admin.CookieSecret, "admin", time.Now().Add(ttl))
		http.SetCookie(w, &http.Cookie{
			Name: adminCookieName, Value: token, Path: "/",
			HttpOnly: true, Secure: cfg.Server.Mode == "production",
			MaxAge: int(ttl.Seconds()), SameSite: http.SameSiteLaxMode,
		})
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]bool{"ok": true})
	}
}

// NewAdminLogoutHandler POST /admin/api/logout — 用 MaxAge=-1 清除 admin_sess cookie。
// 仅接受 POST（与 login 对称），其余方法返回 405。无服务端 session 状态，清除 cookie 即登出。
func NewAdminLogoutHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		http.SetCookie(w, &http.Cookie{
			Name: adminCookieName, Value: "", Path: "/",
			HttpOnly: true, MaxAge: -1,
		})
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]bool{"ok": true})
	}
}
