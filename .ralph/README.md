# Ralph Loop 脚手架

> 多任务复用的循环框架
> 每个任务一个 task.md，验证逻辑随任务而定

## 目录结构

```
.ralph/
├── scripts/
│   ├── run-ralph.sh      # 主循环脚本（固定）
│   └── stop-hook.sh      # 验证脚本执行器（固定）
│
├── templates/
│   └── task-template.md  # 任务模板
│
├── current/
│   └── task.md           # 当前任务（含验证脚本）
│
├── tasks/                # 历史任务归档
│   ├── 2026-02-22-fix-test/
│   │   └── task.md
│   └── 2026-02-23-add-login/
│       └── task.md
│
└── logs/                 # 循环日志
```

## task.md 结构

```markdown
# 任务：修复登录测试

## 成功标准
- [ ] 测试通过
- [ ] Lint 清零

## 验证脚本
<!-- ⚠️ 这是关键！定义如何检查任务是否完成 -->

\`\`\`bash
#!/bin/bash
set -e

cd /path/to/project/backend

# 任务特定的检查逻辑
go test ./internal/service/auth_test.go -v
golangci-lint run ./internal/service/...
\`\`\`

## 实现计划（可选）
- [ ] 步骤 1
- [ ] 步骤 2

## 完成信号
MISSION_COMPLETE
```

## 验证脚本的作用

| 任务类型 | 验证脚本检查内容 |
|----------|-----------------|
| 修复测试 | `go test ./path/to/test -v` |
| 实现 API | `go test ./...` + `curl` 健康检查 |
| 添加 lint | `golangci-lint run` 无错误 |
| 前端功能 | `npm run test` + `npm run build` |

## 工作流程

```
┌─────────────────────────────────────────────────────────┐
│  1. 创建 task.md                                        │
│     - 定义成功标准                                       │
│     - 编写验证脚本 ⬅️ 关键！                             │
│                                                         │
│  2. 启动循环                                            │
│     ↓                                                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │ while 未达到 MAX_ITERATIONS:                      │  │
│  │                                                   │  │
│  │   # 全新 AI 实例                                  │  │
│  │   claude -p task.md                               │  │
│  │                                                   │  │
│  │   # 执行任务特定的验证脚本                        │  │
│  │   bash stop-hook.sh                               │  │
│  │   if 通过: break                                  │  │
│  │                                                   │  │
│  │   # 追加失败日志                                  │  │
│  │   echo 失败日志 >> task.md                        │  │
│  └───────────────────────────────────────────────────┘  │
│     ↓                                                   │
│  3. 归档任务                                            │
└─────────────────────────────────────────────────────────┘
```

## 使用方法

```bash
# 创建新任务
./.ralph/scripts/run-ralph.sh --new

# 编辑任务（重点是验证脚本！）
vim .ralph/current/task.md

# 运行循环
./.ralph/scripts/run-ralph.sh

# 归档
./.ralph/scripts/run-ralph.sh --archive fix-login-test
```

## 验证脚本示例

### 示例 1：修复单个测试

```bash
#!/bin/bash
set -e
cd /Users/lance.wang/workspace/wzgown/highschool_new/backend
go test ./internal/service/auth_test.go -v
```

### 示例 2：实现 API 功能

```bash
#!/bin/bash
set -e
cd /Users/lance.wang/workspace/wzgown/highschool_new/backend

# 1. 测试通过
go test ./... -v

# 2. Lint 通过
golangci-lint run

# 3. API 可达
curl -f http://localhost:8080/health
```

### 示例 3：前端功能

```bash
#!/bin/bash
set -e
cd /Users/lance.wang/workspace/wzgown/highschool_new/frontend

# 1. 类型检查
npm run type-check

# 2. 构建成功
npm run build

# 3. 测试通过
npm run test
```

## 命令参考

```bash
./.ralph/scripts/run-ralph.sh --new           # 创建新任务
./.ralph/scripts/run-ralph.sh --status        # 显示状态
./.ralph/scripts/run-ralph.sh --archive       # 归档当前任务
./.ralph/scripts/run-ralph.sh --reset         # 清空失败日志
./.ralph/scripts/run-ralph.sh --help          # 显示帮助
```

## 关键要点

1. **验证脚本在 task.md 中** — 每个任务有不同的检查逻辑
2. **stop-hook.sh 是执行器** — 提取并执行验证脚本
3. **客观检查** — 用脚本验证，不是 AI 自评
4. **完成信号** — AI 必须输出 `MISSION_COMPLETE`
