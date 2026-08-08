import pdfplumber, os
for f in ["jingan_plan.pdf","yangpu_plan.pdf","xuhui_plan.pdf","putuo_plan.pdf"]:
    print("="*70)
    print(f)
    try:
        with pdfplumber.open(f) as pdf:
            print("pages:", len(pdf.pages))
            txt = pdf.pages[0].extract_text() or ""
            print("page0 text len:", len(txt))
            print(repr(txt[:600]))
    except Exception as e:
        print("ERR", repr(e))
