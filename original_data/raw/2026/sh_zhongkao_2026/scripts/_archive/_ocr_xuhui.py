import pytesseract, os
from PIL import Image
from collections import defaultdict
import csv

pytesseract.pytesseract.tesseract_cmd = '/opt/homebrew/bin/tesseract'
D = os.path.dirname(os.path.abspath(__file__))
def p(name): return os.path.join(D, name)

# 高中 columns in left-to-right order (from header)
HS_ORDER = ['上海市南洋模范中学','上海市位育中学','上海市第二中学','上海市第二中学(梅陇校区)',
            '上海市南洋中学','复旦大学附属中学徐汇分校','上海市上海中学','上海交通大学附属中学',
            '复旦大学附属中学','华东师范大学第二附属中学','上海师范大学附属中学']

pages = ['xuhui_h-1.png','xuhui_h-2.png']

all_digit = []  # (left, top, w, h, text, pageno)
rows_by_page = defaultdict(list)  # pageno -> list of (top, left, text, isdigit)
for pi, fn in enumerate(pages):
    img = Image.open(p(fn))
    W,H = img.size
    data = pytesseract.image_to_data(img, lang='chi_sim', output_type=pytesseract.Output.DICT)
    n = len(data['text'])
    for i in range(n):
        t = data['text'][i].strip()
        if not t: continue
        conf = int(data['conf'][i])
        if conf < 30: continue
        left=int(data['left'][i]); top=int(data['top'][i]); w=int(data['width'][i]); h=int(data['height'][i])
        rows_by_page[pi].append((top, left, t, t.isdigit() and len(t)<=2))
        if t.isdigit() and len(t)<=2:
            all_digit.append((left, top, w, h, t, pi))

# cluster digit x-centers into columns
centers = sorted(set(c[0]+c[2]//2 for c in all_digit))
# greedy clustering by gap
thr = 70
clusters=[]; cur=[centers[0]]
for x in centers[1:]:
    if x - cur[-1] > thr:
        clusters.append(cur); cur=[x]
    else:
        cur.append(x)
clusters.append(cur)
col_center = [sum(c)//len(c) for c in clusters]
print('NUM COLUMNS DETECTED:', len(col_center), col_center)

def col_of(x):
    cx = x  # center approx; use left
    best=0; bd=1e9
    for j,c in enumerate(col_center):
        d=abs(c-cx)
        if d<bd: bd=d; best=j
    return best

# build rows per page: cluster words by top
for pi in rows_by_page:
    words = rows_by_page[pi]
    words.sort()
    rows=[]; curtop=None; row=[]
    for (top,left,t,isd) in words:
        if curtop is None or abs(top-curtop) > 18:
            if row: rows.append(row)
            row=[(left,t,isd)]; curtop=top
        else:
            row.append((left,t,isd))
    if row: rows.append(row)
    rows_by_page[pi]=rows

out=[]
for pi in range(len(pages)):
    for row in rows_by_page[pi]:
        # name = chinese tokens; numbers by column
        nameparts=[t for (left,t,isd) in row if not isd and not t.isdigit()]
        # numbers
        colvals=defaultdict(list)
        for (left,t,isd) in row:
            if isd:
                colvals[col_of(left)].append(t)
        # only keep rows that look like data (have a 初中 name with 中学/学校 and >=6 numbers)
        nm=''.join(nameparts)
        if ('中学' in nm or '学校' in nm or '实验' in nm) and len(colvals)>=6:
            vals=[]
            ok=True
            for j in range(len(col_center)):
                if j in colvals:
                    # take first token if multiple
                    vals.append(colvals[j][0])
                else:
                    vals.append('')
            out.append((nm, vals))
            print(nm, vals)

with open(p('to_school_plan_徐汇.csv'),'w',encoding='utf-8-sig',newline='') as f:
    wtr=csv.writer(f)
    wtr.writerow(['区','初中学校','招生学校','计划数'])
    for nm,vals in out:
        for j,v in enumerate(vals):
            if v=='' : continue
            wtr.writerow(['徐汇区',nm,HS_ORDER[j],v])
print('TOTAL ROWS', len(out))
