import pdfplumber
WM = set("未经许可不得转载，。允")
def cn2(s): return s.replace("\n","").strip() if s else ""
def num(s):
    if s is None: return 0
    d="".join(c for c in s if c.isdigit()); return int(d) if d else 0

with pdfplumber.open("pdfs/songjiang.pdf") as pdf:
    for pi,page in enumerate(pdf.pages):
        fp = page.filter(lambda c: c.get("text") is None or c["text"] not in WM)
        tbl = fp.extract_table()
        if not tbl: continue
        for r in tbl:
            if not r: continue
            if r[0] and r[0].strip().isdigit() and len(r[0].strip())==6:
                s5 = sum(num(r[3+j]) for j in range(5))
                tot = num(r[8]) if len(r)>8 else 0
                if s5 != tot:
                    print(f"page{pi} {r[0].strip()} {cn2(r[1])[:10]} sum5={s5} total={tot} nums={[cn2(r[3+j]) for j in range(5)]} wei={cn2(r[2])}")
print("done")
