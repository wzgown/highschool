package logger

import (
	"time"

	"go.uber.org/zap"
)

// String 字符串字段
func String(key, val string) zap.Field {
	return zap.String(key, val)
}

// Int 整数字段
func Int(key string, val int) zap.Field {
	return zap.Int(key, val)
}

// Duration 持续时间字段
func Duration(key string, val time.Duration) zap.Field {
	return zap.Duration(key, val)
}

// Error 错误字段
func ErrorField(err error) zap.Field {
	return zap.Error(err)
}

// Any 任意类型字段
func Any(key string, val interface{}) zap.Field {
	return zap.Any(key, val)
}
