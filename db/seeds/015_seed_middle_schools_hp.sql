-- =============================================================================
-- 黄浦区初中学校数据
-- =============================================================================

INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
('010101', '上海市格致初级中学', '格致初中', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010102', '上海市大同初级中学', '大同初中', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010103', '上海市向明初级中学', '向明初中', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010104', '上海市卢湾中学', '卢湾中学', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010105', '上海市兴业中学', '兴业中学', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010106', '上海市储能中学', '储能中学', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010107', '上海市光明初级中学', '光明初中', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010108', '上海市市南中学', '市南中学', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010109', '上海市第十中学', '市十中学', 2, 'PUBLIC', TRUE, 2025, TRUE),
('010110', '上海市敬业初级中学', '敬业初中', 2, 'PUBLIC', TRUE, 2025, TRUE)
ON CONFLICT (code, data_year) DO NOTHING;
