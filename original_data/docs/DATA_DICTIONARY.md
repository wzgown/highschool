# 上海中考数据字典

本文档定义上海中考相关数据的字段含义和格式规范。

## 核心实体

### 学校 (School)

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| school_code | string | 6位学校代码 | 152003 |
| school_name | string | 学校全称 | 华东师范大学第二附属中学 |
| district_id | int | 所属区县代码 | 12 |
| district_name | string | 所属区县名称 | 浦东新区 |
| school_type_id | int | 学校类型ID | 1=市重点, 2=区重点, 3=一般高中 |
| school_type_name | string | 学校类型名称 | 市实验性示范性高中 |
| school_nature_id | int | 学校性质ID | 1=公办, 2=民办 |
| has_international_course | boolean | 是否有国际课程班 | true/false |

### 区县 (District)

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| district_id | int | 区县代码 | 1 |
| district_name | string | 区县名称 | 黄浦区 |
| exam_count | int | 中考报名人数 | 5800 |

### 录取分数线 (CutoffScore)

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| year | int | 年份 | 2024 |
| school_code | string | 学校代码 | 152003 |
| school_name | string | 学校名称 | 华东师范大学第二附属中学 |
| batch_type | string | 批次类型 | quota_to_district / quota_to_school / unified |
| district_id | int | 区县代码 | 12 |
| cutoff_score | decimal | 录取最低分 | 688.5 |
| quota_count | int | 招生计划数 | 2 |

### 名额分配 (Quota)

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| year | int | 年份 | 2024 |
| school_code | string | 学校代码 | 152003 |
| school_name | string | 学校名称 | 华东师范大学第二附属中学 |
| quota_type | string | 分配类型 | district(到区) / school(到校) |
| target_district_id | int | 目标区县ID（到区用） | 12 |
| target_school_id | int | 目标初中ID（到校用） | 12001 |
| quota_count | int | 分配名额数 | 3 |

## 批次类型说明

| 批次代码 | 批次名称 | 说明 | 志愿数 |
|-----------|----------|------|--------|
| autonomous | 自主招生 | 校测+中考综合录取 | 2个 |
| quota_to_district | 名额分配到区 | 全区排名竞争 | 1个 |
| quota_to_school | 名额分配到校 | 校内排名竞争 | 2个 |
| unified | 统一招生 | 平行志愿录取 | 15个 |

## 学校类型说明

| 类型ID | 类型名称 | 说明 |
|--------|----------|------|
| 1 | 市实验性示范性高中 | 市重点 |
| 2 | 区实验性示范性高中 | 区重点 |
| 3 | 一般高中 | 普通高中 |
| 4 | 中职校 | 中等职业学校 |

## 区县代码表

| 代码 | 区县名称 |
|------|----------|
| 1 | 黄浦区 |
| 2 | 徐汇区 |
| 3 | 长宁区 |
| 4 | 静安区 |
| 5 | 普陀区 |
| 6 | 虹口区 |
| 7 | 杨浦区 |
| 8 | 闵行区 |
| 9 | 宝山区 |
| 10 | 嘉定区 |
| 11 | 浦东新区 |
| 12 | 金山区 |
| 13 | 松江区 |
| 14 | 青浦区 |
| 15 | 奉贤区 |
| 16 | 崇明区 |

## 文件命名规范

### 原始数据 (raw/)
- `{年份}_{区县}_{数据类型}.csv`
  - 例：`2024_浦东新区_1-15志愿分数线.csv`
- `{年份}_{数据类型}.pdf`
  - 例：`2025_名额分配到区招生计划.pdf`

### 整理后数据 (processed/)
- `{年份}_cutoff_scores_{批次}.csv`
  - 例：`2024_cutoff_scores_unified.csv`
- `quota_to_{district|school}_{年份}.csv`
  - 例：`quota_to_district_2024.csv`

## 数据导入说明

### 导入到 PostgreSQL

```sql
-- 导入学校列表
COPY schools(school_code, school_name, district_id, school_type_id)
FROM 'processed/schools/school_list_2024.csv' CSV HEADER;

-- 导入分数线
COPY cutoff_scores(year, school_code, batch_type, cutoff_score)
FROM 'processed/cutoff_scores/2024_cutoff_scores.csv' CSV HEADER;

-- 导入名额分配
COPY quota_district(year, school_code, target_district_id, quota_count)
FROM 'processed/quota/quota_to_district_2024.csv' CSV HEADER;
```

## 数据更新流程

1. 从官方渠道获取最新数据
2. 放入 `raw/{年份}/` 对应目录
3. 数据清洗和格式化
4. 存入 `processed/` 对应目录
5. 更新本数据字典
6. 执行数据库导入脚本

## 数据质量检查

### 必填字段
- 学校代码（6位）
- 学校名称
- 区县代码
- 批次类型
- 年份

### 数据一致性
- 学校代码必须与学校列表一致
- 区县代码必须在1-16范围内
- 分数线数值必须在0-750之间（名额分配）或0-800之间（统一招生）
