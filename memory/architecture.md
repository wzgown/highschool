# 架构详细说明

## 后端分层 DDD 详解

### 1. API 层 (`internal/api/v1/`)

**职责**：
- Connect-RPC 服务实现
- 协议转换（Protobuf ←→ 内部模型）
- HTTP 参数校验
- 错误响应格式化

**文件**：
- `reference_connect.go` - ReferenceService 实现
- `candidate_connect.go` - CandidateService 实现

### 2. Service 层 (`internal/service/`)

**职责**：
- 业务逻辑编排
- 跨 domain 协调
- 事务边界管理

**文件**：
- `reference_service.go` - 参考数据服务
- `candidate_service.go` - 候选人分析服务

### 3. Domain 层 (`internal/domain/`)

**职责**：
- 核心业务规则实现
- 录取模拟引擎
- 纯业务逻辑，无外部依赖

**文件**：
- `simulation/engine.go` - 模拟引擎核心
- `simulation/competitor_generator.go` - 虚拟竞争对手生成器

### 4. Repository 层 (`internal/repository/`)

**职责**：
- 数据库 CRUD 操作
- SQL 查询封装
- 数据模型转换

**文件**：
- `district_repository.go` - 区县数据
- `school_repository.go` - 学校数据
- `middle_school_repository.go` - 初中学校数据
- `simulation_history.go` - 模拟历史数据

### 5. Infrastructure 层 (`internal/infrastructure/`)

**职责**：
- 数据库连接管理
- 外部服务集成

**文件**：
- `database/connection.go` - PostgreSQL 连接池

## 前端架构详解

### 状态管理 (Pinia)

```typescript
// stores/candidate.ts - 考生信息
// stores/simulation.ts - 模拟状态
```

### API 客户端

```typescript
// api/connect.ts - Connect-RPC 客户端配置
// api/candidate.ts - CandidateService 客户端
// api/reference.ts - ReferenceService 客户端
```

## 数据流

```
用户输入 (Vue 组件)
  → Pinia Store 状态管理
  → Connect-RPC 客户端
  → HTTP/JSON 传输
  → 后端 API 层
  → Service 层业务逻辑
  → Domain 层核心算法
  → Repository 层数据访问
  → PostgreSQL 数据库
```

## 测试架构

```
单元测试（TDD）：
  - domain/ 层：纯函数测试，覆盖率 93.3%
  - service/ 层：业务逻辑测试，使用 mock
  - api/ 层：协议转换测试
  - repository/ 层：数据访问测试
```
