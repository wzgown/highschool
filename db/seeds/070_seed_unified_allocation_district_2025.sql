-- =============================================================================
-- 2025年统一招生分区名额 - 种子数据
-- =============================================================================
-- 说明:
--   存储统一招生批次各学校在各区的招生名额
--   数据来源: 从 ref_admission_plan_summary 的 unified_count 推导
--
--   目前策略:
--   - 委属学校: 将 unified_count 分配到所有16个区（跨区招生）
--   - 区属学校: 将 unified_count 全部分配到本区
--
--   TODO: 当获取到官方跨区招生数据后，更新此文件
-- =============================================================================

-- 清除2025年现有数据
DELETE FROM ref_quota_unified_allocation_district WHERE year = 2025;

-- =============================================================================
-- 策略1: 从 ref_admission_plan_summary 导入数据
-- 对于区属学校，统一招生名额全部面向本区
-- =============================================================================

INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count)
SELECT
    2025,
    school_id,
    school_code,
    district_id,
    unified_count
FROM ref_admission_plan_summary
WHERE year = 2025
  AND unified_count > 0
  AND is_municipal = FALSE  -- 区属学校：本区招生
ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- =============================================================================
-- 策略2: 委属学校的统一招生名额分配到所有区
-- 委属学校可以跨区招生，将名额平均分配到16个区
-- =============================================================================

-- 委属学校列表及其统一招生名额
-- 上海中学 (042032): 27人
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count)
SELECT
    2025,
    (SELECT id FROM ref_school WHERE code = '042032'),
    '042032',
    d.id,
    2  -- 27 / 16 ≈ 2 (向下取整，剩余名额放浦东)
FROM ref_district d
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '042032')
ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 更新浦东的名额（加剩余）
UPDATE ref_quota_unified_allocation_district
SET quota_count = quota_count + 11  -- 27 - 2*16 + 2 = 11 额外给浦东
WHERE school_code = '042032'
  AND district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND year = 2025;

-- 上海交通大学附属中学 (102056): 11人
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count)
SELECT
    2025,
    (SELECT id FROM ref_school WHERE code = '102056'),
    '102056',
    d.id,
    1  -- 11 / 16 ≈ 1
FROM ref_district d
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102056')
ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学 (102057): 10人
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count)
SELECT
    2025,
    (SELECT id FROM ref_school WHERE code = '102057'),
    '102057',
    d.id,
    1  -- 10 / 16 ≈ 1
FROM ref_district d
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102057')
ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 (152003): 27人
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count)
SELECT
    2025,
    (SELECT id FROM ref_school WHERE code = '152003'),
    '152003',
    d.id,
    2  -- 27 / 16 ≈ 2
FROM ref_district d
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152003')
ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 更新浦东的名额
UPDATE ref_quota_unified_allocation_district
SET quota_count = quota_count + 11  -- 剩余给浦东
WHERE school_code = '152003'
  AND district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND year = 2025;

-- 上海师范大学附属中学 (152006): 12人
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count)
SELECT
    2025,
    (SELECT id FROM ref_school WHERE code = '152006'),
    '152006',
    d.id,
    1  -- 12 / 16 ≈ 1
FROM ref_district d
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152006')
ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校 (155001): 5人
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count)
SELECT
    2025,
    (SELECT id FROM ref_school WHERE code = '155001'),
    '155001',
    d.id,
    1  -- 5 / 16 ≈ 1 (只在5个区招)
FROM ref_district d
WHERE d.code IN ('PD', 'XH', 'JW', 'HP', 'CN')  -- 只面向部分区
  AND EXISTS (SELECT 1 FROM ref_school WHERE code = '155001')
ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- =============================================================================
-- 验证数据完整性
-- =============================================================================

-- 检查数据是否正确导入
DO $$
DECLARE
    total_records INTEGER;
    schools_with_data INTEGER;
    schools_expected INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_records
    FROM ref_quota_unified_allocation_district WHERE year = 2025;

    SELECT COUNT(DISTINCT school_id) INTO schools_with_data
    FROM ref_quota_unified_allocation_district WHERE year = 2025;

    SELECT COUNT(DISTINCT school_id) INTO schools_expected
    FROM ref_admission_plan_summary WHERE year = 2025 AND unified_count > 0;

    RAISE NOTICE '统一招生分区名额导入完成:';
    RAISE NOTICE '  - 总记录数: %', total_records;
    RAISE NOTICE '  - 学校数: %', schools_with_data;
    RAISE NOTICE '  - 预期学校数: %', schools_expected;
END $$;
