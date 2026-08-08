# -*- coding: utf-8 -*-
import pdfplumber, csv, re, os

# 路径对齐：本文件位于 scripts/parse/，上两级即项目根（含 data/ raw/ output/）
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
RAW = os.path.join(ROOT, "raw")
DATA = os.path.join(ROOT, "data")          # 清洗好的结构化数据（输出）
os.makedirs(DATA, exist_ok=True)

WM = set('转载得不得经未经许允受，。、')
def clean(s):
    if s is None:
        return ""
    return "".join(c for c in str(s) if c not in WM and c != '\n' and c != ' ')

ZERO_TOKENS = {'', '／', '/', '—', '-', '﹣'}
def cell_num(raw, watermark=False):
    """Return integer plan number from a cell. When watermark=True (崇明),
    a cell that had content but no digit was a watermarked '1' (only possible
    non-zero value in 委属 columns)."""
    if raw is None:
        return 0
    c = clean(raw)
    if c in ZERO_TOKENS:
        return 0
    if re.fullmatch(r'\d+', c):
        return int(c)
    if watermark and str(raw).strip() != "":
        return 1
    return 0

# ---------- 青浦 ----------
def parse_qp(path):
    pages = []
    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            t = page.extract_tables()
            pages.append(t[0] if t else [])
    p0 = pages[0]
    p0data = [r for r in p0[1:] if (r[0] is not None) or (r[2] is not None)]
    current_hs = None
    labeled = []
    for r in p0data[:6]:
        if r[0] is not None and r[1] is not None:
            current_hs = clean(r[1])
        assert current_hs is not None
        labeled.append((current_hs, clean(r[3]), clean(r[4])))
    blockA_head = [(clean(r[3]), clean(r[4])) for r in p0data[6:]]
    cont = []
    for p in pages[1:]:
        for r in p:
            if r[0] is None:
                continue
            if re.fullmatch(r'\d{6}', str(r[0]).strip()):
                cont.append((clean(r[1]), clean(r[2])))
    flat = [(l[1], l[2]) for l in labeled] + blockA_head + cont
    assert len(labeled) == 6, f"qp labeled={len(labeled)}"
    assert len(flat) == 99, f"qp flat={len(flat)}"
    def isum(slc):
        return sum(int(x[1]) for x in slc)
    bA, bB, bC = flat[6:37], flat[37:68], flat[68:99]
    assert isum(bA) == 146, f"blockA={isum(bA)}"
    assert isum(bB) == 314, f"blockB={isum(bB)}"
    assert isum(bC) == 300, f"blockC={isum(bC)}"
    rows = [("青浦区", jr, hs, pl) for hs, jr, pl in labeled]
    rows += [("青浦区", jr, "复旦大学附属中学青浦分校", pl) for jr, pl in bA]
    rows += [("青浦区", jr, "上海市青浦高级中学", pl) for jr, pl in bB]
    rows += [("青浦区", jr, "上海市朱家角中学", pl) for jr, pl in bC]
    return rows

# ---------- 奉贤 ----------
FX_HS = {
    "奉贤中学": "上海市奉贤中学",
    "临港奉贤": "华东师范大学第二附属中学临港奉贤分校",
    "格致": "上海市格致中学（奉贤校区）",
    "上海中": "上海市上海中学",
    "上海师范": "上海师范大学附属中学",
    "华东师范": "华东师范大学第二附属中学",
    "复旦": "复旦大学附属中学",
    "交通": "上海交通大学附属中学",
}
def parse_fx(path):
    with pdfplumber.open(path) as pdf:
        tbl = pdf.pages[0].extract_tables()[0]
    header = tbl[0]
    hs_names = []
    for c in header[2:]:
        cc = clean(c)
        for k, v in FX_HS.items():
            if k in cc:
                hs_names.append(v)
                break
    rows = []
    for r in tbl[1:]:
        jr = clean(r[1])
        if jr == "" or jr == "合计":
            continue
        for i, val in enumerate(r[2:]):
            v = cell_num(val)
            if v > 0:
                rows.append(("奉贤区", jr, hs_names[i], str(v)))
    return rows

# ---------- 金山 ----------
JS_WM_HS = {
    "华东师范": "华东师范大学第二附属中学",
    "上海师范": "上海师范大学附属中学",
    "上海交通": "上海交通大学附属中学",
    "上海中学": "上海市上海中学",
    "复旦": "复旦大学附属中学",
}
def parse_js(path):
    rows = []
    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            tbl = page.extract_tables()[0]
            for r in tbl:
                jr = clean(r[1])
                if jr == "" or jr == "合计":
                    continue
                wei = r[2]
                if wei is not None and clean(wei) != "":
                    hs = [JS_WM_HS[k] for k in JS_WM_HS if k in clean(wei)]
                    if hs:
                        rows.append(("金山区", jr, hs[0], "1"))
                js = cell_num(r[3])
                if js > 0:
                    rows.append(("金山区", jr, "上海市金山中学", str(js)))
                h3 = cell_num(r[4])
                if h3 > 0:
                    rows.append(("金山区", jr, "华东师范大学第三附属中学", str(h3)))
    return rows

# ---------- 崇明 ----------
CM_HS = {
    "崇明中学": "上海市崇明中学",
    "上实东滩": "上海市实验学校东滩高级中学",
    "上海中学": "上海市上海中学",
    "华师大二": "华东师范大学第二附属中学",
    "复旦": "复旦大学附属中学",
    "交大": "上海交通大学附属中学",
}
def parse_cm(path):
    with pdfplumber.open(path) as pdf:
        tbl = pdf.pages[0].extract_tables()[0]
    hidx = next(i for i, r in enumerate(tbl) if r[0] and "序号" in str(r[0]))
    header = tbl[hidx]
    hs_names = []
    for c in header[3:]:
        cc = clean(c)
        for k, v in CM_HS.items():
            if k in cc:
                hs_names.append(v)
                break
    rows = []
    for r in tbl[hidx+1:]:
        jr = clean(r[2])
        if jr == "" or jr == "合计":
            continue
        for i, val in enumerate(r[3:]):
            v = cell_num(val, watermark=True)
            if v > 0:
                rows.append(("崇明区", jr, hs_names[i], str(v)))
    return rows

def write_csv(name, rows):
    out = os.path.join(DATA, name)
    with open(out, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        w.writerow(["区", "初中学校", "招生学校", "计划数"])
        for r in rows:
            w.writerow(r)
    return out

for key, fn, short in [("qingpu", parse_qp, "青浦"), ("fengxian", parse_fx, "奉贤"),
                       ("jinshan", parse_js, "金山"), ("changning", parse_cm, "崇明")]:
    rows = fn(os.path.join(RAW, "plan", f"{key}.pdf"))
    p = write_csv(f"to_school_plan_{short}.csv", rows)
    print(f"{short}: {len(rows)} rows -> {p}")
