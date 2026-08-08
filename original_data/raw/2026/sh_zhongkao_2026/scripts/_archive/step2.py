import requests, pdfplumber, os, json

# 1) download 到区 plan (all schools, code+name)
r = requests.get("https://www.shmeea.edu.cn/download/20260529/4.pdf", timeout=90, headers={"User-Agent":"Mozilla/5.0"})
print("daoqu", r.status_code, len(r.content))
open("pdfs/daoqu.pdf","wb").write(r.content)

code2name = {}
with pdfplumber.open("pdfs/daoqu.pdf") as pdf:
    for page in pdf.pages:
        for row in (page.extract_table() or []):
            if not row: continue
            # rows: 序号, 学校招生代码, 学校名称, 所属区, ...
            if len(row) >= 3 and row[1] and row[1].isdigit() and len(row[1])==6:
                code2name[row[1]] = row[2].strip()
print("codes loaded:", len(code2name))
json.dump(code2name, open("pdfs/code2name.json","w"), ensure_ascii=False, indent=0)

# 2) test extract_table on each 到校 pdf
for name in ["minxing","jiading","baoshan","songjiang"]:
    print("="*80)
    print("TABLE TEST:", name)
    with pdfplumber.open(f"pdfs/{name}.pdf") as pdf:
        for i in range(min(2,len(pdf.pages))):
            t = pdf.pages[i].extract_table()
            print(f"--- page {i}, rows={len(t) if t else 0}")
            if t:
                for rrow in t[:4]:
                    print(rrow)
