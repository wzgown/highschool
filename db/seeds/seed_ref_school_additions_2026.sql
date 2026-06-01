-- ============================================================
-- 2026年新增学校
-- 生成时间: 2026-06-01
-- 数据来源: 2026年名额分配到区招生计划 PDF (上海市教育考试院)
-- ============================================================
--
-- 同济大学科技中学 (招生代码: 012011)
-- 所属区: 黄浦区 (HP)
-- 学校类型: 参照"探索建立拔尖创新人才培养基地"项目高中
-- 寄宿情况: 部分寄宿
-- 名额到区计划数: 47
--
-- school_type_id 使用 CITY_POLICY (与格致奉贤校区、向明浦江校区等分校/校区一致)
-- school_nature_id 使用 PUBLIC (公办)
-- boarding_type_id 使用 PARTIAL (部分寄宿)
-- district_id=2 对应黄浦区

INSERT INTO ref_school (id, code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, remarks, is_active)
VALUES (347, '012011', '同济大学科技中学', '同济科技', 2, 'PUBLIC', 'CITY_POLICY', 'PARTIAL', false, '参照探索建立拔尖创新人才培养基地项目高中', true);
