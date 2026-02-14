-- =============================================================================
-- 计算并更新初中学校的估算考生人数
-- =============================================================================
-- 算法：
-- 1. 计算每个初中学校获得的名额分配到校总数
-- 2. 计算该区所有名额分配到校的总数
-- 3. 估算人数 = 该区考生总数 * (该校名额数 / 该区名额总数)

-- 更新估算考生人数
WITH middle_school_quota AS (
    -- 计算每个初中学校的名额分配到校总数
    SELECT
        qas.middle_school_name,
        qas.district_id,
        qas.year,
        SUM(qas.quota_count) as school_quota_total
    FROM ref_quota_allocation_school qas
    WHERE qas.middle_school_name IS NOT NULL
    GROUP BY qas.middle_school_name, qas.district_id, qas.year
),
district_quota_total AS (
    -- 计算每个区的名额分配到校总数
    SELECT
        district_id,
        year,
        SUM(quota_count) as district_quota_total
    FROM ref_quota_allocation_school
    GROUP BY district_id, year
),
district_exam AS (
    -- 获取各区考生人数
    SELECT
        d.id as district_id,
        dec.exam_count,
        dec.year
    FROM ref_district_exam_count dec
    JOIN ref_district d ON dec.district_id = d.id
),
estimation AS (
    -- 计算估算人数
    SELECT
        ms.id as middle_school_id,
        msq.year,
        ROUND(dec.exam_count * (msq.school_quota_total::DECIMAL / dqt.district_quota_total))::INTEGER as estimated_count
    FROM middle_school_quota msq
    JOIN district_quota_total dqt ON msq.district_id = dqt.district_id AND msq.year = dqt.year
    JOIN district_exam dec ON msq.district_id = dec.district_id AND msq.year = dec.year
    JOIN ref_middle_school ms ON ms.name = msq.middle_school_name AND ms.district_id = msq.district_id
    WHERE dqt.district_quota_total > 0
)
UPDATE ref_middle_school ms
SET estimated_student_count = e.estimated_count,
    updated_at = CURRENT_TIMESTAMP
FROM estimation e
WHERE ms.id = e.middle_school_id;

-- 验证结果
SELECT
    d.code as district_code,
    d.name as district_name,
    COUNT(*) as school_count,
    SUM(CASE WHEN ms.estimated_student_count IS NOT NULL THEN 1 ELSE 0 END) as has_estimate,
    SUM(ms.estimated_student_count) as total_estimated,
    dec.exam_count as district_exam_count
FROM ref_middle_school ms
JOIN ref_district d ON ms.district_id = d.id
LEFT JOIN ref_district_exam_count dec ON dec.district_id = d.id AND dec.year = 2024
WHERE ms.data_year = 2024
GROUP BY d.code, d.name, dec.exam_count
ORDER BY d.code;
