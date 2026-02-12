# 上海中考原始数据

本目录存储上海中考相关的原始数据和整理后的数据，供 `highschool` 项目使用。

## ETL 数据处理流程

**重要**：本目录的数据处理遵循标准的 ETL (Extract → Transform → Load) 流程。

```
raw/                  →  processed/           →  db/seeds/
(原始数据/PDF/Excel)   (清洗后的CSV)          (SQL种子文件)
```

### 三步骤说明

1. **Extract（提取）**：从 raw/ 或 policies/ 的原始文件（PDF、Excel、CSV）提取数据到 `processed/` 目录
   - 输出标准化CSV格式（UTF-8编码，Unix换行符）
   - 包含数据源文件名追踪

2. **Transform（转换/清洗）**：在 processed/ 目录中对数据进行清洗和标准化
   - 字段映射和统一命名
   - 移除错误前缀、处理空值
   - 数据合并（多个区文件合并为全市文件）

3. **Load（加载）**：从 processed/ 目录读取清洗后的CSV，生成SQL种子文件到 `db/seeds/`
   - 使用 `ON CONFLICT ... DO UPDATE` 确保幂等性
   - 包含清晰的数据来源注释

### 为什么需要 ETL 流程？

- **数据可靠性**：raw/ 数据不可变，processed/ 数据可重现
- **可维护性**：新增数据时只需重复相同流程
- **可追溯性**：每条数据都有来源记录

### 设计原则：增量脚本策略

**核心思路**：不需要用统一的脚本处理所有数据。

- 原始数据来源多样但**有限且固定**（官方PDF、各区公示文件等）
- 只有**增量数据**进入（按年份递增：2024 → 2025 → 2026...）
- 为**每批增量数据配套对应的专门脚本**

**示例**：
- `etl_2025_quota_district_fixed.py` - 专门处理2025年名额分配到区PDF
- `extract_middle_schools.py` - 专门处理2024年各区初中数据
- `generate_2025_quota_district_sql.py` - 专门加载2025年CSV到SQL

这种"增量脚本"策略比"统一通用脚本"更简单、专注、易维护。

详见：[ETL_PIPELINE_SOP.md](./docs/ETL_PIPELINE_SOP.md)

详见：[ETL_PIPELINE_SOP.md](./docs/ETL_PIPELINE_SOP.md)

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
├── processed/                   # 整理后的标准化数据（ETL输出）
│   ├── 2024/
│   │   ├── cutoff_scores/       # 2024年录取分数线
│   │   ├── quota_district/      # 2024年名额分配到区
│   │   └── quota_school/       # 2024年名额分配到校（含初中学校）
│   └── 2025/
│       └── quota_district/      # 2025年名额分配到区
│
└── docs/                       # 数据文档和报告
    ├── ETL_PIPELINE_SOP.md      # ETL流程规范文档
    ├── COLLECTION_STATUS.md      # 数据收集状态
    ├── COMPLETE_DATA_SUMMARY.md  # 数据汇总报告
    └── DATA_DICTIONARY.md      # 数据字典
```

## 数据说明

### 政策文件 (policies/)
- 存储官方发布的招生政策、实施细则
- 按年份组织，保留历史版本
- **用途**：Extract步骤的主要数据源

### 原始数据 (raw/)
- 存储未经处理的原始数据
- 按年份和数据类型分类
- 保持原始文件格式（PDF、Excel、原始CSV）
- **不可变**：原始文件不应被修改
- **用途**：Extract步骤的数据源

### 整理数据 (processed/)
- **ETL流程产物**：经过Extract和Transform处理后的数据
- 统一文件格式（CSV，UTF-8编码）
- 统一字段命名
- 包含数据来源追踪
- **可重现**：可通过ETL脚本从raw/重新生成
- **用途**：Load步骤的数据源，直接用于生成SQL种子文件

## 数据状态

| 年份 | 招生计划 | 分数线 | 名额分配 | 状态 |
|------|----------|--------|----------|------|
| 2025 | ✅ | ⏳ 待发布 | ✅ | 招生计划、名额分配已完成 |
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

- 2025-02-12: **建立标准ETL流程规范**
  - 创建 `docs/ETL_PIPELINE_SOP.md`：定义 Extract → Transform → Load 三步流程
  - 2025年名额分配到区数据完成完整ETL流程：
    - Extract: `scripts/etl_2025_quota_district_fixed.py` 从PDF提取到CSV
    - Load: `scripts/generate_2025_quota_district_sql.py` 从CSV生成SQL
    - 产物: `processed/2025/quota_district/2025年名额分配到区招生计划.csv` (76所，6724名额)
  - 修复PDF解析bug：原始CSV列错位（计划区域字段包含名额数值），已修正

- 2025-02-12: 创建重组方案，整合分散的数据目录
- 2025-02-10: 收集2025年招生计划数据
- 2025-01-XX: 完成2024年全量数据收集
