import pdfplumber

with pdfplumber.open("downloads/qp.pdf") as pdf:
    for pi, page in enumerate(pdf.pages):
        print(f"===== QP page {pi} : table cols =====")
        for tbl in page.extract_tables():
            print("ncols:", len(tbl[0]) if tbl else 0, "nrows:", len(tbl))
            for r in tbl:
                print(r)
