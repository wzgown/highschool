-- =============================================================================
-- 2025年上海市高中学校名单 - 种子数据
-- =============================================================================
-- 数据来源:
--   PDF1: https://www.shmeea.edu.cn/download/20250528/014.pdf (名额分配到区招生计划 - 76所)
--   PDF2: https://www.shmeea.edu.cn/download/20250430/90.pdf (招生学校名单 - 290+所)
-- =============================================================================


-- =============================================================================
-- 委属市实验性示范性高中 (6所)
-- 这些学校的所属区为"上海市"（代码为SH），需要先插入
-- =============================================================================
INSERT INTO ref_district (code, name, name_en, display_order) VALUES
('SH', '上海市', 'Shanghai', 0)
ON CONFLICT (code) DO NOTHING;

-- 委属市实验性示范性高中
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
('042032', '上海市上海中学', '上海中学', (SELECT id FROM ref_district WHERE code = 'SH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'MUNICIPAL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
('102056', '上海交通大学附属中学', '交大附中', (SELECT id FROM ref_district WHERE code = 'SH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'MUNICIPAL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('102057', '复旦大学附属中学', '复旦附中', (SELECT id FROM ref_district WHERE code = 'SH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'MUNICIPAL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('152003', '华东师范大学第二附属中学', '华二', (SELECT id FROM ref_district WHERE code = 'SH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'MUNICIPAL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('152006', '上海师范大学附属中学', '上师大附中', (SELECT id FROM ref_district WHERE code = 'SH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'MUNICIPAL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('155001', '上海市实验学校', '实验学校', (SELECT id FROM ref_district WHERE code = 'SH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'MUNICIPAL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('092003', '上海外国语大学附属外国语学校', '上外附中', (SELECT id FROM ref_district WHERE code = 'SH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'MUNICIPAL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'))
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 黄浦区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('012001', '上海市格致中学', '格致中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('012003', '上海市大同中学', '大同中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), TRUE),
('012005', '上海市向明中学', '向明中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('012007', '上海外国语大学附属大境中学', '大境中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('012008', '上海市光明中学', '光明中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('012009', '上海市敬业中学', '敬业中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('012010', '上海市卢湾高级中学', '卢湾高中', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 享受市实验性示范性高中招生政策高中
('012002', '上海市格致中学（奉贤校区）', '格致奉贤', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('012006', '上海市向明中学（浦江校区）', '向明浦江', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
-- 区实验性示范性高中 / 其他
('012011', '上海市第八中学', '市八中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('012012', '上海市第十中学', '市十中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('012013', '上海市五爱高级中学', '五爱高中', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('012014', '上海市储能中学', '储能中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('014001', '上海市金陵中学', '金陵中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('014003', '上海市市南中学', '市南中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('014004', '上海音乐学院附属黄浦比乐中学', '比乐中学', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('014006', '上海市同济黄浦设计创意中学', '同济黄浦', (SELECT id FROM ref_district WHERE code = 'HP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 徐汇区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('042001', '上海市第二中学', '市二中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('042008', '上海市南洋模范中学', '南洋模范', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('042035', '上海市位育中学', '位育中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('043015', '上海市南洋中学', '南洋中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 享受市实验性示范性高中招生政策高中
('042002', '上海市第二中学（梅陇校区）', '市二梅陇', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('042036', '复旦大学附属中学徐汇分校', '复旦徐汇', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 区实验性示范性高中 / 其他
('044109', '上海市上海中学东校', '上中东校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('044103', '上海市中国中学', '中国中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('044107', '上海市第五十四中学', '市五十四中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('044111', '上海市第四中学', '市四中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('044114', '上海市零陵中学', '零陵中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('044133', '华东理工大学附属中学', '华理附中', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 民办学校
('044162', '上海市西南位育中学', '西南位育', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('041363', '上海市世外中学', '世外中学', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('044083', '上海市民办西南高级中学', '西南高中', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('044164', '上海市西南模范中学', '西南模范', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('044239', '上海市徐汇区董恒甫高级中学', '董恒甫高中', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('044101', '上海市位育附属徐汇科技实验中学', '位育实验', (SELECT id FROM ref_district WHERE code = 'XH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 长宁区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('052001', '上海市第三女子中学', '市三女中', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('052002', '上海市延安中学', '延安中学', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('053004', '上海市复旦中学', '复旦中学', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
-- 区实验性示范性高中 / 其他
('053003', '上海市建青实验学校', '建青实验', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('053005', '上海市建青实验学校（高中部）', '建青高中', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('054030', '上海市仙霞高级中学', '仙霞高中', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('054010', '上海市西郊学校', '西郊学校', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('054043', '上海市民办新虹桥中学', '新虹桥', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('054013', '上海市天山中学', '天山中学', (SELECT id FROM ref_district WHERE code = 'CN'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 静安区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('062001', '上海市市西中学', '市西中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('062002', '上海市育才中学', '育才中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), TRUE),
('062003', '上海市新中高级中学', '新中高中', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('062004', '上海市市北中学', '市北中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('062011', '上海市回民中学', '回民中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('063004', '上海市第六十中学', '六十中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('064001', '上海市华东模范中学', '华东模范', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 区实验性示范性高中 / 其他
('064004', '上海戏剧学院附属高级中学', '上戏附中', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('064002', '上海市民立中学', '民立中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('063001', '上海市第一中学', '市一中', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('063002', '上海市华东模范中学', '华东模范', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('063003', '上海市逸夫职业学校', '逸夫职校', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('063007', '上海市彭浦中学', '彭浦中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('063008', '上海市久隆模范中学', '久隆模范', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('063077', '上海市闸北第八中学', '闸北八中', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('064007', '上海大学市北附属中学', '市北附中', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 民办学校
('064003', '上海田家炳中学', '田家炳中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('064008', '上海市民办扬波中学', '扬波中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('064021', '上海市民办扬波中学（分校）', '扬波分校', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('064023', '上海市民办新和中学', '新和中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('064024', '上海市民办风范中学', '风范中学', (SELECT id FROM ref_district WHERE code = 'JA'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 普陀区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('072001', '上海市晋元高级中学', '晋元高中', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('072002', '上海市曹杨第二中学', '曹杨二中', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), TRUE),
('073003', '上海市宜川中学', '宜川中学', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 享受市实验性示范性高中招生政策高中
('073082', '华东师范大学第二附属中学（普陀校区）', '华二普陀', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 区实验性示范性高中 / 其他
('073004', '上海市曹杨中学', '曹杨中学', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074005', '上海市晋元高级中学附属学校', '晋元附校', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074007', '上海市甘泉外国语中学', '甘泉外国语', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074016', '上海市同济大学第二附属中学', '同济二附中', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074010', '上海市华阴师范大学', '华阴师大', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074011', '上海市桃浦中学', '桃浦中学', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074018', '上海市民办进华中学', '进华中学', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074081', '上海安生学校', '安生学校', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('074085', '上海市曹杨第二中学东校', '曹二东校', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('075013', '上海培佳双语学校', '培佳双语', (SELECT id FROM ref_district WHERE code = 'PT'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 虹口区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
-- 市实验性示范性高中
('092001', '复旦大学附属复兴中学', '复兴中学', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('092002', '华东师范大学第一附属中学', '华师大一附', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('093001', '上海财经大学附属北郊高级中学', '北郊高中', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
-- 区实验性示范性高中 / 其他
('094005', '上海音乐学院虹口区北虹高级中学', '北虹高中', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('093003', '上海市继光高级中学', '继光高中', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('093004', '同济大学附属澄衷中学', '澄衷中学', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('094006', '上海市鲁迅中学', '鲁迅中学', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('094001', '上海市虹口区教育学院附属中学', '虹教附中', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('094003', '上海市友谊中学', '友谊中学', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('094004', '上海外国语大学附属外国语学校东校', '上外东校', (SELECT id FROM ref_district WHERE code = 'HK'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'))
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 杨浦区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
-- 市实验性示范性高中
('102004', '上海市杨浦高级中学', '杨浦高级', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('102032', '上海市控江中学', '控江中学', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('103002', '同济大学第一附属中学', '同济一附', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
-- 区实验性示范性高中 / 其他
('103039', '上海市复旦大学附属中学', '复旦附中', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('103012', '上海市上海理工大学附属中学', '上理工附中', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('103026', '上海财经大学附属中学', '财大附中', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('103049', '上海市同济中学', '同济中学', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('103061', '上海市市东中学', '市东中学', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('103075', '上海市思源中学', '思源中学', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('104050', '上海理工大学附属杨浦少云中学', '少云中学', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('104066', '上海市民星中学', '民星中学', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('104073', '上海市体育学院附属中学', '体院附中', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
-- 民办学校
('102058', '复旦大学第二附属中学', '复旦二附', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('104021', '上海市民办上实剑桥外国语中学', '上实剑桥', (SELECT id FROM ref_district WHERE code = 'YP'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'))
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 闵行区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('122001', '上海市七宝中学', '七宝中学', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('123001', '上海市闵行中学', '闵行中学', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 享受市实验性示范性高中招生政策高中
('122002', '华东师范大学第二附属中学闵行紫竹分校', '华二紫竹', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('122003', '上海师范大学附属中学闵行分校', '上师大闵行', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('122004', '上海交通大学附属中学闵行分校', '交大闵分', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 区实验性示范性高中 / 其他
('124006', '上海市闵行第三中学', '闵行三中', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('123002', '上海市莘庄中学', '莘庄中学', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('123003', '上海外国语大学闵行外国语中学', '上外闵外', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124005', '华东理工大学附属闵行科技高级中学', '华理闵行', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124022', '北京外国语大学附属上海闵行田园高级中学', '北外田园', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 民办学校
('124108', '上海市文来中学', '文来中学', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('125028', '华东师范大学附属闵行永德学校', '华师永德', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124010', '上海市第二体育运动学校（上海市体育中学）', '市体校', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124011', '上海市七宝中学附属鑫都实验中学', '七宝鑫都', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124012', '上海市闵行中学东校', '闵中东校', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124013', '上海市闵行区实验高级中学', '闵行实验', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124015', '上海市七宝中学浦江分校', '七宝浦江', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124019', '上海中医药大学附属浦江高级中学', '上中医浦江', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124020', '上海市金汇高级中学', '金汇高中', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124024', '上海市古美高级中学', '古美高中', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124109', '上海市民办文绮中学', '文绮中学', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124111', '上海协和双语高级中学', '协和双语', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('124114', '上海市闵行区教育学院附属中学', '闵教附中', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('124116', '上海市民办燎原双语高级中学', '燎原双语', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('125008', '上海交通大学附属闵行实验学校', '交附闵实', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('125113', '上海星河湾双语学校', '星河湾', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('125115', '上海闵行区万科双语学校', '万科双语', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('125117', '上海闵行区诺达双语学校', '诺达双语', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('125119', '上海闵行区德闳学校', '德闳学校', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('128100', '上海闵行区民办美高双语学校', '美高双语', (SELECT id FROM ref_district WHERE code = 'MH'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 宝山区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
-- 市实验性示范性高中
('132001', '上海市行知中学', '行知中学', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('132002', '上海大学附属中学', '上大附中', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
('133001', '上海市吴淞中学', '吴淞中学', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
-- 享受市实验性示范性高中招生政策高中
('132003', '上海师范大学附属中学宝山分校', '上师大宝山', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
('133003', '华东师范大学第二附属中学（宝山校区）', '华二宝山', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
-- 区实验性示范性高中 / 其他
('134001', '上海市罗店中学', '罗店中学', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134004', '上海市顾村中学', '顾村中学', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134005', '上海市行知实验中学', '行知实验', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134003', '上海市淞浦中学', '淞浦中学', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134006', '上海市高境第一中学', '高境一中', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134009', '上海市宝山区海滨中学', '海滨中学', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
-- 民办学校
('134010', '上海民办行中中学', '行中中学', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134012', '上海存志高级中学', '存志高中', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134013', '上海宝山区民办维尚高级中学', '维尚高中', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134014', '上海创艺高级中学', '创艺高中', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('134015', '上海金瑞学校', '金瑞学校', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('135001', '上海市同洲模范学校', '同洲模范', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('135003', '上海金瑞学校', '金瑞学校', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('135034', '上海宝山区世外学校', '宝山世外', (SELECT id FROM ref_district WHERE code = 'BS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'))
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 嘉定区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
-- 市实验性示范性高中
('142001', '上海市嘉定区第一中学', '嘉定一中', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
-- 享受市实验性示范性高中招生政策高中
('142002', '上海交通大学附属中学嘉定分校', '交大嘉分', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('142004', '上海师范大学附属中学嘉定新城分校', '上师大嘉定', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
-- 区实验性示范性高中 / 其他
('143001', '上海市嘉定区第二中学', '嘉定二中', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('144011', '上海市嘉定区嘉一实验高级中学', '嘉一实验', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('144010', '上海师范大学附属嘉定高级中学', '上师大嘉高', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('144006', '上海市嘉定区安亭高级中学', '安亭高中', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
-- 民办学校
('145007', '上海市民办远东学校', '远东学校', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('145018', '上海华旭双语学校', '华旭双语', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('145030', '上海嘉定区民办华盛怀少学校', '华盛怀少', (SELECT id FROM ref_district WHERE code = 'JD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'))
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 浦东新区学校 (部分)
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('152001', '上海市建平中学', '建平中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), TRUE),
('152002', '上海市进才中学', '进才中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('152004', '上海南汇中学', '南汇中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('153001', '上海市洋泾中学', '洋泾中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('153004', '上海市高桥中学', '高桥中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('153005', '上海市川沙中学', '川沙中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 享受市实验性示范性高中招生政策高中
('151078', '上海中学东校', '上中东校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('152005', '上海市浦东复旦附中分校', '浦外分校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('155004', '上海市上海外国语大学附属浦东外国语学校', '浦外', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), TRUE),
-- 区实验性示范性高中 / 其他（部分示例）
('154013', '上海海事大学附属北蔡高级中学', '海事附中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153003', '上海市上南中学', '上南中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153006', '上海市三林中学', '三林中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153007', '上海市杨思高级中学', '杨思高中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153008', '上海市新川中学', '新川中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153009', '华东师范大学附属周浦中学', '周浦中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153010', '上海海洋大学附属大团高级中学', '大团高中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153011', '上海市新场中学', '新场中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153012', '华东理工大学附属浦东科技高级中学', '华理浦东', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('153013', '华东师范大学附属浦东临港高级中学', '华师临港', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154003', '上海市文建中学', '文建中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154011', '上海市陆行中学', '陆行中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154012', '上海市浦东中学', '浦东中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154016', '上海立信会计金融学院附属高行中学', '立信高行', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154044', '上海市建平世纪中学', '建平世纪', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154046', '上海交通大学附属中学浦东实验高中', '交附浦实', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154050', '上海市南汇第一中学', '南汇一中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('151087', '上海市浦东外国语学校东校', '浦外东校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 民办学校（部分示例）
('151082', '上海民办光华中学', '光华中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('152007', '上海市建平中学筠溪分校', '建平筠溪', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('152008', '上海市进才中学根林分校', '进才根林', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154033', '上海市浦东新区民办浦实高级中学', '浦实高中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154037', '上海市民办育辛高级中学', '育辛高中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154039', '上海市民办丰华高级中学', '丰华高中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154047', '上海市祝桥高级中学', '祝桥高中', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154048', '民办上海工商外国语职业学院附属中学', '工商外附', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154051', '上海市老港中学', '老港中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154052', '上海市泥城中学', '泥城中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('154053', '上海市吴迅中学', '吴迅中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155002', '上海市长岛中学', '长岛中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155008', '上海市民办平和学校', '平和学校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('155013', '上海市民办金苹果学校', '金苹果', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155041', '上海浦东新区民办东鼎外国语学校', '东鼎外国语', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155043', '上海市民办尚德实验学校', '尚德实验', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155047', '上海浦东新区民办沪港学校', '沪港学校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155049', '上海民办华曜浦东实验学校', '华曜浦东', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155050', '上海浦东新区民办万科学校', '万科学校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155052', '上海浦东新区民办惠立学校', '惠立学校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155053', '上海浦东新区民办宏文学校', '宏文学校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155055', '上海浦东民办未来科技学校', '未来科技', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155056', '上海浦东新区民办欣竹中学', '欣竹中学', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('155057', '上海浦东新区民办宏志学校', '宏志学校', (SELECT id FROM ref_district WHERE code = 'PD'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 金山区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('162000', '上海市金山中学', '金山中学', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('163002', '华东师范大学第三附属中学', '华师三附', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
-- 区实验性示范性高中 / 其他
('163001', '上海市张堰中学', '张堰中学', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('164000', '华东师范大学附属枫泾中学', '枫泾中学', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('164002', '上海体育大学附属金山亭林中学', '亭林中学', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 民办学校
('165004', '上海金山区世外学校', '金山世外', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('164006', '上海枫叶双语学校', '枫叶双语', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('164008', '上海市民办永昌中学', '永昌中学', (SELECT id FROM ref_district WHERE code = 'JS'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 松江区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course) VALUES
-- 市实验性示范性高中
('172001', '上海市松江二中', '松江二中', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('173001', '上海市松江一中', '松江一中', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 享受市实验性示范性高中招生政策高中
('172002', '华东师范大学第二附属中学松江分校', '华二松江', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
('172004', '上海师范大学附属中学松江分校', '上师大松江', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL'), FALSE),
('174003', '上海外国语大学附属外国语学校松江云间中学', '云间中学', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL'), FALSE),
-- 区实验性示范性高中 / 其他
('174009', '上海市松江区第四中学', '松江四中', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('174016', '上海市松江区九亭中学', '九亭中学', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('172003', '华东政法大学附属松江高级中学', '华政附高', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('173003', '东华大学附属松江高级中学', '东华附高', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('174001', '上海市松江区立达中学', '立达中学', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('174002', '上海市松江区第四中学', '松江四中', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
-- 民办学校
('173002', '上海市松江区科德高级中学', '科德高中', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('174007', '上海市松江区民办茸一中学', '茸一中学', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('174008', '上海市松江九峰实验学校', '九峰实验', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('174013', '上海领科双语学校', '领科双语', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('175018', '上海阿德科特学校', '阿德科特', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('175021', '上海外国语大学附属外国语学校松江分校', '上外松分', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), TRUE),
('175024', '上海赫贤学校', '赫贤学校', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE),
('175025', '上海松江区爱菊学校', '爱菊学校', (SELECT id FROM ref_district WHERE code = 'SJ'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'), FALSE)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 青浦区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
-- 市实验性示范性高中
('182001', '上海市青浦高级中学', '青浦高中', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
('183002', '上海市朱家角中学', '朱家角中学', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'PARTIAL')),
-- 享受市实验性示范性高中招生政策高中
('182002', '复旦大学附属中学青浦分校', '复旦青浦', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
-- 区实验性示范性高中 / 其他
('184005', '上海市青浦区第一中学', '青浦一中', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('184003', '上海市青浦区第二中学', '青浦二中', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('184004', '上海市青浦区东湖中学', '东湖中学', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
-- 民办学校
('184006', '上海青浦区五科艺校', '五科艺校', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('184007', '上海青浦区世界外国语学校', '青浦世外', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('185014', '上海青浦区协和双语学校', '青浦协和', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('185000', '上海宋庆龄学校', '宋庆龄学校', (SELECT id FROM ref_district WHERE code = 'QP'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'))
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 奉贤区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
-- 市实验性示范性高中
('202001', '上海市奉贤中学', '奉贤中学', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
-- 享受市实验性示范性高中招生政策高中
('202002', '华东师范大学第二附属中学临港奉贤分校', '华二奉贤', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
-- 区实验性示范性高中 / 其他
('203002', '华东理工大学附属奉贤曙光中学', '曙光中学', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('204001', '上海市奉贤区奉城高级中学', '奉城高中', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('204005', '上海市奉贤区曙光中学', '曙光中学', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('204006', '上海市奉贤区景秀高级中学', '景秀高中', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('204008', '上海市奉贤区致远中学', '致远中学', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
-- 民办学校
('205006', '上海奉贤区博华高级中学', '博华高中', (SELECT id FROM ref_district WHERE code = 'FX'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'))
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 崇明区学校
-- =============================================================================
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id) VALUES
-- 市实验性示范性高中
('512000', '上海市崇明中学', '崇明中学', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
-- 享受市实验性示范性高中招生政策高中
('512001', '上海市实验学校东滩高级中学', '实验东滩', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'CITY_POLICY'), (SELECT id FROM ref_boarding_type WHERE code = 'FULL')),
-- 区实验性示范性高中 / 其他
('514001', '上海市崇明区城桥中学', '城桥中学', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('513001', '上海市崇明区民本中学', '民本中学', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('513009', '上海市扬子中学', '扬子中学', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('514004', '上海市崇明区堡镇中学', '堡镇中学', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'DISTRICT_MODEL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
-- 民办学校
('514010', '上海民办民一中学', '民一中学', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PRIVATE'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE')),
('514013', '上海市崇明区横沙中学', '横沙中学', (SELECT id FROM ref_district WHERE code = 'CM'), (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'), (SELECT id FROM ref_school_type WHERE code = 'GENERAL'), (SELECT id FROM ref_boarding_type WHERE code = 'NONE'))
ON CONFLICT (code) DO NOTHING;
