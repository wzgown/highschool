package database

import (
	"context"
	"fmt"
	"net/url"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Config 数据库配置
type Config struct {
	Host       string
	Port       int
	Name       string
	User       string
	Password   string
	SSLMode    string
	MaxConns   int32
}

// DB 数据库连接池
var db *pgxpool.Pool

// Initialize 初始化数据库连接
func Initialize(cfg Config) (*pgxpool.Pool, error) {
	// 使用 url.UserPassword 正确处理特殊字符
	u := &url.URL{
		Scheme: "postgres",
		User:   url.UserPassword(cfg.User, cfg.Password),
		Host:   fmt.Sprintf("%s:%d", cfg.Host, cfg.Port),
		Path:   cfg.Name,
	}
	q := u.Query()
	q.Set("sslmode", cfg.SSLMode)
	q.Set("pool_max_conns", fmt.Sprintf("%d", cfg.MaxConns))
	u.RawQuery = q.Encode()

	poolConfig, err := pgxpool.ParseConfig(u.String())
	if err != nil {
		return nil, fmt.Errorf("parse config error: %w", err)
	}

	poolConfig.MaxConnLifetime = time.Hour
	poolConfig.MaxConnIdleTime = time.Minute * 30

	db, err = pgxpool.NewWithConfig(context.Background(), poolConfig)
	if err != nil {
		return nil, fmt.Errorf("create pool error: %w", err)
	}

	// 测试连接
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.Ping(ctx); err != nil {
		return nil, fmt.Errorf("ping error: %w", err)
	}

	return db, nil
}

// GetDB 获取数据库连接池
func GetDB() *pgxpool.Pool {
	return db
}

// Close 关闭数据库连接
func Close() {
	if db != nil {
		db.Close()
	}
}

// Transaction 执行事务
func Transaction(ctx context.Context, fn func(tx pgx.Tx) error) error {
	tx, err := db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	if err := fn(tx); err != nil {
		return err
	}

	return tx.Commit(ctx)
}
