# original_data 目录重组方案

## 当前状态分析

### 现有目录结构
```
original_data/
├── 2022中考/          # 少量文件
├── 2023中考/          # 少量文件
├── 2024中考/          # 230+ 文件（最全）
│   ├── 自招/          # 自主招生录取方案
│   └── 招生录取分数线/  # 各区分数线CSV
├── 2025中考/          # 少量文件
├── shanghai-zhongkao/  # 整理后的数据
│   ├── scores/         # 分数线数据
│   ├── quota/          # 名额分配数据
│   ├── policies/       # 政策文件
│   ├── docs/           # 文档报告
│   └── scripts/        # 脚本
└── 2025年上海市高中阶段学校考试招生工作实施细则.md  # 单独的政策文件
```

### 问题
1. 数据分散在两个不同的命名风格目录（"202X中考" vs "shanghai-zhongkao"）
2. 政策文件位置不统一
3. 年份数据与分类数据（scores、quota）混在一起

## 重组方案

### 新目录结构
```
original_data/
├── README.md                    # 数据说明文档
│
├── policies/                    # 政策文件（按年份）
│   ├── 2025-实施细则.md
│   ├── 2024-政策文件汇总.md
│   └── historical/             # 历史政策存档
│
├── raw/                        # 原始数据（按年份）
│   ├── 2022/
│   │   └── cutoff_scores.xlsx
│   ├── 2023/
│   │   └── cutoff_scores.xlsx
│   ├── 2024/
│   │   ├── admission_plans/      # 招生计划
│   │   ├── cutoff_scores/        # 分数线
│   │   ├── quota_district/       # 名额分配到区
│   │   ├── quota_school/         # 名额分配到校
│   │   └── autonomous/          # 自主招生方案
│   └── 2025/
│       ├── admission_plans/
│       ├── exam_counts/
│       └── quota_district.pdf
│
├── processed/                   # 整理后的数据
│   ├── cutoff_scores/           # 历年分数线
│   │   ├── 2022_cutoff_scores.csv
│   │   ├── 2023_cutoff_scores.csv
│   │   ├── 2024_cutoff_scores.csv
│   │   └── cutoff_scores_template.csv
│   ├── quota/                  # 名额分配数据
│   │   ├── quota_to_district_2024.csv
│   │   ├── quota_to_school_2024.csv
│   │   └── exam_counts_2025.csv
│   └── schools/                # 学校信息
│       ├── school_list_2024.csv
│       └── school_list_template.csv
│
└── docs/                       # 数据文档
    ├── DATA_COLLECTION_STATUS.md
    ├── COMPLETE_DATA_SUMMARY.md
    └── DATA_DICTIONARY.md
```

## 迁移计划

### 第一阶段：创建新结构
- [ ] 创建新目录结构
- [ ] 创建 README.md 说明文档

### 第二阶段：迁移数据
- [ ] 迁移政策文件到 `policies/`
- [ ] 迁移原始数据到 `raw/`（保持年份结构）
- [ ] 迁移整理后数据到 `processed/`
- [ ] 迁移文档到 `docs/`

### 第三阶段：清理
- [ ] 删除空的旧目录
- [ ] 更新数据收集报告中的路径引用

## 文件命名规范

### 原始数据（raw/）
- CSV: `{年份}_{区县}_{数据类型}.csv`
  - 例：`2024_嘉定区_1-15志愿分数线.csv`
- PDF: `{年份}_{文件类型}.pdf`
  - 例：`2025_名额分配到区招生计划.pdf`

### 整理后数据（processed/）
- 分数线：`{年份}_cutoff_scores_{批次}.csv`
  - 例：`2024_cutoff_scores_unified.csv`
- 名额分配：`quota_to_{district|school}_{年份}.csv`
  - 例：`quota_to_district_2024.csv`
