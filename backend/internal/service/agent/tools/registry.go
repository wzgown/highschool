// Package tools AI 顾问 Agent 受控工具集（全部只读）
// 设计文档: docs/agent-mode-plan.md §3.2.3
package tools

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"time"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

// defaultToolTimeout 单次工具执行超时
const defaultToolTimeout = 5 * time.Second

// ToolRegistry 工具注册表（map 注册 + 统一超时/panic 保护）
type ToolRegistry struct {
	tools   map[string]agent.Tool
	timeout time.Duration
}

// NewToolRegistry 创建注册表并注册给定工具；timeout <= 0 用默认 5s
func NewToolRegistry(timeout time.Duration, toolList ...agent.Tool) *ToolRegistry {
	if timeout <= 0 {
		timeout = defaultToolTimeout
	}
	r := &ToolRegistry{
		tools:   make(map[string]agent.Tool, len(toolList)),
		timeout: timeout,
	}
	for _, t := range toolList {
		r.tools[t.Spec().Name] = t
	}
	return r
}

// NewRegistry 注册全部 12 个只读数据工具
func NewRegistry(repo repository.AgentDataRepository) *ToolRegistry {
	return NewToolRegistry(defaultToolTimeout,
		NewGetAdmissionScoresTool(repo),
		NewSearchSchoolsTool(repo),
		NewGetSchoolDetailTool(repo),
		NewGetQuotaPlanTool(repo),
		NewGetControlScoresTool(repo),
		NewGetMiddleSchoolStatsTool(repo),
		NewCompareSchoolsTool(repo),
		NewGetScoreTrendTool(repo),
		NewGetMiddleSchoolAdvantageTool(repo),
		NewLocateScoreTool(repo),
		NewGetQuotaChangeTool(repo),
		NewGetTieBreakDetailTool(repo),
	)
}

// NewRegistryWithEngine 注册 12 个只读数据工具 + 2 个引擎型工具（P2）
// engine 由 service.NewRecommendationService() 满足；simRepo 由 repository.NewSimulationHistoryRepository() 满足
func NewRegistryWithEngine(repo repository.AgentDataRepository, engine RecommendationEngine, simRepo SimulationHistoryReader) *ToolRegistry {
	r := NewRegistry(repo)
	if engine != nil {
		r.tools[NewRunRecommendationTool(repo, engine).Spec().Name] = NewRunRecommendationTool(repo, engine)
	}
	if simRepo != nil {
		r.tools[NewGetAnalysisResultTool(simRepo).Spec().Name] = NewGetAnalysisResultTool(simRepo)
	}
	return r
}

// Specs 全部工具的 ToolSpec（按名字排序，保证 LLM tools 参数稳定）
func (r *ToolRegistry) Specs() []agent.ToolSpec {
	names := make([]string, 0, len(r.tools))
	for name := range r.tools {
		names = append(names, name)
	}
	sort.Strings(names)

	specs := make([]agent.ToolSpec, 0, len(names))
	for _, name := range names {
		specs = append(specs, r.tools[name].Spec())
	}
	return specs
}

// Execute 执行工具：未知工具报错；带超时与 panic 保护
func (r *ToolRegistry) Execute(ctx context.Context, name string, args json.RawMessage) (result *agent.ToolResult, err error) {
	tool, ok := r.tools[name]
	if !ok {
		return nil, fmt.Errorf("工具 %q 未注册", name)
	}

	ctx, cancel := context.WithTimeout(ctx, r.timeout)
	defer cancel()

	defer func() {
		if rec := recover(); rec != nil {
			result = nil
			err = fmt.Errorf("工具 %q 执行 panic: %v", name, rec)
		}
	}()

	result, err = tool.Execute(ctx, args)
	if err == nil && ctx.Err() == context.DeadlineExceeded {
		return nil, fmt.Errorf("工具 %q 执行超时（%s）", name, r.timeout)
	}
	return result, err
}
