import pdfplumber, re
WM = set("未经许可不得转载，。允")
with pdfplumber.open("pdfs/songjiang.pdf") as pdf:
    for pi,page in enumerate(pdf.pages):
        print(f"===== PAGE {pi} RAW =====")
        txt = page.extract_text() or ""
        for line in txt.split("\n"):
            # keep only lines that look like data (start with a 6-digit code OR contain a school name with numbers)
            if re.match(r"^\s*\d{6}\s", line) or re.search(r"上海|中学|学校|学院|外国语", line):
                print(line)
