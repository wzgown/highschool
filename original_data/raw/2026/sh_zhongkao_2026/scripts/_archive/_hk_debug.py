import urllib.request, ssl, re
from html.parser import HTMLParser
URL="https://www.shhk.gov.cn/hkjy/zfxx/001007/001007001/20260531/bea19d54-4532-4de3-bea4-ceffcd0a8bfb.html"
ctx=ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
req=urllib.request.Request(URL, headers={"User-Agent":"Mozilla/5.0"})
html=urllib.request.urlopen(req,timeout=60,context=ctx).read().decode("utf-8","ignore")
class TP(HTMLParser):
    def __init__(s):
        super().__init__(); s.tables=[]; s.cur=None; s.row=None; s.cell=None; s.buf=[]
    def handle_starttag(s,t,a):
        if t=="table": s.cur=[]; s.tables.append(s.cur)
        elif t=="tr" and s.cur is not None: s.row=[]; s.cur.append(s.row)
        elif t in("td","th") and s.row is not None: s.cell=True; s.buf=[]
    def handle_endtag(s,t):
        if t in("td","th") and s.cell:
            if s.row is not None: s.row.append("".join(s.buf).strip())
            s.cell=False; s.buf=[]
    def handle_data(s,d):
        if s.cell: s.buf.append(d)
p=TP(); p.feed(html)
target=max(p.tables,key=len)
for r in target:
    print(r)
# also print raw html segment for 虹口实验
i=html.find("虹口实验学校")
print("\nRAW HTML around 虹口实验学校:")
print(html[i-50:i+400])
