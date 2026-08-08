import os
D="/Users/wangzhigang/WorkBuddy/2026-07-23-16-07-03/sh_zhongkao_2026/data"
for d in ["静安","普陀","杨浦","虹口","徐汇"]:
    f=f"to_school_plan_{d}.csv"
    p=os.path.join(D,f)
    lines=sum(1 for _ in open(p,encoding="utf-8-sig"))
    print(f, lines, "行")
print("--- 徐汇文件内容 ---")
print(open(os.path.join(D,"to_school_plan_徐汇.csv"),encoding="utf-8-sig").read())
