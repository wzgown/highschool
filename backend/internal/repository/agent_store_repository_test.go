// agent_store_repository_test.go checkpoint 持久化契约的集成测试（真库）。
// 运行：HS_DATABASE_HOST=<postgres地址> go test ./internal/repository/ -run AgentStore -v -count=1
// （-count=1 必须：go test 缓存不追踪自定义环境变量，否则会复用「跳过」的旧结果）
// 未设该变量或库不可达时自动跳过，不阻断 CI（与 admin_repository_test 同一模式）。
package repository

import (
	"context"
	"os"
	"strconv"
	"testing"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/service/agent"
)

// TestMain 仅在显式提供 HS_DATABASE_HOST 时初始化连接池（make test 会经由
// Makefile 的 export 注入 192.168.71.160）。初始化失败（网络不可达等）保持
// nil，包内所有集成测试统一跳过。
func TestMain(m *testing.M) {
	if host := os.Getenv("HS_DATABASE_HOST"); host != "" {
		port := 5432
		if p := os.Getenv("HS_DATABASE_PORT"); p != "" {
			if v, err := strconv.Atoi(p); err == nil {
				port = v
			}
		}
		cfg := database.Config{
			Host:     host,
			Port:     port,
			Name:     envOr("HS_DATABASE_NAME", "highschool"),
			User:     envOr("HS_DATABASE_USER", "highschool"),
			Password: os.Getenv("HS_DATABASE_PASSWORD"),
			SSLMode:  envOr("HS_DATABASE_SSL_MODE", "disable"),
			MaxConns: 2,
		}
		_, _ = database.Initialize(cfg) // 失败留 nil → 用例跳过
	}
	os.Exit(m.Run())
}

func envOr(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

// TestAgentStore_SaveCheckpoint_MultiTurn 锁定契约（迁移 015 / review §4 C1）：
//  1. Run 每轮 stepSeq 重置 → 同 session 重复 step_seq 的 checkpoint 必须都能写入。
//     这同时守护 SaveCheckpoint 不得携带 ON CONFLICT (session_id, step_seq)——
//     约束已删，携带该子句会在 plan 阶段报 42P10，且 graph 层只告警不中断，属静默故障。
//  2. LatestCheckpoint 按写入序（id）取最新，即使其 step_seq 比历史行小。
func TestAgentStore_SaveCheckpoint_MultiTurn(t *testing.T) {
	if database.GetDB() == nil {
		t.Skip("database not initialized; set HS_DATABASE_HOST to run agent store integration test")
	}
	ctx := context.Background()

	// 前置：迁移 015 必须已应用，否则重复 step_seq 写入必然违反 UNIQUE
	var hasUnique bool
	if err := database.GetDB().QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM pg_constraint
		  WHERE conrelid = 'agent_checkpoint'::regclass
		    AND conname = 'agent_checkpoint_session_id_step_seq_key')`).Scan(&hasUnique); err != nil {
		t.Fatalf("check unique constraint: %v", err)
	}
	if hasUnique {
		t.Fatal("迁移 015 未应用：agent_checkpoint 仍有 UNIQUE(session_id, step_seq)")
	}

	r := NewAgentStoreRepository()
	sid, err := r.CreateSession(ctx, "it-test-checkpoint", nil)
	if err != nil {
		t.Fatalf("CreateSession: %v", err)
	}
	t.Cleanup(func() {
		_, _ = database.GetDB().Exec(ctx, `DELETE FROM agent_session WHERE id=$1`, sid)
	})

	st := &agent.State{SessionID: sid, Intent: agent.IntentDataQuery,
		Slots: map[string]any{"district_name": "徐汇区"}}

	// 模拟三轮：每轮 stepSeq 从 1 重置（graph.Run 每轮重建 State 的既有行为）
	save := func(seq int, node string) int64 {
		t.Helper()
		id, err := r.SaveCheckpoint(ctx, sid, seq, node, st)
		if err != nil {
			t.Fatalf("SaveCheckpoint(step=%d, node=%s): %v", seq, node, err)
		}
		return id
	}
	id1 := save(1, "router")         // 轮1
	_ = save(2, "planner")           // 轮1
	_ = save(1, "router")            // 轮2：与轮1 重复 step_seq，必须放行
	_ = save(2, "planner")           // 轮2
	_ = save(3, "executor")          // 轮2
	idLast := save(1, "synthesizer") // 轮3：中断在首步——最后写入的行 step_seq 反而最小

	if idLast <= id1 {
		t.Fatalf("重复 step_seq 应插入新行（id 递增）：first=%d last=%d", id1, idLast)
	}

	// 最新快照 = 最后写入的行（按 id），而非 step_seq 最大的行（旧实现会返回 executor）
	seq, node, got, err := r.LatestCheckpoint(ctx, sid)
	if err != nil {
		t.Fatalf("LatestCheckpoint: %v", err)
	}
	if node != "synthesizer" || seq != 1 {
		t.Fatalf("LatestCheckpoint 应按写入序取最新：got step=%d node=%s, want step=1 node=synthesizer", seq, node)
	}
	if got == nil || got.Intent != agent.IntentDataQuery || got.Slots["district_name"] != "徐汇区" {
		t.Fatalf("LatestCheckpoint 状态反序列化异常：%#v", got)
	}
}
