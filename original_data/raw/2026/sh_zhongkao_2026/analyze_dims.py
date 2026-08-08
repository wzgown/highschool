#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""维度级对比：zip 2026 数据 vs 仓库 2026 种子 SQL"""
import csv, re, os, glob, collections

BASE = os.path.dirname(os.path.abspath(__file__))
CSV = os.path.join(BASE, 'csv')
REPO = os.path.expanduser('~/workspace/wzgown/highschool_new')
SEEDS = os.path.join(REPO, 'db/seeds')

def read_csv(path):
    with open(path, encoding='utf-8') as f:
        return list(csv.reader(f))

def load_sheet(fn):
    rows = read_csv(os.path.join(CSV, fn))
    for i, r in enumerate(rows):
        if r and r[0] in ('区', '接收区', '招生代码'):
            return r, rows[i+1:]
    raise ValueError(fn)

# zip 到校计划: 区,初中学校,招生学校,计划数
_, plan_rows = load_sheet('名额分配到校计划(逐校).csv')
plan_rows = [r for r in plan_rows if len(r) >= 4 and r[0] and r[1] and r[3].isdigit()]
zip_plan = collections.Counter()          # (区, 初中, 高中) -> 计划数
zip_plan_by_dist = collections.Counter()
for r in plan_rows:
    zip_plan[(r[0], r[1], r[2])] += int(r[3])
    zip_plan_by_dist[r[0]] += int(r[3])

# ---------- 解析仓库 2026 quota_school 种子 ----------
# INSERT INTO ref_quota_allocation_school (..., district_id, high_school_id, high_school_code, middle_school_name, quota_count ...)
seed_plan = collections.Counter()   # (district_id, middle, high_code) -> quota
seed_files = glob.glob(os.path.join(SEEDS, '*quota_allocation_school*2026*.sql')) + \
             glob.glob(os.path.join(SEEDS, '2026_quota_school_*.sql')) + \
             glob.glob(os.path.join(SEEDS, 'seed_ref_quota_allocation_pudong_2026.sql')) + \
             glob.glob(os.path.join(SEEDS, 'seed_ref_quota_allocation_yangpu_2026.sql'))
seed_files = sorted(set(seed_files))
print('2026 到校/浦东/杨浦 种子文件:')
for f in seed_files: print('  ', os.path.basename(f))

pat = re.compile(r"INSERT INTO ref_quota_allocation_school\s*\(([^)]*)\)\s*VALUES\s*\((.*?)\);", re.S)
def parse_vals(s):
    # VALUES 内容可能多行：先去掉换行再按 CSV 解析
    return [v.strip().strip("'") for v in next(csv.reader([s.replace('\n', ' ')], skipinitialspace=True))]

def extract_tuples(vals_text):
    """从 VALUES 后面的文本提取所有 (...) 元组（括号平衡扫描）"""
    tuples, depth, buf, inq = [], 0, [], False
    for ch in vals_text:
        if ch == "'":
            inq = not inq
        if inq:
            buf.append(ch); continue
        if ch == '(':
            depth += 1
            if depth == 1: buf = []
            else: buf.append(ch)
        elif ch == ')':
            depth -= 1
            if depth == 0: tuples.append(''.join(buf))
            else: buf.append(ch)
        elif depth >= 1:
            buf.append(ch)
    return tuples

# 通用：解析指定表的多行 INSERT
insert_pat = lambda table: re.compile(
    r"INSERT INTO " + table + r"\s*\(([^)]*)\)\s*VALUES\s*(.*?);", re.S)

def parse_seed_file(f, table):
    out = []
    txt = open(f, encoding='utf-8').read()
    for m in insert_pat(table).finditer(txt):
        cols = [c.strip() for c in m.group(1).split(',')]
        for t in extract_tuples(m.group(2)):
            vals = parse_vals(t)
            if len(vals) == len(cols):
                out.append(dict(zip(cols, vals)))
    return out

nrows = 0
for f in seed_files:
    for row in parse_seed_file(f, 'ref_quota_allocation_school'):
        key = (row.get('district_id'), row.get('middle_school_name'), row.get('high_school_code'))
        try:
            seed_plan[key] += int(row.get('quota_count', '0'))
            nrows += 1
        except ValueError:
            pass
print(f'种子到校计划行数: {nrows}')

# district_id -> 区名
dist = {r['id']: r['name'] for r in
        (dict(zip(['id','code','name','name_en','display_order'], r)) for r in read_csv(os.path.join(BASE,'dbdump','ref_district.csv'))[1:])} \
        if os.path.exists(os.path.join(BASE,'dbdump','ref_district.csv')) else {}
if not dist:
    dist = {'1':'上海市','2':'徐汇区','3':'长宁区','4':'静安区','5':'普陀区','6':'虹口区','7':'杨浦区',
            '8':'闵行区','9':'宝山区','10':'嘉定区','11':'浦东新区','12':'金山区','13':'松江区',
            '14':'青浦区','15':'奉贤区','16':'崇明区','17':'黄浦区'}

# high_school_code -> full_name (from db dump)
schools = read_csv(os.path.join(BASE, 'dbdump', 'ref_school.csv'))
code2name = {r[1]: r[2] for r in schools[1:]}

# 按区汇总种子
seed_plan_by_dist = collections.Counter()
for (did, mn, hc), q in seed_plan.items():
    seed_plan_by_dist[dist.get(did, did)] += q

print('\n===== 到校计划：zip vs 仓库种子（按区合计）=====')
all_d = sorted(set(zip_plan_by_dist) | set(seed_plan_by_dist))
print(f'{"区":8s} {"zip":>8s} {"种子":>8s} {"差":>8s}')
for d in all_d:
    z, s = zip_plan_by_dist.get(d, 0), seed_plan_by_dist.get(d, 0)
    print(f'{d:8s} {z:8d} {s:8d} {z-s:8d}')

# 逐行对比重叠区（名称直接相等的组合）
print('\n===== 到校计划：重叠区逐(初中,高中)对比 =====')
# 建 zip 按键（区,初中,高中）；种子键（区名, 初中名, 高中全名）
seed_keyed = {}
for (did, mn, hc), q in seed_plan.items():
    dname = dist.get(did, did)
    hname = code2name.get(hc, hc)
    seed_keyed[(dname, mn, hname)] = q

both = miss_in_zip = miss_in_seed = diff = 0
diff_rows = []
for k, q in seed_keyed.items():
    if k in zip_plan:
        both += 1
        if zip_plan[k] != q:
            diff += 1
            if len(diff_rows) < 30: diff_rows.append((k, zip_plan[k], q))
    else:
        miss_in_zip += 1
for k in zip_plan:
    if k[0] in seed_plan_by_dist and k not in seed_keyed:
        miss_in_seed += 1
print(f'  键完全匹配: {both}（其中数值不同: {diff}）  种子有zip无: {miss_in_zip}  zip有种子无: {miss_in_seed}')
for k, z, s in diff_rows:
    print(f'    差异 {k}: zip={z} 种子={s}')

# ---------- 平行志愿：zip vs 种子（长宁/金山 2026）----------
print('\n===== 平行志愿 2026：zip vs 仓库种子 =====')
uni_files = glob.glob(os.path.join(SEEDS, '*unified*2026*.sql'))
zip_uni = {}
_, pl_rows = load_sheet('平行志愿分数线.csv')
for r in pl_rows:
    if len(r) >= 4 and r[1].isdigit() and r[3]:
        try: zip_uni[(r[0], r[1])] = (r[2], float(r[3]))
        except ValueError: pass

for f in sorted(uni_files):
    rows = parse_seed_file(f, 'ref_admission_score_unified')
    print(f'  {os.path.basename(f)}: {len(rows)} 行')
    same = diff = miss = 0
    for row in rows:
        dname = dist.get(row.get('district_id'), row.get('district_id'))
        code = row.get('school_code', '')
        sc = row.get('min_score', '')
        key = (dname, code)
        if key in zip_uni:
            zname, zscore = zip_uni[key]
            if abs(zscore - float(sc)) < 0.001: same += 1
            else:
                diff += 1
                if diff <= 15: print(f'    分数不同 {dname} {code} {row.get("school_name")}: 种子={sc} zip={zscore} ({zname})')
        else:
            miss += 1
            if miss <= 15: print(f'    zip无此校 {dname} {code} {row.get("school_name")} 种子分={sc}')
    print(f'    → 一致 {same} / 分数不同 {diff} / zip缺失 {miss}')

# ---------- 到区计划：zip 77校总数 vs 种子 ----------
print('\n===== 到区计划 2026：zip 总数 vs 仓库种子 =====')
_, qdp_rows = load_sheet('名额分配到区计划(市重77所).csv')
qdp_rows = [r for r in qdp_rows if len(r) >= 7 and r[0].isdigit()]
zip_qd_total = {r[0]: (r[1], int(float(r[6]))) for r in qdp_rows}
seed_qd = collections.Counter()
qd_files = sorted(set(glob.glob(os.path.join(SEEDS, '*quota_allocation_district*2026*.sql')) +
                      glob.glob(os.path.join(SEEDS, '2026_quota_district_*.sql'))))
print('  种子文件:', ', '.join(os.path.basename(f) for f in qd_files))
for f in qd_files:
    for row in parse_seed_file(f, 'ref_quota_allocation_district'):
        try: seed_qd[row.get('school_code')] += int(row.get('quota_count', '0'))
        except (ValueError, TypeError): pass
print(f'{"代码":8s} {"zip校名":22s} {"zip合计":>8s} {"种子合计":>8s}')
mismatch = 0
for code, (name, q) in zip_qd_total.items():
    s = seed_qd.get(code, 0)
    flag = '' if s == q else '  <-- 不一致'
    if s != q: mismatch += 1
    if s > 0 or s != q:
        print(f'{code:8s} {name:22s} {q:8d} {s:8d}{flag}')
print(f'不一致学校数: {mismatch} / zip 77 校；种子覆盖学校数: {len(seed_qd)}')
