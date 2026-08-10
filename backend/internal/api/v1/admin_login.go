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
		if cfg.Admin.PasswordHash == "" || cfg.Admin.CookieSecret == "" {
			http.Error(w, "admin disabled", http.StatusServiceUnavailable)
			return
		}
		var body struct {
			Password string `json:"password"`
		}
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
			HttpOnly: true, MaxAge: int(ttl.Seconds()), SameSite: http.SameSiteLaxMode,
		})
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]bool{"ok": true})
	}
}
