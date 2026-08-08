import os, csv
from collections import defaultdict
D = os.path.dirname(os.path.abspath(__file__))
def p(name): return os.path.join(D, name)
HS = ['上海市南洋模范中学','上海市位育中学','上海市第二中学','上海市第二中学(梅陇校区)',
      '上海市南洋中学','复旦大学附属中学徐汇分校','上海市上海中学','上海交通大学附属中学',
      '复旦大学附属中学','华东师范大学第二附属中学','上海师范大学附属中学']
HEADER_NAMES=set(['南洋模范','位育中学','市二中学','市二梅隆','市二梅陇','南洋中学','复附徐汇','上海中学','交大附中','复旦附中','华二附中','上师附中'])

def read_tsv(fn):
    toks=[]
    import csv as _csv
    with open(fn, encoding='utf-8') as f:
        for r in _csv.DictReader(f, delimiter='\t'):
            t=(r.get('text') or '').strip()
            if not t: continue
            toks.append((int(r['left']),int(r['top']),t,int(float(r['conf']))))
    return toks

# header anchors from 6-digit codes at top of page
anchors=[]
for pg in [1,2]:
    for (l,tp,t,conf) in read_tsv(p('xh_eng_xuhui_page-%d.tsv'%pg)):
        if len(t)==6 and tp<260:
            anchors.append(l)
# cluster
anchors=sorted(set(anchors))
thr=60; cl=[]; cur=[anchors[0]]
for x in anchors[1:]:
    if x-cur[-1]>thr: cl.append(cur); cur=[x]
    else: cur.append(x)
cl.append(cur)
anchors=[sum(c)//len(c) for c in cl]
print('HEADER ANCHORS', len(anchors), anchors)

def col_of(x):
    best=0; bd=1e9
    for j,a in enumerate(anchors):
        d=abs(a-x)
        if d<bd: bd=d; best=j
    return best

# gather tokens
eng_digits=[]; names=[]
for pg in [1,2]:
    for (l,tp,t,conf) in read_tsv(p('xh_eng_xuhui_page-%d.tsv'%pg)):
        if t.isdigit() and conf>=30 and len(t)<=2 and tp>=260:
            eng_digits.append((l,tp,t))
    for (l,tp,t,conf) in read_tsv(p('xh_chi_sim_xuhui_page-%d.tsv'%pg)):
        if conf>=30:
            names.append((l,tp,t))

# row cluster
allt=[(tp,l,t,'D') for l,tp,t in eng_digits]+[(tp,l,t,'N') for l,tp,t in names]
allt.sort(key=lambda r:r[0])
rows=[]; ct=None; row=[]
for (tp,l,t,kind) in allt:
    if ct is None or abs(tp-ct)>26:
        if row: rows.append(row)
        row=[(tp,l,t,kind)]; ct=tp
    else:
        row.append((tp,l,t,kind))
if row: rows.append(row)

out=[]
for row in rows:
    nm=''.join(t for tp,l,t,k in row if k=='N')
    if not (('中学' in nm) or ('学校' in nm) or ('实验' in nm) or ('学院' in nm)): continue
    if nm in HEADER_NAMES or any(h in nm for h in HEADER_NAMES): continue
    a0=anchors[0]
    colvals=defaultdict(list)
    for tp,l,t,k in row:
        if k=='D' and l>=a0-120:
            colvals[col_of(l)].append(t)
    vals=[max(colvals[j],key=len) if j in colvals else '0' for j in range(11)]
    out.append((nm,vals))
    print(nm, vals)

from collections import Counter
tot=Counter()
for nm,vals in out:
    for j,v in enumerate(vals): tot[HS[j]]+=int(v)
print('TOTALS')
for k in HS: print(' ',k,tot[k])
print('rows', len(out))
with open(p('to_school_plan_徐汇.csv'),'w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f); w.writerow(['区','初中学校','招生学校','计划数'])
    for nm,vals in out:
        for j,v in enumerate(vals):
            w.writerow(['徐汇区',nm,HS[j],v])
