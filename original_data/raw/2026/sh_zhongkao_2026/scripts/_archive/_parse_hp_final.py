import pdfplumber, os, csv
D = os.path.dirname(os.path.abspath(__file__))
def p(name): return os.path.join(D, name)

WM = set("转载不得经允许未，")

def clean(cell):
    if cell is None: return ''
    return ''.join(ch for ch in cell if ch not in WM)

# 高中 code -> full name (with 上海市 prefix)
HS = {
 '012001':'上海市格致中学',
 '012002':'上海市格致中学(奉贤校区)',
 '012003':'上海市大同中学',
 '012005':'上海市向明中学',
 '012006':'上海市向明中学(浦江校区)',
 '012007':'上海外国语大学附属大境中学',
 '012008':'上海市光明中学',
 '012009':'上海市敬业中学',
 '012010':'上海市卢湾高级中学',
 '012011':'上海市同济黄浦设计创意中学',
 '042032':'上海市上海中学',
 '102056':'上海交通大学附属中学',
 '102057':'复旦大学附属中学',
 '152003':'华东师范大学第二附属中学',
}

with pdfplumber.open(p('huangpu_plan.pdf')) as pdf:
    t = pdf.pages[0].extract_tables()[0]

# header row 0: col0 is label, cols1..14 are "NAME\n(CODE)"
schools = []  # list of (code, fullname)
for cell in t[0][1:]:
    c = clean(cell)
    # find code
    code = None; name = None
    for part in c.split('\n'):
        part = part.strip()
        if part.startswith('(') and part.endswith(')'):
            code = part[1:-1]
        elif part:
            name = part
    assert code in HS, (code, c)
    schools.append((code, HS[code]))

rows = []
for r in t[1:]:
    raw0 = clean(r[0])
    # code is 6 digits at start
    code = ''.join(ch for ch in raw0 if ch.isdigit())
    name = ''.join(ch for ch in raw0 if not ch.isdigit()).strip()
    if not name:  # not a data row
        continue
    for (hs_code, hs_name), val in zip(schools, r[1:]):
        v = clean(val).strip()
        if v == '' or v == '—':
            continue
        rows.append(('黄浦区', name, hs_name, v))

with open(p('to_school_plan_黄浦.csv'), 'w', encoding='utf-8-sig', newline='') as f:
    w = csv.writer(f)
    w.writerow(['区','初中学校','招生学校','计划数'])
    for r in rows:
        w.writerow(r)
print('黄浦 rows:', len(rows))
print('初中数:', len(set(r[1] for r in rows)))
# sanity: totals per 高中
from collections import Counter
tot = Counter()
for r in rows:
    tot[r[2]] += int(r[3])
for k,v in tot.items():
    print(' ', k, v)
