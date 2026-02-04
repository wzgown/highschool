-- =============================================================================
-- 2024年名额分配到校招生计划（嘉定区）- 种子数据
-- =============================================================================
-- 数据来源: 2024年上海市高中名额分配到校招生计划（嘉定区）.csv
--
-- 说明:
--   - 每个初中学校可填报2个平行志愿
--   - 限不选择生源初中在籍在读满3年的应届生填报
--   - 数据格式: 初中学校, 招生学校代码1, 招生学校名称1, 计划数1, 招生学校代码2, 招生学校名称2, 计划数2
-- =============================================================================

-- 首先插入嘉定区的初中学校
INSERT INTO ref_middle_school (name, district_id, school_nature_id, is_non_selective, data_year) VALUES
('上海市嘉定区启良中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区方泰中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市曹杨二中附属江桥实验中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区迎园中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区南苑中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区黄渡中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区徐行中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区马陆育才联合中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市民办嘉一联合中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', FALSE, 2024),
('上海市嘉定区丰庄中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区外冈中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海民办华曜嘉定初级中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', FALSE, 2024),
('上海市嘉定区震川中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海大学附属嘉定留云中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('交大附中附属嘉定德富中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('同济大学附属实验中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区华江中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区新城实验中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区南翔中学', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区疁城实验学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区戬浜学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区朱桥学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区苏民学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市民办远东学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', FALSE, 2024),
('上海市民办桃李园实验学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', FALSE, 2024),
('上海市嘉定区华亭学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区娄塘学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海外国语大学嘉定外国语学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024),
('上海市嘉定区练川实验学校', (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024)
ON CONFLICT (code, data_year) DO NOTHING;

-- 插入名额分配到校招生计划数据（嘉定区）
-- 每个初中学校的2个志愿
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_name, quota_count, data_year)
WITH district_id AS (SELECT id FROM ref_district WHERE code = 'JD')
SELECT 2024,
       district_id.id,
       s.id,
       s.code,
       ms.name AS middle_school_name,
       -- 解析计划数（志愿1和志愿2）
       CASE
           WHEN s.code = '142001' THEN 7  -- 启良中学志愿1
           WHEN s.code = '142002' THEN 9  -- 启良中学志愿2
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区方泰中学' THEN 2
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区方泰中学' THEN 2
           WHEN s.code = '102057' AND ms.name = '上海市曹杨二中附属江桥实验中学' THEN 1  -- 复旦附中
           WHEN s.code = '142001' AND ms.name = '上海市曹杨二中附属江桥实验中学' THEN 8
           WHEN s.code = '142002' AND ms.name = '上海市曹杨二中附属江桥实验中学' THEN 11
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区迎园中学' THEN 12
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区迎园中学' THEN 15
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区南苑中学' THEN 4
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区南苑中学' THEN 5
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区黄渡中学' THEN 6
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区黄渡中学' THEN 8
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区徐行中学' THEN 2
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区徐行中学' THEN 3
           WHEN s.code = '102057' AND ms.name = '上海市嘉定区马陆育才联合中学' THEN 1
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区马陆育才联合中学' THEN 4
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区马陆育才联合中学' THEN 3
           WHEN s.code = '142001' AND ms.name = '上海市民办嘉一联合中学' THEN 9
           WHEN s.code = '142002' AND ms.name = '上海市民办嘉一联合中学' THEN 11
           WHEN s.code = '152006' AND ms.name = '上海市嘉定区丰庄中学' THEN 1  -- 上师大附中
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区丰庄中学' THEN 6
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区丰庄中学' THEN 7
           WHEN s.code = '152003' AND ms.name = '上海市嘉定区外冈中学' THEN 1  -- 华二
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区外冈中学' THEN 4
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区外冈中学' THEN 3
           WHEN s.code = '142001' AND ms.name = '上海民办华曜嘉定初级中学' THEN 7
           WHEN s.code = '142002' AND ms.name = '上海民办华曜嘉定初级中学' THEN 8
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区震川中学' THEN 14
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区震川中学' THEN 16
           WHEN s.code = '142001' AND ms.name = '上海大学附属嘉定留云中学' THEN 3
           WHEN s.code = '142002' AND ms.name = '上海大学附属嘉定留云中学' THEN 3
           WHEN s.code = '102056' AND ms.name = '交大附中附属嘉定德富中学' THEN 1  -- 交大附中
           WHEN s.code = '142001' AND ms.name = '交大附中附属嘉定德富中学' THEN 8
           WHEN s.code = '142002' AND ms.name = '交大附中附属嘉定德富中学' THEN 11
           WHEN s.code = '142001' AND ms.name = '同济大学附属实验中学' THEN 6
           WHEN s.code = '142002' AND ms.name = '同济大学附属实验中学' THEN 7
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区华江中学' THEN 5
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区华江中学' THEN 6
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区新城实验中学' THEN 7
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区新城实验中学' THEN 8
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区南翔中学' THEN 6
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区南翔中学' THEN 7
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区疁城实验学校' THEN 11
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区疁城实验学校' THEN 13
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区戬浜学校' THEN 1
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区戬浜学校' THEN 1
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区朱桥学校' THEN 2
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区朱桥学校' THEN 3
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区苏民学校' THEN 7
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区苏民学校' THEN 9
           WHEN s.code = '142001' AND ms.name = '上海市民办远东学校' THEN 5
           WHEN s.code = '142002' AND ms.name = '上海市民办远东学校' THEN 6
           WHEN s.code = '142001' AND ms.name = '上海市民办桃李园实验学校' THEN 13
           WHEN s.code = '142002' AND ms.name = '上海市民办桃李园实验学校' THEN 15
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区华亭学校' THEN 1
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区华亭学校' THEN 1
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区娄塘学校' THEN 1
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区娄塘学校' THEN 2
           WHEN s.code = '102056' AND ms.name = '上海外国语大学嘉定外国语学校' THEN 1
           WHEN s.code = '142001' AND ms.name = '上海外国语大学嘉定外国语学校' THEN 9
           WHEN s.code = '142002' AND ms.name = '上海外国语大学嘉定外国语学校' THEN 9
           WHEN s.code = '142001' AND ms.name = '上海市嘉定区练川实验学校' THEN 6
           WHEN s.code = '142002' AND ms.name = '上海市嘉定区练川实验学校' THEN 7
           ELSE 0
       END AS quota_count,
       2024
FROM ref_school s
CROSS JOIN (SELECT id FROM ref_district WHERE code = 'JD') AS district_id
CROSS JOIN LATERAL (
    SELECT name FROM ref_middle_school ms
    WHERE ms.district_id = district_id.id
      AND ms.data_year = 2024
      AND EXISTS (
          SELECT 1 FROM (
              SELECT '上海市嘉定区启良中学' AS name UNION ALL
              SELECT '上海市嘉定区方泰中学' UNION ALL
              SELECT '上海市曹杨二中附属江桥实验中学' UNION ALL
              SELECT '上海市嘉定区迎园中学' UNION ALL
              SELECT '上海市嘉定区南苑中学' UNION ALL
              SELECT '上海市嘉定区黄渡中学' UNION ALL
              SELECT '上海市嘉定区徐行中学' UNION ALL
              SELECT '上海市嘉定区马陆育才联合中学' UNION ALL
              SELECT '上海市民办嘉一联合中学' UNION ALL
              SELECT '上海市嘉定区丰庄中学' UNION ALL
              SELECT '上海市嘉定区外冈中学' UNION ALL
              SELECT '上海民办华曜嘉定初级中学' UNION ALL
              SELECT '上海市嘉定区震川中学' UNION ALL
              SELECT '上海大学附属嘉定留云中学' UNION ALL
              SELECT '交大附中附属嘉定德富中学' UNION ALL
              SELECT '同济大学附属实验中学' UNION ALL
              SELECT '上海市嘉定区华江中学' UNION ALL
              SELECT '上海市嘉定区新城实验中学' UNION ALL
              SELECT '上海市嘉定区南翔中学' UNION ALL
              SELECT '上海市嘉定区疁城实验学校' UNION ALL
              SELECT '上海市嘉定区戬浜学校' UNION ALL
              SELECT '上海市嘉定区朱桥学校' UNION ALL
              SELECT '上海市嘉定区苏民学校' UNION ALL
              SELECT '上海市民办远东学校' UNION ALL
              SELECT '上海市民办桃李园实验学校' UNION ALL
              SELECT '上海市嘉定区华亭学校' UNION ALL
              SELECT '上海市嘉定区娄塘学校' UNION ALL
              SELECT '上海外国语大学嘉定外国语学校' UNION ALL
              SELECT '上海市嘉定区练川实验学校'
          ) valid_ms
          WHERE valid_ms.name = ms.name
      )
) ms
WHERE s.data_year = 2024
  AND s.code IN ('142001', '142002', '102057', '152006', '152003', '102056')
  AND (
    (s.code = '142001') OR  -- 嘉定区第一中学
    (s.code = '142002') OR  -- 交大附中嘉定分校
    (s.code = '102057') OR  -- 复旦附中
    (s.code = '152006') OR  -- 上师大附中
    (s.code = '152003') OR  -- 华二
    (s.code = '102056')     -- 交大附中
  )
ON CONFLICT (year, high_school_code, middle_school_name) DO NOTHING;
