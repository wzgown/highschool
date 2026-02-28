package logger

import (
	"context"
	"os"

	"highschool-backend/pkg/tracing"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var log *zap.Logger

// Initialize 初始化日志
func Initialize(level string, format string) error {
	var lvl zapcore.Level
	switch level {
	case "debug":
		lvl = zapcore.DebugLevel
	case "info":
		lvl = zapcore.InfoLevel
	case "warn":
		lvl = zapcore.WarnLevel
	case "error":
		lvl = zapcore.ErrorLevel
	default:
		lvl = zapcore.InfoLevel
	}

	encoderConfig := zapcore.EncoderConfig{
		TimeKey:        "timestamp",
		LevelKey:       "level",
		NameKey:        "logger",
		CallerKey:      "caller",
		FunctionKey:    zapcore.OmitKey,
		MessageKey:     "msg",
		StacktraceKey:  "stacktrace",
		LineEnding:     zapcore.DefaultLineEnding,
		EncodeLevel:    zapcore.LowercaseLevelEncoder,
		EncodeTime:     zapcore.ISO8601TimeEncoder,
		EncodeDuration: zapcore.SecondsDurationEncoder,
		EncodeCaller:   zapcore.ShortCallerEncoder,
	}

	var encoder zapcore.Encoder
	if format == "json" {
		encoder = zapcore.NewJSONEncoder(encoderConfig)
	} else {
		encoder = zapcore.NewConsoleEncoder(encoderConfig)
	}

	core := zapcore.NewCore(
		encoder,
		zapcore.AddSync(os.Stdout),
		lvl,
	)

	log = zap.New(core, zap.AddCaller(), zap.AddStacktrace(zapcore.ErrorLevel))
	return nil
}

// GetLogger 获取日志实例
func GetLogger() *zap.Logger {
	if log == nil {
		log, _ = zap.NewDevelopment()
	}
	return log
}

// withTraceFields extracts trace_id from context and returns a logger with trace field
func withTraceFields(ctx context.Context) *zap.Logger {
	logger := GetLogger()
	if ctx == nil {
		return logger
	}
	traceID := tracing.GetTraceID(ctx)
	if traceID != "" {
		return logger.With(zap.String("trace_id", traceID))
	}
	return logger
}

// Ctx returns a logger with trace_id from context
// If ctx is nil, returns the default logger without trace_id
func Ctx(ctx context.Context) *zap.Logger {
	return withTraceFields(ctx)
}

// Info 信息日志 - ctx作为第一个参数，可以为nil
func Info(ctx context.Context, msg string, fields ...zap.Field) {
	withTraceFields(ctx).Info(msg, fields...)
}

// Error 错误日志 - ctx作为第一个参数，可以为nil
func Error(ctx context.Context, msg string, err error, fields ...zap.Field) {
	if err != nil {
		fields = append(fields, zap.Error(err))
	}
	withTraceFields(ctx).Error(msg, fields...)
}

// Debug 调试日志 - ctx作为第一个参数，可以为nil
func Debug(ctx context.Context, msg string, fields ...zap.Field) {
	withTraceFields(ctx).Debug(msg, fields...)
}

// Warn 警告日志 - ctx作为第一个参数，可以为nil
func Warn(ctx context.Context, msg string, fields ...zap.Field) {
	withTraceFields(ctx).Warn(msg, fields...)
}
