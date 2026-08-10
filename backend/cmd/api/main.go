package main

import (
	"context"
	"encoding/json"
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
	"highschool-backend/internal/infrastructure/settings"
	"highschool-backend/internal/repository"
	"highschool-backend/pkg/config"
	"highschool-backend/pkg/logger"
	"highschool-backend/pkg/metrics"
	"highschool-backend/pkg/otellog"
	"highschool-backend/pkg/tracing"
)

func main() {
	// 加载配置
	cfg, err := config.Load()
	if err != nil {
		fmt.Printf("load config error: %v\n", err)
		os.Exit(1)
	}

	// 初始化日志（stdout + OTLP 导出）
	// OTLP 日志导出必须先于 logger.Initialize，因为 logger 构建 zapcore 时需要 otellog provider
	otellogShutdown, err := otellog.Initialize(context.Background(), otellog.Config{
		Enabled:     cfg.Tracing.Enabled,
		Endpoint:    cfg.Tracing.OTLPEndpoint,
		URLPath:     "/api/default/v1/logs",
		Headers:     cfg.Tracing.Headers,
		ServiceName: cfg.Tracing.ServiceName,
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "[otellog] init error: %v (logs will only go to stdout)\n", err)
	}
	defer otellogShutdown(context.Background())

	if err := logger.Initialize(cfg.Log.Level, cfg.Log.Format); err != nil {
		fmt.Printf("init logger error: %v\n", err)
		os.Exit(1)
	}

	// 初始化 OpenTelemetry 分布式追踪
	tracingCfg := tracing.Config{
		Enabled:      cfg.Tracing.Enabled,
		ServiceName:  cfg.Tracing.ServiceName,
		OTLPEndpoint: cfg.Tracing.OTLPEndpoint,
		Protocol:     cfg.Tracing.Protocol,
		URLPath:      cfg.Tracing.URLPath,
		Headers:      cfg.Tracing.Headers,
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

	// 根路径
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"service":"highschool-backend","version":"1.0.0","status":"running"}`))
	})

	// 健康检查
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok","time":` + fmt.Sprintf("%d", time.Now().Unix()) + `}`))
	})

	// Prometheus 指标
	mux.Handle("/metrics", metrics.Handler())

	// 应用功能开关（AI 顾问 + 打赏码；DB app_config 表驱动，UPDATE 后 60s 内生效，无需重启）
	tipCfg := cfg.Tip
	featureFlags := settings.NewProvider(settings.Fallback{
		AgentEnabled:      cfg.Feature.AgentEnabled,
		ReviewVersions:    cfg.Feature.ReviewVersions,
		TipEnabled:        tipCfg.Enabled,
		TipURL:            tipCfg.QrURL,
		TipReviewVersions: tipCfg.ReviewVersions,
	})
	mux.HandleFunc("/tip-config", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")

		json.NewEncoder(w).Encode(map[string]string{
			"url": featureFlags.TipURL(r.Context(), r.URL.Query().Get("version")),
		})
	})

	mux.HandleFunc("/app-config", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")

		version := r.URL.Query().Get("version")

		resp := map[string]any{
			"agent_enabled": featureFlags.AgentEnabled(r.Context(), version),
			"tip_url":       featureFlags.TipURL(r.Context(), version),
		}
		// 顾问频道 UI 文案仅在开启时下发；提审版本（关闭）不携带任何相关字样，
		// 小程序包体内不含深度合成相关静态文本
		if resp["agent_enabled"] == true {
			resp["agent_ui"] = map[string]string{
				"tab":                "顾问",
				"title":              "AI 顾问",
				"subtitle":           "分数线 · 政策 · 志愿策略，有问必答",
				"welcome_title":      "你好，我是 AI 顾问",
				"welcome_desc":       "可以问我中考分数线、名额分配政策、志愿填报策略等问题。",
				"welcome_disclaimer": "回答由 DeepSeek 模型生成，仅供参考；数据以上海市教育考试院官方公布为准。",
				"result_cta":         "问问 AI 顾问",
				"about_title":        "AI 生成内容声明",
				"about_1_label":      "AI 顾问",
				"about_1_value":      "「顾问」频道的回答由深度求索（DeepSeek）人工智能模型生成，仅供参考",
				"about_2_label":      "内容安全",
				"about_2_value":      "提问与回答均经内容安全检测，请勿输入违法违规信息",
				"about_3_label":      "准确性",
				"about_3_value":      "AI 回答可能存在偏差，数据类结论以上海市教育考试院官方公布为准",
			}
		}

		json.NewEncoder(w).Encode(resp)
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
	v1.RegisterAgentService(mux, otelInterceptor)

	// 管理后台：AdminService（cookie 鉴权）+ 登录 + SPA 静态
	v1.RegisterAdminService(mux, otelInterceptor, cfg.Admin.CookieSecret, repository.NewAdminRepository())
	mux.HandleFunc("/admin/api/login", v1.NewAdminLoginHandler(cfg))
	mux.Handle("/admin/", http.StripPrefix("/admin/", v1.AdminSPAHandler()))
	mux.HandleFunc("/admin", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/admin/", http.StatusFound)
	})

	// 添加中间件
	// 顺序（从外到内）：OTel HTTP tracing -> 日志 -> handler
	// CORS 由 Nginx 反代层处理，后端不再设置
	handler := withLogging(mux)

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
