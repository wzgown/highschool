# -*- coding: utf-8 -*-
# 用官方 parallel_*.csv 计算各区平行志愿分数水平(区级代理) -> district_score_proxy.csv
import csv, os, glob, statistics

# 路径对齐：本文件位于 scripts/derive/，上两级即项目根（含 data/ raw/ output/）
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, "data")                      # 清洗好的结构化数据（读写）
OUT = os.path.join(DATA, "district_score_proxy.csv")

DIST_ORDER = ["黄浦区","徐汇区","长宁区","静安区","普陀区","虹口区","杨浦区",
              "闵行区","宝山区","嘉定区","浦东新区","金山区","松江区","青浦区","奉贤区","崇明区"]

def norm_dist(d):
    d = d.strip()
    if d == "浦东":
        return "浦东新区"
    if not d.endswith("区"):
        return d + "区"
    return d

by_dist = {d: [] for d in DIST_ORDER}
for p in glob.glob(os.path.join(DATA, "parallel_*.csv")):
    with open(p, encoding="utf-8-sig") as f:
        rdr = csv.reader(f)
        header = next(rdr)
        for row in rdr:
            if not row or len(row) < 4:
                continue
            d = norm_dist(row[0])
            try:
                s = float(row[3])
            except (ValueError, IndexError):
                continue
            if d in by_dist:
                by_dist[d].append(s)

rows = []
for d in DIST_ORDER:
    scores = by_dist[d]
    if not scores:
        continue
    n = len(scores)
    mean = statistics.mean(scores)
    med = statistics.median(scores)
    mx, mn = max(scores), min(scores)
    p700 = sum(1 for x in scores if x >= 700) / n * 100
    p680 = sum(1 for x in scores if x >= 680) / n * 100
    p650 = sum(1 for x in scores if x >= 650) / n * 100
    rows.append([d, n, round(mean, 2), round(med, 2), mx, mn,
                 round(p700, 1), round(p680, 1), round(p650, 1)])

with open(OUT, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f)
    w.writerow(["区","高中数(本区招生)","平行志愿线均值","中位数","最高线","最低线","≥700占比%","≥680占比%","≥650占比%","数据状态"])
    for r in rows:
        status = "部分·仅头部6所(官方图片未全解析)" if r[0] == "宝山区" else "完整·官方平行志愿线"
        w.writerow(r + [status])

for r in rows:
    print(r)
