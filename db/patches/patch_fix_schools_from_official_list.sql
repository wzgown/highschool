-- ============================================================================
-- 修复 ref_school 表中的学校数据（基于2025年官方招生名单）
-- 生成时间: 2026-02-22
-- ============================================================================

-- 开始事务
BEGIN;

-- ============================================================================
-- 第一部分：修正名称错误的学校
-- ============================================================================

-- 徐汇区
UPDATE ref_school SET full_name = '上海市徐汇中学', short_name = '徐汇中学', updated_at = NOW() WHERE code = '044109';
UPDATE ref_school SET full_name = '上海市紫竹园中学', short_name = '紫竹园中学', updated_at = NOW() WHERE code = '044223';

-- 长宁区
UPDATE ref_school SET full_name = '华东师范大学附属天山学校', short_name = '天山学校', updated_at = NOW() WHERE code = '053003';
UPDATE ref_school SET full_name = '上海市建青实验学校', short_name = '建青实验', updated_at = NOW() WHERE code = '053005';
UPDATE ref_school SET full_name = '华东政法大学附属中学', short_name = '华政附中', updated_at = NOW() WHERE code = '054013';

-- 静安区（整体修正）
UPDATE ref_school SET full_name = '上海市民立中学', short_name = '民立中学', updated_at = NOW() WHERE code = '063001';
UPDATE ref_school SET full_name = '上海市第一中学', short_name = '市一中', updated_at = NOW() WHERE code = '063002';
UPDATE ref_school SET full_name = '上海市风华中学', short_name = '风华中学', updated_at = NOW() WHERE code = '063003';
UPDATE ref_school SET full_name = '同济大学附属七一中学', short_name = '同济七一', updated_at = NOW() WHERE code = '064003';
UPDATE ref_school SET full_name = '上海田家炳中学', short_name = '田家炳中学', updated_at = NOW() WHERE code = '064020';
UPDATE ref_school SET full_name = '上海市向东中学', short_name = '向东中学', updated_at = NOW() WHERE code = '064007';
UPDATE ref_school SET full_name = '上海大学市北附属中学', short_name = '市北附中', updated_at = NOW() WHERE code = '064008';
UPDATE ref_school SET full_name = '上海市民办扬波中学', short_name = '扬波中学', updated_at = NOW() WHERE code = '064021';

-- 普陀区
UPDATE ref_school SET full_name = '同济大学第二附属中学', short_name = '同济二附中', updated_at = NOW() WHERE code = '074005';
UPDATE ref_school SET full_name = '上海音乐学院附属安师实验中学', short_name = '安师实验', updated_at = NOW() WHERE code = '074016';
UPDATE ref_school SET full_name = '上海市长征中学', short_name = '长征中学', updated_at = NOW() WHERE code = '074010';
UPDATE ref_school SET full_name = '上海华东师范大学附属进华中学', short_name = '进华中学', updated_at = NOW() WHERE code = '074018';

-- 虹口区（整体修正）
UPDATE ref_school SET full_name = '上海音乐学院虹口区北虹高级中学', short_name = '北虹高中', updated_at = NOW() WHERE code = '093003';
UPDATE ref_school SET full_name = '上海市继光高级中学', short_name = '继光高中', updated_at = NOW() WHERE code = '093004';
UPDATE ref_school SET full_name = '上海市鲁迅中学', short_name = '鲁迅中学', updated_at = NOW() WHERE code = '094001';
UPDATE ref_school SET full_name = '上海市第五十二中学', short_name = '市五十二中', updated_at = NOW() WHERE code = '094003';
UPDATE ref_school SET full_name = '上海市友谊中学', short_name = '友谊中学', updated_at = NOW() WHERE code = '094004';
UPDATE ref_school SET full_name = '上海师范大学附属虹口中学', short_name = '上师虹口', updated_at = NOW() WHERE code = '094005';
UPDATE ref_school SET full_name = '同济大学附属澄衷中学', short_name = '澄衷中学', updated_at = NOW() WHERE code = '094006';
-- 上外东校 code 错误，需要更新 code
UPDATE ref_school SET code = '094049', full_name = '上海外国语大学附属外国语学校东校', short_name = '上外东校', updated_at = NOW() WHERE id = 119;

-- 杨浦区
UPDATE ref_school SET full_name = '上海市市东实验学校（上海市市东中学）', short_name = '市东实验', updated_at = NOW() WHERE code = '103012';
UPDATE ref_school SET full_name = '上海市中原中学', short_name = '中原中学', updated_at = NOW() WHERE code = '103061';
UPDATE ref_school SET full_name = '上海市复旦实验中学', short_name = '复旦实验', updated_at = NOW() WHERE code = '103075';

-- 闵行区
UPDATE ref_school SET full_name = '上海师范大学附属中学闵行分校', short_name = '上师大闵行', updated_at = NOW() WHERE code = '122003';
UPDATE ref_school SET full_name = '上海闵行区民办德闳学校', short_name = '德闳学校', updated_at = NOW() WHERE code = '125119';
UPDATE ref_school SET full_name = '上海七宝德怀特高级中学', short_name = '七宝德怀特', updated_at = NOW() WHERE code = '128100';

-- 宝山区
UPDATE ref_school SET full_name = '上海师范大学附属中学宝山分校', short_name = '上师大宝山', updated_at = NOW() WHERE code = '132003';
UPDATE ref_school SET full_name = '上海市宝山中学', short_name = '宝山中学', updated_at = NOW() WHERE code = '134001';

-- 嘉定区
UPDATE ref_school SET full_name = '上海交通大学附属中学嘉定分校', short_name = '交大嘉分', updated_at = NOW() WHERE code = '142002';
UPDATE ref_school SET full_name = '上海市嘉定区封浜高级中学', short_name = '封浜高中', updated_at = NOW() WHERE code = '144006';
UPDATE ref_school SET full_name = '上海市嘉定区中光高级中学', short_name = '中光高中', updated_at = NOW() WHERE code = '144010';
UPDATE ref_school SET full_name = '上海师范大学附属嘉定高级中学', short_name = '上师大嘉高', updated_at = NOW() WHERE code = '143002';
UPDATE ref_school SET full_name = '上海市嘉定区安亭高级中学', short_name = '安亭高中', updated_at = NOW() WHERE code = '143003';
UPDATE ref_school SET full_name = '上海市嘉定区嘉一实验高级中学', short_name = '嘉一实验', updated_at = NOW() WHERE code = '142003';

-- 浦东新区
UPDATE ref_school SET full_name = '上海市建平中学筠溪分校', short_name = '建平筠溪', updated_at = NOW() WHERE code = '152007';
UPDATE ref_school SET full_name = '上海外国语大学附属浦东外国语学校', short_name = '浦外', updated_at = NOW() WHERE code = '155004';
UPDATE ref_school SET full_name = '上海浦东新区民办康德学校', short_name = '康德学校', updated_at = NOW() WHERE code = '155056';
UPDATE ref_school SET full_name = '上海浦东新区民办籽奥高级中学', short_name = '籽奥高中', updated_at = NOW() WHERE code = '155057';

-- 金山区
UPDATE ref_school SET full_name = '上海师范大学第二附属中学', short_name = '上师大二附', updated_at = NOW() WHERE code = '163001';
UPDATE ref_school SET full_name = '上海市张堰中学', short_name = '张堰中学', updated_at = NOW() WHERE code = '163000';

-- 松江区
UPDATE ref_school SET full_name = '华东师范大学第二附属中学松江分校', short_name = '华二松江', updated_at = NOW() WHERE code = '172002';
UPDATE ref_school SET full_name = '上海师范大学附属中学松江分校', short_name = '上师大松江', updated_at = NOW() WHERE code = '172004';
UPDATE ref_school SET full_name = '上海师范大学附属外国语中学', short_name = '上师外附', updated_at = NOW() WHERE code = '174009';
UPDATE ref_school SET full_name = '华东师范大学松江实验高级中学', short_name = '华师松江', updated_at = NOW() WHERE code = '174016';
UPDATE ref_school SET full_name = '上海市西外外国语学校', short_name = '西外', updated_at = NOW() WHERE code = '175018';
UPDATE ref_school SET full_name = '上海民办包玉刚实验高中', short_name = '包玉刚', updated_at = NOW() WHERE code = '175021';

-- 青浦区
UPDATE ref_school SET full_name = '上海青浦区世外高级中学', short_name = '青浦世外', updated_at = NOW() WHERE code = '184006';
UPDATE ref_school SET full_name = '上海青浦区宏润博源高级中学', short_name = '宏润博源', updated_at = NOW() WHERE code = '184007';
UPDATE ref_school SET full_name = '上海宋庆龄学校', short_name = '宋庆龄学校', updated_at = NOW() WHERE code = '185008';

-- 奉贤区
UPDATE ref_school SET full_name = '华东师范大学第二附属中学临港奉贤分校', short_name = '华二奉贤', updated_at = NOW() WHERE code = '202002';
UPDATE ref_school SET full_name = '东华大学附属奉贤致远中学', short_name = '东华致远', updated_at = NOW() WHERE code = '204001';
UPDATE ref_school SET full_name = '上海市奉贤区奉城高级中学', short_name = '奉城高中', updated_at = NOW() WHERE code = '204005';
UPDATE ref_school SET full_name = '上海师范大学第四附属中学', short_name = '上师大四附', updated_at = NOW() WHERE code = '204006';
UPDATE ref_school SET full_name = '上海市奉贤区景秀高级中学', short_name = '景秀高中', updated_at = NOW() WHERE code = '204008';

-- ============================================================================
-- 第二部分：添加缺失的学校
-- ============================================================================

-- 黄浦区（code 修正）
UPDATE ref_school SET code = '013001' WHERE id = 40;
UPDATE ref_school SET code = '013003' WHERE id = 41;
UPDATE ref_school SET code = '013004' WHERE id = 43;

-- 徐汇区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '044223', '上海市紫竹园中学', '紫竹园中学', 3, 'PUBLIC', 'DISTRICT_FEATURED', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '044223');

-- 长宁区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '054013', '华东政法大学附属中学', '华政附中', 4, 'PUBLIC', 'DISTRICT_FEATURED', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '054013');

-- 静安区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '064020', '上海田家炳中学', '田家炳中学', 5, 'PRIVATE', 'DISTRICT_MODEL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '064020');

-- 普陀区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '074016', '上海音乐学院附属安师实验中学', '安师实验', 6, 'PUBLIC', 'DISTRICT_FEATURED', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '074016');

-- 宝山区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '133002', '上海师范大学附属宝山罗店中学', '罗店中学', 10, 'PUBLIC', 'DISTRICT_FEATURED', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '133002');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '134002', '上海市通河中学', '通河中学', 10, 'PUBLIC', 'DISTRICT_MODEL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '134002');

-- 闵行区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '124115', '上海闵行区协和双语教科学校', '协和教科', 9, 'PRIVATE', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '124115');

-- 浦东新区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '153002', '华东师范大学附属东昌中学', '东昌中学', 12, 'PUBLIC', 'DISTRICT_FEATURED', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '153002');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154009', '上海市香山中学', '香山中学', 12, 'PUBLIC', 'DISTRICT_FEATURED', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154009');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '152009', '上海市川沙中学友仁分校', '川沙友仁', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '152009');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154008', '上海市泾南中学', '泾南中学', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154008');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154010', '上海市沪新中学', '沪新中学', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154010');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154015', '上海市育民中学', '育民中学', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154015');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154017', '上海第二工业大学附属龚路中学', '龚路中学', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154017');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154020', '上海市江镇中学', '江镇中学', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154020');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154024', '华东师范大学张江实验中学', '张江实验', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154024');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154026', '上海市三林中学东校', '三林东校', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154026');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154028', '上海市川沙中学北校', '川沙北校', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154028');
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '154045', '上海市高东中学', '高东中学', 12, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '154045');

-- 市属学校缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '155054', '上海科技大学附属学校', '上科大附校', 1, 'PUBLIC', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '155054');

-- 金山区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '164005', '上海市民办交大南洋中学', '交大南洋', 13, 'PRIVATE', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '164005');

-- 奉贤区缺失
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active, created_at, updated_at)
SELECT '204020', '上海美达菲双语高级中学', '美达菲', 16, 'PRIVATE', 'GENERAL', 'DAY', FALSE, 2025, TRUE, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ref_school WHERE code = '204020');

-- ============================================================================
-- 第三部分：删除重复/错误的记录
-- ============================================================================

-- 删除重复的华东模范中学（064001和063002重复）
DELETE FROM ref_school WHERE code = '064001' AND full_name = '上海市华东模范中学';

-- 删除重复的松江四中（174002和174009重复，保留174002）
-- 注意：先检查是否有关联数据

-- ============================================================================
-- 第四部分：修正嘉定区学校 ID 和 code 的对应关系
-- ============================================================================

-- 修正嘉定区学校的 code 和名称对应
UPDATE ref_school SET code = '144011', full_name = '上海大学附属嘉定高级中学', short_name = '上大嘉高', updated_at = NOW()
WHERE id = 164 AND code = '144011';

-- ============================================================================
-- 验证修改结果
-- ============================================================================

-- 显示修改后的统计
SELECT '修正后的学校总数' as description, COUNT(*) as count FROM ref_school WHERE data_year = 2025;

COMMIT;

-- ============================================================================
-- 注意事项：
-- 1. 执行前请备份数据库
-- 2. 某些学校可能有关联的招生计划数据，删除时需要谨慎
-- 3. 执行后请验证 ref_admission_plan_summary 等关联表的数据一致性
-- ============================================================================
