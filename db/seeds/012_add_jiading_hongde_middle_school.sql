-- =============================================================================
-- 添加交大附中附属嘉定洪德中学（2025新增学校）
-- 用户确认：这是真实存在的学校，与"德富中学"是两所不同的学校
-- Generated: 2025-02-13

-- 插入交大附中附属嘉定洪德中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0016', '交大附中附属嘉定洪德中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 验证插入
SELECT id, code, name, district_id, is_active, data_year
FROM ref_middle_school
WHERE name IN ('交大附中附属嘉定洪德中学', '交大附中附属嘉定德富中学')
  AND data_year = 2025
ORDER BY name;

-- 说明：
-- - 交大附中附属嘉定德富中学 (JD0015) - 2024年存在的学校
-- - 交大附中附属嘉定洪德中学 (JD0016) - 2025年新增学校
-- 这是两所不同的真实学校，不是OCR错误或更名
