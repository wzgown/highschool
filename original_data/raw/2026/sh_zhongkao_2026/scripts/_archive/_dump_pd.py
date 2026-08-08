import pdfplumber, os
D = os.path.dirname(os.path.abspath(__file__))
def p(name): return os.path.join(D, name)
with pdfplumber.open(p('pudong_plan.pdf')) as pdf:
    print('PAGES', len(pdf.pages))
    for pi in range(min(2, len(pdf.pages))):
        tables = pdf.pages[pi].extract_tables()
        print('=== PAGE', pi, 'tables', len(tables))
        for ti, t in enumerate(tables):
            print(' table', ti, 'rows', len(t), 'cols', len(t[0]))
            for r in t[:4]:
                print([ (c[:20] if c else c) for c in r])
