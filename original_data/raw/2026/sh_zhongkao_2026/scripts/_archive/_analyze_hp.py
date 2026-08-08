import csv, pdfplumber, os
D = os.path.dirname(os.path.abspath(__file__))
def p(name): return os.path.join(D, name)
rows = list(csv.DictReader(open(p('to_school_plan_黄浦.csv'), encoding='utf-8-sig')))
print('黄浦 total rows:', len(rows))
schools = sorted(set(r['初中学校'] for r in rows))
print('初中学校数:', len(schools))
for s in schools:
    print('  ', repr(s))
with pdfplumber.open(p('huangpu_plan.pdf')) as pdf:
    print('pages', len(pdf.pages))
    t = pdf.pages[0].extract_text()
    print('TEXT LEN', len(t) if t else 0)
    print('---RAW HEAD---')
    print(t[:1400] if t else 'NONE')
