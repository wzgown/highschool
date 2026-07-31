-- ============================================================
-- Agent 分析视图层（docs/agent-mode-plan.md §3.2.2）
-- 预聚合三年分数线/计划，供 Agent 分析型工具与其他模块使用。
-- 普通 VIEW：与基表实时一致，数据再导入后自动生效，无需刷新。
-- 口径提醒: QUOTA_DISTRICT/QUOTA_SCHOOL 为 800 分制(含综评50)，UNIFIED_1_15 为 750 分制。
-- ============================================================

-- 校 × 批次 × 区 × 年 分数线 + 同比涨跌
CREATE OR REPLACE VIEW v_school_score_trend AS
WITH all_scores AS (
    SELECT 'UNIFIED_1_15'::varchar AS batch, year, district_id, school_id, school_name,
           NULL::varchar AS middle_school_name, min_score,
           chinese_math_foreign_sum, math_score, chinese_score,
           NULL::numeric AS integrated_test_score, NULL::numeric AS comprehensive_quality_score,
           NULL::boolean AS is_tie_preferred
    FROM ref_admission_score_unified
    UNION ALL
    SELECT 'QUOTA_DISTRICT', year, district_id, school_id, school_name, NULL,
           min_score, chinese_math_foreign_sum, math_score, chinese_score,
           integrated_test_score, comprehensive_quality_score, is_tie_preferred
    FROM ref_admission_score_quota_district
    UNION ALL
    SELECT 'QUOTA_SCHOOL', year, district_id, school_id, school_name, middle_school_name,
           min_score, chinese_math_foreign_sum, math_score, chinese_score,
           integrated_test_score, comprehensive_quality_score, is_tie_preferred
    FROM ref_admission_score_quota_school
)
SELECT batch, year, district_id, school_id, school_name, middle_school_name,
       min_score,
       min_score - LAG(min_score) OVER w AS yoy_change,
       chinese_math_foreign_sum, math_score, chinese_score,
       integrated_test_score, comprehensive_quality_score, is_tie_preferred
FROM all_scores
WINDOW w AS (PARTITION BY batch, district_id, school_name, COALESCE(middle_school_name, '') ORDER BY year);

-- 校 × 批次 × 区 × 年 招生名额 + 同比增减
CREATE OR REPLACE VIEW v_quota_trend AS
WITH all_q AS (
    SELECT 'QUOTA_DISTRICT'::varchar AS batch, year, district_id, school_id, school_code, quota_count
    FROM ref_quota_allocation_district
    UNION ALL
    SELECT 'QUOTA_SCHOOL', year, district_id, high_school_id, high_school_code, SUM(quota_count)
    FROM ref_quota_allocation_school
    GROUP BY year, district_id, high_school_id, high_school_code
)
SELECT batch, year, district_id, school_id, school_code, quota_count,
       quota_count - LAG(quota_count) OVER w AS yoy_change
FROM all_q
WINDOW w AS (PARTITION BY batch, district_id, school_code ORDER BY year);

-- 高中画像：主档属性 + 本区最新三类线 + 最新年名额合计
CREATE OR REPLACE VIEW v_school_profile AS
SELECT
    s.id          AS school_id,
    s.code,
    s.full_name,
    s.short_name,
    d.name        AS district_name,
    s.school_type_id,
    s.school_nature_id,
    s.boarding_type_id,
    s.has_international_course,
    u.year        AS unified_year,
    u.min_score   AS unified_min_score,
    qd.year       AS quota_district_year,
    qd.min_score  AS quota_district_min_score,
    qs.year       AS quota_school_year,
    qs.min_line   AS quota_school_min,
    qs.avg_line   AS quota_school_avg,
    qdp.quota_total AS quota_district_total_latest,
    qsp.quota_total AS quota_school_total_latest
FROM ref_school s
JOIN ref_district d ON d.id = s.district_id
LEFT JOIN LATERAL (
    SELECT year, min_score FROM ref_admission_score_unified x
    WHERE x.school_id = s.id AND x.district_id = s.district_id
    ORDER BY year DESC LIMIT 1
) u ON TRUE
LEFT JOIN LATERAL (
    SELECT year, min_score FROM ref_admission_score_quota_district x
    WHERE x.school_id = s.id AND x.district_id = s.district_id
    ORDER BY year DESC LIMIT 1
) qd ON TRUE
LEFT JOIN LATERAL (
    SELECT year, MIN(min_score) AS min_line, ROUND(AVG(min_score), 1) AS avg_line
    FROM ref_admission_score_quota_school x
    WHERE x.school_id = s.id AND x.district_id = s.district_id
    GROUP BY year ORDER BY year DESC LIMIT 1
) qs ON TRUE
LEFT JOIN LATERAL (
    SELECT SUM(quota_count) AS quota_total FROM ref_quota_allocation_district x
    WHERE x.school_id = s.id
      AND x.year = (SELECT MAX(year) FROM ref_quota_allocation_district)
) qdp ON TRUE
LEFT JOIN LATERAL (
    SELECT SUM(quota_count) AS quota_total FROM ref_quota_allocation_school x
    WHERE x.high_school_id = s.id
      AND x.year = (SELECT MAX(year) FROM ref_quota_allocation_school)
) qsp ON TRUE;

-- 初中画像：主档 + 梯队/排名/人数/700+ + 最新年到校名额与录取线聚合
CREATE OR REPLACE VIEW v_middle_school_profile AS
SELECT
    m.id          AS middle_school_id,
    m.name,
    m.short_name,
    d.name        AS district_name,
    m.school_nature_id,
    m.is_non_selective,
    m.tier,
    m.district_rank,
    m.reputation_score,
    m.exact_student_count,
    m.estimated_student_count,
    m.score_700plus_count,
    m.score_700plus_reliability,
    plan.quota_total       AS quota_total_latest,
    plan.high_school_count AS quota_high_school_count,
    lines.line_count       AS quota_school_line_count,
    lines.min_line         AS quota_school_min,
    lines.avg_line         AS quota_school_avg
FROM ref_middle_school m
JOIN ref_district d ON d.id = m.district_id
LEFT JOIN LATERAL (
    SELECT SUM(quota_count) AS quota_total, COUNT(DISTINCT high_school_code) AS high_school_count
    FROM ref_quota_allocation_school x
    WHERE x.district_id = m.district_id AND x.middle_school_name = m.name
      AND x.year = (SELECT MAX(year) FROM ref_quota_allocation_school)
) plan ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS line_count, MIN(min_score) AS min_line, ROUND(AVG(min_score), 1) AS avg_line
    FROM ref_admission_score_quota_school x
    WHERE x.district_id = m.district_id AND x.middle_school_name = m.name
      AND x.year = (SELECT MAX(year) FROM ref_admission_score_quota_school)
) lines ON TRUE;
