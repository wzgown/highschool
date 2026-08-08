import csv, os
D = '/Users/wangzhigang/WorkBuddy/2026-07-23-16-07-03/sh_zhongkao_2026/data'
for short in ['长宁','黄浦','浦东','徐汇']:
    fn = os.path.join(D, f'to_school_plan_{short}.csv')
    rows = list(csv.reader(open(fn, encoding='utf-8-sig')))
    header = rows[0]
    data = [r for r in rows[1:] if r and not r[0].startswith('#')]
    comments = [r for r in rows[1:] if r and r[0].startswith('#')]
    schools = len(set(r[1] for r in data)) if data else 0
    print(f'{short}: 文件={os.path.basename(fn)} 数据行={len(data)} 初中数={schools} 注释行={len(comments)}')
    if data:
        from collections import Counter
        c = Counter(r[2] for r in data)
        print('   高中数:', len(c), ' 计划合计:', sum(int(r[3]) for r in data))
