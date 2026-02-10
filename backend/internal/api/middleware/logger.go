package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"highschool-backend/pkg/logger"
)

// Logger 日志中间件
func Logger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		query := c.Request.URL.RawQuery

		c.Next()

		duration := time.Since(start)
		status := c.Writer.Status()

		if query != "" {
			path = path + "?" + query
		}

		logger.Info("http request",
			logger.String("method", c.Request.Method),
			logger.String("path", path),
			logger.Int("status", status),
			logger.Duration("duration", duration),
			logger.String("client_ip", c.ClientIP()),
		)
	}
}
