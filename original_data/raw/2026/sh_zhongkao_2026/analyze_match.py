#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""校名匹配分析：新2026数据集 vs highschool_new DB"""
import csv, re, os, collections

BASE = os.path.dirname(os.path.abspath(__file__))
CSV = os.path.join(BASE, 'csv')
DB = os.path.join(BASE, 'dbdump')

def read_csv(path):
    with open(path, encoding='utf-8') as f:
        return list(csv.reader(f))

def norm(s):
    """校名归一化：去空白、去上海市/区前缀、统一括号"""
    if s is None: return ''
    s = re.sub(r'\s+', '', s)
    s = s.replace('（', '(').replace('）', ')')
    return s

def norm_strip(s):
    """更激进：去掉 上海市XX区 前缀，用于模糊匹配"""
    s = norm(s)
    s = re.sub(r'^上海市', '', s)
    s = re.sub(r'^(黄浦|徐汇|长宁|静安|普陀|虹口|杨浦|闵行|宝山|嘉定|浦东新|金山|松江|青浦|奉贤|崇明)区?', '', s)
    return s

# ---------- 加载 DB ----------
schools = read_csv(os.path.join(DB, 'ref_school.csv'))
sh_header = schools[0]
schools = [dict(zip(sh_header, r)) for r in schools[1:]]
ms = read_csv(os.path.join(DB, 'ref_middle_school.csv'))
ms_header = ms[0]
mschools = [dict(zip(ms_header, r)) for r in ms[1:]]

hs_by_code = {s['code']: s for s in schools}
hs_by_name = {norm(s['full_name']): s for s in schools}
hs_by_short = {norm(s['short_name']): s for s in schools if s['short_name']}
# 归一化索引（去前缀）-> 可能多对多
hs_by_norm = collections.defaultdict(list)
for s in schools:
    hs_by_norm[norm_strip(s['full_name'])].append(s)

ms_by_dist_name = collections.defaultdict(dict)   # district -> norm name -> row
ms_by_dist_short = collections.defaultdict(dict)
ms_by_dist_norm = collections.defaultdict(lambda: collections.defaultdict(list))
for m in mschools:
    d = m['district']
    ms_by_dist_name[d][norm(m['name'])] = m
    if m['short_name']:
        ms_by_dist_short[d][norm(m['short_name'])] = m
    ms_by_dist_norm[d][norm_strip(m['name'])].append(m)

DIST_ALIAS = {'浦东新区':'浦东新区','黄浦区':'黄浦区','徐汇区':'徐汇区','长宁区':'长宁区','静安区':'静安区',
              '普陀区':'普陀区','虹口区':'虹口区','杨浦区':'杨浦区','闵行区':'闵行区','宝山区':'宝山区',
              '嘉定区':'嘉定区','金山区':'金山区','松江区':'松江区','青浦区':'青浦区','奉贤区':'奉贤区','崇明区':'崇明区'}

def match_hs(name, code=None):
    """返回 (匹配方式, db行 or None)"""
    if code and code in hs_by_code:
        return 'code', hs_by_code[code]
    n = norm(name)
    if n in hs_by_name: return 'full_name', hs_by_name[n]
    if n in hs_by_short: return 'short_name', hs_by_short[n]
    ns = norm_strip(name)
    cands = hs_by_norm.get(ns, [])
    if len(cands) == 1: return 'norm', cands[0]
    if len(cands) > 1: return 'norm_ambiguous', None
    return 'UNMATCHED', None

def match_ms(district, name):
    d = DIST_ALIAS.get(district, district)
    n = norm(name)
    if n in ms_by_dist_name.get(d, {}): return 'full_name', ms_by_dist_name[d][n]
    if n in ms_by_dist_short.get(d, {}): return 'short_name', ms_by_dist_short[d][n]
    ns = norm_strip(name)
    cands = ms_by_dist_norm.get(d, {}).get(ns, [])
    if len(cands) == 1: return 'norm', cands[0]
    if len(cands) > 1: return 'norm_ambiguous', None
    return 'UNMATCHED', None

# ---------- 加载 zip 各表 ----------
def load_sheet(fn, header_row_idx):
    """找到表头行（以'区'或'接收区'开头），返回 (header, rows)"""
    rows = read_csv(os.path.join(CSV, fn))
    for i, r in enumerate(rows):
        if r and r[0] in ('区', '接收区', '招生代码', '区域', '排名'):
            return r, rows[i+1:]
    raise ValueError(fn)

# 1. 到校计划
_, plan_rows = load_sheet('名额分配到校计划(逐校).csv', 2)
plan_rows = [r for r in plan_rows if len(r) >= 4 and r[0] and r[1]]
# 2. 到校录取线（跳过 plan_ 前缀行）
_, qs_rows = load_sheet('名额到校录取分数线.csv', 2)
qs_rows = [r for r in qs_rows if len(r) >= 4 and r[0] and not r[0].startswith('plan_')]
# 3. 平行志愿
_, pl_rows = load_sheet('平行志愿分数线.csv', 2)
pl_rows = [r for r in pl_rows if len(r) >= 4 and r[0] and r[2]]
# 4. 到区录取线
_, qd_rows = load_sheet('名额到区录取分数线.csv', 2)
qd_rows = [r for r in qd_rows if len(r) >= 3 and r[0] and r[1]]
# 5. 到区计划
_, qdp_rows = load_sheet('名额分配到区计划(市重77所).csv', 2)
qdp_rows = [r for r in qdp_rows if len(r) >= 7 and r[0].isdigit()]

print(f'到校计划行数: {len(plan_rows)}  到校录取线行数: {len(qs_rows)}  平行志愿行数: {len(pl_rows)}')
print(f'到区录取线行数: {len(qd_rows)}  到区计划行数: {len(qdp_rows)}')

# ---------- 高中校名匹配 ----------
hs_stats = collections.Counter()
hs_unmatched = collections.defaultdict(set)   # source -> names
hs_code_name_conflict = []

def check_hs(source, name, code=None):
    how, row = match_hs(name, code)
    hs_stats[(source, how)] += 1
    if how == 'UNMATCHED' or how == 'norm_ambiguous':
        hs_unmatched[source].add(f'{name}({"歧义" if how=="norm_ambiguous" else "无匹配"})')
    if code and row and norm(row['full_name']) != norm(name):
        hs_code_name_conflict.append((source, code, name, row['full_name']))
    return how, row

for r in plan_rows: check_hs('到校计划', r[2])
for r in qs_rows:   check_hs('到校录取线', r[2])
for r in pl_rows:   check_hs('平行志愿', r[2], r[1] if r[1].isdigit() else None)
for r in qd_rows:   check_hs('到区录取线', r[1])
for r in qdp_rows:  check_hs('到区计划', r[1], r[0])

print('\n===== 高中校名匹配统计（按数据源×方式）=====')
for (src, how), c in sorted(hs_stats.items()):
    print(f'  {src:8s} {how:14s} {c}')

print('\n===== 代码匹配但名称不一致（前20）=====')
seen = set()
for src, code, zn, dn in hs_code_name_conflict:
    k = (code, zn, dn)
    if k in seen: continue
    seen.add(k)
    print(f'  [{src}] code={code} zip="{zn}"  db="{dn}"')
print(f'  共 {len(seen)} 组唯一冲突')

print('\n===== 未匹配高中（按数据源）=====')
for src, names in hs_unmatched.items():
    print(f'  [{src}] {len(names)} 个:')
    for n in sorted(names): print(f'    {n}')

# ---------- 初中校名匹配 ----------
ms_stats = collections.Counter()
ms_unmatched = collections.defaultdict(set)

def check_ms(source, district, name):
    how, row = match_ms(district, name)
    ms_stats[(source, how)] += 1
    if how in ('UNMATCHED', 'norm_ambiguous'):
        ms_unmatched[source].add(f'{district}|{name}|{"歧义" if how=="norm_ambiguous" else "无匹配"}')
    return how, row

for r in plan_rows: check_ms('到校计划', r[0], r[1])
for r in qs_rows:   check_ms('到校录取线', r[0], r[1])

print('\n===== 初中校名匹配统计 =====')
for (src, how), c in sorted(ms_stats.items()):
    print(f'  {src:8s} {how:14s} {c}')

print('\n===== 未匹配初中（按数据源，去重）=====')
for src, names in sorted(ms_unmatched.items()):
    print(f'  [{src}] {len(names)} 个:')
    for n in sorted(names): print(f'    {n}')

# ---------- 到区计划：与 DB 2025 结构对比 + zip 内部合计 ----------
print('\n===== zip 到区计划合计 =====')
tot = sum(int(float(r[6])) for r in qdp_rows)
print(f'  zip 77校到区计划合计: {tot}')
