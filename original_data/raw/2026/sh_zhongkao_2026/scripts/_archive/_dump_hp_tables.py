import pdfplumber, os
D = os.path.dirname(os.path.abspath(__file__))
def p(name): return os.path.join(D, name)
with pdfplumber.open(p('huangpu_plan.pdf')) as pdf:
    for pi, page in enumerate(pdf.pages):
        print('=== PAGE', pi, '===')
        tables = page.extract_tables()
        print('num tables:', len(tables))
        for ti, t in enumerate(tables):
            print('--- table', ti, 'rows', len(t), 'cols', len(t[0]) if t else 0)
            for row in t:
                print(row)
