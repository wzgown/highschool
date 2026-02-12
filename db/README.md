# 上海中考招生模拟系统 - 数据库文档

## 目录结构

```
db/
├── migrations/           # 数据库迁移脚本（DDL）
│   ├── 001_create_reference_tables.sql       # 参考表（区县、学校、科目等）
│   └── 002_create_history_tables.sql         # 历史数据表（录取分数线等）
├── seeds/               # 种子数据SQL
│   ├── 001_seed_reference_data.sql           # 枚举数据
│   ├── 002_seed_schools_2025.sql             # 2025年学校数据
│   ├── 003_seed_quota_allocation_district_2025.sql  # 2025年名额分配到区计划
│   ├── 010_seed_district_exam_count.sql      # 2024-2025年各区中考人数
│   ├── 020_seed_2024_jiading_quota_school.sql         # 2024年名额分配到校（嘉定区示例）
│   ├── 021_seed_2024_jiading_admission_quota_district.sql  # 2024年名额分配到区分数线（嘉定）
│   ├── 022_seed_2024_jiading_admission_quota_school.sql   # 2024年名额分配到校分数线（嘉定）
│   └── 023_seed_2024_jiading_admission_unified.sql       # 2024年1-15志愿分数线（嘉定）
└── README.md            # 本文档
```

## 数据表说明

### 参考表 (Reference Tables)

#### 1. ref_district - 区县表
上海16个区的参考数据。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| code | VARCHAR(20) | 区代码（如: HP=黄浦区, PD=浦东新区） |
| name | VARCHAR(50) | 区名称 |
| name_en | VARCHAR(50) | 区英文名称 |
| display_order | INTEGER | 显示顺序 |

**区代码列表**：
- HP - 黄浦区 | XH - 徐汇区 | CN - 长宁区 | JA - 静安区
- PT - 普陀区 | HK - 虹口区 | YP - 杨浦区 | MH - 闵行区
- BS - 宝山区 | JD - 嘉定区 | PD - 浦东新区 | JS - 金山区
- SJ - 松江区 | QP - 青浦区 | FX - 奉贤区 | CM - 崇明区
- SH - 上海市（委属学校）

#### 2. ref_school - 学校主表
基于2025年参加本市高中阶段学校招生学校名单（约290+所学校）。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| code | VARCHAR(20) | 学校招生代码（6位） |
| full_name | VARCHAR(200) | 学校全称 |
| short_name | VARCHAR(100) | 学校简称 |
| district_id | INTEGER | 所属区ID |
| school_nature_id | INTEGER | 办别ID（公办/民办） |
| school_type_id | INTEGER | 学校类型ID |
| boarding_type_id | INTEGER | 寄宿情况ID |
| has_international_course | BOOLEAN | 是否含国际课程班 |
| remarks | TEXT | 备注 |
| data_year | INTEGER | 数据年份 |

#### 3. ref_middle_school - 初中学校表
用于名额分配到校招生计划。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| code | VARCHAR(20) | 学校代码 |
| name | VARCHAR(200) | 学校全称 |
| short_name | VARCHAR(100) | 学校简称 |
| district_id | INTEGER | 所属区ID |
| school_nature_id | INTEGER | 办别ID（公办/民办） |
| is_non_selective | BOOLEAN | 是否不选择生源初中（名额分配到校填报资格） |
| data_year | INTEGER | 数据年份 |

#### 4. ref_school_type - 学校类型枚举

| 代码 | 名称 | 说明 |
|------|------|------|
| CITY_MODEL | 市实验性示范性高中 | 76所名额分配到区学校 |
| CITY_FEATURED | 市特色普通高中 | - |
| CITY_POLICY | 享受市实验性示范性高中招生政策高中 | 分校等 |
| DISTRICT_MODEL | 区实验性示范性高中 | - |
| DISTRICT_FEATURED | 区特色普通高中 | - |
| GENERAL | 一般高中 | - |
| MUNICIPAL | 委属市实验性示范性高中 | 市教委直属6所 |

#### 5. ref_school_nature - 办别枚举

| 代码 | 名称 |
|------|------|
| PUBLIC | 公办 |
| PRIVATE | 民办 |
| COOPERATION | 中外合作 |

#### 6. ref_boarding_type - 寄宿情况枚举

| 代码 | 名称 |
|------|------|
| FULL | 全部寄宿 |
| PARTIAL | 部分寄宿 |
| NONE | 无寄宿 |

#### 7. ref_subject - 科目表

| 代码 | 名称 | 满分值 |
|------|------|--------|
| chinese | 语文 | 150 |
| math | 数学 | 150 |
| foreign | 外语 | 150 |
| integrated | 综合测试 | 150 |
| ethics | 道德与法治 | 60 |
| history | 历史 | 60 |
| pe | 体育与健身 | 30 |
| comprehensive_quality | 综合素质评价 | 50 |

#### 8. ref_control_score - 最低投档控制分数线表

2025年各批次最低投档控制分数线：

| 批次 | 类别 | 最低分 |
|------|------|--------|
| 自主招生录取 | 普通高中自主招生录取 | 605 |
| 名额分配综合评价录取 | 名额分配综合评价录取 | 605 |
| 统一招生录取 | 普通高中统一招生录取 | 513 |
| 统一招生录取 | 中本贯通录取 | 513 |
| 统一招生录取 | 五年一贯制和中高职贯通录取 | 400 |
| 统一招生录取 | 普通中专录取 | 350 |

#### 9. ref_admission_batch - 招生批次枚举

| 代码 | 名称 | 说明 |
|------|------|------|
| AUTONOMOUS | 自主招生录取 | 最先执行，本系统不支持 |
| QUOTA_DISTRICT | 名额分配到区 | 1个志愿，总分800分 |
| QUOTA_SCHOOL | 名额分配到校 | 2个平行志愿，总分800分 |
| UNIFIED_1_15 | 统一招生1-15志愿 | 15个平行志愿，总分750分 |
| UNIFIED_CONSULT | 统一招生征求志愿 | 征求志愿，总分750分 |

### 招生计划表 (Quota Tables)

#### 10. ref_quota_allocation_district - 名额分配到区招生计划表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| year | INTEGER | 招生年份 |
| school_id | INTEGER | 学校ID |
| school_code | VARCHAR(20) | 学校代码 |
| district_id | INTEGER | 分配区ID |
| quota_count | INTEGER | 计划数 |
| data_year | INTEGER | 数据年份 |

#### 11. ref_quota_allocation_school - 名额分配到校招生计划表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| year | INTEGER | 招生年份 |
| district_id | INTEGER | 所属区ID |
| high_school_id | INTEGER | 高中学校ID |
| high_school_code | VARCHAR(20) | 高中学校代码 |
| middle_school_id | INTEGER | 初中学校ID |
| middle_school_name | VARCHAR(200) | 初中学校名称 |
| quota_count | INTEGER | 分配到该校的计划数 |
| data_year | INTEGER | 数据年份 |

### 历史数据表 (History Tables)

#### 12. ref_district_exam_count - 各区中考人数表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| year | INTEGER | 中考年份 |
| district_id | INTEGER | 区ID |
| exam_count | INTEGER | 中考报名人数 |
| data_source | VARCHAR(255) | 数据来源文件 |

**数据覆盖**：
- 2024年：约112,631人（估算）
- 2025年：约118,834人（官方数据）

#### 13. ref_admission_score_quota_district - 名额分配到区录取最低分数线表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| year | INTEGER | 招生年份 |
| district_id | INTEGER | 录取区ID |
| school_id | INTEGER | 学校ID |
| school_name | VARCHAR(200) | 学校名称 |
| min_score | DECIMAL(6,2) | 录取最低分（总分800分） |
| is_tie_preferred | BOOLEAN | 是否同分优待 |
| chinese_math_foreign_sum | DECIMAL(6,2) | 语数外三科合计 |
| math_score | DECIMAL(5,2) | 数学成绩 |
| chinese_score | DECIMAL(5,2) | 语文成绩 |
| integrated_test_score | DECIMAL(5,2) | 综合测试成绩 |
| comprehensive_quality_score | DECIMAL(4,1) | 综合素质评价成绩（默认50分） |
| data_year | INTEGER | 数据年份 |

**同分比较规则**（名额分配批次）：
1. 同分优待
2. 综合素质评价成绩（50分满分）
3. 语数外三科合计
4. 数学成绩
5. 语文成绩
6. 综合测试成绩

#### 14. ref_admission_score_quota_school - 名额分配到校录取最低分数线表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| year | INTEGER | 招生年份 |
| district_id | INTEGER | 录取区ID |
| school_id | INTEGER | 高中学校ID |
| school_name | VARCHAR(200) | 高中学校名称 |
| middle_school_name | VARCHAR(200) | 初中学校名称 |
| min_score | DECIMAL(6,2) | 录取最低分（总分800分） |
| is_tie_preferred | BOOLEAN | 是否同分优待 |
| chinese_math_foreign_sum | DECIMAL(6,2) | 语数外三科合计 |
| math_score | DECIMAL(5,2) | 数学成绩 |
| chinese_score | DECIMAL(5,2) | 语文成绩 |
| integrated_test_score | DECIMAL(5,2) | 综合测试成绩 |
| comprehensive_quality_score | DECIMAL(4,1) | 综合素质评价成绩（默认50分） |
| data_year | INTEGER | 数据年份 |

#### 15. ref_admission_score_unified - 1-15志愿录取分数线表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | SERIAL | 主键 |
| year | INTEGER | 招生年份 |
| district_id | INTEGER | 录取区ID |
| school_id | INTEGER | 学校ID |
| school_name | VARCHAR(200) | 学校名称 |
| min_score | DECIMAL(6,2) | 投档分数线（总分750分） |
| chinese_math_foreign_sum | DECIMAL(6,2) | 语数外三科合计 |
| math_score | DECIMAL(5,2) | 数学成绩 |
| chinese_score | DECIMAL(5,2) | 语文成绩 |
| data_year | INTEGER | 数据年份 |

## 使用说明

### 1. 创建表结构

```bash
# 创建参考表
psql -U your_user -d your_database -f db/migrations/001_create_reference_tables.sql

# 创建历史数据表
psql -U your_user -d your_database -f db/migrations/002_create_history_tables.sql
```

### 2. 导入种子数据

```bash
# 参考数据
psql -U your_user -d your_database -f db/seeds/001_seed_reference_data.sql
psql -U your_user -d your_database -f db/seeds/002_seed_schools_2025.sql
psql -U your_user -d your_database -f db/seeds/003_seed_quota_allocation_district_2025.sql

# 历史数据（2024年嘉定区示例）
psql -U your_user -d your_database -f db/seeds/010_seed_district_exam_count.sql
psql -U your_user -d your_database -f db/seeds/020_seed_2024_jiading_quota_school.sql
psql -U your_user -d your_database -f db/seeds/021_seed_2024_jiading_admission_quota_district.sql
psql -U your_user -d your_database -f db/seeds/022_seed_2024_jiading_admission_quota_school.sql
psql -U your_user -d your_database -f db/seeds/023_seed_2024_jiading_admission_unified.sql
```

### 3. 或者在psql中执行

```sql
-- 创建表结构
\i db/migrations/001_create_reference_tables.sql
\i db/migrations/002_create_history_tables.sql

-- 导入种子数据
\i db/seeds/001_seed_reference_data.sql
\i db/seeds/002_seed_schools_2025.sql
\i db/seeds/003_seed_quota_allocation_district_2025.sql

-- 导入历史数据
\i db/seeds/010_seed_district_exam_count.sql
\i db/seeds/020_seed_2024_jiading_quota_school.sql
\i db/seeds/021_seed_2024_jiading_admission_quota_district.sql
\i db/seeds/022_seed_2024_jiading_admission_quota_school.sql
\i db/seeds/023_seed_2024_jiading_admission_unified.sql
```

## 数据来源

所有数据均来自官方权威来源或 `original_data/` 目录：

### 官方网站数据
1. **2025年最低投档控制分数线**：https://www.shmeea.edu.cn/page/08000/20250708/19584.html
2. **2025年名额分配到区/到校录取最低分数线**：https://www.shmeea.edu.cn/page/03600/20250714/19623.html
3. **2025年高中名额分配到区招生计划**：https://www.shmeea.edu.cn/download/20250528/014.pdf
4. **2025年参加本市高中阶段学校招生学校名单**：https://www.shmeea.edu.cn/download/20250430/90.pdf
5. **上海市教育委员会关于2025年本市高中阶段学校招生工作的若干意见**：https://edu.sh.gov.cn/xxgk2_zdgz_rxgkyzs_03/20250227/3c7070cb012f44d19b1683b50be33071.html

### original_data/ 目录数据
| 文件类型 | 2024年 | 2025年 | 2026年 | 2027年 |
|---------|--------|--------|--------|--------|
| 各区中考人数 | ✅ | ✅ | ✅ | ✅ |
| 名额分配到区招生计划 | ✅ (16区) | ✅ | - | - |
| 名额分配到校招生计划 | ✅ (16区) | ✅ | - | - |
| 名额分配到区录取分数线 | ✅ (16区) | ✅ | - | - |
| 名额分配到校录取分数线 | ✅ (16区) | ✅ | - | - |
| 1-15志愿录取分数线 | ✅ (16区) | ✅ | - | - |
| 自主招生计划 | ✅ | ✅ | - | - |
| 招生学校名单 | ✅ | ✅ | - | - |

## 更新日志

### 2025-02-12
- **新增2024年全市录取分数线数据**：
  - 030_seed_admission_score_unified_2024.sql：1-15志愿录取分数线（35条）
  - 031_seed_admission_score_quota_district_2024.sql：名额分配到区录取分数线
  - 032_seed_admission_score_quota_school_2024.sql：名额分配到校录取分数线
- **新增2024年全市招生计划数据**：
  - 033_seed_quota_allocation_district_2024.sql：名额分配到区招生计划（74条）
  - 034_seed_quota_allocation_school_2024.sql：名额分配到校招生计划
- **新增数据生成脚本**：
  - scripts/generate_cutoff_scores_sql.py：从 processed/cutoff_scores/ 生成 SQL
  - scripts/generate_quota_sql.py：从 processed/quota/ 生成 SQL
- **数据来源**：基于 original_data/ 目录重组后的 processed/ 目录数据

### 2025-02-01
- 创建初始表结构
- 导入2025年学校数据（约290+所）
- 导入2025年名额分配到区招生计划（76所市实验性示范性高中）
- 导入2025年最低投档控制分数线

### 2025-02-01 (扩展)
- 新增历史数据表结构
- 导入2024-2027年各区中考人数
- 导入2024年嘉定区名额分配到校招生计划（示例）
- 导入2024年嘉定区录取分数线数据（名额分配到区、到校、1-15志愿）
