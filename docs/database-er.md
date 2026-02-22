# 数据库ER图

## 概述

上海中考招生模拟系统的数据库包含以下主要模块：
- **基础数据**：区县、高中学校、初中学校
- **招生计划**：年度招生计划汇总
- **历史分数线**：统一招生、名额分配到区、名额分配到校分数线
- **名额分配**：名额分配到区、名额分配到校计划
- **模拟数据**：模拟历史、竞争对手生成日志

---

## ER图 (Mermaid)

```mermaid
erDiagram
    ref_district ||--o{ ref_school : contains
    ref_district ||--o{ ref_middle_school : contains
    ref_district ||--o{ ref_district_exam_count : stats
    ref_school ||--o{ ref_admission_plan_summary : plan
    ref_district ||--o{ ref_admission_plan_summary : district_plan
    ref_school ||--o{ ref_admission_score_unified : unified_score
    ref_district ||--o{ ref_admission_score_unified : district_score
    ref_school ||--o{ ref_admission_score_quota_district : quota_district_score
    ref_district ||--o{ ref_admission_score_quota_district : district_quota
    ref_school ||--o{ ref_admission_score_quota_school : quota_school_score
    ref_district ||--o{ ref_admission_score_quota_school : district_school_quota
    ref_school ||--o{ ref_quota_allocation_district : alloc_district
    ref_district ||--o{ ref_quota_allocation_district : receive_district
    ref_school ||--o{ ref_quota_allocation_school : alloc_school
    ref_middle_school ||--o{ ref_quota_allocation_school : receive_school
    ref_district ||--o{ ref_quota_allocation_school : district_alloc

    ref_district {
        int id PK
        varchar code
        varchar name
        varchar name_en
        int display_order
        timestamp created_at
        timestamp updated_at
    }

    ref_school {
        int id PK
        varchar code
        varchar full_name
        varchar short_name
        int district_id FK
        varchar school_nature_id
        varchar school_type_id
        varchar boarding_type_id
        boolean has_international_course
        int data_year
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    ref_middle_school {
        int id PK
        varchar name
        int district_id FK
        varchar school_type
        int data_year
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    ref_admission_plan_summary {
        int id PK
        int year
        int school_id FK
        varchar school_code
        varchar school_name
        int district_id FK
        varchar school_type_id
        boolean is_municipal
        int autonomous_count
        int autonomous_sports_count
        int autonomous_arts_count
        int quota_district_count
        int quota_school_count
        int unified_count
        int total_plan_count
        int data_year
        timestamp created_at
        timestamp updated_at
    }

    ref_admission_score_unified {
        int id PK
        int year
        int district_id FK
        int school_id FK
        varchar school_name
        decimal min_score
        decimal chinese_math_foreign_sum
        decimal math_score
        decimal chinese_score
        int data_year
        timestamp created_at
        timestamp updated_at
    }

    ref_admission_score_quota_district {
        int id PK
        int year
        int district_id FK
        int school_id FK
        varchar school_name
        decimal min_score
        boolean is_tie_preferred
        decimal chinese_math_foreign_sum
        decimal math_score
        decimal chinese_score
        decimal integrated_test_score
        decimal comprehensive_quality_score
        int data_year
        timestamp created_at
        timestamp updated_at
    }

    ref_admission_score_quota_school {
        int id PK
        int year
        int district_id FK
        int school_id FK
        varchar school_name
        varchar middle_school_name
        decimal min_score
        boolean is_tie_preferred
        decimal chinese_math_foreign_sum
        decimal math_score
        decimal chinese_score
        decimal integrated_test_score
        decimal comprehensive_quality_score
        int data_year
        timestamp created_at
        timestamp updated_at
    }

    ref_control_score {
        int id PK
        int year
        varchar admission_batch_id
        varchar category
        decimal min_score
        text description
        int data_year
        timestamp created_at
        timestamp updated_at
    }

    ref_quota_allocation_district {
        int id PK
        int year
        int school_id FK
        varchar school_name
        int district_id FK
        varchar district_name
        int quota_count
        int data_year
        timestamp created_at
        timestamp updated_at
    }

    ref_quota_allocation_school {
        int id PK
        int year
        int high_school_id FK
        varchar high_school_name
        int middle_school_id FK
        varchar middle_school_name
        int district_id FK
        int quota_count
        int data_year
        timestamp created_at
        timestamp updated_at
    }

    ref_district_exam_count {
        int id PK
        int year
        int district_id FK
        int exam_count
        varchar data_source
        timestamp created_at
        timestamp updated_at
    }

    simulation_history {
        bigint id PK
        varchar device_id
        decimal score
        int district_id
        int middle_school_id
        jsonb volunteers
        jsonb admission_result
        jsonb simulation_params
        jsonb probability_result
        timestamp created_at
    }

    competitor_generation_log {
        int id PK
        varchar device_id
        varchar candidate_score_range
        jsonb generated_competitors
        decimal actual_success_rate
        timestamp created_at
    }
```

---

## 表分类说明

### 1. 基础数据表 (3张)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `ref_district` | 区县基础信息 | id, code, name |
| `ref_school` | 高中学校信息 | id, code, full_name, district_id |
| `ref_middle_school` | 初中学校信息 | id, name, district_id |

### 2. 招生计划表 (1张)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `ref_admission_plan_summary` | 年度招生计划汇总 | year, school_id, autonomous_count, quota_district_count, quota_school_count, unified_count |

### 3. 历史分数线表 (4张)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `ref_admission_score_unified` | 统一招生分数线 | year, district_id, school_id, min_score |
| `ref_admission_score_quota_district` | 名额分配到区分数线 | year, district_id, school_id, min_score |
| `ref_admission_score_quota_school` | 名额分配到校分数线 | year, district_id, school_id, middle_school_name, min_score |
| `ref_control_score` | 各批次最低控分线 | year, admission_batch_id, category, min_score |

### 4. 名额分配计划表 (2张)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `ref_quota_allocation_district` | 名额分配到区计划 | year, school_id, district_id, quota_count |
| `ref_quota_allocation_school` | 名额分配到校计划 | year, high_school_id, middle_school_id, quota_count |

### 5. 辅助数据表 (1张)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `ref_district_exam_count` | 各区中考人数 | year, district_id, exam_count |

### 6. 模拟相关表 (2张)

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| `simulation_history` | 模拟历史记录 | device_id, score, volunteers, admission_result |
| `competitor_generation_log` | 竞争对手生成日志 | device_id, candidate_score_range, generated_competitors |

---

## 核心关系图

```
                    +-------------------+
                    |   ref_district    |
                    |     (区县表)       |
                    +--------+----------+
                             |
           +-----------------+------------------+
           |                 |                  |
           v                 v                  v
    +-------------+   +-------------+   +------------------+
    | ref_school  |   |ref_middle_  |   |ref_district_     |
    |  (高中表)    |   |school(初中) |   |exam_count(人数)  |
    +------+------+   +------+------+   +------------------+
           |                 |
           |                 |
           v                 v
    +----------------------------------------------+
    |              招生计划 & 分数线                |
    +----------------------------------------------+
    | ref_admission_plan_summary    (招生计划)     |
    | ref_admission_score_unified   (统一招生)     |
    | ref_admission_score_quota_    (名额到区)     |
    | ref_admission_score_quota_    (名额到校)     |
    +----------------------------------------------+
                             |
                             v
    +----------------------------------------------+
    |              名额分配计划                     |
    +----------------------------------------------+
    | ref_quota_allocation_district  (到区计划)    |
    | ref_quota_allocation_school    (到校计划)    |
    +----------------------------------------------+
```

---

## 数据量统计 (2026-02-22)

| 表名 | 记录数 |
|------|--------|
| ref_district | 17 |
| ref_school | ~300 |
| ref_middle_school | 726 |
| ref_admission_plan_summary | 189 (2025年) |
| ref_admission_score_unified | 457 (2025年) |
| ref_admission_score_quota_district | 914 |
| ref_admission_score_quota_school | 3672 |
| ref_quota_allocation_district | 76 (2025年) |
| ref_quota_allocation_school | 2537 (2025年) |

---

## 字段说明

### ref_district (区县表)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| code | varchar | 区县代码 |
| name | varchar | 区县名称 |
| name_en | varchar | 英文名称 |
| display_order | int | 显示顺序 |

### ref_school (高中学校表)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| code | varchar | 学校代码 |
| full_name | varchar | 学校全称 |
| short_name | varchar | 学校简称 |
| district_id | int | 所属区县FK |
| school_nature_id | varchar | 学校性质(公办/民办) |
| school_type_id | varchar | 学校类型(普通/重点) |
| boarding_type_id | varchar | 住宿类型 |
| has_international_course | boolean | 是否有国际课程 |
| data_year | int | 数据年份 |
| is_active | boolean | 是否有效 |

### ref_admission_score_unified (统一招生分数线)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| year | int | 年份 |
| district_id | int | 区县FK |
| school_id | int | 学校FK |
| school_name | varchar | 学校名称 |
| min_score | decimal | 最低分数线 |
| chinese_math_foreign_sum | decimal | 语数外总分 |
| math_score | decimal | 数学成绩 |
| chinese_score | decimal | 语文成绩 |
| data_year | int | 数据年份 |

---

## 更新记录

| 日期 | 说明 |
|------|------|
| 2026-02-22 | 初始版本，基于现有数据库结构生成 |
