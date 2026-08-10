package v1

import (
	"embed"
	"io/fs"
	"net/http"
	"strings"
)

//go:embed admin_dist/*
var adminDist embed.FS

// AdminSPAHandler 托管管理后台 SPA；找不到的子路径回落 index.html（客户端路由）。
func AdminSPAHandler() http.Handler {
	sub, _ := fs.Sub(adminDist, "admin_dist")
	fileServer := http.FileServer(http.FS(sub))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// 客户端路由路径（如 /admin/replay/7）回落到 index.html
		if _, err := fs.Stat(sub, strings.TrimPrefix(r.URL.Path, "/")); err != nil {
			r.URL.Path = "/"
		}
		fileServer.ServeHTTP(w, r)
	})
}
