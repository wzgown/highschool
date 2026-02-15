-- 005_create_active_middle_schools_view.sql
-- 创建有效初中学校视图，优先使用最新年份数据
-- 2025-02-14: 添加排名字段 (district_rank, tier, ranking_remarks)

-- Drop view if exists
DROP VIEW IF EXISTS vw_active_middle_schools;

-- Create view for active middle schools with latest year data
CREATE VIEW vw_active_middle_schools AS
SELECT DISTINCT ON (code)
    id,
    code,
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
ORDER BY code, data_year DESC;

COMMENT ON VIEW vw_active_middle_schools IS '有效初中学校视图，每个学校只保留最新年份数据，包含区内排名和梯队信息';
