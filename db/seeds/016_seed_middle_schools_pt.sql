-- =============================================================================
-- 普陀区初中学校数据
-- =============================================================================

INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
('070101', '上海市曹杨第二中学附属学校', '曹杨二中附校', 6, 'PUBLIC', TRUE, 2025, TRUE),
('070102', '上海市晋元高级中学附属学校', '晋元附校', 6, 'PUBLIC', TRUE, 2025, TRUE),
('070103', '上海市宜川中学附属学校', '宜川附校', 6, 'PUBLIC', TRUE, 2025, TRUE),
('070104', '上海市甘泉外国语中学', '甘泉外国语', 6, 'PUBLIC', TRUE, 2025, TRUE),
('070105', '上海市同济大学第二附属中学', '同济二附中', 6, 'PUBLIC', TRUE, 2025, TRUE),
('070106', '上海市梅陇中学', '梅陇中学', 6, 'PUBLIC', TRUE, 2025, TRUE),
('070107', '上海市曹杨中学', '曹杨中学', 6, 'PUBLIC', TRUE, 2025, TRUE),
('070108', '上海市长征中学', '长征中学', 6, 'PUBLIC', TRUE, 2025, TRUE)
ON CONFLICT (code, data_year) DO NOTHING;
