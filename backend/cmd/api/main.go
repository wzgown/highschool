package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	v1 "highschool-backend/internal/api/v1"
	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/pkg/config"
	"highschool-backend/pkg/logger"
)

func main() {
	// 加载配置
	cfg, err := config.Load()
	if err != nil {
		fmt.Printf("load config error: %v\n", err)
		os.Exit(1)
	}

	// 初始化日志
	if err := logger.Initialize(cfg.Log.Level, cfg.Log.Format); err != nil {
		fmt.Printf("init logger error: %v\n", err)
		os.Exit(1)
	}

	logger.Info("starting highschool backend service (Connect-RPC)")

	// 初始化数据库
	dbCfg := database.Config{
		Host:     cfg.Database.Host,
		Port:     cfg.Database.Port,
		Name:     cfg.Database.Name,
		User:     cfg.Database.User,
		Password: cfg.Database.Password,
		SSLMode:  cfg.Database.SSLMode,
		MaxConns: cfg.Database.MaxConns,
	}

	if _, err := database.Initialize(dbCfg); err != nil {
		logger.Error("database init error", err)
		os.Exit(1)
	}
	defer database.Close()

	logger.Info("database connected")

	// 创建 HTTP 路由
	mux := http.NewServeMux()

	// 健康检查
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok","time":` + fmt.Sprintf("%d", time.Now().Unix()) + `}`))
	})

	// 注册 Connect-RPC 服务
	v1.RegisterReferenceService(mux)
	v1.RegisterCandidateService(mux)

	// 添加 CORS 中间件
	handler := withCORS(mux)

	// 创建 HTTP 服务器（支持 h2c）
	addr := fmt.Sprintf("%s:%d", cfg.Server.Host, cfg.Server.Port)
	srv := &http.Server{
		Addr:    addr,
		Handler: h2c.NewHandler(handler, &http2.Server{}),
	}

	// 启动服务器
	go func() {
		logger.Info("server started", logger.String("addr", addr))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Error("server error", err)
		}
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Error("server forced to shutdown", err)
	}

	logger.Info("server exited")
}

// CORS 中间件
func withCORS(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization, X-Requested-With, Connect-Protocol-Version, Connect-Timeout-Ms")
		w.Header().Set("Access-Control-Expose-Headers", "Content-Length, Content-Type")
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		h.ServeHTTP(w, r)
	})
}
