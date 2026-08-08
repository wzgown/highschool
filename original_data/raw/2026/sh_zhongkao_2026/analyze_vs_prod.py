#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""zip 2026 数据 vs 线上生产库(36.150.236.225) 2026 数据"""
import csv, re, os, collections

BASE = os.path.dirname(os.path.abspath(__file__))
CSV = os.path.join(BASE, 'csv')
DB = os.path.join(BASE, 'dbdump_prod')

def read_csv(p):
    with open(p, encoding='utf-8') as f: return list(csv.reader(f))

def load_sheet(fn):
    rows = read_csv(os.path.join(CSV, fn))
    for i, r in enumerate(rows):
        if r and r[0] in ('区', '接收区', '招生代码'):
            return r, rows[i+1:]

# ---------- 1. 到校计划 ----------
_, plan_rows = load_sheet('名额分配到校计划(逐校).csv')
zip_plan = collections.Counter()
zip_plan_dist = collections.Counter()
for r in plan_rows:
    if len(r) >= 4 and r[0].endswith('区') and r[1] and r[3].isdigit():
        zip_plan[(r[0], r[1], r[2])] += int(r[3])
        zip_plan_dist[r[0]] += int(r[3])

db_plan = collections.Counter()
db_plan_dist = collections.Counter()
for r in read_csv(os.path.join(DB, 'quota_school_2026.csv'))[1:]:
    # year, district, high_school_code, middle_name, quota
    db_plan[(r[1], r[3], r[2])] += int(r[4])
    db_plan_dist[r[1]] += int(r[4])

print('===== 到校计划 2026：zip vs 线上库（按区合计）=====')
print(f'{"区":8s} {"zip":>7s} {"线上":>7s} {"差":>6s}')
for d in sorted(set(zip_plan_dist) | set(db_plan_dist)):
    z, s = zip_plan_dist.get(d, 0), db_plan_dist.get(d, 0)
    print(f'{d:8s} {z:7d} {s:7d} {z-s:6d}')
print(f'{"合计":8s} {sum(zip_plan_dist.values()):7d} {sum(db_plan_dist.values()):7d}')

# 高中代码→名称，用于把 DB 的 code 换成名字再比
schools = read_csv(os.path.join(DB, 'ref_school.csv'))
code2name = {r[1]: r[2] for r in schools[1:]}
# DB 按 code 存，zip 按名字。为逐行对比，把 DB 键转为 (区, 初中, 高中全名)
db_plan_named = collections.Counter()
for (d, m, c), q in db_plan.items():
    db_plan_named[(d, m, code2name.get(c, c))] += q

both = only_db = only_zip = diff = 0
diff_samples, only_db_samples, only_zip_samples = [], [], []
for k, q in db_plan_named.items():
    if k in zip_plan:
        both += 1
        if zip_plan[k] != q:
            diff += 1
            if len(diff_samples) < 15: diff_samples.append((k, zip_plan[k], q))
    else:
        only_db += 1
        if len(only_db_samples) < 15: only_db_samples.append((k, q))
for k, q in zip_plan.items():
    if k not in db_plan_named:
        only_zip += 1
        if len(only_zip_samples) < 15: only_zip_samples.append((k, q))
print(f'\n逐行(区,初中,高中)对比: 共同键 {both}（数值不同 {diff}）, 仅线上 {only_db}, 仅zip {only_zip}')
print('-- 数值不同样例 (键, zip, 线上):')
for s in diff_samples: print('  ', s)
print('-- 仅线上有样例:')
for s in only_db_samples: print('  ', s)
print('-- 仅zip有样例:')
for s in only_zip_samples: print('  ', s)

# ---------- 2. 到区计划 ----------
_, qdp = load_sheet('名额分配到区计划(市重77所).csv')
zip_qd = {r[0]: (r[1], int(float(r[6]))) for r in qdp if len(r) >= 7 and r[0].isdigit()}
db_qd = collections.Counter()
db_qd_dist = collections.Counter()
for r in read_csv(os.path.join(DB, 'quota_district_2026.csv'))[1:]:
    db_qd[r[1]] += int(r[3])
    db_qd_dist[r[2]] += int(r[3])

print('\n===== 到区计划 2026：zip(校总数) vs 线上库(分区合计→校) =====')
print(f'线上库覆盖学校代码数: {len(db_qd)}, 总名额 {sum(db_qd.values())}; zip 77校总名额 {sum(q for _, q in zip_qd.values())}')
print(f'线上库分区名额: {dict(sorted(db_qd_dist.items()))}')
diff_qd = [(c, zip_qd[c][0], zip_qd[c][1], db_qd.get(c, 0)) for c in zip_qd if zip_qd[c][1] != db_qd.get(c, 0)]
print(f'校级总数不一致 {len(diff_qd)}/77:')
for c, n, z, s in diff_qd[:25]:
    print(f'  {c} {n}: zip={z} 线上={s} (差{z-s})')

# ---------- 3. 平行志愿 ----------
_, pl = load_sheet('平行志愿分数线.csv')
zip_uni_dist = collections.Counter()
zip_uni = {}
for r in pl:
    if len(r) >= 4 and r[0].endswith('区') and r[3]:
        try:
            zip_uni[(r[0], r[2].strip())] = float(r[3])
            zip_uni_dist[r[0]] += 1
        except ValueError: pass

db_uni_dist = collections.Counter()
db_uni = {}
for r in read_csv(os.path.join(DB, 'score_unified_2026.csv'))[1:]:
    db_uni[(r[1], r[3])] = float(r[4])
    db_uni_dist[r[1]] += 1

print('\n===== 平行志愿 2026：zip vs 线上库（按区行数）=====')
print(f'{"区":8s} {"zip":>6s} {"线上":>6s}')
for d in sorted(set(zip_uni_dist) | set(db_uni_dist)):
    print(f'{d:8s} {zip_uni_dist.get(d,0):6d} {db_uni_dist.get(d,0):6d}')
# 重叠区分数核对
same = dif = miss = 0
for k, sc in db_uni.items():
    if k in zip_uni:
        if abs(zip_uni[k]-sc) < 0.001: same += 1
        else:
            dif += 1
            if dif <= 15: print(f'  分数不同 {k}: 线上={sc} zip={zip_uni[k]}')
    else: miss += 1
print(f'线上 {len(db_uni)} 行中: 与zip一致 {same}, 分数不同 {dif}, zip无此键 {miss}')

# ---------- 4. 高中校名匹配（对线上库 320 所）----------
name2school = {re.sub(r'\s+','',r[2]): r for r in schools[1:]}
short2school = {re.sub(r'\s+','',r[3]): r for r in schools[1:] if r[3]}
code2school = {r[1]: r for r in schools[1:]}
print('\n===== 关键新校检查 =====')
for code, label in [('012011', '同济大学科技中学')]:
    print(f'  {code} {label}: {"在线上有 -> " + code2school[code][2] if code in code2school else "线上库缺失!"}')

# 到校录取线的高中使用线上库重查
_, qs = load_sheet('名额到校录取分数线.csv')
hs_un = collections.Counter()
for r in qs:
    if len(r) >= 4 and r[0].endswith('区') and r[2]:
        n = re.sub(r'\s+','',r[2])
        if n not in name2school and n not in short2school:
            hs_un[r[2]] += 1
print(f'到校录取线高中名未匹配(线上库): {dict(hs_un)}')

# ---------- 5. 初中匹配（对线上库 746 所）----------
msrows = read_csv(os.path.join(DB, 'ref_middle_school.csv'))[1:]
ms_by_dist = collections.defaultdict(set)
for r in msrows:
    ms_by_dist[r[3]].add(re.sub(r'\s+','',r[1]))
    if r[2]: ms_by_dist[r[3]].add(re.sub(r'\s+','',r[2]))
_, rk = load_sheet('初中学校排行榜(分区分榜).csv')
rkd = [r for r in rk if len(r) >= 15 and r[0].endswith('区')]
un = [(r[0], r[1]) for r in rkd if re.sub(r'\s+','',r[1]) not in ms_by_dist[r[0]]]
print(f'\n排行榜 {len(rkd)} 校中线上库未匹配: {len(un)}')
for d, n in un[:30]: print(f'   {d} {n}')

# tier 覆盖
tier_filled = sum(1 for r in msrows if r[4])
print(f'线上库初中 tier 已填: {tier_filled}/{len(msrows)}')
