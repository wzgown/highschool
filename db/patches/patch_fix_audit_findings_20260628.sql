-- ============================================================================
-- 修复远端数据审计发现的问题
-- 日期: 2026-06-28
--
-- 范围:
--   1. 2024 名额分配录取分数线中“复兴高级中学”空 school_id
--   2. 2025 招生计划汇总中的代码/名称/总数口径错配
--   3. 2024/2025 统一招生分数线中的名称错配
--   4. 2026 嘉定统一招生中两个艺术班招生代码的 school_id 错配
-- ============================================================================

BEGIN;

-- 备份受影响行，便于回滚核查。
CREATE TABLE IF NOT EXISTS backup_audit_fix_20260628_ref_admission_score_quota_district AS
SELECT *
FROM ref_admission_score_quota_district
WHERE year = 2024
  AND school_id IS NULL
  AND school_name = '上海市复兴高级中学';

CREATE TABLE IF NOT EXISTS backup_audit_fix_20260628_ref_admission_score_quota_school AS
SELECT *
FROM ref_admission_score_quota_school
WHERE year = 2024
  AND school_id IS NULL
  AND school_name = '上海市复兴高级中学';

CREATE TABLE IF NOT EXISTS backup_audit_fix_20260628_ref_admission_plan_summary AS
SELECT *
FROM ref_admission_plan_summary
WHERE id IN (22, 24, 102, 112, 138, 142, 205, 277);

CREATE TABLE IF NOT EXISTS backup_audit_fix_20260628_ref_admission_score_unified AS
SELECT *
FROM ref_admission_score_unified
WHERE id IN (313, 1550, 2029, 2329, 2504, 2509, 2556, 2558, 2592, 2594, 2679);

CREATE TABLE IF NOT EXISTS backup_audit_fix_20260628_ref_quota_unified_allocation_district AS
SELECT *
FROM ref_quota_unified_allocation_district
WHERE year = 2026
  AND school_code IN ('069004', '079016');

CREATE TABLE IF NOT EXISTS backup_audit_fix_20260628_ref_school AS
SELECT *
FROM ref_school
WHERE code IN ('064004', '069004', '074016', '079016', '092001');

-- 远端序列曾落后于现有最大 id；插入新 school 前先校正。
SELECT setval('ref_school_id_seq', (SELECT COALESCE(MAX(id), 0) FROM ref_school), true);

-- 将特殊艺术班招生代码作为独立招生项建模，避免招生代码挂在基础学校上产生错配。
INSERT INTO ref_school (
  code, full_name, short_name, district_id, school_nature_id, school_type_id,
  boarding_type_id, has_international_course, remarks, is_active, created_at, updated_at
)
VALUES
  (
    '069004',
    '上海戏剧学院附属高级中学（艺术班）',
    '上戏附中艺术班',
    5,
    'PUBLIC',
    'DISTRICT_MODEL',
    'PARTIAL',
    false,
    '2026统一招生艺术班招生代码；基础学校代码064004',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
  ),
  (
    '079016',
    '上海音乐学院附属安师实验中学（艺术班）',
    '上音安师艺术班',
    6,
    'PUBLIC',
    'DISTRICT_MODEL',
    'PARTIAL',
    false,
    '2026统一招生艺术班招生代码；基础学校代码074016',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
  )
ON CONFLICT (code) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  short_name = EXCLUDED.short_name,
  district_id = EXCLUDED.district_id,
  school_nature_id = EXCLUDED.school_nature_id,
  school_type_id = EXCLUDED.school_type_id,
  boarding_type_id = EXCLUDED.boarding_type_id,
  has_international_course = EXCLUDED.has_international_course,
  remarks = EXCLUDED.remarks,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

-- 2024 复兴高级中学分数线引用复旦大学附属复兴中学。
UPDATE ref_admission_score_quota_district
SET school_id = 110,
    school_name = '复旦大学附属复兴中学',
    updated_at = CURRENT_TIMESTAMP
WHERE year = 2024
  AND school_id IS NULL
  AND school_name = '上海市复兴高级中学';

UPDATE ref_admission_score_quota_school
SET school_id = 110,
    school_name = '复旦大学附属复兴中学',
    updated_at = CURRENT_TIMESTAMP
WHERE year = 2024
  AND school_id IS NULL
  AND school_name = '上海市复兴高级中学';

-- 2025 招生计划汇总对齐基础学校表。
UPDATE ref_admission_plan_summary p
SET school_code = s.code,
    school_name = s.full_name,
    updated_at = CURRENT_TIMESTAMP
FROM ref_school s
WHERE p.school_id = s.id
  AND p.id IN (102, 112, 138, 142, 205, 277);

-- autonomous_sports_count/autonomous_arts_count 是自主招生中的“其中”项；
-- 这两行原 autonomous_count 未包含其中项，导致 total_plan_count 不闭合。
UPDATE ref_admission_plan_summary
SET autonomous_count = autonomous_count + autonomous_sports_count + autonomous_arts_count,
    autonomous_ratio = ROUND(((autonomous_count + autonomous_sports_count + autonomous_arts_count)::numeric * 100 / NULLIF(total_plan_count, 0)), 2),
    quota_ratio = ROUND((quota_total_count::numeric * 100 / NULLIF(total_plan_count, 0)), 2),
    unified_ratio = ROUND((unified_count::numeric * 100 / NULLIF(total_plan_count, 0)), 2),
    updated_at = CURRENT_TIMESTAMP
WHERE id IN (22, 24)
  AND total_plan_count <> autonomous_count + quota_district_count + quota_school_count + unified_count;

-- 统一招生分数线名称对齐基础学校表。
UPDATE ref_admission_score_unified u
SET school_name = s.full_name,
    updated_at = CURRENT_TIMESTAMP
FROM ref_school s
WHERE u.school_id = s.id
  AND u.id IN (313, 1550, 2029, 2329, 2504, 2509);

-- 艺术班分数线改指向独立招生代码项。
UPDATE ref_admission_score_unified
SET school_id = (SELECT id FROM ref_school WHERE code = '069004'),
    school_name = '上海戏剧学院附属高级中学（艺术班）',
    updated_at = CURRENT_TIMESTAMP
WHERE id IN (2556, 2592, 2679);

UPDATE ref_admission_score_unified
SET school_id = (SELECT id FROM ref_school WHERE code = '079016'),
    school_name = '上海音乐学院附属安师实验中学（艺术班）',
    updated_at = CURRENT_TIMESTAMP
WHERE id IN (2558, 2594);

-- 2026 嘉定统一招生艺术班记录改指向对应招生代码项。
UPDATE ref_quota_unified_allocation_district
SET school_id = (SELECT id FROM ref_school WHERE code = '069004'),
    updated_at = CURRENT_TIMESTAMP
WHERE year = 2026
  AND school_code = '069004';

UPDATE ref_quota_unified_allocation_district
SET school_id = (SELECT id FROM ref_school WHERE code = '079016'),
    updated_at = CURRENT_TIMESTAMP
WHERE year = 2026
  AND school_code = '079016';

-- 事务内校验。若仍有已知问题，整批回滚。
DO $$
DECLARE
  v_count integer;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM ref_admission_score_quota_district
  WHERE school_id IS NULL;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ref_admission_score_quota_district still has NULL school_id: %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ref_admission_score_quota_school
  WHERE school_id IS NULL;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ref_admission_score_quota_school still has NULL school_id: %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ref_admission_plan_summary p
  JOIN ref_school s ON s.id = p.school_id
  WHERE p.school_code IS DISTINCT FROM s.code;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ref_admission_plan_summary school_code mismatches remain: %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ref_admission_plan_summary p
  JOIN ref_school s ON s.id = p.school_id
  WHERE p.school_name IS DISTINCT FROM s.full_name;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ref_admission_plan_summary school_name mismatches remain: %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ref_admission_plan_summary
  WHERE total_plan_count <> autonomous_count + quota_district_count + quota_school_count + unified_count;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ref_admission_plan_summary total mismatches remain: %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ref_quota_unified_allocation_district q
  JOIN ref_school s ON s.id = q.school_id
  WHERE q.school_code IS DISTINCT FROM s.code;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ref_quota_unified_allocation_district code mismatches remain: %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM ref_admission_score_unified u
  JOIN ref_school s ON s.id = u.school_id
  WHERE u.school_name IS DISTINCT FROM s.full_name;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'ref_admission_score_unified name mismatches remain: %', v_count;
  END IF;
END $$;

COMMIT;
