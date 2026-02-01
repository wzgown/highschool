-- =============================================================================
-- 2025年上海市高中名额分配到区招生计划 - 种子数据
-- =============================================================================
-- 数据来源: https://www.shmeea.edu.cn/download/20250528/014.pdf
--
-- 说明:
--   - 委属市实验性示范性高中的到区计划约占该批次招生计划的80%
--   - 区属市实验性示范性高中的到区计划约占该批次招生计划的30%
--   - 本表记录各校分配到各区的计划数
--   - "全市"表示该计划可分配到全市16个区
-- =============================================================================

-- 由于PDF显示的是"计划区域: 全市"和总计划数，这里创建全市统一的分配记录
-- 实际分配到各区时需要按各区报名人数比例进行分配

INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year)
SELECT 2025,
       s.id,
       s.code,
       d.id,
       -- 委属市实验性示范性高中
       CASE
           WHEN s.code = '042032' THEN 286  -- 上海市上海中学
           WHEN s.code = '102056' THEN 319  -- 上海交通大学附属中学
           WHEN s.code = '102057' THEN 255  -- 复旦大学附属中学
           WHEN s.code = '152003' THEN 280  -- 华东师范大学第二附属中学
           WHEN s.code = '152006' THEN 187  -- 上海师范大学附属中学
           WHEN s.code = '155001' THEN 52   -- 上海市实验学校
           WHEN s.code = '092003' THEN 0    -- 上海外国语大学附属外国语学校（名额分配单独计算）
       -- 黄浦区市实验性示范性高中
           WHEN s.code = '012001' THEN 126  -- 上海市格致中学
           WHEN s.code = '012003' THEN 136  -- 上海市大同中学
           WHEN s.code = '012005' THEN 59   -- 上海市向明中学
           WHEN s.code = '012007' THEN 96   -- 上海外国语大学附属大境中学
           WHEN s.code = '012008' THEN 86   -- 上海市光明中学
           WHEN s.code = '012009' THEN 76   -- 上海市敬业中学
           WHEN s.code = '012010' THEN 96   -- 上海市卢湾高级中学
       -- 黄浦区享受政策高中
           WHEN s.code = '012002' THEN 40   -- 上海市格致中学（奉贤校区）
           WHEN s.code = '012006' THEN 38   -- 上海市向明中学（浦江校区）
       -- 徐汇区市实验性示范性高中
           WHEN s.code = '042001' THEN 52   -- 上海市第二中学
           WHEN s.code = '042008' THEN 90   -- 上海市南洋模范中学
           WHEN s.code = '042035' THEN 89   -- 上海市位育中学
           WHEN s.code = '043015' THEN 78   -- 上海市南洋中学
       -- 徐汇区享受政策高中
           WHEN s.code = '042002' THEN 53   -- 上海市第二中学（梅陇校区）
           WHEN s.code = '042036' THEN 31   -- 复旦大学附属中学徐汇分校
       -- 长宁区市实验性示范性高中
           WHEN s.code = '052001' THEN 51   -- 上海市第三女子中学
           WHEN s.code = '052002' THEN 72   -- 上海市延安中学
           WHEN s.code = '053004' THEN 53   -- 上海市复旦中学
       -- 静安区市实验性示范性高中
           WHEN s.code = '062001' THEN 70   -- 上海市市西中学
           WHEN s.code = '062002' THEN 67   -- 上海市育才中学
           WHEN s.code = '062003' THEN 67   -- 上海市新中高级中学
           WHEN s.code = '062004' THEN 74   -- 上海市市北中学
           WHEN s.code = '062011' THEN 53   -- 上海市回民中学
           WHEN s.code = '063004' THEN 53   -- 上海市第六十中学
           WHEN s.code = '064001' THEN 44   -- 上海市华东模范中学
       -- 普陀区市实验性示范性高中
           WHEN s.code = '072001' THEN 0    -- 上海市晋元高级中学（PDF数据缺失）
           WHEN s.code = '072002' THEN 82   -- 上海市曹杨第二中学
           WHEN s.code = '073003' THEN 84   -- 上海市宜川中学
       -- 普陀区享受政策高中
           WHEN s.code = '073082' THEN 30   -- 华东师范大学第二附属中学（普陀校区）
       -- 虹口区市实验性示范性高中
           WHEN s.code = '092001' THEN 76   -- 复旦大学附属复兴中学
           WHEN s.code = '092002' THEN 71   -- 华东师范大学第一附属中学
           WHEN s.code = '093001' THEN 56   -- 上海财经大学附属北郊高级中学
       -- 杨浦区市实验性示范性高中
           WHEN s.code = '102004' THEN 100  -- 上海市杨浦高级中学
           WHEN s.code = '102032' THEN 100  -- 上海市控江中学
           WHEN s.code = '103002' THEN 84   -- 同济大学第一附属中学
       -- 闵行区市实验性示范性高中
           WHEN s.code = '122001' THEN 120  -- 上海市七宝中学
           WHEN s.code = '123001' THEN 120  -- 上海市闵行中学
       -- 闵行区享受政策高中
           WHEN s.code = '122002' THEN 69   -- 华东师范大学第二附属中学闵行紫竹分校
           WHEN s.code = '122003' THEN 86   -- 上海师范大学附属中学闵行分校
           WHEN s.code = '122004' THEN 69   -- 上海交通大学附属中学闵行分校
       -- 宝山区市实验性示范性高中
           WHEN s.code = '132001' THEN 101  -- 上海市行知中学
           WHEN s.code = '132002' THEN 101  -- 上海大学附属中学
           WHEN s.code = '133001' THEN 98   -- 上海市吴淞中学
       -- 宝山区享受政策高中
           WHEN s.code = '132003' THEN 34   -- 上海师范大学附属中学宝山分校
           WHEN s.code = '133003' THEN 49   -- 华东师范大学第二附属中学（宝山校区）
       -- 嘉定区市实验性示范性高中
           WHEN s.code = '142001' THEN 87   -- 上海市嘉定区第一中学
       -- 嘉定区享受政策高中
           WHEN s.code = '142002' THEN 105  -- 上海交通大学附属中学嘉定分校
           WHEN s.code = '142004' THEN 35   -- 上海师范大学附属中学嘉定新城分校
       -- 浦东新区市实验性示范性高中
           WHEN s.code = '152001' THEN 109  -- 上海市建平中学
           WHEN s.code = '152002' THEN 109  -- 上海市进才中学
           WHEN s.code = '152004' THEN 140  -- 上海南汇中学
           WHEN s.code = '153001' THEN 109  -- 上海市洋泾中学
           WHEN s.code = '153004' THEN 94   -- 上海市高桥中学
           WHEN s.code = '153005' THEN 94   -- 上海市川沙中学
       -- 浦东新区享受政策高中
           WHEN s.code = '151078' THEN 94   -- 上海中学东校
           WHEN s.code = '152005' THEN 56   -- 上海市浦东复旦附中分校
       -- 金山区市实验性示范性高中
           WHEN s.code = '162000' THEN 78   -- 上海市金山中学
           WHEN s.code = '163002' THEN 0    -- 华东师范大学第三附属中学（PDF数据缺失）
       -- 松江区市实验性示范性高中
           WHEN s.code = '172001' THEN 82   -- 上海市松江二中
           WHEN s.code = '173001' THEN 82   -- 上海市松江一中
       -- 松江区享受政策高中
           WHEN s.code = '172002' THEN 33   -- 华东师范大学第二附属中学松江分校
           WHEN s.code = '172004' THEN 18   -- 上海师范大学附属中学松江分校
           WHEN s.code = '174003' THEN 82   -- 上海外国语大学附属外国语学校松江云间中学
       -- 青浦区市实验性示范性高中
           WHEN s.code = '182001' THEN 112  -- 上海市青浦高级中学
           WHEN s.code = '183002' THEN 112  -- 上海市朱家角中学
       -- 青浦区享受政策高中
           WHEN s.code = '182002' THEN 49   -- 复旦大学附属中学青浦分校
       -- 奉贤区市实验性示范性高中
           WHEN s.code = '202001' THEN 87   -- 上海市奉贤中学
       -- 奉贤区享受政策高中
           WHEN s.code = '202002' THEN 43   -- 华东师范大学第二附属中学临港奉贤分校
       -- 崇明区市实验性示范性高中
           WHEN s.code = '512000' THEN 62   -- 上海市崇明中学
       -- 崇明区享受政策高中
           WHEN s.code = '512001' THEN 31   -- 上海市实验学校东滩高级中学
           ELSE 0
       END AS quota_count,
       2025
FROM ref_school s
CROSS JOIN ref_district d
WHERE s.data_year = 2025
  AND d.code = 'SH'  -- 使用"上海市"作为全市的统一分配区域
  AND EXISTS (
      SELECT 1 FROM (
          -- 委属市实验性示范性高中
          SELECT '042032' AS code UNION ALL SELECT '102056' UNION ALL SELECT '102057' UNION ALL
          SELECT '152003' UNION ALL SELECT '152006' UNION ALL SELECT '155001' UNION ALL
          -- 黄浦区
          SELECT '012001' UNION ALL SELECT '012003' UNION ALL SELECT '012005' UNION ALL
          SELECT '012007' UNION ALL SELECT '012008' UNION ALL SELECT '012009' UNION ALL
          SELECT '012010' UNION ALL SELECT '012002' UNION ALL SELECT '012006' UNION ALL
          -- 徐汇区
          SELECT '042001' UNION ALL SELECT '042008' UNION ALL SELECT '042035' UNION ALL
          SELECT '043015' UNION ALL SELECT '042002' UNION ALL SELECT '042036' UNION ALL
          -- 长宁区
          SELECT '052001' UNION ALL SELECT '052002' UNION ALL SELECT '053004' UNION ALL
          -- 静安区
          SELECT '062001' UNION ALL SELECT '062002' UNION ALL SELECT '062003' UNION ALL
          SELECT '062004' UNION ALL SELECT '062011' UNION ALL SELECT '063004' UNION ALL
          SELECT '064001' UNION ALL
          -- 普陀区
          SELECT '072001' UNION ALL SELECT '072002' UNION ALL SELECT '073003' UNION ALL
          SELECT '073082' UNION ALL
          -- 虹口区
          SELECT '092001' UNION ALL SELECT '092002' UNION ALL SELECT '093001' UNION ALL
          -- 杨浦区
          SELECT '102004' UNION ALL SELECT '102032' UNION ALL SELECT '103002' UNION ALL
          -- 闵行区
          SELECT '122001' UNION ALL SELECT '123001' UNION ALL SELECT '122002' UNION ALL
          SELECT '122003' UNION ALL SELECT '122004' UNION ALL
          -- 宝山区
          SELECT '132001' UNION ALL SELECT '132002' UNION ALL SELECT '133001' UNION ALL
          SELECT '132003' UNION ALL SELECT '133003' UNION ALL
          -- 嘉定区
          SELECT '142001' UNION ALL SELECT '142002' UNION ALL SELECT '142004' UNION ALL
          -- 浦东新区
          SELECT '152001' UNION ALL SELECT '152002' UNION ALL SELECT '152004' UNION ALL
          SELECT '153001' UNION ALL SELECT '153004' UNION ALL SELECT '153005' UNION ALL
          SELECT '151078' UNION ALL SELECT '152005' UNION ALL
          -- 金山区
          SELECT '162000' UNION ALL SELECT '163002' UNION ALL
          -- 松江区
          SELECT '172001' UNION ALL SELECT '173001' UNION ALL SELECT '172002' UNION ALL
          SELECT '172004' UNION ALL SELECT '174003' UNION ALL
          -- 青浦区
          SELECT '182001' UNION ALL SELECT '183002' UNION ALL SELECT '182002' UNION ALL
          -- 奉贤区
          SELECT '202001' UNION ALL SELECT '202002' UNION ALL
          -- 崇明区
          SELECT '512000' UNION ALL SELECT '512001'
      ) valid_schools
      WHERE valid_schools.code = s.code
  )
ON CONFLICT (year, school_code, district_id) DO NOTHING;

-- =============================================================================
-- 说明：名额分配实际分配逻辑
-- =============================================================================
--
-- 1. 委属市实验性示范性高中（6所）
--    - 到区计划占该批次招生计划的80%
--    - 按各区中招报名人数占全市中招报名人数的比例进行分配
--
-- 2. 区属市实验性示范性高中（约70所）
--    - 到区计划占该批次招生计划的30%
--    - 其中90%-95%分配到外区
--
-- 3. 实际使用时需要：
--    a) 根据各区报名人数比例，将全市计划数拆分到各区
--    b) 区属学校需要考虑本校所在区与外区的分配比例
--
-- 4. 本表存储的是全市总计划数，实际分配到各区的数据需要运行时计算
-- =============================================================================
