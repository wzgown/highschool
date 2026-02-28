# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

上海中考招生模拟系统 - 帮助考生评估录取概率、优化志愿填报策略的 Web 应用。

**技术栈**：
- 后端：Go 1.24+ + Connect-RPC (Protocol Buffers) + PostgreSQL (pgx)
- 前端：Vue 3 + TypeScript + Vite + Element Plus + Pinia
- 代码共享：Protocol Buffers (`proto/` 定义前后端共享类型)

## 开发命令

### Protobuf 代码生成

修改 `.proto` 文件后必须运行：

```bash
cd proto && buf generate
```

生成位置：
- Go 代码：`backend/gen/highschool/v1/`
- TypeScript 代码：`frontend/src/gen/highschool/v1/`

### 后端开发

```bash
cd backend

# 运行
make run          # 或 go run cmd/api/main.go

# 开发模式（热重载，需安装 air）
make dev

# 测试
make test         # 或 go test ./internal/... -v

# 构建
make build

# 代码检查
make lint
```

### 前端开发

```bash
cd frontend

# 开发服务器
npm run dev      # 默认 http://localhost:5173

# 类型检查
npm run type-check

# 构建
npm run build
```

### 数据库

```bash
# 启动 PostgreSQL 和 Redis
docker compose up -d

# 初始化数据库
psql -U highschool -d highschool -f db/migrations/001_create_reference_tables_v2.sql
psql -U highschool -d highschool -f db/migrations/002_create_history_tables_v2.sql
psql -U highschool -d highschool -f db/migrations/003_create_simulation_history.sql

# 导入种子数据
psql -U highschool -d highschool -f db/seeds/000_seed_districts.sql
psql -U highschool -d highschool -f db/seeds/002_seed_schools_2025_v2.sql
```

## 架构设计

### 后端架构（分层 DDD）

```
backend/
├── cmd/api/              # 应用入口
├── internal/
│   ├── api/v1/           # Connect-RPC 服务实现层
│   ├── service/          # 业务逻辑层
│   ├── domain/           # 领域层（模拟引擎核心）
│   ├── repository/       # 数据访问层
│   └── infrastructure/  # 基础设施（数据库连接等）
├── gen/                 # Protobuf 生成代码（勿手动修改）
├── pkg/                 # 公共包（config、logger）
└── config.yaml          # 配置文件
```

**职责划分**：
- `api/v1/`：协议转换、参数校验、HTTP 处理
- `service/`：业务编排、跨 domain 协调
- `domain/simulation/`：核心模拟算法、录取规则引擎
- `repository/`：数据库 CRUD 操作

### 前端架构（Vue 3 SPA）

```
frontend/
├── src/
│   ├── views/           # 页面视图
│   ├── components/      # 组件
│   ├── stores/          # Pinia 状态管理
│   ├── api/             # Connect-RPC 客户端
│   ├── gen/             # Protobuf 生成代码（勿手动修改）
│   ├── router/          # Vue Router 配置
│   └── utils/          # 工具函数
```

### Connect-RPC 服务端点

| 服务 | 路径 | 功能 |
|------|------|------|
| ReferenceService | `/highschool.v1.ReferenceService/*` | 区县、学校、历史分数查询 |
| CandidateService | `/highschool.v1.CandidateService/*` | 志愿分析、模拟提交、历史记录 |

## 核心业务规则

### 录取批次（按顺序执行）

1. **名额分配到区**：1个志愿，全区排名竞争
2. **名额分配到校**：2个志愿，校内排名竞争（需具备资格）
3. **统一招生**：15个志愿，平行志愿投档

### 同分比较规则（6位序）

1. 同分优待
2. 综合素质评价成绩
3. 语数外三科合计
4. 数学成绩
5. 语文成绩
6. 综合测试成绩

### 平行志愿原则

"分数优先、遵循志愿、一轮投档"

## TDD 测试策略

项目采用测试驱动开发，测试分层进行：

```bash
# 运行所有测试
go test ./internal/... -v

# 分层测试
go test ./internal/domain/simulation/... -v    # 领域层
go test ./internal/service/... -v              # 服务层
go test ./internal/api/v1/... -v               # API层
go test ./internal/repository/... -v            # 仓储层

# 查看覆盖率
go test ./internal/... -cover
```

详见 `docs/tdd-report.md`。

## 重要注意事项

1. **Protobuf 变更**：修改 `.proto` 文件后必须运行 `buf generate`，前后端同步更新
2. **成绩校验**：中考总分必须等于各科成绩之和（语文+数学+外语+综合+道德法治+历史+体育）
3. **数据脱敏**：存储到 `simulation_history` 表的候选人数据需要脱敏处理
4. **前后端类型**：前后端通过 Protobuf 共享类型，不要重复定义
5. **常量定义**：枚举常量定义在代码中（`internal/shared/constants/`），而非数据库
