import pdfplumber, re
codes=[]; shengji=0
with pdfplumber.open("pdfs/songjiang.pdf") as pdf:
    for page in pdf.pages:
        txt = page.extract_text() or ""
        for line in txt.split("\n"):
            m = re.match(r"^\s*(\d{6})\b", line)
            if m:
                codes.append(m.group(1))
            # also capture 合计 from lines that end with a number after 5 numbers
print("codes found:", len(codes))
print(sorted(codes))
# expected contiguous-ish list: build set, find gaps
s=set(codes)
# known range 171001..175041
for c in range(171001,175042):
    if c not in s:
        pass # just note
print("missing in 171001..175041:", [c for c in range(171001,175042) if c not in s])
