#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 2026 数据导入 SQL（基于 zip 数据集 × 线上库交叉比对）v2
- 右锚定解析（列错位修复）
- 校区歧义：2026计划过滤 + 2025分数就近的全排列最优分配
"""
import csv, re, os, collections, itertools

BASE = os.path.dirname(os.path.abspath(__file__))
CSV = os.path.join(BASE, 'csv')
DB = os.path.join(BASE, 'dbdump_prod')
REPO = os.path.expanduser('~/workspace/wzgown/highschool_new')

def read_csv(p):
    with open(p, encoding='utf-8') as f: return list(csv.reader(f))

def load_sheet(fn):
    rows = read_csv(os.path.join(CSV, fn))
    for i, r in enumerate(rows):
        if r and r[0] in ('区', '接收区', '招生代码', '区域'):
            return r, rows[i+1:]
    raise ValueError(fn)

def N(s):
    return re.sub(r'\s+', '', s or '').replace('（', '(').replace('）', ')')

def base_name(s):
    return re.sub(r'\(.*\)$', '', N(s))

def esc(s):
    return "'" + (s or '').replace("'", "''") + "'"

def num(v):
    if v is None or str(v).strip() == '': return 'NULL'
    return str(v)

NUM_RE = re.compile(r'^\d+(\.\d+)?$')

def parse_score_row_right(r, name_idx, n_numeric=5, tie_vals=('是', '否')):
    """右锚定：找最后一个 是/否 单元格，其前 n_numeric 个数值为分数列。
    返回数值列表（长度 n_numeric）+ tie，或 None"""
    tie_idx = None
    for i in range(len(r) - 1, name_idx, -1):
        if (r[i] or '').strip() in tie_vals:
            tie_idx = i; break
    if tie_idx is None or tie_idx < name_idx + n_numeric:
        return None
    cells = [(r[tie_idx - k] or '').strip() for k in range(1, n_numeric + 1)][::-1]
    if not all(NUM_RE.match(c) for c in cells):
        return None
    return cells, r[tie_idx].strip()

def parse_qd(r):
    """到区: 校名后5个数值 [score,cmf,math,chinese,integrated]，右锚定 + 位置回退"""
    res = parse_score_row_right(r, 1, 5)
    if res:
        cells, tie = res
        return {'score': cells[0], 'cmf': cells[1], 'math': cells[2],
                'chinese': cells[3], 'integrated': cells[4], 'tie': tie}
    # 回退：取校名后所有数值单元格，第一个是 score，其余按序
    nums = [(c or '').strip() for c in r[2:] if NUM_RE.match((c or '').strip())]
    if not nums: return None
    tie = '是' if any((c or '').strip() == '是' for c in r[2:]) else '否'
    nums += [''] * (5 - len(nums))
    return {'score': nums[0], 'cmf': nums[1], 'math': nums[2],
            'chinese': nums[3], 'integrated': nums[4], 'tie': tie}

def parse_qs(r):
    """到校: 校名后6个数值 [score,综评,cmf,math,chinese,integrated]，右锚定 + 位置回退"""
    res = parse_score_row_right(r, 2, 6)
    if res:
        cells, tie = res
        return {'score': cells[0], 'cqs': cells[1], 'cmf': cells[2], 'math': cells[3],
                'chinese': cells[4], 'integrated': cells[5], 'tie': tie}
    nums = [(c or '').strip() for c in r[3:] if NUM_RE.match((c or '').strip())]
    if not nums: return None
    tie = '是' if any((c or '').strip() == '是' for c in r[3:]) else '否'
    nums += [''] * (6 - len(nums))
    return {'score': nums[0], 'cqs': nums[1] or '50', 'cmf': nums[2], 'math': nums[3],
            'chinese': nums[4], 'integrated': nums[5], 'tie': tie}

def parse_uni(r):
    """平行志愿: 固定位置 score=r[3],cmf=r[4],math=r[5],chinese=r[6]（兼容嘉定短行）"""
    if not NUM_RE.match((r[3] or '').strip()): return None
    g = lambda i: r[i].strip() if len(r) > i and NUM_RE.match((r[i] or '').strip()) else ''
    return {'score': g(3), 'cmf': g(4), 'math': g(5), 'chinese': g(6)}

# ---------- 加载线上库 ----------
schools = [dict(zip(['id','code','full_name','short_name','district','type','nature'], r))
           for r in read_csv(f'{DB}/ref_school.csv')[1:]]
mschools = [dict(zip(['id','name','short_name','district','tier','rank','est'], r))
            for r in read_csv(f'{DB}/ref_middle_school.csv')[1:]]
dist_name2id = {'上海市':'1','黄浦区':'2','徐汇区':'3','长宁区':'4','静安区':'5','普陀区':'6','虹口区':'7',
                '杨浦区':'8','闵行区':'9','宝山区':'10','嘉定区':'11','浦东新区':'12','金山区':'13',
                '松江区':'14','青浦区':'15','奉贤区':'16','崇明区':'17'}

hs_by_code = {s['code']: s for s in schools}
hs_by_full = {N(s['full_name']): s for s in schools}
hs_by_short = {N(s['short_name']): s for s in schools if s['short_name']}
hs_base = collections.defaultdict(list)
for s in schools:
    hs_base[base_name(s['full_name'])].append(s)

plan26 = collections.defaultdict(set)
for r in read_csv(f'{DB}/quota_school_2026.csv')[1:]:
    plan26[(r[1], N(r[3]))].add(r[2])

qs25 = {}
for r in read_csv(f'{DB}/score_qs_2025.csv')[1:]:
    try: qs25[(r[0], N(r[2]), N(r[1]))] = float(r[3])
    except ValueError: pass
qd25 = {}
for r in read_csv(f'{DB}/score_qd_2025.csv')[1:]:
    try: qd25[(r[0], N(r[1]))] = float(r[2])
    except ValueError: pass

ms_by_dist = collections.defaultdict(dict)
for m in mschools:
    d = ms_by_dist[m['district']]
    d.setdefault(N(m['name']), m)
    if m['short_name']: d.setdefault(N(m['short_name']), m)

MS_ALIAS = {
    ('杨浦区', '上海市三门中学（上海财大学附属初级中学）'): '上海市三门中学（上海财经大学附属初级中学）',
    ('浦东新区', '上海浦东民办来科技学校'): '上海浦东民办未来科技学校',
}
HS_ALIAS = {
    '市复旦大学附属中学': '复旦大学附属中学',
    '上海市复旦附中': '复旦大学附属中学',
    '上海市交大附中': '上海交通大学附属中学',
    '复旦复兴': '复旦大学附属复兴中学',
    '师大一附': '华东师范大学第一附属中学',
    '上财北郊': '上海财经大学附属北郊高级中学',
    '继光高级': '上海市继光高级中学',
    '五十二中': '上海市第五十二中学',
    '上音北虹': '上海音乐学院虹口区北虹高级中学',
    '上音安师': '上海音乐学院附属安师实验中学',
    '同济澄衷': '同济大学附属澄衷中学',
    '同济创意': '上海市同济黄浦设计创意中学',
    '华曜高级': '上海市宝山华曜高级中学',
    '师大二附': '上海师范大学第二附属中学',
    '东鼎外语': '上海浦东新区民办东鼎外国语学校',
    '西外外语': '上海市西外外国语学校',
    '博华高级': '上海奉贤区博华高级中学',
    '华东师范大学第二附属中学宝山校区': '华东师范大学第二附属中学（宝山校区）',
    '上海师范大学附属罗店中学': '上海师范大学附属宝山罗店中学',
}

audit = []
def log(cat, msg): audit.append((cat, msg))

def match_ms(district, name):
    if (district, name) in MS_ALIAS:
        name = MS_ALIAS[(district, name)]
    return ms_by_dist.get(district, {}).get(N(name)), name

def resolve_hs_simple(name):
    n = N(name)
    if n in hs_by_full: return hs_by_full[n]
    if name in HS_ALIAS and N(HS_ALIAS[name]) in hs_by_full:
        return hs_by_full[N(HS_ALIAS[name])]
    if n in hs_by_short: return hs_by_short[n]
    cands = hs_base.get(base_name(name), [])
    if len(cands) == 1: return cands[0]
    return None

def campus_candidates(name):
    return hs_base.get(base_name(name), [])

PENALTY_NOREF = 20.0   # 无2025参考分时的惩罚（分）

def assign_by_2025(rows, candidates, ref25_of):
    """全排列最优：把 len(rows) 个 zip 行分配给 candidates 的子集（数量须 >= len(rows)），
    使 sum |row.score - ref25(candidate)| 最小。返回 [(row, school)] 或 None。"""
    if len(candidates) < len(rows) or not candidates:
        return None
    scores = [float(r['_score']) for r in rows]
    best, bestcost = None, 1e18
    for combo in itertools.permutations(candidates, len(rows)):
        cost = 0.0
        for sc, c in zip(scores, combo):
            ref = ref25_of(c)
            cost += abs(sc - ref) if ref is not None else PENALTY_NOREF
        if cost < bestcost - 1e-9:
            bestcost, best = cost, combo
    return list(zip(rows, best))

# ============================================================
# 1. 名额到区录取线 2026（右锚定）
# ============================================================
_, qd_rows = load_sheet('名额到区录取分数线.csv')
qd_data, qd_bad = [], 0
for r in qd_rows:
    if len(r) < 8 or not r[0].endswith('区') or not r[1].strip(): continue
    p = parse_qd(r)
    if not p:
        qd_bad += 1; continue
    qd_data.append({'dist': r[0], 'name': r[1], '_score': p['score'], 'p': p})
print(f'到区录取线: 有效 {len(qd_data)} 行, 解析失败 {qd_bad}')

groups = collections.defaultdict(list)
for d in qd_data:
    groups[(d['dist'], N(d['name']))].append(d)

out_qd = []
for (dist, nname), rows in groups.items():
    cands = campus_candidates(rows[0]['name'])
    if len(cands) > 1:
        pairs = assign_by_2025(rows, cands, lambda c: qd25.get((dist, N(c['full_name']))))
        if pairs:
            for r, c in pairs:
                out_qd.append((r, c))
                if len(rows) > 1 or N(c['full_name']) != nname:
                    log('到区-校区分配', f"{dist}|{r['name']}|{r['_score']} -> {c['full_name']}({c['code']})")
            continue
    for r in rows[1:]:
        log('到区-重复键丢弃', f"{dist}|{r['name']}|丢弃{r['_score']}（保留{rows[0]['_score']}）")
    s = resolve_hs_simple(rows[0]['name'])
    if s: out_qd.append((rows[0], s))
    else: log('到区-未匹配高中', f"{dist}|{rows[0]['name']}")
print(f'到区录取线 -> 生成 {len(out_qd)} 行')

def bool_cn(v): return 'TRUE' if (v or '').strip() == '是' else 'FALSE'

sql_qd = []
for r, s in out_qd:
    p = r['p']
    sql_qd.append(
        f"INSERT INTO ref_admission_score_quota_district (year, district_id, school_id, school_name, min_score, "
        f"is_tie_preferred, chinese_math_foreign_sum, math_score, chinese_score, integrated_test_score, comprehensive_quality_score) "
        f"VALUES (2026, {dist_name2id[r['dist']]}, {s['id']}, {esc(s['full_name'])}, {p['score']}, {bool_cn(p['tie'])}, "
        f"{num(p['cmf'])}, {num(p['math'])}, {num(p['chinese'])}, {num(p['integrated'])}, 50) "
        f"ON CONFLICT (year, district_id, school_name) DO UPDATE SET "
        f"school_id=EXCLUDED.school_id, min_score=EXCLUDED.min_score, is_tie_preferred=EXCLUDED.is_tie_preferred, "
        f"chinese_math_foreign_sum=EXCLUDED.chinese_math_foreign_sum, math_score=EXCLUDED.math_score, "
        f"chinese_score=EXCLUDED.chinese_score, integrated_test_score=EXCLUDED.integrated_test_score;")

# ============================================================
# 2. 名额到校录取线 2026（右锚定；综评分固定50, zip 有单独列）
# ============================================================
_, qs_rows = load_sheet('名额到校录取分数线.csv')
qs_data, qs_bad = [], 0
for r in qs_rows:
    if len(r) < 9 or not r[0].endswith('区') or not r[1].strip(): continue
    p = parse_qs(r)
    if not p:
        qs_bad += 1; continue
    qs_data.append({'dist': r[0], 'ms': r[1], 'name': r[2], '_score': p['score'], 'p': p})
print(f'到校录取线: 有效 {len(qs_data)} 行, 解析失败 {qs_bad}')

groups = collections.defaultdict(list)
for d in qs_data:
    groups[(d['dist'], N(d['ms']), N(d['name']))].append(d)

out_qs = []
ms_unmatched = collections.Counter()
for (dist, nms, nname), rows in groups.items():
    cands = campus_candidates(rows[0]['name'])
    s_list = None
    if len(cands) > 1:
        have = [c for c in cands if c['code'] in plan26.get((dist, nms), set())]
        use = have if len(have) >= len(rows) else cands
        pairs = assign_by_2025(rows, use,
                lambda c: qs25.get((dist, nms, N(c['full_name']))) or qs25.get((dist, nms.replace('上海市', ''), N(c['full_name']))))
        if pairs:
            s_list = pairs
            for r, c in pairs:
                if len(rows) > 1 or N(c['full_name']) != nname:
                    log('到校-校区分配', f"{dist}|{rows[0]['ms']}|{r['name']}|{r['_score']} -> {c['full_name']}({c['code']})")
    if s_list is None:
        s = resolve_hs_simple(rows[0]['name'])
        if not s:
            log('到校-未匹配高中', f"{dist}|{rows[0]['ms']}|{rows[0]['name']}"); continue
        s_list = [(rows[0], s)]
        for r in rows[1:]:
            log('到校-重复键丢弃', f"{dist}|{rows[0]['ms']}|{r['name']}|丢弃{r['_score']}（保留{rows[0]['_score']}）")
    m, canon_ms = match_ms(dist, rows[0]['ms'])
    if not m: ms_unmatched[f"{dist}|{canon_ms}"] += 1
    for r, c in s_list:
        out_qs.append((r, c, m, canon_ms))
print(f'到校录取线 -> 生成 {len(out_qs)} 行; 初中未匹配(原名插入) {len(ms_unmatched)} 所')
for k, c in sorted(ms_unmatched.items()): log('到校-初中未匹配', f'{k} ({c}行)')

sql_qs = []
for r, s, m, canon_ms in out_qs:
    p = r['p']
    msname = m['name'] if m else canon_ms
    sql_qs.append(
        f"INSERT INTO ref_admission_score_quota_school (year, district_id, school_id, school_name, middle_school_name, min_score, "
        f"is_tie_preferred, chinese_math_foreign_sum, math_score, chinese_score, integrated_test_score, comprehensive_quality_score) "
        f"VALUES (2026, {dist_name2id[r['dist']]}, {s['id']}, {esc(s['full_name'])}, {esc(msname)}, {p['score']}, {bool_cn(p['tie'])}, "
        f"{num(p['cmf'])}, {num(p['math'])}, {num(p['chinese'])}, {num(p['integrated'])}, {num(p['cqs'])}) "
        f"ON CONFLICT (year, district_id, school_name, middle_school_name) DO UPDATE SET "
        f"school_id=EXCLUDED.school_id, min_score=EXCLUDED.min_score, is_tie_preferred=EXCLUDED.is_tie_preferred, "
        f"chinese_math_foreign_sum=EXCLUDED.chinese_math_foreign_sum, math_score=EXCLUDED.math_score, "
        f"chinese_score=EXCLUDED.chinese_score, integrated_test_score=EXCLUDED.integrated_test_score, "
        f"comprehensive_quality_score=EXCLUDED.comprehensive_quality_score;")

# ============================================================
# 3. 平行志愿补缺（右锚定, ON CONFLICT DO NOTHING）
# ============================================================
_, pl_rows = load_sheet('平行志愿分数线.csv')
pl_data = []
for r in pl_rows:
    if len(r) < 8 or not r[0].endswith('区') or not r[2].strip(): continue
    if '分数线' in r[2] or '志愿' in r[2]: continue
    p = parse_uni(r)
    if not p: continue
    pl_data.append({'dist': r[0], 'code': r[1].strip(), 'name': r[2].strip(), 'p': p})
sql_uni = []
for d in pl_data:
    s = hs_by_code.get(d['code']) if d['code'].isdigit() else None
    if not s: s = resolve_hs_simple(d['name'])
    if not s:
        log('平行志愿-未匹配', f"{d['dist']}|{d['code']}|{d['name']}|{d['p']['score']}"); continue
    p = d['p']
    sql_uni.append(
        f"INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, "
        f"chinese_math_foreign_sum, math_score, chinese_score) "
        f"VALUES (2026, {dist_name2id[d['dist']]}, {s['id']}, {esc(s['full_name'])}, {p['score']}, {num(p['cmf'])}, {num(p['math'])}, {num(p['chinese'])}) "
        f"ON CONFLICT (year, district_id, school_name) DO NOTHING;")
print(f'平行志愿: 有效 {len(pl_data)} 行 -> 生成 {len(sql_uni)} 行(DO NOTHING)')

# ============================================================
# 4. 2026 各区中考人数（民间估算）
# ============================================================
_, ex_rows = load_sheet('考生人数.csv')
sql_ex = []
for r in ex_rows:
    if len(r) >= 3 and r[0] in dist_name2id and r[0] != '上海市':
        src = r[3] if len(r) > 3 else ''
        sql_ex.append(
            f"INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) "
            f"VALUES (2026, {dist_name2id[r[0]]}, {int(float(r[1]))}, {esc('2026民间估算(haoxue360): ' + src)}) "
            f"ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;")
print(f'中考人数: 生成 {len(sql_ex)} 行')

# ============================================================
# 5. 到区计划：删除 152006/155001 的“上海市”总计行
# ============================================================
sql_patch_qd = [
    "-- 2026 到区计划中 152006/155001 同时存在按区明细行和 district='上海市' 的校级总计行，",
    "-- 按校汇总会双倍计数（其余75校均无此行）。后端按 student district 查询，不受影响。",
    "DELETE FROM ref_quota_allocation_district WHERE year=2026 AND district_id=1 AND school_code IN ('152006','155001');",
]

# ============================================================
# 6. 初中：4 所新校 + tier/排名/人数/声誉/700+ 回填
# ============================================================
NEW_MS = [
    ('浦东新区', '上海交通大学附属浦东实验中学'),
    ('浦东新区', '上海市浦东新区进才万祥学校'),
    ('浦东新区', '上海中医药大学附属浦东鹤沙学校'),
    ('浦东新区', '上海师范大学附属浦东秋萍学校'),
]
sql_new_ms = [
    f"INSERT INTO ref_middle_school (name, district_id, is_non_selective, ranking_remarks) "
    f"SELECT {esc(n)}, {dist_name2id[d]}, TRUE, '2026年新增（来源：2026名额分配到校计划/分数线）' "
    f"WHERE NOT EXISTS (SELECT 1 FROM ref_middle_school WHERE name={esc(n)} AND district_id={dist_name2id[d]});"
    for d, n in NEW_MS]

_, rk_rows = load_sheet('初中学校排行榜(分区分榜).csv')
rk_data = [r for r in rk_rows if len(r) >= 15 and r[0].endswith('区')]
TIER_MAP = {'第一梯队': '一梯队', '第二梯队': '二梯队', '第三梯队': '三梯队'}
sql_ms_upd = []
for r in rk_data:
    dist, name = r[0], r[1]
    canon = MS_ALIAS.get((dist, name), name)
    tier = next((v for k, v in TIER_MAP.items() if k in (r[8] if len(r) > 8 else '')), None)
    rank = r[12] if r[12].strip().isdigit() else None
    repu = r[7] if NUM_RE.match(r[7].strip()) else None
    sets = []
    if tier: sets.append(f"tier={esc(tier)}")
    if rank: sets.append(f"district_rank={rank}")
    if repu: sets.append(f"reputation_score={repu}")
    if not sets: continue
    sql_ms_upd.append(
        f"UPDATE ref_middle_school SET {', '.join(sets)} "
        f"WHERE district_id={dist_name2id[dist]} AND name={esc(canon)};")
print(f'排行榜回填: {len(sql_ms_upd)} 行 UPDATE')

_, est_rows = load_sheet('各初中考生人数(推算).csv')
sql_est = []
for r in est_rows:
    if len(r) >= 3 and r[0].endswith('区') and r[2].strip().isdigit():
        canon = MS_ALIAS.get((r[0], r[1]), r[1])
        sql_est.append(
            f"UPDATE ref_middle_school SET estimated_student_count={int(r[2])} "
            f"WHERE district_id={dist_name2id[r[0]]} AND name={esc(canon)} AND estimated_student_count IS NULL;")
print(f'推算人数回填(仅NULL): {len(sql_est)} 行 UPDATE')

rows7 = read_csv(f'{CSV}/初中校700分以上人数(民间统计).csv')
hdr7 = next(i for i, r in enumerate(rows7) if r and r[0] == '区')
sql_700 = []
for r in rows7[hdr7+1:]:
    if len(r) < 11 or not r[0].endswith('区') or not r[4].strip().isdigit(): continue
    canon = r[2].strip() or MS_ALIAS.get((r[0], r[1]), r[1])
    sql_700.append(
        f"UPDATE ref_middle_school SET score_700plus_count={int(r[4])}, score_700plus_reliability={esc(r[10])} "
        f"WHERE district_id={dist_name2id[r[0]]} AND name={esc(canon)};")
print(f'700+回填: {len(sql_700)} 行 UPDATE')

# ============================================================
# 写 SQL 文件到仓库
# ============================================================
def write_sql(path, header, lines):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(header + '\nBEGIN;\n\n' + '\n'.join(lines) + '\n\nCOMMIT;\n')
    print('写出', os.path.basename(path), len(lines), '条')

write_sql(f'{REPO}/db/seeds/seed_ref_admission_score_quota_district_2026.sql',
          '-- 2026年名额分配到区录取最低分数线\n-- 来源: sh_zhongkao_2026 数据集(官方: 上海教育考试院/各区教育局)\n-- 校区歧义按2025年分数线就近分配, 审计见 import_audit.csv', sql_qd)
write_sql(f'{REPO}/db/seeds/seed_ref_admission_score_quota_school_2026.sql',
          '-- 2026年名额分配到校录取最低分数线\n-- 来源: sh_zhongkao_2026 数据集(官方)\n-- 校区歧义按2026计划+2025分数消解; 初中名已对齐ref_middle_school', sql_qs)
write_sql(f'{REPO}/db/seeds/seed_ref_admission_score_unified_2026_fill.sql',
          '-- 2026年1-15志愿(平行志愿)录取分数线补缺\n-- 来源: sh_zhongkao_2026 数据集(官方)\n-- ON CONFLICT DO NOTHING: 线上已有行保持不变(含与zip冲突的4行)', sql_uni)
write_sql(f'{REPO}/db/seeds/seed_ref_district_exam_count_2026.sql',
          '-- 2026年各区中考报名人数(民间估算, 官方仅公布全市138000人)', sql_ex)
write_sql(f'{REPO}/db/patches/patch_2026_quota_district_remove_total_rows.sql',
          '-- 修复: 2026到区计划 152006/155001 冗余"上海市"总计行导致汇总双倍计数', sql_patch_qd)
write_sql(f'{REPO}/db/patches/patch_2026_middle_schools_new.sql',
          '-- 2026年新增初中（2026名额分配数据中出现, ref_middle_school缺失）', sql_new_ms)
write_sql(f'{REPO}/db/patches/patch_2026_middle_school_ranking.sql',
          '-- 初中梯队/区内排名/声誉分回填(来源: sh_zhongkao_2026 排行榜, 声誉为主观口碑仅供参考)\n-- 依赖: db/migrations/008_add_middle_school_2026_stats_columns.sql', sql_ms_upd)
write_sql(f'{REPO}/db/patches/patch_2026_middle_school_est_count.sql',
          '-- 初中推算考生数回填(仅填NULL, 来源: sh_zhongkao_2026 按到校名额占比推算)', sql_est)
write_sql(f'{REPO}/db/patches/patch_2026_middle_school_700plus.sql',
          '-- 初中700+人数(民间统计,非官方)回填\n-- 依赖: db/migrations/008_add_middle_school_2026_stats_columns.sql', sql_700)

with open(f'{BASE}/import_audit.csv', 'w', newline='', encoding='utf-8') as f:
    w = csv.writer(f); w.writerow(['类别', '说明']); w.writerows(audit)
print(f'\n审计条目: {len(audit)} -> import_audit.csv')
for k, v in collections.Counter(c for c, _ in audit).most_common(): print(f'  {k}: {v}')
