-- 2026 平行志愿数据清理
-- 1) 删除艺术班幻影行: zip 平行志愿中"上海戏剧学院附属高级中学"/"上海音乐学院附属安师实验中学"
--    (无招生代码) 与同区"（艺术班）"行同分, 实为同一条艺术班录取线, 本部校名行系误配
-- 2) 修复徐汇区历史数据: 2026 徐汇平行志愿行 school_id 全部为 1(上海中学), 按校名回挂正确 school_id

BEGIN;

DELETE FROM ref_admission_score_unified a
WHERE a.year = 2026
  AND a.school_name IN ('上海戏剧学院附属高级中学', '上海音乐学院附属安师实验中学')
  AND a.district_id IN (3, 11, 17)
  AND EXISTS (
    SELECT 1 FROM ref_admission_score_unified b
    WHERE b.year = 2026 AND b.district_id = a.district_id AND b.min_score = a.min_score
      AND b.school_name = a.school_name || '（艺术班）'
  );

UPDATE ref_admission_score_unified u
SET school_id = s.id
FROM ref_school s
WHERE u.year = 2026 AND u.district_id = 3 AND u.school_id = 1
  AND u.school_name <> '上海市上海中学'
  AND s.full_name = u.school_name;

COMMIT;
