-- 2026年新增初中（2026名额分配数据中出现, ref_middle_school缺失）
BEGIN;

INSERT INTO ref_middle_school (name, district_id, is_non_selective, ranking_remarks) SELECT '上海交通大学附属浦东实验中学', 12, TRUE, '2026年新增（来源：2026名额分配到校计划/分数线）' WHERE NOT EXISTS (SELECT 1 FROM ref_middle_school WHERE name='上海交通大学附属浦东实验中学' AND district_id=12);
INSERT INTO ref_middle_school (name, district_id, is_non_selective, ranking_remarks) SELECT '上海市浦东新区进才万祥学校', 12, TRUE, '2026年新增（来源：2026名额分配到校计划/分数线）' WHERE NOT EXISTS (SELECT 1 FROM ref_middle_school WHERE name='上海市浦东新区进才万祥学校' AND district_id=12);
INSERT INTO ref_middle_school (name, district_id, is_non_selective, ranking_remarks) SELECT '上海中医药大学附属浦东鹤沙学校', 12, TRUE, '2026年新增（来源：2026名额分配到校计划/分数线）' WHERE NOT EXISTS (SELECT 1 FROM ref_middle_school WHERE name='上海中医药大学附属浦东鹤沙学校' AND district_id=12);
INSERT INTO ref_middle_school (name, district_id, is_non_selective, ranking_remarks) SELECT '上海师范大学附属浦东秋萍学校', 12, TRUE, '2026年新增（来源：2026名额分配到校计划/分数线）' WHERE NOT EXISTS (SELECT 1 FROM ref_middle_school WHERE name='上海师范大学附属浦东秋萍学校' AND district_id=12);

COMMIT;
