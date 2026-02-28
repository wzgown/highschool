# Highschool Backend (Go)

上海中考招生模拟系统后端 - Go 实现

## 技术栈

- **语言**: Go 1.21+
- **Web框架**: Gin
- **数据库**: PostgreSQL (pgx)
- **缓存**: Redis
- **配置**: Viper
- **日志**: Zap

## 目录结构

```
backend-go/
├── cmd/api/              # 应用入口
├── internal/
│   ├── api/              # API 层
│   │   ├── middleware/   # 中间件
│   │   └── v1/           # API v1 处理器
│   ├── domain/           # 领域层
│   │   ├── admission/    # 录取规则
│   │   └── simulation/   # 模拟引擎
│   ├── infrastructure/   # 基础设施层
│   │   └── database/     # 数据库连接
│   └── shared/           # 共享代码
│       ├── constants/    # 常量定义
│       ├── types/        # 类型定义
│       └── utils/        # 工具函数
├── pkg/                  # 公共包
│   ├── config/           # 配置管理
│   └── logger/           # 日志
├── config.yaml           # 配置文件
├── go.mod                # Go 模块
└── Makefile              # 构建脚本
```

## 快速开始

### 1. 安装依赖

```bash
cd backend-go
go mod download
```

### 2. 配置

编辑 `config.yaml` 或设置环境变量:

```yaml
server:
  host: 0.0.0.0
  port: 3000
  mode: development

database:
  host: localhost
  port: 5432
  name: highschool
  user: highschool
  password: HS2025!db#SecurePass88
  ssl_mode: disable
```

### 3. 运行

```bash
make run
# 或
go run cmd/api/main.go
```

### 4. 构建

```bash
make build
./bin/api
```

## API 端点

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /health | 健康检查 |
| GET | /api/v1/reference/districts | 获取区县列表 |
| GET | /api/v1/reference/middle-schools | 获取初中学校列表 |
| GET | /api/v1/reference/schools | 获取高中学校列表 |
| GET | /api/v1/reference/schools/:id | 获取学校详情 |
| POST | /api/v1/candidates/analysis | 提交模拟分析 |
| GET | /api/v1/candidates/analysis/:id | 获取分析结果 |
| GET | /api/v1/candidates/history | 获取历史记录 |

## 环境变量

所有配置项都可以通过环境变量设置，前缀为 `HS_`:

- `HS_SERVER_HOST` - 服务器地址
- `HS_SERVER_PORT` - 服务器端口
- `HS_DATABASE_HOST` - 数据库地址
- `HS_DATABASE_PASSWORD` - 数据库密码

## 数据库

使用现有 PostgreSQL 数据库，表结构已在 `db/migrations/` 中定义。
