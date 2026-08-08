import pdfplumber
for f in ["jingan_plan.pdf","putuo_plan.pdf","yangpu_plan.pdf"]:
    print("="*80)
    print(f)
    with pdfplumber.open(f) as pdf:
        for pi, page in enumerate(pdf.pages):
            tables = page.extract_tables()
            print(f"--- page {pi} tables={len(tables)}")
            for ti, t in enumerate(tables):
                print(f"  table {ti} rows={len(t)}")
                for r in t[:3]:
                    print("   ", r)
