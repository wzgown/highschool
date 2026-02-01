# 上海中考招生模拟系统 - 技术方案

## 项目概述

构建一个前后端分离的中考志愿分析系统，支持多平台前端（Web/H5/微信小程序/Android App）。

## 技术栈选型

### 后端技术栈

| 组件 | 技术选型 | 说明 |
|------|----------|------|
| 语言 | Node.js + TypeScript | 与前端共享类型定义，降低联调成本 |
| 框架 | Fastify | 高性能、插件化，比Express快2倍 |
| ORM | Drizzle ORM | 轻量级、类型安全、SQL可控性强 |
| 数据库 | PostgreSQL | 已有完整SQL设计 |
| 缓存 | Redis | 模拟结果缓存 |
| 计算加速 | Worker Threads | 模拟引擎放入Worker，不阻塞主线程 |

> **技术栈决策说明**：选择Node.js而非Golang的核心原因是**前后端类型共享**。模拟计算使用Worker Threads处理，性能足够。未来如需优化，可将模拟引擎单独拆分为Go微服务。

### 前端技术栈

| 组件 | 技术选型 | 说明 |
|------|----------|------|
| 框架 | Vue 3 + TypeScript | 组件化开发 |
| 多平台框架 | uni-app | 一套代码编译到多端 |
| 状态管理 | Pinia | Vue官方推荐 |
| UI组件库 | uni-ui (H5/小程序) + Element Plus (Web) |
| 构建工具 | Vite | 快速开发 |
| 设备识别 | fingerprintjs (Web) / uni.getSystemInfo (小程序) | 生成设备指纹 |

## 项目目录结构

```
highschool_new/
├── backend/                 # 后端服务
│   ├── src/
│   │   ├── api/            # API路由定义
│   │   │   ├── v1/         # v1版本API
│   │   │   │   ├── candidate.ts      # 考生相关API
│   │   │   │   ├── simulation.ts     # 模拟分析API
│   │   │   │   ├── admin.ts          # 管理员API
│   │   │   │   └── reference.ts      # 参考数据API
│   │   ├── domain/        # 领域层
│   │   │   ├── candidate/ # 考生领域
│   │   │   ├── school/    # 学校领域
│   │   │   ├── simulation/# 模拟引擎
│   │   │   └── admission/ # 录取规则
│   │   ├── infrastructure/ # 基础设施层
│   │   │   ├── database/  # 数据库访问
│   │   │   ├── cache/     # 缓存
│   │   │   └── queue/     # 任务队列
│   │   ├── application/   # 应用服务层
│   │   │   ├── services/  # 服务实现
│   │   │   └── dto/       # 数据传输对象
│   │   ├── shared/        # 共享模块
│   │   │   ├── types/     # 类型定义
│   │   │   ├── utils/     # 工具函数
│   │   │   └── constants/ # 常量
│   │   ├── main.ts        # 入口文件
│   │   └── app.ts         # 应用配置
│   ├── prisma/            # Prisma配置
│   │   ├── schema.prisma  # 数据模型
│   │   └── migrations/    # 迁移记录
│   ├── test/              # 测试
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/              # 前端项目（uni-app Vue3）
│   ├── src/
│   │   ├── pages/         # 页面
│   │   │   ├── index/     # 首页
│   │   │   ├── form/      # 志愿填报页
│   │   │   ├── result/    # 分析结果页
│   │   │   └── admin/     # 管理员页面
│   │   ├── components/    # 组件
│   │   ├── composables/   # 组合式API
│   │   ├── stores/        # Pinia状态管理
│   │   ├── api/           # API调用
│   │   ├── types/         # 类型定义
│   │   ├── utils/         # 工具函数
│   │   ├── App.vue
│   │   └── main.ts
│   ├── platforms/         # 平台特定配置
│   │   ├── h5/
│   │   ├── mp-weixin/
│   │   └── app/
│   ├── package.json
│   ├── vite.config.ts
│   └── tsconfig.json
│
├── shared/                # 前后端共享类型
│   └── types/
│       ├── candidate.ts
│       ├── school.ts
│       ├── simulation.ts
│       └── api.ts
│
├── db/                    # 数据库SQL（已有）
│   ├── migrations/
│   └── seeds/
│
├── docs/                  # 文档（已有）
│   ├── requirements.md
│   └── reference.md
│
├── scripts/               # 脚本工具
│   ├── setup.sh           # 环境初始化
│   └── deploy.sh          # 部署脚本
│
└── README.md
```

## 核心模块设计

### 1. 后端API设计

#### RESTful API规范

```
BASE_URL: /api/v1

# 考生相关
POST   /candidates/analysis          # 提交模拟分析请求
GET    /candidates/analysis/{id}     # 获取分析结果
GET    /candidates/analysis/{id}/pdf # 导出PDF报告
GET    /candidates/history           # 获取历史记录
DELETE /api/v1/candidates/history/{id}  # 删除单条记录

# 参考数据
GET    /reference/districts          # 获取区县列表
GET    /reference/schools            # 获取学校列表
GET    /reference/schools/{id}       # 获取学校详情
GET    /reference/middle-schools     # 获取初中学校列表
GET    /reference/history-scores     # 获取历年分数线

# 管理员API
POST   /admin/data/import            # 导入数据
GET    /admin/data/import/{id}       # 获取导入状态
GET    /admin/data/schools           # 管理学校信息
PUT    /admin/data/schools/{id}      # 更新学校信息
GET    /admin/data/districts         # 管理区县信息
```

#### 数据传输对象（DTO）示例

```typescript
// 提交分析请求
interface SubmitAnalysisRequest {
  candidate: {
    districtId: number;
    middleSchoolId: number;
    hasQuotaSchoolEligibility: boolean;
  };
  scores: {
    total: number;           // 0-750
    chinese: number;
    math: number;
    foreign: number;
    integrated: number;
    ethics: number;
    history: number;
    pe: number;
  };
  ranking: {
    rank: number;
    totalStudents: number;
  };
  comprehensiveQuality: number; // 默认50
  volunteers: {
    quotaDistrict: number | null;      // school_id
    quotaSchool: [number, number];     // 最多2个
    unified: number[];                 // 最多15个
  };
}

// 分析结果响应
interface AnalysisResultResponse {
  id: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  results?: {
    predictions: {
      districtRank: number;
      districtRankRange: [number, number];
      confidence: 'high' | 'medium' | 'low';
    };
    probabilities: {
      batch: 'QUOTA_DISTRICT' | 'QUOTA_SCHOOL' | 'UNIFIED';
      schoolId: number;
      schoolName: string;
      probability: number;      // 0-100
      riskLevel: 'safe' | 'moderate' | 'risky' | 'high_risk';
      scoreDiff: number | null; // 与历年分对比
    }[];
    strategy: {
      score: number;            // 策略评分
      gradient: {
        reach: number;          // 冲刺志愿数
        target: number;         // 稳妥志愿数
        safety: number;         // 保底志愿数
      };
      suggestions: string[];
      warnings: string[];
    };
    competitors: {
      count: number;
      scoreDistribution: {
        range: string;
        count: number;
      }[];
    };
  };
  createdAt: string;
}
```

### 2. 核心领域模块

#### 模拟引擎（Simulation Engine）

```typescript
// domain/simulation/engine.ts
class AdmissionSimulationEngine {
  async simulate(request: AnalysisRequest): Promise<SimulationResult> {
    // 1. 预测考生区内排名
    const districtRank = await this.rankPredictor.predict(request);

    // 2. 生成虚拟竞争对手
    const competitors = await this.competitorGenerator.generate(
      request,
      districtRank
    );

    // 3. 执行N次模拟
    const simulationRuns = await this.runMultipleSimulations(
      request,
      competitors,
      this.config.simulationCount // 默认1000次
    );

    // 4. 统计概率
    const probabilities = this.calculateProbabilities(simulationRuns);

    // 5. 分析策略
    const strategy = await this.strategyAnalyzer.analyze(
      request,
      probabilities
    );

    return { probabilities, strategy, competitors };
  }
}
```

#### 录取规则引擎（Admission Rules）

```typescript
// domain/admission/rules.ts
class AdmissionRulesEngine {
  // 按批次执行录取
  async executeByBatch(
    candidates: Candidate[],
    batch: AdmissionBatch
  ): Promise<AdmissionResult[]> {
    const sortedCandidates = this.sortByScoreAndTieBreaker(candidates);
    const results: AdmissionResult[] = [];

    for (const candidate of sortedCandidates) {
      // 检查是否已被录取
      if (candidate.isAdmitted) continue;

      // 平行志愿投档
      const result = this.parallelVolunteerAdmission(candidate, batch);
      results.push(result);
    }

    return results;
  }

  // 平行志愿录取
  private parallelVolunteerAdmission(
    candidate: Candidate,
    batch: AdmissionBatch
  ): AdmissionResult {
    for (const volunteer of candidate.volunteers) {
      const school = this.getSchool(volunteer.schoolId);
      if (school.hasRemainingQuota) {
        return AdmissionResult.admitted(school, volunteer);
      }
    }
    return AdmissionResult.notAdmitted();
  }

  // 同分比较
  private sortByScoreAndTieBreaker(
    candidates: Candidate[]
  ): Candidate[] {
    return candidates.sort((a, b) => {
      // 总分比较
      if (a.totalScore !== b.totalScore) {
        return b.totalScore - a.totalScore;
      }

      // 6位序比较
      return this.compareByTieBreaker(a, b);
    });
  }

  private compareByTieBreaker(a: Candidate, b: Candidate): number {
    // 1. 同分优待
    if (a.isTiePreferred !== b.isTiePreferred) {
      return a.isTiePreferred ? -1 : 1;
    }
    // 2. 综合素质评价
    if (a.comprehensiveQuality !== b.comprehensiveQuality) {
      return b.comprehensiveQuality - a.comprehensiveQuality;
    }
    // 3. 语数外合计
    if (a.chineseMathForeignSum !== b.chineseMathForeignSum) {
      return b.chineseMathForeignSum - a.chineseMathForeignSum;
    }
    // 4. 数学
    if (a.mathScore !== b.mathScore) {
      return b.mathScore - a.mathScore;
    }
    // 5. 语文
    if (a.chineseScore !== b.chineseScore) {
      return b.chineseScore - a.chineseScore;
    }
    // 6. 综合测试
    return b.integratedTestScore - a.integratedTestScore;
  }
}
```

### 3. 前端页面设计

#### 主要页面

| 页面 | 路径 | 说明 |
|------|------|------|
| 首页 | /pages/index/index | 系统介绍、入口 |
| 志愿填报 | /pages/form/index | 填写考生信息和志愿 |
| 分析中 | /pages/loading/index | 模拟进行中动画 |
| 分析结果 | /pages/result/index | 展示分析报告 |
| 历史对比 | /pages/history/index | 历年分数线对比 |
| 管理员登录 | /pages/admin/login | 管理员入口 |
| 数据导入 | /pages/admin/import | CSV数据导入 |
| 学校管理 | /pages/admin/schools | 学校信息管理 |

#### 核心组件

```
components/
├── CandidateForm/           # 考生信息表单
├── VolunteerSelector/       # 志愿选择器
├── ScoreInput/              # 成绩输入
├── ProbabilityChart/        # 概率图表
├── StrategyAnalysis/        # 策略分析展示
├── SchoolSelector/          # 学校选择器（支持搜索/筛选）
├── CompetitorDisplay/       # 竞争对手展示
└── Admin/
    ├── DataImport/          # 数据导入
    └── SchoolManager/       # 学校管理
```

## 类型共享方案

### 共享类型目录

```
shared/
├── types/
│   ├── candidate.ts         # 考生相关类型
│   ├── school.ts            # 学校相关类型
│   ├── simulation.ts        # 模拟相关类型
│   └── api.ts               # API通用类型
└── constants/
    ├── admission.ts         # 录取相关常量
    └── district.ts          # 区县常量
```

### TypeScript类型导出

```typescript
// shared/types/candidate.ts
export interface Candidate {
  id: string;
  districtId: number;
  middleSchoolId: number;
  scores: CandidateScores;
  ranking: CandidateRanking;
  volunteers: CandidateVolunteers;
}

// 后端使用
import { Candidate } from '@/shared/types/candidate';

// 前端使用
import type { Candidate } from '@/shared/types/candidate';
```

## 部署架构

```
┌─────────────────────────────────────────────────────────┐
│                       负载均衡                           │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼────────┐          ┌──────▼────────┐
│  后端服务实例1   │          │  后端服务实例2  │
│  (Node.js)      │          │  (Node.js)     │
└───────┬────────┘          └──────┬────────┘
        │                           │
        └───────────┬───────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
┌───────▼────────┐    ┌────────▼────────┐
│  PostgreSQL    │    │     Redis       │
│  (主从复制)     │    │   (缓存/队列)    │
└────────────────┘    └─────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    前端静态资源                          │
│  (CDN: Web H5 / 微信小程序 / Android APK)              │
└─────────────────────────────────────────────────────────┘
```

## 开发环境配置

```bash
# 安装依赖
npm install

# 初始化数据库
npm run db:init
npm run db:seed

# 启动后端开发服务
npm run dev:backend

# 启动前端开发服务
npm run dev:frontend

# 类型检查
npm run type-check

# 测试
npm run test
```

## 新增需求：模拟历史持久化

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
    INDEX idx_device_created (device_id, created_at)
);

-- 虚拟竞争对手生成记录（用于算法优化）
CREATE TABLE competitor_generation_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(255) NOT NULL,
    candidate_score_range VARCHAR(20),         -- 考生分数区间
    generated_competitors JSONB NOT NULL,      -- 生成的竞争对手数据
    actual_success_rate DECIMAL(5,2),          -- 实际成功率（用于验证）
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 设备识别机制

| 平台 | 识别方案 |
|------|----------|
| Web H5 | fingerprintjs 生成设备指纹 |
| 微信小程序 | uni.getSystemInfo() + 微信openid |
| Android App | 设备唯一标识（需授权） |

**设备指纹组成**（Web端）：
```typescript
interface DeviceFingerprint {
  userAgent: string;
  screenResolution: string;
  timezone: string;
  language: string;
  canvas: string;  // Canvas指纹
  // ... 其他特征
  // 最终生成 hash 值
}
```

### 虚拟竞争对手生成算法优化

```typescript
// 原始算法：纯随机生成
class CompetitorGenerator {
  generate(candidateScore: number, count: number): Competitor[] {
    // 在 candidateScore ± 30分范围内随机生成
  }
}

// 优化算法：基于历史数据
class SmartCompetitorGenerator {
  constructor(private historyRepository: HistoryRepository) {}

  async generate(candidate: Candidate, count: number): Promise<Competitor[]> {
    // 1. 获取相似考生的历史数据
    const historyData = await this.historyRepository.findSimilarCandidates(
      candidate.scoreRange,
      candidate.districtId
    );

    // 2. 分析这些考生的实际志愿分布
    const volunteerDistribution = this.analyzeVolunteerPattern(historyData);

    // 3. 生成更真实的竞争对手
    //    - 分数分布基于历史数据
    //    - 志愿选择符合实际规律
    return this.generateFromDistribution(volunteerDistribution, count);
  }

  // 验证生成质量
  async validate(): Promise<boolean> {
    const recentPredictions = await this.getRecentPredictions();
    const accuracy = this.calculateAccuracy(recentPredictions);
    return accuracy > 0.7; // 目标准确率70%
  }
}
```

### 数据脱敏处理

为了保护隐私，存储的候选数据需要脱敏：

```typescript
interface AnonymizedCandidateData {
  // 不存储：真实姓名、身份证号、联系方式
  districtId: number;
  middleSchoolId: number;
  scoreRange: string;  // "700-710" 而非精确分数
  schoolType: string;
  // ... 其他非敏感信息
}
```

### 考生历史查询API

```
GET /api/v1/candidates/history?deviceId=xxx
Response:
{
  "histories": [
    {
      "id": "uuid",
      "createdAt": "2025-02-01T10:00:00Z",
      "summary": {
        "totalVolunteers": 18,
        "safeCount": 5,
        "moderateCount": 8,
        "riskyCount": 5
      },
      "result": { ... }  // 完整结果
    }
  ],
  "total": 12
}

DELETE /api/v1/candidates/history/{id}  // 删除单条记录
DELETE /api/v1/candidates/history       // 删除该设备所有记录
```

---

## 技术决策总结

| 决策项 | 选择 | 说明 |
|--------|------|------|
| 后端框架 | **Fastify + TypeScript** | 高性能，与前端共享类型 |
| Android App | **暂不考虑** | 优先Web/H5/小程序，后期可加 |
| 用户认证 | **设备识别（无登录）** | 使用设备指纹，无需注册 |
| 模拟方式 | **异步任务 + WebSocket** | 提交后后台计算，实时推送进度 |
| 模拟次数 | **1000次** | 平衡准确度与性能 |
| 历史数据 | **持久化 + 算法优化** | 用于改进虚拟竞争对手生成 |

---

## 待实现文件清单

### 阶段一：项目初始化
- [ ] `/backend/package.json` - 后端依赖配置
- [ ] `/backend/tsconfig.json` - TypeScript配置
- [ ] `/backend/src/main.ts` - 后端入口
- [ ] `/backend/src/shared/types/` - 共享类型定义
- [ ] `/frontend/package.json` - 前端依赖配置
- [ ] `/frontend/vite.config.ts` - Vite配置
- [ ] `/frontend/src/main.ts` - 前端入口

### 阶段二：核心模块
- [ ] `/backend/src/domain/admission/rules.ts` - 录取规则引擎
- [ ] `/backend/src/domain/simulation/engine.ts` - 模拟引擎
- [ ] `/backend/src/domain/simulation/competitor-generator.ts` - 竞争对手生成器
- [ ] `/backend/src/infrastructure/database/` - 数据库访问层

### 阶段三：API层
- [ ] `/backend/src/api/v1/candidate.ts` - 考生相关API
- [ ] `/backend/src/api/v1/reference.ts` - 参考数据API
- [ ] `/backend/src/api/v1/admin.ts` - 管理员API

### 阶段四：前端页面
- [ ] `/frontend/src/pages/form/index.vue` - 志愿填报页
- [ ] `/frontend/src/pages/result/index.vue` - 分析结果页
- [ ] `/frontend/src/pages/history/index.vue` - 历史记录页

### 阶段五：数据库扩展
- [ ] `/db/migrations/003_add_simulation_history.sql` - 历史记录表
