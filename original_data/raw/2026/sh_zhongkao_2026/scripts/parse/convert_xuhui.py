import csv, os
# 路径对齐：本文件位于 scripts/parse/，上两级即项目根（含 data/ raw/ output/）
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# src 为用户手工提供的徐汇原始 CSV（来自 Downloads，不纳入仓库）；如有需要请改为实际路径
src = "/Users/wangzhigang/Downloads/徐汇区2026年名额分配到校招生计划 (1).csv"
dst = os.path.join(ROOT, "data", "to_school_plan_徐汇.csv")

# 矩阵列简称 -> 录取线表全称
short2full = {
    "042008南洋模范": "上海市南洋模范中学",
    "042035位育中学": "上海市位育中学",
    "042001市二中学": "上海市第二中学",
    "042002市二梅陇": "上海市第二中学（梅陇校区）",
    "043015南洋中学": "上海市南洋中学",
    "042036复附徐汇": "复旦大学附属中学徐汇分校",
    "042032上海中学": "上海市上海中学",
    "102056交大附中": "上海交通大学附属中学",
    "102057复旦附中": "复旦大学附属中学",
    "152003华二附中": "华东师范大学第二附属中学",
    "152006上师附中": "上海师范大学附属中学",
}

with open(src, encoding="utf-8-sig") as f:
    rows = list(csv.reader(f))
hdr = rows[0]
hs_cols = hdr[3:]
assert all(c in short2full for c in hs_cols), "列名未全覆盖: " + str([c for c in hs_cols if c not in short2full])

out = [["区", "初中学校", "招生学校", "计划数"]]
total = 0
n_cells = 0
juniors = set()
hs_set = set()
for r in rows[1:]:
    if not r or not r[0].strip().isdigit():
        continue
    junior = r[2].strip()
    juniors.add(junior)
    for col, val in zip(hs_cols, r[3:]):
        val = val.strip()
        if val:
            n = int(val)
            out.append(["徐汇区", junior, short2full[col], n])
            total += n
            n_cells += 1
            hs_set.add(short2full[col])

with open(dst, "w", encoding="utf-8-sig", newline="") as f:
    csv.writer(f).writerows(out)

print("写入:", dst)
print("输出行数(含表头):", len(out), " 分配单元格数:", n_cells)
print("计划数合计:", total, " (应=899)", "OK" if total == 899 else "!!MISMATCH!!")
print("初中数:", len(juniors), " (应=31)", "OK" if len(juniors) == 31 else "!!MISMATCH!!")
print("高中数:", len(hs_set), " (应=11)", "OK" if len(hs_set) == 11 else "!!MISMATCH!!")
