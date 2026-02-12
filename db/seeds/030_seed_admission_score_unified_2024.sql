-- ============================================================================
-- 2024年1-15志愿录取分数线 - 种子数据
-- 数据来源: processed/cutoff_scores/cutoff_scores_2024.csv
-- 总分750分（学业考成绩）
-- ============================================================================

-- 上海市奉贤中学 (202001) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市奉贤中学', 677.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学临港奉贤分校 (202002) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '华东师范大学第二附属中学临港奉贤分校', 672.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学（奉贤校区） (12002) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市格致中学（奉贤校区）', 670.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 华东理工大学附属奉贤曙光中学 (203002) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '华东理工大学附属奉贤曙光中学', 647.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 东华大学附属奉贤致远中学 (204001) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '东华大学附属奉贤致远中学', 626.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区奉城高级中学 (204005) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市奉贤区奉城高级中学', 611.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区景秀高级中学 (204008) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市奉贤区景秀高级中学', 589.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学第四附属中学 (204006) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海师范大学第四附属中学', 583.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海奉贤区博华双语学校 (205006) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海奉贤区博华双语学校', 560.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海美达菲双语高级中学 (204020) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海美达菲双语高级中学', 518.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市五爱高级中学 (13002) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市五爱高级中学', 673.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市上海中学 (42032) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市上海中学', 705.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海田家炳中学 (64020) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海田家炳中学', 631.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海戏剧学院附属高级中学（艺术班） (69004) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海戏剧学院附属高级中学（艺术班）', 624.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海安生学校 (74081) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海安生学校', 540.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海音乐学院附属安师实验中学（艺术班） (79016) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海音乐学院附属安师实验中学（艺术班）', 606.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学 (102056) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海交通大学附属中学', 701.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学 (102057) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '复旦大学附属中学', 699.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办文绮中学 (124109) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市民办文绮中学', 634.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海存志高级中学 (134012) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海存志高级中学', 617.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山华曜高级中学 (134015) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市宝山华曜高级中学', 612.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办远东学校 (145007) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市民办远东学校', 577.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 (152003) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '华东师范大学第二附属中学', 701.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学 (152006) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海师范大学附属中学', 688.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办丰华高级中学 (154039) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市民办丰华高级中学', 582.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 民办上海工商外国语职业学院附属中学 (154048) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '民办上海工商外国语职业学院附属中学', 578.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办东鼎外国语学校 (155041) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海浦东新区民办东鼎外国语学校', 580.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办尚德实验学校 (155043) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市民办尚德实验学校', 642.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办交大南洋中学 (164005) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市民办交大南洋中学', 581.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办永昌中学 (164008) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市民办永昌中学', 574.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海金山区世外学校 (165004) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海金山区世外学校', 617.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市西外外国语学校 (175018) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海市西外外国语学校', 551.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海赫贤学校 (175024) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海赫贤学校', 623.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海青浦区世外高级中学 (184006) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海青浦区世外高级中学', 549.0, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办民一中学 (514010) - 崇明区
INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, data_year
) VALUES (
    2024, (SELECT id FROM ref_district WHERE code = 'CM'), '上海民办民一中学', 581.5, 2024
) ON CONFLICT (year, district_id, school_name) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    updated_at = CURRENT_TIMESTAMP;
