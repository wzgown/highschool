# 上海中考招生模拟系统

## 项目概述

这是一个前后端分离的中考志愿分析系统，支持多平台前端（Web/H5/微信小程序）。

## 技术栈

### 后端
- **语言**: Node.js + TypeScript
- **框架**: Fastify
- **ORM**: Drizzle ORM
- **数据库**: PostgreSQL
- **缓存**: Redis

### 前端
- **框架**: Vue 3 + TypeScript
- **多平台**: uni-app
- **状态管理**: Pinia
- **构建工具**: Vite

## 目录结构

```
highschool/
├── backend/                 # 后端服务
│   ├── src/
│   │   ├── api/v1/         # API路由
│   │   ├── domain/         # 领域层
│   │   ├── infrastructure/ # 基�设施层
│   │   └── shared/         # 共享模块
│   └── package.json
│
├── frontend/              # 前端项目
│   ├── src/
│   │   ├── pages/         # 页面
│   │   ├── components/    # 组件
│   │   ├── composables/   # 组合式API
│   │   ├── stores/        # Pinia状态管理
│   │   └── api/           # API调用
│   └── package.json
│
├── shared/                # 前后端共享类型和常量
│   ├── types/             # TypeScript 类型定义
│   └── constants/         # 枚举和常量定义（已优化，不再存储在数据库）
│
├── db/                    # 数据库SQL
│   ├── migrations/        # 表结构定义
│   │   ├── 001_create_reference_tables_v2.sql    # 参考数据表（优化版）
│   │   └── 002_create_history_tables_v2.sql      # 历史数据表（优化版）
│   └── seeds/             # 种子数据
│       ├── 001_seed_control_score_v2.sql         # 最低投档控制分数线
│       ├── 002_seed_schools_2025_v2.sql         # 2025年学校名单
│       ├── 003_seed_quota_allocation_district_2025.sql  # 名额分配到区计划
│       ├── 010_seed_district_exam_count.sql       # 各区中考人数
│       ├── 020_seed_2024_jiading_quota_school_v2.sql     # 2024年嘉定名额分配到校
│       ├── 021_seed_2024_jiading_admission_quota_district.sql  # 2024年嘉定名额分配到区分数线
│       ├── 022_seed_2024_jiading_admission_quota_school.sql   # 2024年嘉定名额分配到校分数线
│       └── 023_seed_2024_jiading_admission_unified_fixed.sql # 2024年嘉定1-15志愿分数线
│
├── scripts/               # 脚本工具
│   ├── setup.sh           # 环境初始化
│   └── deploy.sh          # 部署脚本
│
└── docs/                  # 文档
    ├── requirements.md
    ├── reference.md
    └── technical-plan.md
```

## 快速开始

### 环境要求
- Node.js >= 20.0.0
- PostgreSQL >= 14
- Redis >= 6.0

### 安装依赖

```bash
# 安装后端依赖
cd backend
npm install

# 安装前端依赖
cd ../frontend
npm install
```

### 配置环境变量

```bash
# 后端配置
cp backend/.env.example backend/.env
# 编辑 backend/.env 配置数据库等信息

# 前端配置
cp frontend/.env.h5.example frontend/.env.h5
# 编辑 frontend/.env.h5 配置API地址
```

### 初始化数据库

```bash
# 执行数据库迁移（使用优化后的脚本）
psql -U highschool -d highschool -f db/migrations/001_create_reference_tables_v2.sql
psql -U highschool -d highschool -f db/migrations/002_create_history_tables_v2.sql

# 导入种子数据（使用优化后的脚本）
psql -U highschool -d highschool -f db/seeds/001_seed_control_score_v2.sql
psql -U highschool -d highschool -f db/seeds/002_seed_schools_2025_v2.sql
psql -U highschool -d highschool -f db/seeds/003_seed_quota_allocation_district_2025.sql
psql -U highschool -d highschool -f db/seeds/010_seed_district_exam_count.sql
psql -U highschool -d highschool -f db/seeds/020_seed_2024_jiading_quota_school_v2.sql
psql -U highschool -d highschool -f db/seeds/021_seed_2024_jiading_admission_quota_district.sql
psql -U highschool -d highschool -f db/seeds/022_seed_2024_jiading_admission_quota_school.sql
psql -U highschool -d highschool -f db/seeds/023_seed_2024_jiading_admission_unified_fixed.sql
```

### 使用 Docker

```bash
# 启动 PostgreSQL 和 Redis
cd /root/.openclaw/workspace/highschool
docker compose up -d

# 检查容器状态
docker ps
```

### 启动开发服务

```bash
# 启动后端 (终端1)
cd backend
npm run dev

# 启动前端 (终端2)
cd frontend
npm run dev:h5
```

## API文档

启动后端服务后访问: http://localhost:3000/docs

## 功能特性

### 核心功能
1. **志愿分析**: 基于考生成绩和志愿，模拟录取概率
2. **策略评估**: 分析志愿梯度，提供优化建议
3. **历史记录**: 保存分析历史，支持数据脱敏
4. **实时更新**: WebSocket支持模拟进度推送

### 支持的批次
- 名额分配到区 (1个志愿)
- 名额分配到校 (2个志愿)
- 统一招生1-15志愿 (15个志愿)

## 核心模块

### 模拟引擎
- 区内排名预测
- 虚拟竞争对手生成
- 多次蒙特卡洛模拟
- 概率统计分析

### 录取规则引擎
- 平行志愿录取
- 同分比较(6位序)
- 批次顺序录取

## 数据库设计优化

### 优化说明
为了减少数据库复杂度，将枚举类型的常量数据从数据库中移除，改为代码常量：

**已删除的常量表（已迁移到代码）：**
- `ref_school_nature` → `shared/constants/index.ts` 中的 `SchoolNature` 枚举
- `ref_school_type` → `shared/constants/index.ts` 中的 `SchoolType` 枚举
- `ref_boarding_type` → `shared/constants/index.ts` 中的 `BoardingType` 枚举
- `ref_admission_batch` → `shared/constants/index.ts` 中的 `AdmissionBatch` 枚举
- `ref_subject` → `shared/constants/index.ts` 中的 `Subject` 枚举

**修改的表（使用常量代码代替外键）：**
- `ref_school` 表的 `school_nature_id`, `school_type_id`, `boarding_type_id` 改为 VARCHAR 类型
- `ref_middle_school` 表的 `school_nature_id` 改为 VARCHAR 类型
- `ref_control_score` 表的 `admission_batch_id` 改为 VARCHAR 类型

**保留的数据表：**
- `ref_district` - 上海16个区（保留，因为可能有动态变化）
- `ref_school` - 学校主表
- `ref_quota_allocation_district` - 名额分配到区计划
- `ref_middle_school` - 初中学校表
- `ref_quota_allocation_school` - 名额分配到校计划
- `ref_district_exam_count` - 各区中考人数
- `ref_admission_score_quota_district` - 名额分配到区录取分数线
- `ref_admission_score_quota_school` - 名额分配到校录取分数线
- `ref_admission_score_unified` - 1-15志愿录取分数线
- `ref_control_score` - 最低投档控制分数线

## 脚本命令

```bash
# 环境初始化
bash scripts/setup.sh

# 部署到服务器
bash scripts/deploy.sh
```

## 数据来源

所有数据均来自官方权威来源:
- [上海招考热线](https://www.shmeea.edu.cn/)

## 许可证

MIT
