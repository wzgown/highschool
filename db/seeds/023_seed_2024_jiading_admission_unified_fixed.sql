-- =============================================================================
-- 2024年1-15志愿录取分数线（嘉定区）- 种子数据
-- =============================================================================
-- 数据来源: 2024中考1-15志愿录取分数线嘉定区.csv
--
-- 说明:
--   - 总分750分（学业考成绩）
--   - 平行志愿原则：分数优先、遵循志愿、一轮投档
--   - "/" 表示未招满或无人填报
-- =============================================================================

INSERT INTO ref_admission_score_unified (
    year, district_id, school_name, min_score, chinese_math_foreign_sum,
    math_score, chinese_score, data_year
)
SELECT 2024,
       (SELECT id FROM ref_district WHERE code = 'JD'),
       school_name,
       min_score,
       CASE WHEN chinese_math_foreign_sum IS NULL THEN NULL ELSE chinese_math_foreign_sum::DECIMAL(6,2) END,
       CASE WHEN math_score IS NULL THEN NULL ELSE math_score::DECIMAL(5,2) END,
       CASE WHEN chinese_score IS NULL THEN NULL ELSE chinese_score::DECIMAL(5,2) END,
       2024
FROM (
    VALUES
    -- 嘉定区本地高中
    ('上海市嘉定区第一中学', 675.0, 390.5, NULL, NULL),
    ('上海交通大学附属中学嘉定分校', 684.0, 398.5, NULL, NULL),
    ('上海市嘉定区第二中学', 648.5, 379.0, 123.0, NULL),
    ('上海市嘉定区嘉一实验高级中学', 664.0, 392.0, NULL, NULL),
    ('上海师范大学附属嘉定高级中学', 634.5, 377.0, NULL, NULL),
    ('上海市嘉定区安亭高级中学', 623.0, 360.0, NULL, NULL),
    ('上海大学附属嘉定高级中学', 610.0, 347.5, NULL, NULL),
    ('上海市嘉定区中光高级中学', 593.0, 357.5, 108.0, 124.0),
    ('上海市嘉定区封浜高级中学', 557.5, NULL, NULL, NULL),
    -- 民办学校（未招满）
    ('上海市民办远东学校', 518.0, NULL, NULL, NULL),
    ('上海华旭双语学校', 518.0, NULL, NULL, NULL),
    ('上海嘉定区民办华盛怀少学校', 518.0, NULL, NULL, NULL),
    -- 委属市实验性示范性高中（在嘉定招生）
    ('上海市上海中学', 712.0, NULL, NULL, NULL),
    ('上海交通大学附属中学', 707.5, 423.5, NULL, NULL),
    ('复旦大学附属中学', 708.0, NULL, NULL, NULL),
    ('华东师范大学第二附属中学', 710.5, NULL, NULL, NULL),
    ('上海师范大学附属中学', 687.0, NULL, NULL, NULL),
    -- 黄浦区高中
    ('上海市五爱高级中学', 661.5, NULL, NULL, NULL),
    ('上海市同济黄浦设计创意中学', 630.0, NULL, NULL, NULL),
    -- 静安区高中
    ('上海市久隆模范中学', NULL, NULL, NULL, NULL),
    -- 普陀区高中
    ('上海田家炳中学', 645.0, NULL, NULL, NULL),
    -- 宝山区高中
    ('上海安生学校', 518.0, NULL, NULL, NULL),
    ('上海存志高级中学', 633.0, NULL, NULL, NULL),
    ('上海创艺高级中学', 518.0, NULL, NULL, NULL),
    ('上海市宝山华曜高级中学', 628.5, NULL, NULL, NULL),
    ('上海市同洲模范学校', 523.5, NULL, NULL, NULL),
    ('上海金瑞学校', 518.0, NULL, NULL, NULL),
    ('上海宝山区世外学校', 666.0, NULL, NULL, NULL),
    -- 浦东新区高中
    ('上海市浦东新区民办浦实高级中学', 518.0, NULL, NULL, NULL)
) AS data (school_name, min_score, chinese_math_foreign_sum, math_score, chinese_score)
WHERE min_score IS NOT NULL
ON CONFLICT (year, district_id, school_name) DO NOTHING;

-- =============================================================================
-- 说明
-- =============================================================================
-- 1. 本表存储1-15志愿录取分数线
-- 2. 总分750分 = 学业考试总成绩（不含综合素质评价）
-- 3. 518分为2024年普通高中最低投档控制分数线
-- 4. "/" 或 NULL 表示未招满或无人填报
-- 5. 平行志愿执行"分数优先、遵循志愿、一轮投档"原则
-- 6. 一旦投档被某所学校录取，后续志愿自然失效
-- =============================================================================
