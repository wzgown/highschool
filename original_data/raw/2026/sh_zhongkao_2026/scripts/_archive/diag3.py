import pdfplumber
WM = set("未经许可不得转载，。")
WEI = {"上海市上海中学","上海交通大学附属中学","复旦大学附属中学","华东师范大学第二附属中学","上海师范大学附属中学"}
def cn(s): return "".join(c for c in s if c not in WM).replace("\n","").strip() if s else ""
def cn2(s): return s.replace("\n","").strip() if s else ""

with pdfplumber.open("pdfs/songjiang.pdf") as pdf:
    for page in pdf.pages:
        fp = page.filter(lambda c: c.get("text") is None or c["text"] not in WM)
        tbl = fp.extract_table()
        if not tbl: continue
        for r in tbl:
            if not r: continue
            if r[0] and r[0].strip().isdigit() and len(r[0].strip())==6:
                code=r[0].strip(); name=cn2(r[1])
                wei=cn(r[2])
                nums=[cn2(r[3+j]) for j in range(5)]
                # check 委属
                if wei and wei not in WEI:
                    print("WEI-UNKNOWN:", code, name, "|", wei, "| nums=",nums)
print("scan done")
