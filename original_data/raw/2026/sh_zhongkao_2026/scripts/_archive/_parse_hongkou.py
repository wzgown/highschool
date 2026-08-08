import urllib.request, ssl, re, csv, os
from html.parser import HTMLParser

URL="https://www.shhk.gov.cn/hkjy/zfxx/001007/001007001/20260531/bea19d54-4532-4de3-bea4-ceffcd0a8bfb.html"
ctx=ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
req=urllib.request.Request(URL, headers={"User-Agent":"Mozilla/5.0"})
html=urllib.request.urlopen(req,timeout=60,context=ctx).read().decode("utf-8","ignore")

class TableParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tables=[]; self.cur=None; self.row=None; self.cell=None; self.buf=[]
    def handle_starttag(self,tag,attrs):
        if tag=="table": self.cur=[]; self.tables.append(self.cur)
        elif tag=="tr" and self.cur is not None: self.row=[]; self.cur.append(self.row)
        elif tag in ("td","th") and self.row is not None:
            self.cell=True; self.buf=[]
    def handle_endtag(self,tag):
        if tag in ("td","th") and self.cell:
            if self.row is not None: self.row.append("".join(self.buf).strip())
            self.cell=False; self.buf=[]
    def handle_data(self,data):
        if self.cell: self.buf.append(data)

p=TableParser(); p.feed(html)
# pick table containing 初中学校
target=None
for t in p.tables:
    if t and t[0] and any("初中学校" in (c or "") for c in t[0]):
        target=t; break
if target is None:
    # fallback: biggest table
    target=max(p.tables,key=len)
print("chosen table rows:", len(target))
for r in target[:3]:
    print(r)

NAME_MAP=[
    ("复兴", "复旦大学附属复兴中学"),
    ("一附中", "华东师范大学第一附属中学"),
    ("北郊", "上海财经大学附属北郊高级中学"),
    ("上海中学", "上海市上海中学"),
    ("上中", "上海市上海中学"),
    ("华二", "华东师范大学第二附属中学"),
    ("复附", "复旦大学附属中学"),
    ("交附", "上海交通大学附属中学"),
]
def mapname(txt):
    for k,n in NAME_MAP:
        if k in txt: return n
    return None

header=target[0]
hs=[]
for i,c in enumerate(header):
    if i<2: continue
    nm=mapname(c or "")
    if nm: hs.append((i,nm))
wei_idx=next((i for i,c in enumerate(header) if '委属' in (c or '')), None)
if wei_idx is not None and len(target)>1:
    for k,sub in enumerate(target[1]):
        nm=mapname(sub or "")
        if nm: hs.append((wei_idx+k, nm))
hs.sort()
print("hs cols:", hs)
rows=[]
for r in target[1:]:
    if len(r)<2: continue
    jn=r[1]
    if not jn or not re.search(r"中学|学校|学院", jn): continue
    if not any(ch.isdigit() for ch in "".join(r[2:])):  # skip if no numbers (e.g., 总计/header)
        continue
    ok=False
    for (i,nm) in hs:
        val=(r[i] if i<len(r) else "").strip()
        if val in ("","—","-"): val="0"
        rows.append(("虹口区", jn, nm, val))
        ok=True
    if not ok: 
        print("skip row no num:", r[:3])
print("虹口 rows:", len(rows), "schools:", len(set(x[1] for x in rows)))
# validate 委属 total
wei_total=sum(int(r[3]) for r in rows if r[2] in ("上海市上海中学","华东师范大学第二附属中学","复旦大学附属中学","上海交通大学附属中学"))
print("委属四校合计:", wei_total)

fn=os.path.join("/Users/wangzhigang/WorkBuddy/2026-07-23-16-07-03/sh_zhongkao_2026/data","to_school_plan_虹口.csv")
with open(fn,"w",newline="",encoding="utf-8-sig") as f:
    w=csv.writer(f); w.writerow(["区","初中学校","招生学校","计划数"])
    for r in rows: w.writerow(r)
print("written", fn)
