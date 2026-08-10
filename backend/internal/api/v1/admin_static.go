package v1

import (
	"io/fs"
	"net/http"
	"strings"
)

// adminDistFS 是管理后台 SPA 的根文件系统。
// 由 admin_dist_embed.go（tag: admindist，真实构建产物）或
// admin_dist_stub.go（默认，占位页）赋值。
var adminDistFS fs.FS

// AdminSPAHandler 托管管理后台 SPA；找不到的子路径回落 index.html（客户端路由）。
func AdminSPAHandler() http.Handler {
	fileServer := http.FileServer(http.FS(adminDistFS))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rel := strings.TrimPrefix(r.URL.Path, "/")
		if rel == "" {
			rel = "index.html"
		}
		if _, err := fs.Stat(adminDistFS, rel); err != nil {
			r.URL.Path = "/index.html"
		}
		fileServer.ServeHTTP(w, r)
	})
}
