# -*- coding: utf-8 -*-
"""从上海本地宝文本页解析 闵行/嘉定/松江 1-15志愿 录取分数线 -> parallel_*.csv"""
import requests, pandas as pd, csv, os, re, time
from io import StringIO

# 路径对齐：本文件位于 scripts/parse/，上两级即项目根（含 data/ raw/ output/）
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, "data")          # 清洗好的结构化数据（输出）
URLS = {
    "闵行": "https://sh.bendibao.com/edu/2026723/307939.shtm",
    "嘉定": "https://sh.bendibao.com/edu/2026723/307943.shtm",
    "松江": "https://sh.bendibao.com/edu/2026723/307919.shtm",
}
HDR = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36"}

def pick_header(cells):
    """返回该行的关键词命中数，用于挑选最深的真表头行。"""
    s = " ".join(str(c) for c in cells)
    score = 0
    if "学校名称" in s or "招生学校名称" in s: score += 3
    if "语数外" in s: score += 2
    if "数学" in s: score += 1
    if "语文" in s: score += 1
    if "综合测试" in s: score += 1
    if "录取最低分" in s or "录取分数线" in s or "投档分数线" in s: score += 2
    if "同分优待" in s: score += 1
    return score

def col_index(cells, *keywords):
    for kw in keywords:
        for j, c in enumerate(cells):
            if kw in str(c):
                return j
    return None

def is_note(name):
    return (not name or name in ("学校名称","招生学校名称","学校代码")
            or "末位录取考生成绩" in name or name.startswith("说明") or name.startswith("注")
            or name.startswith("根据") or "录取总分相同" in name or "投档分数线" in name and "招生" in name)

OUT_HEADER = ["区","招生代码","招生学校","录取最低分","语数外","数学","语文","综合测试","是否同分优待","备注"]

for dist, url in URLS.items():
    print("="*60); print(f"### {dist}")
    r = requests.get(url, headers=HDR, timeout=30); r.encoding = r.apparent_encoding
    tables = None
    for attempt in range(4):
        try:
            tables = pd.read_html(StringIO(r.text))
            if tables:
                break
        except Exception:
            pass
        try:
            tables = pd.read_html(StringIO(r.text), flavor="html5lib")
            if tables:
                break
        except Exception:
            pass
        time.sleep(2)
        r = requests.get(url, headers=HDR, timeout=30); r.encoding = r.apparent_encoding
    if not tables:
        print("  抓取失败(无表格)"); continue
    cand = None
    for t in tables:
        if t.shape[1] >= 4 and any("学校" in str(c) for c in t.iloc[0].tolist() + (t.iloc[1].tolist() if len(t)>1 else [])):
            if cand is None or t.shape[0] > cand.shape[0]:
                cand = t
    if cand is None:
        print("  未找到数据表"); continue
    df = cand
    # 选最深表头行
    best_h, best_s = -1, -1
    for i in range(min(8, len(df))):
        s = pick_header(df.iloc[i].tolist())
        if s > best_s:
            best_s, best_h = s, i
    hr = best_h
    hdr = [str(c) for c in df.iloc[hr].tolist()]
    print(f"  表头行={hr}, 表头={hdr}")
    ci = {
        "code": col_index(hdr, "学校代码", "代码"),
        "name": col_index(hdr, "学校名称", "招生学校名称", "招生学校"),
        "score": col_index(hdr, "录取最低分", "录取分数线", "投档分数线", "分数线"),
        "ysw": col_index(hdr, "语数外"),
        "math": col_index(hdr, "数学"),
        "chi": col_index(hdr, "语文"),
        "comp": col_index(hdr, "综合测试"),
        "pref": col_index(hdr, "同分优待"),
        "note": col_index(hdr, "备注"),
    }
    rows = []
    for i in range(hr+1, len(df)):
        raw = [("" if pd.isna(v) else str(v).strip()) for v in df.iloc[i].tolist()]
        name = raw[ci["name"]] if ci["name"] is not None else ""
        if is_note(name): continue
        if not re.search(r"[\u4e00-\u9fff]", name): continue  # 校名应含汉字
        def g(k):
            j = ci[k]
            return raw[j] if (j is not None and j < len(raw)) else ""
        rows.append([dist, g("code"), name, g("score"), g("ysw"), g("math"), g("chi"), g("comp"), g("pref"), g("note")])
    out = DATA + f"/parallel_{dist}.csv"
    with open(out, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f); w.writerow(OUT_HEADER); w.writerows(rows)
    print(f"  写入 {len(rows)} 行 -> {out}")
    print("  首:", rows[0]); print("  尾:", rows[-1])
