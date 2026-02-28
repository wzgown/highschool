package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"connectrpc.com/otelconnect"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	v1 "highschool-backend/internal/api/v1"
	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/pkg/config"
	"highschool-backend/pkg/logger"
	"highschool-backend/pkg/tracing"
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

	// 初始化 OpenTelemetry 分布式追踪
	tracingCfg := tracing.Config{
		Enabled:      cfg.Tracing.Enabled,
		ServiceName:  cfg.Tracing.ServiceName,
		OTLPEndpoint: cfg.Tracing.OTLPEndpoint,
		SampleRate:   cfg.Tracing.SampleRate,
	}
	tracingShutdown, err := tracing.Initialize(tracingCfg)
	if err != nil {
		logger.Error(context.Background(), "tracing init error", err)
		os.Exit(1)
	}
	defer tracingShutdown(context.Background())

	logger.Info(context.Background(), "starting highschool backend service (Connect-RPC)")

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
		logger.Error(context.Background(), "database init error", err)
		os.Exit(1)
	}
	defer database.Close()

	logger.Info(context.Background(), "database connected")

	// 创建 HTTP 路由
	mux := http.NewServeMux()

	// 健康检查
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok","time":` + fmt.Sprintf("%d", time.Now().Unix()) + `}`))
	})

	// 创建 OpenTelemetry 拦截器
	var otelInterceptor *otelconnect.Interceptor
	if cfg.Tracing.Enabled {
		otelInterceptor, err = otelconnect.NewInterceptor()
		if err != nil {
			logger.Error(context.Background(), "create otel interceptor error", err)
			os.Exit(1)
		}
	}

	// 注册 Connect-RPC 服务
	v1.RegisterReferenceService(mux, otelInterceptor)
	v1.RegisterCandidateService(mux, otelInterceptor)

	// 添加中间件
	// 顺序（从外到内）：OTel HTTP tracing -> 日志 -> CORS -> handler
	handler := withCORS(mux)
	handler = withLogging(handler)

	// 如果启用 tracing，添加 OTel HTTP 中间件
	if cfg.Tracing.Enabled {
		handler = otelhttp.NewHandler(handler, "http.request",
			otelhttp.WithMessageEvents(otelhttp.ReadEvents, otelhttp.WriteEvents),
		)
	}

	// 创建 HTTP 服务器（支持 h2c）
	addr := fmt.Sprintf("%s:%d", cfg.Server.Host, cfg.Server.Port)
	srv := &http.Server{
		Addr:    addr,
		Handler: h2c.NewHandler(handler, &http2.Server{}),
	}

	// 启动服务器
	go func() {
		logger.Info(context.Background(), "server started", logger.String("addr", addr))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Error(context.Background(), "server error", err)
		}
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info(context.Background(), "shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Error(ctx, "server forced to shutdown", err)
	}

	logger.Info(ctx, "server exited")
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

// responseWriter 包装 http.ResponseWriter 以捕获状态码
type responseWriter struct {
	http.ResponseWriter
	statusCode int
	written    bool
}

func (rw *responseWriter) WriteHeader(code int) {
	if !rw.written {
		rw.statusCode = code
		rw.written = true
		rw.ResponseWriter.WriteHeader(code)
	}
}

func (rw *responseWriter) Write(b []byte) (int, error) {
	if !rw.written {
		rw.WriteHeader(http.StatusOK)
	}
	return rw.ResponseWriter.Write(b)
}

// withLogging 请求日志中间件
func withLogging(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// 从请求中提取 trace context
		ctx := r.Context()

		// 包装 response writer 以捕获状态码
		rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

		// 处理请求
		h.ServeHTTP(rw, r)

		// 记录请求日志
		duration := time.Since(start)

		// 根据状态码选择日志级别
		if rw.statusCode >= 500 {
			logger.Error(ctx, "request completed with error", nil,
				logger.String("method", r.Method),
				logger.String("path", r.URL.Path),
				logger.Int("status", rw.statusCode),
				logger.Duration("duration", duration),
			)
		} else if rw.statusCode >= 400 {
			logger.Warn(ctx, "request completed with client error",
				logger.String("method", r.Method),
				logger.String("path", r.URL.Path),
				logger.Int("status", rw.statusCode),
				logger.Duration("duration", duration),
			)
		} else {
			logger.Info(ctx, "request completed",
				logger.String("method", r.Method),
				logger.String("path", r.URL.Path),
				logger.Int("status", rw.statusCode),
				logger.Duration("duration", duration),
			)
		}
	})
}
