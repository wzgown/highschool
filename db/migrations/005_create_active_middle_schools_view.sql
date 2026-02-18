-- 005_create_active_middle_schools_view.sql
-- 创建有效初中学校视图，优先使用最新年份数据
-- 2025-02-14: 添加排名字段 (district_rank, tier, ranking_remarks)
-- 2025-02-15: 改进去重策略，按标准化名称去重（处理同一学校不同编码的重复记录）

-- Drop view if exists
DROP VIEW IF EXISTS vw_active_middle_schools;

-- Create view for active middle schools with deduplication by normalized name
-- 标准化名称用于去重：
-- 1. 去除括号内容（如"（原黄浦学校）"）
-- 2. 去除"上海市"前缀
-- 3. 统一"初级中学"为"中学"
-- 4. 去除"中学"后缀
-- 优先保留：最新数据年份 > 最大ID
CREATE VIEW vw_active_middle_schools AS
SELECT DISTINCT ON (
  REGEXP_REPLACE(
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(
          REGEXP_REPLACE(name, '（[^）]+）', ''),
          '^上海市', ''
        ),
        '初级中学$', '中学'
      ),
      '中学$', ''
    ),
    '\s+', ''
  )
)
    id,
    name,
    short_name,
    district_id,
    school_nature_id,
    is_non_selective,
    exact_student_count,
    estimated_student_count,
    district_rank,
    tier,
    ranking_remarks,
    data_year,
    created_at,
    updated_at
FROM ref_middle_school
WHERE is_active = TRUE
ORDER BY
  REGEXP_REPLACE(
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(
          REGEXP_REPLACE(name, '（[^）]+）', ''),
          '^上海市', ''
        ),
        '初级中学$', '中学'
      ),
      '中学$', ''
    ),
    '\s+', ''
  ),
  data_year DESC,
  id DESC;

COMMENT ON VIEW vw_active_middle_schools IS '有效初中学校视图，按标准化名称去重，优先保留最新年份数据';
