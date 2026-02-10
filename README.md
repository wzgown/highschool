# 上海中考招生模拟系统

## 项目概述

这是一个前后端分离的中考志愿分析系统，帮助考生评估录取概率，优化志愿填报策略。

## 技术栈

### 后端
- **语言**: Go 1.24+
- **RPC 框架**: Connect-RPC (基于 protobuf)
- **数据库**: PostgreSQL (pgx)
- **协议**: Protocol Buffers + Connect-RPC (支持 HTTP/JSON 和 gRPC)

### 前端
- **框架**: Vue 3 + TypeScript
- **路由**: Vue Router 4
- **状态管理**: Pinia
- **UI组件库**: Element Plus
- **构建工具**: Vite
- **RPC 客户端**: Connect-Web (protobuf-generated)

### 代码生成
- **Protobuf 编译器**: buf
- **生成目标**: 
  - Go: `backend/gen/highschool/v1/`
  - TypeScript: `frontend/src/gen/highschool/v1/`

## 目录结构

```
highschool/
├── backend/               # Go 后端服务
│   ├── cmd/api/           # 应用入口
│   ├── internal/          # 内部代码
│   │   ├── api/v1/        # Connect-RPC 服务实现
│   │   ├── domain/        # 领域层 (模拟引擎)
│   │   └── infrastructure/# 基础设施层
│   ├── gen/               # Protobuf 生成的 Go 代码
│   └── config.yaml        # 配置文件
│
├── frontend/              # Vue 3 前端项目
│   ├── src/
│   │   ├── views/         # 页面视图
│   │   ├── components/    # 组件
│   │   ├── stores/        # Pinia 状态管理
│   │   ├── api/           # Connect-RPC 客户端
│   │   ├── gen/           # Protobuf 生成的 TS 类型
│   │   └── utils/         # 工具函数
│   └── package.json
│
├── proto/                 # Protobuf 定义
│   └── highschool/v1/     # 服务定义
│       ├── candidate_service.proto
│       ├── reference_service.proto
│       └── *.proto
│
├── db/                    # 数据库SQL
│   ├── migrations/        # 表结构定义
│   └── seeds/             # 种子数据
│
├── docs/                  # 文档
│   ├── requirements.md
│   ├── technical-plan.md
│   └── reference.md
│
└── scripts/               # 脚本工具
```

## 快速开始

### 环境要求
- Go 1.24+
- Node.js 20+
- PostgreSQL 14+
- buf (protobuf 编译器)

### 1. 代码生成

修改 `.proto` 文件后，需要重新生成代码：

```bash
cd proto && buf generate
```

这将同时更新后端 Go 代码和前端 TypeScript 类型。

### 2. 安装后端

```bash
cd backend
go mod download

# 配置数据库连接
# 编辑 config.yaml 或设置环境变量

# 运行
go run cmd/api/main.go
```

后端将运行在 http://localhost:3000

### 3. 安装前端

```bash
cd frontend
npm install
npm run dev
```

前端将运行在 http://localhost:5173

### 4. 初始化数据库

```bash
# 创建数据库表
psql -U highschool -d highschool -f db/migrations/001_create_reference_tables_v2.sql
psql -U highschool -d highschool -f db/migrations/002_create_history_tables_v2.sql
psql -U highschool -d highschool -f db/migrations/003_create_simulation_history.sql

# 导入种子数据
psql -U highschool -d highschool -f db/seeds/000_seed_districts.sql
psql -U highschool -d highschool -f db/seeds/002_seed_schools_2025_v2.sql
psql -U highschool -d highschool -f db/seeds/015_seed_middle_schools_hp.sql
```

### 使用 Docker

```bash
# 启动 PostgreSQL
docker compose up -d
```

## API 说明

本项目使用 Connect-RPC 协议，支持 HTTP/JSON 和 gRPC 两种传输方式。

### 服务端点

| 服务 | 路径 |
|------|------|
| ReferenceService | `/highschool.v1.ReferenceService/*` |
| CandidateService | `/highschool.v1.CandidateService/*` |

### 健康检查

```bash
curl http://localhost:3000/health
```

### 测试 API (HTTP/JSON)

```bash
# 获取区县列表
curl -X POST http://localhost:3000/highschool.v1.ReferenceService/GetDistricts \
  -H "Content-Type: application/json" \
  -H "Connect-Protocol-Version: 1" \
  -d '{}'

# 获取学校列表
curl -X POST http://localhost:3000/highschool.v1.ReferenceService/GetSchools \
  -H "Content-Type: application/json" \
  -H "Connect-Protocol-Version: 1" \
  -d '{"page": 1, "pageSize": 10}'
```

## 功能特性

### 核心功能
1. **志愿分析**: 基于考生成绩和志愿，模拟录取概率
2. **策略评估**: 分析志愿梯度，提供优化建议
3. **历史记录**: 保存分析历史，支持数据脱敏

### 支持的批次
- 名额分配到区 (1个志愿)
- 名额分配到校 (2个志愿)
- 统一招生1-15志愿 (15个志愿)

## 数据来源

所有数据均来自官方权威来源:
- [上海招考热线](https://www.shmeea.edu.cn/)

## 许可证

MIT
