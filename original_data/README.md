# 上海中考原始数据

本目录存储上海中考相关的原始数据和整理后的数据，供 `highschool` 项目使用。

## 目录结构

```
original_data/
├── README.md                    # 本文件
├── REORGANIZATION_PLAN.md       # 重组方案说明
│
├── policies/                    # 政策文件
│   ├── 2025-实施细则.md        # 2025年招生实施细则
│   └── historical/             # 历史政策
│
├── raw/                        # 原始数据（按年份）
│   ├── 2024/                  # 2024年数据（最完整）
│   │   ├── admission_plans/     # 招生计划
│   │   ├── cutoff_scores/       # 录取分数线
│   │   ├── quota_district/      # 名额分配到区
│   │   ├── quota_school/        # 名额分配到校
│   │   └── autonomous/         # 自主招生方案
│   ├── 2023/                  # 2023年数据
│   ├── 2022/                  # 2022年数据
│   └── 2025/                  # 2025年数据
│
├── processed/                   # 整理后的标准化数据
│   ├── cutoff_scores/           # 历年分数线
│   ├── quota/                  # 名额分配数据
│   └── schools/                # 学校信息
│
└── docs/                       # 数据文档和报告
    ├── COLLECTION_STATUS.md      # 数据收集状态
    ├── COMPLETE_DATA_SUMMARY.md  # 数据汇总报告
    └── DATA_DICTIONARY.md      # 数据字典
```

## 数据说明

### 政策文件 (policies/)
- 存储官方发布的招生政策、实施细则
- 按年份组织，保留历史版本

### 原始数据 (raw/)
- 存储未经处理的原始数据
- 按年份和数据类型分类
- 保持原始文件格式（PDF、Excel、原始CSV）

### 整理数据 (processed/)
- 经过清洗、标准化的数据
- 统一文件格式（CSV）
- 统一字段命名
- 可直接导入数据库

## 数据状态

| 年份 | 招生计划 | 分数线 | 名额分配 | 状态 |
|------|----------|--------|----------|------|
| 2025 | ✅ | ⏳ 待发布 | ✅ | 招生计划已收集 |
| 2024 | ✅ | ✅ | ✅ | 完整 |
| 2023 | ❌ | ✅ | ❌ | 部分缺失 |
| 2022 | ❌ | ✅ | ❌ | 部分缺失 |
| 2021 | ❌ | ❌ | ❌ | 待收集 |
| 2020 | ❌ | ❌ | ❌ | 待收集 |

## 使用说明

### 导入数据库
```bash
# 导入2024年分数线
psql -U highschool -d highschool -c "\copy cutoff_scores FROM 'processed/cutoff_scores/2024_cutoff_scores.csv' CSV HEADER"

# 导入名额分配数据
psql -U highschool -d highschool -c "\copy quota_district FROM 'processed/quota/quota_to_district_2024.csv' CSV HEADER"
```

### 数据更新
1. 将新数据放入 `raw/{年份}/` 对应目录
2. 整理后放入 `processed/` 对应目录
3. 更新 `docs/COLLECTION_STATUS.md` 记录状态
4. 如有新字段，更新 `docs/DATA_DICTIONARY.md`

## 数据来源

- [上海招考热线](https://www.shmeea.edu.cn/)
- [上海教育](https://www.shmec.gov.cn/)
- 各区教育局官网

## 更新日志

- 2025-02-12: 创建重组方案，整合分散的数据目录
- 2025-02-10: 收集2025年招生计划数据
- 2025-01-XX: 完成2024年全量数据收集
