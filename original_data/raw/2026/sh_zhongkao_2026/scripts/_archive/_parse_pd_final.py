import pdfplumber, os, csv, re
D = os.path.dirname(os.path.abspath(__file__))
def p(name): return os.path.join(D, name)

WM = set("转载不得经允许未，可许")

# column index -> full high-school name (col2..col16)
HS = {
 2:'上海市上海中学',
 3:'华东师范大学第二附属中学',
 4:'复旦大学附属中学',
 5:'上海交通大学附属中学',
 6:'上海师范大学附属中学',
 7:'上海市实验学校',
 8:'上海市建平中学',
 9:'上海市进才中学',
 10:'上海市洋泾中学',
 11:'上海市川沙中学',
 12:'上海南汇中学',
 13:'上海市高桥中学',
 14:'上海市浦东复旦附中分校',
 15:'上海中学东校',
 16:'华东师范大学第二附属中学(临港奉贤分校)',
}

rows = []
with pdfplumber.open(p('pudong_plan.pdf')) as pdf:
    for page in pdf.pages:
        for t in page.extract_tables():
            for r in t:
                if not r or (r[0] or '').strip() == '序号':
                    continue
                seq = (r[0] or '').strip()
                name = ''.join(ch for ch in (r[1] or '') if ch not in WM).strip()
                if not name or '合计' in name:
                    continue
                if not re.search(r'[一-鿿]', name):  # name must contain Chinese
                    continue
                for ci in range(2, 17):
                    v = re.sub(r'\D', '', r[ci] or '')
                    if v == '':
                        continue
                    rows.append(('浦东新区', name, HS[ci], int(v)))

with open(p('to_school_plan_浦东.csv'), 'w', encoding='utf-8-sig', newline='') as f:
    w = csv.writer(f)
    w.writerow(['区','初中学校','招生学校','计划数'])
    for r in rows:
        w.writerow(r)
print('浦东 rows:', len(rows))
print('初中数:', len(set(r[1] for r in rows)))
from collections import Counter
tot = Counter()
for r in rows:
    tot[r[2]] += r[3]
grand = 0
for k, v in tot.items():
    print(' ', k, v); grand += v
print('TOTAL', grand)
print('委属合计', sum(v for k,v in tot.items() if k in ('上海市上海中学','华东师范大学第二附属中学','复旦大学附属中学','上海交通大学附属中学','上海师范大学附属中学','上海市实验学校')))
