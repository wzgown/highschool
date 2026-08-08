import pdfplumber, os, json, csv

# 路径对齐：本文件位于 scripts/parse/，上两级即项目根（含 data/ raw/ output/）
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
RAW = os.path.join(ROOT, "raw")
DATA = os.path.join(ROOT, "data")          # 清洗好的结构化数据（输出）
def _plan_pdf(key):
    """按区键解析规划类 PDF：先 raw/plan，再 raw/to_district（兼容 daoqu_plan.pdf）。"""
    for sub in ("plan", "to_district"):
        for name in (f"{key}.pdf", f"{key}_plan.pdf"):
            cand = os.path.join(RAW, sub, name)
            if os.path.exists(cand):
                return cand
    return os.path.join(RAW, "plan", f"{key}.pdf")

code2name_raw = json.load(open(os.path.join(HERE, "code2name.json"), encoding="utf-8"))
# daoqu.pdf watermark "上海市教育考试院" leaked a single leading watermark char
# (院/考/试/教/育) onto some school-name values -> strip leading 1-char watermark lines
WM2 = set("上海市教育考试院")
def clean_c2n(s):
    if not s:
        return s
    lines = s.split("\n")
    out = [ln for i, ln in enumerate(lines)
           if not (i == 0 and len(ln.strip()) == 1 and ln.strip() in WM2)]
    return "".join(out).replace(" ", "").strip()
code2name = {k: clean_c2n(v) for k, v in code2name_raw.items()}

# safety fallback names for codes possibly missing in daoqu plan
FALLBACK = {
 "122001":"上海市七宝中学","123001":"上海市闵行中学","122002":"华东师范大学第二附属中学闵行紫竹分校",
 "122003":"上海师范大学附属中学闵行分校","122004":"上海交通大学附属中学闵行分校","012006":"上海市向明中学（浦江校区）",
 "042002":"上海市第二中学（梅陇校区）","042032":"上海市上海中学","102056":"上海交通大学附属中学",
 "102057":"复旦大学附属中学","152003":"华东师范大学第二附属中学","152006":"上海师范大学附属中学",
 "142001":"上海市嘉定区第一中学","142002":"上海交通大学附属中学嘉定分校","142004":"上海师范大学附属中学嘉定新城分校",
 "132001":"上海市行知中学","133001":"上海市吴淞中学","132002":"上海大学附属中学","133003":"华东师范大学第二附属中学（宝山校区）",
 "132003":"上海师范大学附属中学宝山分校","172001":"上海市松江二中","173001":"上海市松江一中",
 "174003":"上海外国语大学附属外国语学校松江云间中学","172002":"华东师范大学第二附属中学松江分校","172004":"上海师范大学附属中学松江分校",
}
def name_of(code):
    return code2name.get(code) or FALLBACK.get(code) or code

WATERMARK = set("未经许可不得转载，。允")
def clean_name(s):
    if s is None: return ""
    s = "".join(c for c in s if c not in WATERMARK)
    s = s.replace(" ", "")  # drop stray spaces between CJK chars from extraction
    return s.replace("\n","").strip()

# source PDF text layers dropped a few chars (shown as a gap/space). Correct known schools.
NAME_FIX = {
 "上海对外贸大学附属松江实验学校花园分校":"上海对外经贸大学附属松江实验学校花园分校",
 "上海师范大学附属宝山纬实验中学":"上海师范大学附属宝山经纬实验中学",
 "上海师范大学松江来实验学校":"上海师范大学松江未来实验学校",
}
def fix_name(s):
    return NAME_FIX.get(s, s)
def clean_num(s):
    if s is None: return None
    d = "".join(c for c in s if c.isdigit())
    return int(d) if d else None

DISTRICTS = {
 "minxing":("闵行区","闵行"),
 "jiading":("嘉定区","嘉定"),
 "baoshan":("宝山区","宝山"),
 "songjiang":("松江区","松江"),
}
EXPECT = {"minxing":1290,"jiading":612,"baoshan":1076,"songjiang":791}

BAOSHAN_CODES = ["132001","133001","132002","133003","132003","042032","152003","102057","102056"]
SONGJIANG_CODES = ["172001","173001","174003","172002","172004"]
WEI_MAP = {
 "上海市上海中学":"042032","上海交通大学附属中学":"102056","复旦大学附属中学":"102057",
 "华东师范大学第二附属中学":"152003","上海师范大学附属中学":"152006",
}

def is_code(s):
    return s and s.strip().isdigit() and len(s.strip())==6

out_rows = {k:[] for k in DISTRICTS}

for key,(qu,short) in DISTRICTS.items():
    WM = WATERMARK
    with pdfplumber.open(_plan_pdf(key)) as pdf:
        for page in pdf.pages:
            # remove diagonal watermark characters (independent char objects)
            fp = page.filter(lambda c: c.get("text") is None or c["text"] not in WM)
            try:
                tbl = fp.extract_table()
            except Exception:
                tbl = page.extract_table()
            if not tbl: continue
            codes = None
            for row in tbl:
                if not row: continue
                # ---- 闵行 ----
                if key=="minxing":
                    if row[0] and row[0].strip()=="初中代码":
                        # codes row: cells[2:] are '招生代码\nXXXX'
                        codes = [c.split("\n")[-1].strip() for c in row[2:] if c and "招生代码" in c]
                        continue
                    if codes and is_code(row[0]) and row[1]:
                        cname = fix_name(clean_name(row[1]))
                        for j,code in enumerate(codes):
                            v = clean_num(row[2+j]) if 2+j < len(row) else None
                            if v:
                                out_rows[key].append([qu, cname, name_of(code), v])
                # ---- 嘉定 ----
                elif key=="jiading":
                    if row[0] and row[0].strip() in ("初中学校",): continue
                    if row[0] and not is_code(row[0]) and row[0].strip() and row[0]!="初中学校":
                        cname = fix_name(clean_name(row[0]))
                        if not cname: continue
                        for g in range(0,4):
                            base = 1+3*g
                            if base+2 >= len(row): break
                            code = clean_name(row[base])
                            plan = clean_num(row[base+2])
                            if code and is_code(code) and plan:
                                out_rows[key].append([qu, cname, name_of(code), plan])
                # ---- 宝山 ----
                elif key=="baoshan":
                    if row[0] and row[0].strip()=="序号": continue
                    if is_code(row[1]) and row[2]:
                        cname = fix_name(clean_name(row[2]))
                        for j,code in enumerate(BAOSHAN_CODES):
                            idx = 3+j
                            if idx >= len(row): break
                            v = clean_num(row[idx])
                            if v:
                                out_rows[key].append([qu, cname, name_of(code), v])
                # ---- 松江 ----
                elif key=="songjiang":
                    if row[0] and ("学校" in str(row[0]) or row[0].strip() in ("学校","学校\n代码")): continue
                    if is_code(row[0]) and row[1]:
                        cname = fix_name(clean_name(row[1]))
                        for j,code in enumerate(SONGJIANG_CODES):
                            idx = 3+j
                            if idx >= len(row): break
                            v = clean_num(row[idx])
                            if v:
                                out_rows[key].append([qu, cname, name_of(code), v])
                        # 委属
                        wei = clean_name(row[2]) if len(row)>2 else ""
                        if wei:
                            wc = WEI_MAP.get(wei)
                            if wc:
                                out_rows[key].append([qu, cname, name_of(wc), 1])
                            else:
                                out_rows[key].append([qu, cname, wei, 1])

# write CSVs
data_dir = DATA
os.makedirs(data_dir, exist_ok=True)
for key,(qu,short) in DISTRICTS.items():
    rows = out_rows[key]
    path = os.path.join(data_dir, f"to_school_plan_{short}.csv")
    with open(path,"w",newline="",encoding="utf-8-sig") as f:
        w = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        w.writerow(["区","初中学校","招生学校","计划数"])
        for r in rows:
            w.writerow(r)
    total = sum(r[3] for r in rows)
    print(f"{short}: rows={len(rows)} total_plan={total} expected={EXPECT[key]} match={total==EXPECT[key]}")
    # report any code not found
    missing = set()
    for r in rows:
        pass
print("DONE")
