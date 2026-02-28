// repository/test/test_helper.go - 测试辅助函数
package test

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
)

// TestDB 测试数据库连接
var TestDB *pgxpool.Pool

// SetupTestDB 初始化测试数据库
func SetupTestDB(t *testing.T) *pgxpool.Pool {
	// 使用环境变量或默认值
	dbURL := os.Getenv("TEST_DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://highschool:HS2025%21db%23SecurePass88@localhost:5432/highschool?sslmode=disable"
	}

	config, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		t.Fatalf("Failed to parse test database config: %v", err)
	}

	pool, err := pgxpool.NewWithConfig(context.Background(), config)
	if err != nil {
		t.Fatalf("Failed to connect to test database: %v", err)
	}

	// 测试连接
	if err := pool.Ping(context.Background()); err != nil {
		t.Fatalf("Failed to ping test database: %v", err)
	}

	return pool
}

// CleanupTestData 清理测试数据
func CleanupTestData(t *testing.T, db *pgxpool.Pool) {
	ctx := context.Background()
	
	// 清理测试数据
	tables := []string{"simulation_history"}
	for _, table := range tables {
		_, err := db.Exec(ctx, fmt.Sprintf("DELETE FROM %s WHERE device_id LIKE 'test_%%'", table))
		if err != nil {
			t.Logf("Warning: failed to cleanup table %s: %v", table, err)
		}
	}
}

// SetupMockDB 设置 mock 数据库（用于单元测试）
func SetupMockDB(t *testing.T) {
	// 这里可以使用 pgxmock 或其他 mock 库
	// 简化版：暂时直接连接真实测试数据库
}
