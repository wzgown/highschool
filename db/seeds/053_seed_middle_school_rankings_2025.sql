-- =============================================================================
-- 初中学校区内排名数据更新 - 种子数据
-- =============================================================================
-- 数据来源: shanghai_middle_school_rankings_complete.csv
-- 说明: 更新 ref_middle_school 表的 district_rank, tier, ranking_remarks 字段
-- 支持年份: 2024, 2025
-- =============================================================================

-- 清除现有排名数据
UPDATE ref_middle_school SET district_rank = NULL, tier = NULL, ranking_remarks = NULL WHERE district_rank IS NOT NULL;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '全市顶级民办，四校预录长期第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '华育中学' OR name LIKE '%华育中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = 'IB课程体系强，国际班知名',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '世外中学' OR name LIKE '%世外中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '预录成绩稳定，传统强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '西南模范' OR name LIKE '%西南模范%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '位育高中嫡系，升学率稳定',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '西南位育' OR name LIKE '%西南位育%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '一梯队',
    ranking_remarks = '公办三驾马车之一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '位育初级中学' OR name LIKE '%位育初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '一梯队',
    ranking_remarks = '科技特色班强，公办头部',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '徐汇中学' OR name LIKE '%徐汇中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '一梯队',
    ranking_remarks = '南模高中嫡系，公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '南洋模范初级中学' OR name LIKE '%南洋模范初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '一梯队',
    ranking_remarks = '上中系新校，潜力大',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '上汇实验' OR name LIKE '%上汇实验%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '二梯队',
    ranking_remarks = '教师进修学院附属，成绩稳定',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '徐教院附校' OR name LIKE '%徐教院附校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '二梯队',
    ranking_remarks = '公办中上，对口热门',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '园南中学' OR name LIKE '%园南中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '二梯队',
    ranking_remarks = '九年一贯制，中考成绩好',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '师三实验' OR name LIKE '%师三实验%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '二梯队',
    ranking_remarks = '特色班成绩突出',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '田林三中' OR name LIKE '%田林三中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 13, 
    tier = '二梯队',
    ranking_remarks = '老牌公办，整体中等偏上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '中国中学' OR name LIKE '%中国中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 14, 
    tier = '三梯队',
    ranking_remarks = '市二高中嫡系，文科见长',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '市二初级中学' OR name LIKE '%市二初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 15, 
    tier = '三梯队',
    ranking_remarks = '普通公办，进步中',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '南洋初中' OR name LIKE '%南洋初中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 16, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '龙华中学' OR name LIKE '%龙华中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 17, 
    tier = '三梯队',
    ranking_remarks = '华理附属，普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '华理附中' OR name LIKE '%华理附中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 18, 
    tier = '三梯队',
    ranking_remarks = '强校工程实验校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '紫阳中学' OR name LIKE '%紫阳中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 19, 
    tier = '三梯队',
    ranking_remarks = '近年有进步',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '梅园中学' OR name LIKE '%梅园中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 20, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '零陵中学' OR name LIKE '%零陵中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 21, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '汾阳中学' OR name LIKE '%汾阳中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 22, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '长桥中学' OR name LIKE '%长桥中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 23, 
    tier = '三梯队',
    ranking_remarks = '新校，发展中',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'XH')
  AND (name LIKE '康健外国语实验中学' OR name LIKE '%康健外国语实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '全市顶级民办，复旦系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '兰生复旦中学' OR name LIKE '%兰生复旦中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '复旦子弟学校，全市知名',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '复旦二附中' OR name LIKE '%复旦二附中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '外语特色，预录成绩好',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '上外双语学校' OR name LIKE '%上外双语学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '同济一附中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '存志中学' OR name LIKE '%存志中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '同济系，成绩稳定',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '同济大学实验学校' OR name LIKE '%同济大学实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '民办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '凯慧初级中学' OR name LIKE '%凯慧初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '艺术+学术双特色',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '上海音乐学院实验学校' OR name LIKE '%音乐学院实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '控江高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '控江民办学校' OR name LIKE '%控江学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '三梯队',
    ranking_remarks = '民办中等',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '杨浦实验中学' OR name LIKE '%杨浦实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '鞍山初级中学' OR name LIKE '%鞍山初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '铁岭中学' OR name LIKE '%铁岭中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '三梯队',
    ranking_remarks = '同济系公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '同济第二初级中学' OR name LIKE '%同济第二初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 13, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '惠民中学' OR name LIKE '%惠民中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 14, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '延吉第二初级中学' OR name LIKE '%延吉第二初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 15, 
    tier = '三梯队',
    ranking_remarks = '九年一贯制',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'YP')
  AND (name LIKE '市光学校' OR name LIKE '%市光学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '大同高中嫡系，民办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '民办立达中学' OR name LIKE '%立达中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '大同高中嫡系，公办头部',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '大同初级中学' OR name LIKE '%大同初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '格致高中嫡系，公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '格致初级中学' OR name LIKE '%格致初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '民办知名',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '民办永昌学校' OR name LIKE '%永昌学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '向明高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '向明初级中学' OR name LIKE '%向明初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '卢湾初级中学' OR name LIKE '%卢湾初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '李惠利中学' OR name LIKE '%李惠利中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '明珠中学' OR name LIKE '%明珠中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '市八初级中学' OR name LIKE '%市八初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '尚文中学' OR name LIKE '%尚文中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '储能中学' OR name LIKE '%储能中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HP')
  AND (name LIKE '敬业初级中学' OR name LIKE '%敬业初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '市北理全市知名，公办顶级',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '市北初级中学' OR name LIKE '%市北初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '全区顶尖公办，成绩优异',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '静教院附校' OR name LIKE '%静教院附校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '民办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '民办扬波中学' OR name LIKE '%扬波中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '新晋公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '苏河湾中学' OR name LIKE '%苏河湾中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '市西高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '市西初级中学' OR name LIKE '%市西初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '风华初级中学' OR name LIKE '%风华初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '田家炳中学' OR name LIKE '%田家炳中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '同济系公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '同济附中七一中学' OR name LIKE '%同济附中七一中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '二梯队',
    ranking_remarks = '民办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '民办新和中学' OR name LIKE '%新和中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '育才高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '育才初级中学' OR name LIKE '%育才初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '民立中学' OR name LIKE '%民立中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '华东模范中学' OR name LIKE '%华东模范中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 13, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '五四中学' OR name LIKE '%五四中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 14, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '彭浦初级中学' OR name LIKE '%彭浦初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 15, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '彭浦第三中学' OR name LIKE '%彭浦第三中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 16, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JA')
  AND (name LIKE '岭南中学' OR name LIKE '%岭南中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '全市顶级公办，十年一贯制',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '上海市实验学校' OR name LIKE '%实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '原民办转公，成绩优异',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '张江集团中学' OR name LIKE '%张江集团中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '华二系民办，全市知名',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '浦东华曜' OR name LIKE '%浦东华曜%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '交大附中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '交中初级中学' OR name LIKE '%交中初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '一梯队',
    ranking_remarks = '建平高中嫡系，公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '建平中学西校' OR name LIKE '%建平中学西校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '一梯队',
    ranking_remarks = '建平系公办，规模大',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '建平实验中学' OR name LIKE '%建平实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '一梯队',
    ranking_remarks = '外语特色，保送名额多',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '上外浦东外国语学校' OR name LIKE '%上外浦东外国语学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '一梯队',
    ranking_remarks = '上中系分校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '上中东校' OR name LIKE '%上中东校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '一梯队',
    ranking_remarks = '民办强校，预录成绩好',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '欣竹中学' OR name LIKE '%欣竹中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '二梯队',
    ranking_remarks = '进才高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '进才实验中学' OR name LIKE '%进才实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '二梯队',
    ranking_remarks = '进才系公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '进才北校' OR name LIKE '%进才北校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '二梯队',
    ranking_remarks = '九年一贯制，成绩好',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '洋泾-菊园实验学校' OR name LIKE '%洋泾-菊园实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 13, 
    tier = '二梯队',
    ranking_remarks = '上实系分校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '上实东校' OR name LIKE '%上实东校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 14, 
    tier = '二梯队',
    ranking_remarks = '建平系民办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '建平远翔' OR name LIKE '%建平远翔%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 15, 
    tier = '二梯队',
    ranking_remarks = '大型民办学校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '尚德实验学校' OR name LIKE '%尚德实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 16, 
    tier = '三梯队',
    ranking_remarks = '周浦片区公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '澧溪中学' OR name LIKE '%澧溪中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 17, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '致远中学' OR name LIKE '%致远中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 18, 
    tier = '三梯队',
    ranking_remarks = '南汇片区公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '南汇第一中学' OR name LIKE '%南汇第一中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 19, 
    tier = '三梯队',
    ranking_remarks = '南汇片区公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '南汇第二中学' OR name LIKE '%南汇第二中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 20, 
    tier = '三梯队',
    ranking_remarks = '南汇片区公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '南汇第四中学' OR name LIKE '%南汇第四中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 21, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '浦东模范中学' OR name LIKE '%浦东模范中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 22, 
    tier = '三梯队',
    ranking_remarks = '川沙片区公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PD')
  AND (name LIKE '川沙南校' OR name LIKE '%川沙南校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '七宝中学嫡系，闵行第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '上宝中学' OR name LIKE '%上宝中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '七宝中学嫡系，民办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '文来中学' OR name LIKE '%文来中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '闵行中学嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '文绮中学' OR name LIKE '%文绮中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '华二系民办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '闵行华二' OR name LIKE '%闵行华二%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '公办头部，成绩稳定',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '莘松中学' OR name LIKE '%莘松中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '莘光中学' OR name LIKE '%莘光中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '七宝系公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '七宝二中' OR name LIKE '%七宝二中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '交大系公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '交大二附中' OR name LIKE '%交大二附中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '二梯队',
    ranking_remarks = '上实系分校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '上实西校' OR name LIKE '%上实西校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '九年一贯制',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '莘城学校' OR name LIKE '%莘城学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '三梯队',
    ranking_remarks = '浦江片区公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '浦江一中' OR name LIKE '%浦江一中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '颛桥中学' OR name LIKE '%颛桥中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 13, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '闵行三中' OR name LIKE '%闵行三中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 14, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'MH')
  AND (name LIKE '马桥强恕学校' OR name LIKE '%马桥强恕学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '神仙学校，保送名额多',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '上外附中' OR name LIKE '%上外附中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '民办强校，预录成绩好',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '新华初级中学' OR name LIKE '%新华初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '民办知名',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '迅行中学' OR name LIKE '%迅行中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '复兴高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '新复兴初级中学' OR name LIKE '%新复兴初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '一梯队',
    ranking_remarks = '上外系分校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '上外附中东校' OR name LIKE '%上外附中东校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '新北郊初级中学' OR name LIKE '%新北郊初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '长青学校' OR name LIKE '%长青学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '虹口实验学校' OR name LIKE '%虹口实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '北郊学校' OR name LIKE '%北郊学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '民办中等',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '民办丽英小学（初中部）' OR name LIKE '%丽英小学（初中部）%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '三梯队',
    ranking_remarks = '外语特色',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '民办克勒外国语学校' OR name LIKE '%克勒外国语学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '江湾初级中学' OR name LIKE '%江湾初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 13, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'HK')
  AND (name LIKE '钟山初级中学' OR name LIKE '%钟山初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '华师大二附中嫡系，普陀第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '进华中学' OR name LIKE '%进华中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '双语特色，民办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '培佳双语学校' OR name LIKE '%培佳双语学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '公办强校，成绩优异',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '梅陇中学' OR name LIKE '%梅陇中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '兰田中学' OR name LIKE '%兰田中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '曹二高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '曹杨二中附属学校' OR name LIKE '%曹杨二中附学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '华师大系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '华师大四附中' OR name LIKE '%华师大四附中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '晋元高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '晋元附属学校' OR name LIKE '%晋元附学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '江宁学校' OR name LIKE '%江宁学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '中远实验学校' OR name LIKE '%中远实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '宜川高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '宜川中学附属学校' OR name LIKE '%宜川中学附学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '三梯队',
    ranking_remarks = '外语特色',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '甘泉外国语中学' OR name LIKE '%甘泉外国语中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 12, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'PT')
  AND (name LIKE '真北中学' OR name LIKE '%真北中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '长宁公办第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '东延安中学' OR name LIKE '%东延安中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '西延安中学' OR name LIKE '%西延安中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '公办头部',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '娄山中学' OR name LIKE '%娄山中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '二梯队',
    ranking_remarks = '女子特色，公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '市三女子初级中学' OR name LIKE '%市三女子初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '民办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '新世纪中学' OR name LIKE '%新世纪中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '延安高中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '延安初级中学' OR name LIKE '%延安初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '天山初级中学' OR name LIKE '%天山初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '仙霞高级中学' OR name LIKE '%仙霞高级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '三梯队',
    ranking_remarks = '华政附属',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CN')
  AND (name LIKE '华政附属中学' OR name LIKE '%华政附中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '华二系民办，宝山第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '华曜宝山实验学校' OR name LIKE '%华曜宝山实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '世外系，新校潜力大',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '宝山世外' OR name LIKE '%宝山世外%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '交大附中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '交华中学' OR name LIKE '%交华中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '公办头部',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '宝山实验学校' OR name LIKE '%宝山实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '行知高中嫡系，公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '行知二中' OR name LIKE '%行知二中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '民办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '民办和衷中学' OR name LIKE '%和衷中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '求真中学' OR name LIKE '%求真中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '经纬实验' OR name LIKE '%经纬实验%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '淞谊中学' OR name LIKE '%淞谊中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'BS')
  AND (name LIKE '吴淞中学' OR name LIKE '%吴淞中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '华二系，全市前十级别',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '民办华二初级（嘉定华二）' OR name LIKE '%华二初级（嘉定华二）%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '嘉定本土民办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '桃李园实验学校' OR name LIKE '%桃李园实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '嘉定一中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '嘉一联合中学' OR name LIKE '%嘉一联合中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '二梯队',
    ranking_remarks = '民办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '怀少学校' OR name LIKE '%怀少学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '一梯队',
    ranking_remarks = '交大附中系公办，嘉定公办头部，2021年创办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '交大附中附属嘉定洪德中学' OR name LIKE '%交大附中附嘉定洪德中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '一梯队',
    ranking_remarks = '同济系公办，嘉定公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '同济大学附属实验中学' OR name LIKE '%同济大学附实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '公办头部，传统强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '迎园中学' OR name LIKE '%迎园中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '震川中学' OR name LIKE '%震川中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '三梯队',
    ranking_remarks = '曹二系分校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '曹二附属江桥实验' OR name LIKE '%曹二附江桥实验%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '疁城实验学校' OR name LIKE '%疁城实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '二梯队',
    ranking_remarks = '上外系公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND (name LIKE '上外嘉定外国语' OR name LIKE '%上外嘉定外国语%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '松江民办第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '九峰实验学校' OR name LIKE '%九峰实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '松江中学嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '茸一中学' OR name LIKE '%茸一中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '公办头部，成绩优异',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '民乐学校' OR name LIKE '%民乐学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '三新学校' OR name LIKE '%三新学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '一梯队',
    ranking_remarks = '上外系公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '上外松江外国语' OR name LIKE '%上外松江外国语%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '松江七中' OR name LIKE '%松江七中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '松江二中嫡系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '松江二中初级中学' OR name LIKE '%松江二中初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '二梯队',
    ranking_remarks = '华师大系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '华师大松江实验中学' OR name LIKE '%华师大松江实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 9, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '松江六中' OR name LIKE '%松江六中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 10, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '松江四中' OR name LIKE '%松江四中%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 11, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'SJ')
  AND (name LIKE '九亭中学' OR name LIKE '%九亭中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '兰生系，青浦第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'QP')
  AND (name LIKE '青浦兰生复旦' OR name LIKE '%青浦兰生复旦%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '复旦系民办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'QP')
  AND (name LIKE '复旦五浦汇' OR name LIKE '%复旦五浦汇%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '世外系民办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'QP')
  AND (name LIKE '青浦世外' OR name LIKE '%青浦世外%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '二梯队',
    ranking_remarks = '公办头部',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'QP')
  AND (name LIKE '青浦实验中学' OR name LIKE '%青浦实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'QP')
  AND (name LIKE '尚美中学' OR name LIKE '%尚美中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'QP')
  AND (name LIKE '东方中学' OR name LIKE '%东方中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'QP')
  AND (name LIKE '毓秀学校' OR name LIKE '%毓秀学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '奉贤公办第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'FX')
  AND (name LIKE '奉贤实验中学' OR name LIKE '%奉贤实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'FX')
  AND (name LIKE '育秀实验学校' OR name LIKE '%育秀实验学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'FX')
  AND (name LIKE '汇贤中学' OR name LIKE '%汇贤中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'FX')
  AND (name LIKE '崇实中学' OR name LIKE '%崇实中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '九年一贯制',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'FX')
  AND (name LIKE '弘文学校' OR name LIKE '%弘文学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'FX')
  AND (name LIKE '古华中学' OR name LIKE '%古华中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'FX')
  AND (name LIKE '华亭学校' OR name LIKE '%华亭学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '金山公办第一',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '蒙山中学' OR name LIKE '%蒙山中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '罗星中学' OR name LIKE '%罗星中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '世外系民办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '金山世外' OR name LIKE '%金山世外%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '二梯队',
    ranking_remarks = '公办优质',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '西林中学' OR name LIKE '%西林中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '金山初级中学' OR name LIKE '%金山初级中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '民办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '金盟学校' OR name LIKE '%金盟学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '二梯队',
    ranking_remarks = '存志系',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '存志实验中学' OR name LIKE '%存志实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 8, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'JS')
  AND (name LIKE '石化第五中学' OR name LIKE '%石化第五中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 1, 
    tier = '一梯队',
    ranking_remarks = '崇明民办第一，市重点率65%',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CM')
  AND (name LIKE '民办民一中学' OR name LIKE '%民一中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 2, 
    tier = '一梯队',
    ranking_remarks = '上实系分校，公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CM')
  AND (name LIKE '上实东滩学校' OR name LIKE '%上实东滩学校%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 3, 
    tier = '一梯队',
    ranking_remarks = '公办头部',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CM')
  AND (name LIKE '东门中学' OR name LIKE '%东门中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 4, 
    tier = '一梯队',
    ranking_remarks = '公办强校',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CM')
  AND (name LIKE '崇明实验中学' OR name LIKE '%崇明实验中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 5, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CM')
  AND (name LIKE '裕安中学' OR name LIKE '%裕安中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 6, 
    tier = '二梯队',
    ranking_remarks = '公办中上',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CM')
  AND (name LIKE '正大中学' OR name LIKE '%正大中学%')
  AND is_active = TRUE;

UPDATE ref_middle_school 
SET district_rank = 7, 
    tier = '三梯队',
    ranking_remarks = '普通公办',
    updated_at = CURRENT_TIMESTAMP
WHERE district_id = (SELECT id FROM ref_district WHERE code = 'CM')
  AND (name LIKE '三星中学' OR name LIKE '%三星中学%')
  AND is_active = TRUE;


-- =============================================================================
-- 统计更新结果
-- =============================================================================
SELECT d.name AS 区, COUNT(*) AS 已排名学校数
FROM ref_middle_school ms
JOIN ref_district d ON ms.district_id = d.id
WHERE ms.district_rank IS NOT NULL AND ms.is_active = TRUE
GROUP BY d.name, d.code
ORDER BY d.code;
