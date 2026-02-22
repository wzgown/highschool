-- ============================================================================
-- 修复学校数据完整性问题 V10 (最终版)
-- 生成时间: 2026-02-22
--
-- 关键修复: 删除所有年份的引用，不仅仅是2025
-- ============================================================================

-- 开始事务
BEGIN;

-- ============================================================================
-- 第一步：临时删除唯一约束
-- ============================================================================

ALTER TABLE ref_admission_score_unified DROP CONSTRAINT IF EXISTS ref_admission_score_unified_year_district_id_school_name_key;
ALTER TABLE ref_admission_plan_summary DROP CONSTRAINT IF EXISTS ref_admission_plan_summary_year_school_code_key;

-- ============================================================================
-- 第二步：删除所有年份中引用错误school_id的记录
-- ============================================================================

DELETE FROM ref_admission_score_unified WHERE school_id IN (83, 298, 299);
DELETE FROM ref_admission_plan_summary WHERE school_id IN (83, 298, 299);
DELETE FROM ref_admission_score_quota_district WHERE school_id IN (83, 298, 299);
DELETE FROM ref_admission_score_quota_school WHERE school_id IN (83, 298, 299);

-- ============================================================================
-- 第三步：删除ref_school中的错误记录
-- ============================================================================

DELETE FROM ref_school WHERE id = 83 AND code = '064002';
DELETE FROM ref_school WHERE id = 298 AND code = '143005';
DELETE FROM ref_school WHERE id = 299 AND code = '143006';

-- ============================================================================
-- 第四步：为NULL school_id分配正确的值
-- ============================================================================

UPDATE ref_admission_score_unified u
SET school_id = s.id, updated_at = NOW()
FROM ref_school s
WHERE u.school_id IS NULL
  AND u.school_name = s.full_name
  AND s.is_active = TRUE;

DELETE FROM ref_admission_score_unified WHERE school_id IS NULL;

-- ============================================================================
-- 第五步：同步所有表的school_name和school_code
-- ============================================================================

UPDATE ref_admission_score_unified u
SET school_name = s.full_name, updated_at = NOW()
FROM ref_school s
WHERE u.school_id = s.id AND u.school_name != s.full_name;

UPDATE ref_admission_plan_summary p
SET school_name = s.full_name, school_code = s.code, updated_at = NOW()
FROM ref_school s
WHERE p.school_id = s.id AND (p.school_name != s.full_name OR p.school_code != s.code);

UPDATE ref_admission_score_quota_district q
SET school_name = s.full_name, updated_at = NOW()
FROM ref_school s
WHERE q.school_id = s.id AND q.school_name != s.full_name;

UPDATE ref_admission_score_quota_school q
SET school_name = s.full_name, updated_at = NOW()
FROM ref_school s
WHERE q.school_id = s.id AND q.school_name != s.full_name;

-- ============================================================================
-- 第六步：删除重复记录（同一district_id, school_name，保留ID最小的）
-- ============================================================================

DELETE FROM ref_admission_score_unified a
WHERE EXISTS (
    SELECT 1 FROM ref_admission_score_unified b
    WHERE b.district_id = a.district_id
      AND b.school_name = a.school_name
      AND b.id < a.id
);

DELETE FROM ref_admission_plan_summary a
WHERE EXISTS (
    SELECT 1 FROM ref_admission_plan_summary b
    WHERE b.school_id = a.school_id
      AND b.id < a.id
);

-- ============================================================================
-- 第七步：补充ref_admission_plan_summary中缺失的记录（仅2025年）
-- ============================================================================

INSERT INTO ref_admission_plan_summary (year, school_id, school_code, school_name, district_id, school_type_id, is_municipal, autonomous_count, autonomous_sports_count, autonomous_arts_count, quota_district_count, quota_school_count, unified_count, total_plan_count, data_year, created_at, updated_at)
SELECT
    2025 as year,
    s.id as school_id,
    s.code as school_code,
    s.full_name as school_name,
    s.district_id,
    s.school_type_id,
    CASE WHEN s.code LIKE '012%' OR s.code LIKE '102%' OR s.code LIKE '042%' OR s.code LIKE '1520%' THEN TRUE ELSE FALSE END as is_municipal,
    0 as autonomous_count,
    0 as autonomous_sports_count,
    0 as autonomous_arts_count,
    0 as quota_district_count,
    0 as quota_school_count,
    0 as unified_count,
    0 as total_plan_count,
    2025 as data_year,
    NOW() as created_at,
    NOW() as updated_at
FROM ref_school s
WHERE s.data_year = 2025
AND s.is_active = TRUE
AND NOT EXISTS (
    SELECT 1 FROM ref_admission_plan_summary p
    WHERE p.school_id = s.id AND p.year = 2025 AND p.data_year = 2025
);

-- ============================================================================
-- 第八步：重建唯一约束
-- ============================================================================

ALTER TABLE ref_admission_score_unified
ADD CONSTRAINT ref_admission_score_unified_year_district_id_school_name_key
UNIQUE (year, district_id, school_name);

ALTER TABLE ref_admission_plan_summary
ADD CONSTRAINT ref_admission_plan_summary_year_school_code_key
UNIQUE (year, school_code);

-- ============================================================================
-- 验证
-- ============================================================================

SELECT '=== 数据完整性验证 ===' as header;

SELECT 'ref_school总数(2025)' as 检查项, COUNT(*)::text as 结果 FROM ref_school WHERE data_year = 2025
UNION ALL
SELECT '重复学校名称', COUNT(*)::text FROM (
    SELECT full_name FROM ref_school WHERE data_year = 2025 GROUP BY full_name HAVING COUNT(*) > 1
) t
UNION ALL
SELECT 'NULL school_id数', COUNT(*)::text FROM ref_admission_score_unified WHERE school_id IS NULL
UNION ALL
SELECT '孤儿unified记录', COUNT(*)::text FROM ref_admission_score_unified u
WHERE NOT EXISTS (SELECT 1 FROM ref_school s WHERE s.id = u.school_id)
UNION ALL
SELECT '孤儿plan记录(2025)', COUNT(*)::text FROM ref_admission_plan_summary p
WHERE p.data_year = 2025 AND NOT EXISTS (SELECT 1 FROM ref_school s WHERE s.id = p.school_id AND s.data_year = 2025)
UNION ALL
SELECT 'unified名称不匹配', COUNT(*)::text FROM ref_admission_score_unified u
JOIN ref_school s ON s.id = u.school_id WHERE u.school_name != s.full_name
UNION ALL
SELECT 'plan名称不匹配(2025)', COUNT(*)::text FROM ref_admission_plan_summary p
JOIN ref_school s ON s.id = p.school_id AND s.data_year = 2025
WHERE p.data_year = 2025 AND p.school_name != s.full_name
UNION ALL
SELECT 'quota_district名称不匹配', COUNT(*)::text FROM ref_admission_score_quota_district q
JOIN ref_school s ON s.id = q.school_id WHERE q.school_name != s.full_name
UNION ALL
SELECT 'quota_school名称不匹配', COUNT(*)::text FROM ref_admission_score_quota_school q
JOIN ref_school s ON s.id = q.school_id WHERE q.school_name != s.full_name;

COMMIT;
