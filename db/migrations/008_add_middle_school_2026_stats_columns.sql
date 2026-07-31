-- 2026年初中统计扩展字段
-- 来源: sh_zhongkao_2026 数据集（排行榜声誉分 / 700+民间统计）
-- 说明: reputation_score 为公开口碑归一化分(0-100, 主观, 仅供参考);
--       score_700plus_count 为民间统计的700分以上人数(非官方, 仅高分段);
--       score_700plus_reliability 取值: 多源一致/单一来源/网传存疑/仅最高分

ALTER TABLE ref_middle_school ADD COLUMN IF NOT EXISTS reputation_score NUMERIC(5,1);
ALTER TABLE ref_middle_school ADD COLUMN IF NOT EXISTS score_700plus_count INTEGER;
ALTER TABLE ref_middle_school ADD COLUMN IF NOT EXISTS score_700plus_reliability VARCHAR(20);
