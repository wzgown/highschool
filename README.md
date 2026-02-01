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
highschool_new/
├── backend/                 # 后端服务
│   ├── src/
│   │   ├── api/v1/         # API路由
│   │   ├── domain/         # 领域层
│   │   ├── infrastructure/ # 基础设施层
│   │   ├── shared/         # 共享模块
│   │   └── main.ts         # 入口文件
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/              # 前端项目
│   ├── src/
│   │   ├── pages/         # 页面
│   │   ├── components/    # 组件
│   │   ├── composables/   # 组合式API
│   │   ├── stores/        # Pinia状态管理
│   │   └── api/           # API调用
│   ├── package.json
│   └── vite.config.ts
│
├── shared/                # 前后端共享类型
│   ├── types/
│   └── constants/
│
├── db/                    # 数据库SQL
│   ├── migrations/
│   └── seeds/
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
# 执行数据库迁移
psql -U your_user -d your_database -f db/migrations/001_create_reference_tables.sql
psql -U your_user -d your_database -f db/migrations/002_create_history_tables.sql

# 导入种子数据
psql -U your_user -d your_database -f db/seeds/001_seed_reference_data.sql
psql -U your_user -d your_database -f db/seeds/002_seed_schools_2025.sql
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
