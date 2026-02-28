# 上海中考招生模拟系统 - 技术方案

## 项目概述

构建一个前后端分离的中考志愿分析系统，前端使用纯 Vue 3 SPA 实现，支持响应式布局适配移动端和桌面端。后端使用 Go + Connect-RPC 提供高性能 API 服务。

## 技术栈选型

### 后端技术栈

| 组件 | 技术选型 | 说明 |
|------|----------|------|
| 语言 | Go 1.24+ | 高性能、强类型、编译型语言 |
| RPC 框架 | Connect-RPC | 兼容 gRPC 和 HTTP/JSON，类型安全 |
| 协议定义 | Protocol Buffers | 强类型接口定义，代码生成 |
| 数据库 | PostgreSQL | 关系型数据库，支持 JSONB |
| 数据库驱动 | pgx | Go 语言高性能 PostgreSQL 驱动 |
| 代码生成 | buf | Protobuf 编译器和工具链 |

### 前端技术栈

| 组件 | 技术选型 | 说明 |
|------|----------|------|
| 框架 | Vue 3 + TypeScript | 组件化开发，Composition API |
| 路由 | Vue Router 4 | 单页应用路由管理 |
| 状态管理 | Pinia | Vue官方推荐，类型友好 |
| UI组件库 | Element Plus | 桌面端优秀体验 |
| 移动端适配 | 响应式布局 + vw/vh 单位 | 适配手机和平板 |
| RPC 客户端 | Connect-Web | 与后端共享 protobuf 类型 |
| 构建工具 | Vite | 快速开发，热更新 |
| 设备识别 | fingerprintjs | 生成设备指纹 |

### 类型共享方案

| 方案 | 实现 | 说明 |
|------|------|------|
| 定义 | Protocol Buffers | 单一数据源定义接口 |
| 后端生成 | protoc-gen-go + protoc-gen-connect-go | Go 结构体和服务接口 |
| 前端生成 | protoc-gen-es + protoc-gen-connect-es | TypeScript 类型和客户端 |

## 项目目录结构

```
highschool_new/
├── backend/                 # Go 后端服务
│   ├── cmd/
│   │   └── api/            # 应用入口
│   │       └── main.go
│   ├── internal/           # 内部代码
│   │   ├── api/v1/         # Connect-RPC 服务实现
│   │   │   ├── candidate_connect.go    # CandidateService
│   │   │   └── reference_connect.go    # ReferenceService
│   │   ├── domain/         # 领域层
│   │   │   └── simulation/ # 模拟引擎
│   │   │       ├── engine.go
│   │   │       └── competitor_generator.go
│   │   └── infrastructure/ # 基础设施层
│   │       └── database/   # 数据库连接管理
│   │           └── connection.go
│   ├── gen/                # Protobuf 生成的 Go 代码
│   │   └── highschool/v1/  # 生成的类型和服务接口
│   ├── config.yaml         # 配置文件
│   └── go.mod
│
├── frontend/               # 前端项目（Vue 3 SPA）
│   ├── src/
│   │   ├── views/          # 页面视图
│   │   │   ├── HomeView.vue
│   │   │   ├── FormView.vue
│   │   │   ├── ResultView.vue
│   │   │   └── HistoryView.vue
│   │   ├── components/     # 组件
│   │   │   ├── form/       # 表单组件
│   │   │   └── result/     # 结果展示组件
│   │   ├── stores/         # Pinia 状态管理
│   │   │   ├── candidate.ts
│   │   │   └── simulation.ts
│   │   ├── api/            # Connect-RPC 客户端
│   │   │   ├── connect.ts  # 客户端配置
│   │   │   ├── candidate.ts
│   │   │   └── reference.ts
│   │   ├── gen/            # Protobuf 生成的 TS 代码
│   │   │   └── highschool/v1/
│   │   ├── router/         # 路由配置
│   │   └── utils/          # 工具函数
│   ├── package.json
│   └── vite.config.ts
│
├── proto/                  # Protobuf 定义
│   └── highschool/v1/
│       ├── candidate_service.proto
│       ├── reference_service.proto
│       ├── candidate.proto
│       ├── school.proto
│       └── buf.gen.yaml    # 代码生成配置
│
├── db/                     # 数据库SQL
│   ├── migrations/
│   └── seeds/
│
├── docs/                   # 文档
│   ├── requirements.md
│   └── reference.md
│
└── scripts/                # 脚本工具
```

## 核心模块设计

### 1. Protobuf 服务定义

#### 服务接口

```protobuf
// reference_service.proto
service ReferenceService {
  rpc GetDistricts(GetDistrictsRequest) returns (GetDistrictsResponse);
  rpc GetSchools(GetSchoolsRequest) returns (GetSchoolsResponse);
  rpc GetSchoolDetail(GetSchoolDetailRequest) returns (SchoolDetail);
  rpc GetMiddleSchools(GetMiddleSchoolsRequest) returns (GetMiddleSchoolsResponse);
  rpc GetHistoryScores(GetHistoryScoresRequest) returns (GetHistoryScoresResponse);
  rpc GetDistrictExamCount(GetDistrictExamCountRequest) returns (GetDistrictExamCountResponse);
}

// candidate_service.proto
service CandidateService {
  rpc SubmitAnalysis(SubmitAnalysisRequest) returns (AnalysisResult);
  rpc GetAnalysisResult(GetAnalysisResultRequest) returns (AnalysisResult);
  rpc ListSimulationHistory(ListSimulationHistoryRequest) returns (ListSimulationHistoryResponse);
}
```

#### 消息定义示例

```protobuf
// 提交分析请求
message SubmitAnalysisRequest {
  string device_id = 1;
  CandidateInfo candidate = 2;
  CandidateScores scores = 3;
  RankingInfo ranking = 4;
  int32 comprehensive_quality = 5;
  Volunteers volunteers = 6;
}

message AnalysisResult {
  string id = 1;
  string device_id = 2;
  AnalysisStatus status = 3;
  Predictions predictions = 4;
  repeated Probability probabilities = 5;
  Strategy strategy = 6;
  Competitors competitors = 7;
  string created_at = 8;
}
```

### 2. 前端路由设计

```typescript
// router/index.ts
const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/HomeView.vue')
  },
  {
    path: '/form',
    name: 'Form',
    component: () => import('@/views/FormView.vue')
  },
  {
    path: '/result/:id',
    name: 'Result',
    component: () => import('@/views/ResultView.vue'),
    props: true
  },
  {
    path: '/history',
    name: 'History',
    component: () => import('@/views/HistoryView.vue')
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFoundView.vue')
  }
];
```

### 3. 前端状态管理设计

```typescript
// stores/candidate.ts
export const useCandidateStore = defineStore('candidate', () => {
  // 基本信息
  const districtId = ref<number | null>(null);
  const middleSchoolId = ref<number | null>(null);
  const hasQuotaSchoolEligibility = ref(false);
  
  // 成绩信息
  const scores = ref({
    total: 0,
    chinese: 0,
    math: 0,
    foreign: 0,
    integrated: 0,
    ethics: 0,
    history: 0,
    pe: 0
  });
  
  // 排名信息
  const ranking = ref({
    rank: 0,
    totalStudents: 0
  });
  
  // 综合素质评价
  const comprehensiveQuality = ref(50);
  
  // 志愿信息
  const volunteers = ref({
    quotaDistrict: null as number | null,
    quotaSchool: [] as number[],
    unified: [] as number[]
  });
  
  // 验证总分
  function validateScores(): boolean {
    const calculated = scores.value.chinese + scores.value.math + 
      scores.value.foreign + scores.value.integrated + 
      scores.value.ethics + scores.value.history + scores.value.pe;
    return calculated === scores.value.total;
  }
  
  return {
    districtId, middleSchoolId, hasQuotaSchoolEligibility,
    scores, ranking, comprehensiveQuality, volunteers,
    validateScores
  };
});
```

## 响应式布局设计

### 断点设计

```css
/* 移动端优先 */
:root {
  --breakpoint-sm: 640px;   /* 手机横屏 */
  --breakpoint-md: 768px;   /* 平板竖屏 */
  --breakpoint-lg: 1024px;  /* 平板横屏/小桌面 */
  --breakpoint-xl: 1280px;  /* 桌面 */
}
```

### 布局策略

1. **移动端 (< 768px)**：单列布局，底部固定操作栏
2. **平板 (768px - 1024px)**：两列布局，侧边导航
3. **桌面 (> 1024px)**：三列布局，居中内容区

## 代码生成流程

### 1. 定义 Protobuf

编辑 `proto/highschool/v1/*.proto` 文件定义服务和消息。

### 2. 生成代码

```bash
cd proto && buf generate
```

### 3. 生成文件位置

- **Go**: `backend/gen/highschool/v1/`
  - `*_pb.go` - 消息结构体
  - `*_connect.go` - 服务接口

- **TypeScript**: `frontend/src/gen/highschool/v1/`
  - `*_pb.ts` - 消息类型和序列化
  - `*_connect.ts` - 服务客户端

### 4. 使用生成的代码

**后端 (Go)**:
```go
import highschoolv1 "backend/gen/highschool/v1"

func (s *CandidateServiceServer) SubmitAnalysis(
  ctx context.Context,
  req *connect.Request[highschoolv1.SubmitAnalysisRequest],
) (*connect.Response[highschoolv1.AnalysisResult], error) {
  // 实现逻辑
}
```

**前端 (TypeScript)**:
```typescript
import { CandidateService } from '@/gen/highschool/v1/candidate_connect';
import { createPromiseClient } from '@connectrpc/connect';

const candidateClient = createPromiseClient(
  CandidateService,
  transport
);

const result = await candidateClient.submitAnalysis({
  deviceId: 'xxx',
  // ...
});
```

## 部署架构

```
┌─────────────────────────────────────────────────────────┐
│                       负载均衡                           │
│                 (Nginx / Cloud LB)                      │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼────────┐          ┌──────▼────────┐
│  后端服务实例1   │          │  后端服务实例2  │
│  (Go + Connect) │          │  (Go + Connect)│
└───────┬────────┘          └──────┬────────┘
        │                           │
        └───────────┬───────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
┌───────▼────────┐    ┌────────▼────────┐
│  PostgreSQL    │    │   (可选缓存)     │
│  (主从复制)     │    │                 │
└────────────────┘    └─────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    前端静态资源 (CDN)                     │
│              (Web H5 / 桌面浏览器)                       │
└─────────────────────────────────────────────────────────┘
```

## 开发环境配置

### 初始化项目

```bash
# 克隆仓库
git clone <repo>
cd highschool_new

# 安装 buf (protobuf 编译器)
# macOS
brew install bufbuild/buf/buf

# Linux
https://github.com/bufbuild/buf/releases

# 生成代码
cd proto && buf generate
```

### 启动后端

```bash
cd backend

# 安装依赖
go mod download

# 配置数据库 (编辑 config.yaml)
cp config.example.yaml config.yaml

# 运行
go run cmd/api/main.go

# 或使用 air 热重载
air
```

### 启动前端

```bash
cd frontend

# 安装依赖
npm install

# 开发服务器
npm run dev

# 类型检查
npm run type-check

# 构建
npm run build
```

## 模拟历史持久化

### 需求说明
1. 每个考生的模拟历史需要持久化保存
2. 通过设备ID识别同一考生
3. 历史数据用于优化虚拟竞争对手生成算法

### 数据库设计

```sql
-- 模拟历史记录表
CREATE TABLE simulation_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(255) NOT NULL,           -- 设备指纹
    device_info JSONB,                         -- 设备信息（平台、型号等）
    candidate_data JSONB NOT NULL,             -- 考生输入数据（脱敏）
    simulation_result JSONB NOT NULL,          -- 模拟结果
    created_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT idx_device_created UNIQUE (device_id, created_at)
);

CREATE INDEX idx_simulation_history_device ON simulation_history(device_id, created_at DESC);
```

### 设备识别机制

| 平台 | 识别方案 |
|------|----------|
| Web H5 | fingerprintjs 生成设备指纹 |

**设备指纹组成**（Web端）：
```typescript
interface DeviceFingerprint {
  userAgent: string;
  screenResolution: string;
  timezone: string;
  language: string;
  canvas: string;  // Canvas指纹
  // 最终生成 hash 值
}
```

### 虚拟竞争对手生成算法

```go
// domain/simulation/competitor_generator.go
type CompetitorGenerator struct {
    baseCount    int
    scoreRange   float64
}

func (g *CompetitorGenerator) Generate(
    candidateScore int,
    districtId int32,
    count int,
) []*Competitor {
    competitors := make([]*Competitor, count)
    
    for i := 0; i < count; i++ {
        // 在考生分数附近生成竞争对手
        score := g.generateScore(candidateScore)
        competitors[i] = &Competitor{
            Score: score,
            // ...
        }
    }
    
    return competitors
}
```

### 数据脱敏处理

为了保护隐私，存储的候选数据需要脱敏：

```go
// 存储前脱敏
type AnonymizedCandidateData struct {
    DistrictID        int32  `json:"districtId"`
    MiddleSchoolID    int32  `json:"middleSchoolId"`
    ScoreRange        string `json:"scoreRange"`  // "700-710" 而非精确分数
    SchoolType        string `json:"schoolType"`
}
```

## 技术决策总结

| 决策项 | 选择 | 说明 |
|--------|------|------|
| 后端语言 | **Go 1.24+** | 高性能、强类型、易于部署 |
| 通信协议 | **Connect-RPC + Protobuf** | 类型安全、支持 HTTP/JSON 和 gRPC |
| 前端框架 | **Vue 3 SPA** | 单页应用，更好的交互体验 |
| UI组件库 | **Element Plus** | 功能完善，支持响应式 |
| 用户认证 | **设备识别（无登录）** | 使用设备指纹，无需注册 |
| 模拟方式 | **同步计算** | 1000次模拟在 500ms 内完成 |
| 类型共享 | **Protobuf 代码生成** | 前后端共享同一份类型定义 |
| 数据库 | **PostgreSQL** | 关系型数据库，支持 JSONB 存储 |

## 待实现文件清单

### 阶段一：Protobuf 定义
- [x] `proto/highschool/v1/candidate.proto` - 考生相关消息
- [x] `proto/highschool/v1/school.proto` - 学校相关消息
- [x] `proto/highschool/v1/reference_service.proto` - 参考数据服务
- [x] `proto/highschool/v1/candidate_service.proto` - 考生服务
- [x] `proto/buf.gen.yaml` - 代码生成配置

### 阶段二：后端核心
- [x] `backend/internal/api/v1/reference_connect.go` - ReferenceService 实现
- [x] `backend/internal/api/v1/candidate_connect.go` - CandidateService 实现
- [x] `backend/internal/domain/simulation/engine.go` - 模拟引擎
- [x] `backend/internal/domain/simulation/competitor_generator.go` - 竞争对手生成器
- [x] `backend/internal/infrastructure/database/connection.go` - 数据库连接

### 阶段三：前端核心
- [x] `frontend/src/api/connect.ts` - Connect-RPC 客户端配置
- [x] `frontend/src/api/candidate.ts` - CandidateService 客户端
- [x] `frontend/src/api/reference.ts` - ReferenceService 客户端
- [x] `frontend/src/stores/candidate.ts` - 考生状态管理
- [x] `frontend/src/views/FormView.vue` - 志愿填报页
- [x] `frontend/src/views/ResultView.vue` - 分析结果页
- [x] `frontend/src/views/HistoryView.vue` - 历史记录页

### 阶段四：数据库
- [x] `db/migrations/001_create_reference_tables_v2.sql` - 参考数据表
- [x] `db/migrations/002_create_history_tables_v2.sql` - 历史分数表
- [x] `db/migrations/003_create_simulation_history.sql` - 模拟历史表
