import pdfplumber, re, csv

WM = set("转载不得经允许未")  # watermark chars to strip

with pdfplumber.open("huangpu_plan.pdf") as pdf:
    raw = pdf.pages[0].extract_text() or ""
clean = "".join(ch for ch in raw if ch not in WM)
# keep newlines/spaces
clean = re.sub(r"[ \t]+", " ", clean)

# column codes from header: (012001) etc.
codes = re.findall(r"\((\d{6})\)", clean)
print("COLUMN CODES (first 14):", codes[:14])
# build full name map from known data
NAME = {
 "012001":"上海市格致中学","012002":"上海市格致中学(奉贤校区)","012003":"上海市大同中学",
 "012005":"上海市向明中学","012006":"上海市向明中学(浦江校区)","012007":"上海外国语大学附属大境中学",
 "012008":"上海市光明中学","012009":"上海市敬业中学","012010":"上海市卢湾高级中学",
 "012011":"同济大学科技中学","042032":"上海市上海中学","102056":"上海交通大学附属中学",
 "102057":"复旦大学附属中学","152003":"华东师范大学第二附属中学",
}

# rows: 6-digit code, then 14 ints, then school name (Chinese) up to next 6-digit code
# find all segments: \d{6} followed by numbers then name
# We'll locate each 6-digit code occurrence and capture following tokens until next 6-digit code.
tokens = clean.split()
# locate indices of 6-digit codes
rows = []
i = 0
n = len(tokens)
while i < n:
    if re.fullmatch(r"\d{6}", tokens[i]):
        code = tokens[i]
        j = i+1
        nums = []
        while j < n and re.fullmatch(r"\d+", tokens[j]):
            nums.append(int(tokens[j])); j += 1
        # now collect name tokens (chinese) until next 6-digit code or end
        name_parts = []
        while j < n and not re.fullmatch(r"\d{6}", tokens[j]):
            name_parts.append(tokens[j]); j += 1
        name = "".join(name_parts)
        if len(nums) == 14:
            rows.append((code, nums, name))
        i = j
    else:
        i += 1

print("ROWS PARSED:", len(rows))
for code, nums, name in rows[:3]:
    print(code, nums, name)

# write csv
out = "to_school_plan_黄浦.csv"
with open(out, "w", newline="", encoding="utf-8-sig") as f:
    w = csv.writer(f)
    w.writerow(["区","初中学校","招生学校","计划数"])
    for code, nums, name in rows:
        for colcode, val in zip(codes[:14], nums):
            if val == 0:
                continue
            w.writerow(["黄浦区", name, NAME[colcode], val])
print("written", out)
