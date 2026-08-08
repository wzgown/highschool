import csv
from collections import Counter
for d in ["静安","普陀","杨浦"]:
    fn=f"/Users/wangzhigang/WorkBuddy/2026-07-23-16-07-03/sh_zhongkao_2026/data/to_school_plan_{d}.csv"
    rows=list(csv.reader(open(fn,encoding="utf-8-sig")))
    data=rows[1:]
    schools=sorted(set(r[1] for r in data))
    pairs=Counter((r[1],r[2]) for r in data)
    dups=[k for k,v in pairs.items() if v>1]
    print(d, "总行",len(data),"初中校数",len(schools),"重复(初中,高中)数",len(dups))
    if d=="杨浦":
        for s in schools: print("  ",s)
