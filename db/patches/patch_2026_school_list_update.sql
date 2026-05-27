-- ============================================================================
-- 2026年高中招生学校名单更新
-- 生成时间: 2026-05-27
-- 数据来源: https://www.shmeea.edu.cn/download/20260430/4.pdf
--
-- 变更概要:
--   - 新增 19 所学校 (2026年新招生)
--   - 标记 12 所学校为不招生 (is_active = false)
--   - 总活跃学校: 304 所 (原 297 + 19 - 12)
-- ============================================================================

BEGIN;

-- ============================================================================
-- 新增学校 (19所)
-- ============================================================================

INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, remarks, is_active)
VALUES
  ('012011', '同济大学科技中学', '同济科技中学', 2, 'PUBLIC', 'CITY_POLICY', 'NONE', false, '参照市实验性示范性高中招生政策', true),
  ('044181', '上海民办位育中学', '民办位育', 3, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('064016', '复旦大学附属中学静安高级中学', '复旦附中静安', 5, 'PUBLIC', 'GENERAL', 'NONE', false, NULL, true),
  ('074087', '上海市晋元高级中学南校', '晋元南校', 6, 'PUBLIC', 'GENERAL', 'NONE', false, NULL, true),
  ('124117', '上海闵行区诺美高级中学', '诺美高中', 9, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('124118', '上海圣华紫竹高级中学', '圣华紫竹', 9, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('125029', '上海市第二体育运动学校（上海市体育中学）', '市体育中学', 9, 'PUBLIC', 'GENERAL', 'NONE', false, NULL, true),
  ('135033', '上海民办至德实验学校', '至德实验', 10, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('151019', '上海市洋泾中学南校', '洋泾南校', 12, 'PUBLIC', 'GENERAL', 'NONE', false, NULL, true),
  ('153014', '华东师范大学附属浦东临港科技高级中学', '临港科技高中', 12, 'PUBLIC', 'CITY_MODEL', 'NONE', false, NULL, true),
  ('154054', '上海市浦东新区群峰高级中学', '群峰高中', 12, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('165009', '华东师范大学第二附属中学金山实验学校', '华二金山实验', 13, 'PUBLIC', 'CITY_MODEL', 'NONE', false, NULL, true),
  ('173004', '上海对外经贸大学附属松江高级中学', '外贸大松江高中', 14, 'PUBLIC', 'GENERAL', 'NONE', false, NULL, true),
  ('173005', '上海市松江区励滕高级中学', '励滕高中', 14, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('173006', '上海市松江区弘毅南洋高级中学', '弘毅南洋', 14, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('181020', '上海师范大学附属青浦实验中学', '上师大青浦实验', 15, 'PUBLIC', 'CITY_MODEL', 'NONE', false, NULL, true),
  ('201004', '上海市奉贤中学附属南桥中学', '奉中南桥', 16, 'PUBLIC', 'GENERAL', 'NONE', false, NULL, true),
  ('204021', '上海市奉贤区博华高级中学', '博华高中', 16, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true),
  ('514014', '上海新纪元双语学校', '新纪元双语', 17, 'PRIVATE', 'GENERAL', 'NONE', false, NULL, true)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- 标记不招生学校 (12所 - 存在于DB但不在2026名单中)
-- ============================================================================

UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '012013'; -- 上海市五爱高级中学
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '014004'; -- 上海音乐学院附属黄浦比乐中学
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '064004'; -- 上海戏剧学院附属高级中学
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '064023'; -- 上海市民办新和中学
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '093003'; -- 上海音乐学院虹口区北虹高级中学
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '124010'; -- 上海市第二体育运动学校（上海市体育中学）
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '124024'; -- 上海市古美高级中学
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '135034'; -- 上海宝山区世外学校
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '153013'; -- 华东师范大学附属浦东临港高级中学
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '155055'; -- 上海浦东民办未来科技学校
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '182002'; -- 复旦大学附属中学青浦分校
UPDATE ref_school SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE code = '205006'; -- 上海奉贤区博华高级中学

-- ============================================================================
-- 名称修正 (根据PDF原文校验)
-- ============================================================================

UPDATE ref_school SET full_name = '复旦附中静安高级中学', updated_at = CURRENT_TIMESTAMP WHERE code = '064016';
UPDATE ref_school SET full_name = '上海体育大学附属中学', short_name = '体育大学附中', updated_at = CURRENT_TIMESTAMP WHERE code = '104073';
UPDATE ref_school SET full_name = '上海市浦东临港科技高级中学', updated_at = CURRENT_TIMESTAMP WHERE code = '153014';
UPDATE ref_school SET full_name = '上海应用技术大学附属奉贤奉城高级中学', updated_at = CURRENT_TIMESTAMP WHERE code = '204005';
UPDATE ref_school SET full_name = '上海奉贤区博华高级中学', updated_at = CURRENT_TIMESTAMP WHERE code = '204021';

COMMIT;
