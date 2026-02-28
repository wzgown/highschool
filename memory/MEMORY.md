# 上海中考招生模拟系统 - 项目记忆

## 项目概述

上海中考招生模拟系统 - 帮助考生评估录取概率、优化志愿填报策略的 Web 应用。

## 技术栈

- **后端**：Go 1.24+ + Connect-RPC (Protocol Buffers) + PostgreSQL (pgx)
- **前端**：Vue 3 + TypeScript + Vite + Element Plus + Pinia
- **代码共享**：Protocol Buffers

## 常用命令

### Protobuf 代码生成
```bash
cd proto && buf generate
```
- 生成 Go 代码到：`backend/gen/highschool/v1/`
- 生成 TypeScript 代码到：`frontend/src/gen/highschool/v1/`

### 后端开发
```bash
cd backend && make run    # 运行
cd backend && make dev    # 热重载（需要 air）
cd backend && make test   # 测试
cd backend && make build  # 构建
```

### 前端开发
```bash
cd frontend && npm run dev         # 开发服务器
cd frontend && npm run type-check  # 类型检查
cd frontend && npm run build       # 构建
```

### 数据库
```bash
docker compose up -d  # 启动 PostgreSQL 和 Redis
psql -U highschool -d highschool -f db/migrations/*.sql     # 创建表
psql -U highschool -d highschool -f db/seeds/*.sql          # 导入种子数据
```

## 架构设计

### 后端分层 DDD
```
internal/
├── api/v1/       # Connect-RPC 服务实现层（协议转换、参数校验）
├── service/      # 业务逻辑层（业务编排）
├── domain/       # 领域层（核心模拟算法）
├── repository/   # 数据访问层（数据库 CRUD）
└── infrastructure/  # 基础设施（数据库连接）
```

### 前端架构
```
src/
├── views/       # 页面视图
├── components/  # 组件
├── stores/      # Pinia 状态管理
├── api/         # Connect-RPC 客户端
└── gen/         # Protobuf 生成代码（勿手动修改）
```

## Connect-RPC 服务端点

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
1. 同分优待 → 2. 综合素质评价 → 3. 语数外合计 → 4. 数学 → 5. 语文 → 6. 综合测试

### 平行志愿原则
"分数优先、遵循志愿、一轮投档"

## 重要注意事项

1. **Proto 变更**：修改 `.proto` 文件后必须运行 `buf generate`
2. **成绩校验**：中考总分 = 各科成绩之和
3. **数据脱敏**：存储候选人数据需要脱敏
4. **常量定义**：枚举常量定义在代码中（`internal/shared/constants/`），而非数据库

## 专题文档

- [架构详细说明](./architecture.md)
- [常见问题](./faq.md)
- [开发笔记](./development-notes.md)
