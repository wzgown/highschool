#!/usr/bin/env python3
"""
ETL script: 导入 2025 年崇明区名额到校数据

用途：
1. 从 markdown 文件解析崇明区名额分配到校数据
2. 更新初中学校信息
3. 插入名额分配记录
4. 更新考生人数估算

使用方法：
    python scripts/etl_2025_quota_school_chongming.py
"""

import re
from pathlib import Path

# 配置
INPUT_FILE = Path("original_data/raw/2025/quota_district/markdown/2025_quota_to_school_chongming.md")
OUTPUT_SQL = Path("db/seeds/052_import_2025_chongming_quota_school.sql")

# 崇明区 ID
DISTRICT_ID = 17

def parse_chongming_quota(content: str) -> list[dict]:
    """解析崇明区名额到校表格"""
    records = []

    # 表格格式：
    # | 序号 | 学校代码 | 学校名称 | 崇明中学(512000) | 开实东滩(512001) | ... |
    lines = content.split('\n')

    in_table = False
    high_schools = []  # 列表存储高中学校信息

    for line in lines:
        # 跳过分隔行
        if re.match(r'^\|[\s\-:|]+\|$', line.strip()):
            continue

        if line.strip().startswith('|') and line.strip().endswith('|'):
            cells = [c.strip() for c in line.strip()[1:-1].split('|')]

            # 检测表头
            if '学校代码' in line or '崇明中学' in line:
                # 提取高中学校代码
                for cell in cells:
                    # 匹配格式: "学校名(代码)"
                    match = re.search(r'\((\d+)\)', cell)
                    if match:
                        high_schools.append({
                            'name': re.sub(r'\(\d+\)', '', cell).strip(),
                            'code': match.group(1)
                        })
                in_table = True
                continue

            # 数据行
            if in_table and len(cells) >= 3:
                # 提取初中学校代码和名称
                seq = cells[0]
                ms_code = None
                ms_name = None

                for i, cell in enumerate(cells):
                    if re.match(r'^\d{6}$', cell):
                        ms_code = cell
                        if i + 1 < len(cells):
                            ms_name = cells[i + 1]
                        break

                if ms_code and ms_name:
                    # 提取各高中名额
                    # 前三列是：序号、学校代码、学校名称
                    for j, quota_str in enumerate(cells[3:], start=3):
                        if j - 3 < len(high_schools):
                            # 提取数字
                            quota = 0
                            if quota_str and quota_str not in ['', '多']:
                                nums = re.findall(r'\d+', quota_str)
                                if nums:
                                    quota = int(nums[0])
                            elif quota_str == '多':
                                quota = 0  # 需要人工确认

                            if quota > 0:
                                records.append({
                                    'ms_code': ms_code,
                                    'ms_name': ms_name,
                                    'hs_code': high_schools[j - 3]['code'],
                                    'hs_name': high_schools[j - 3]['name'],
                                    'quota': quota
                                })

    return records

def calculate_estimated_students(records: list[dict], district_total: int) -> dict:
    """根据名额比例估算各校考生人数"""
    # 计算每所初中的总名额
    ms_quotas = {}
    for r in records:
        ms_code = r['ms_code']
        if ms_code not in ms_quotas:
            ms_quotas[ms_code] = {'name': r['ms_name'], 'total_quota': 0}
        ms_quotas[ms_code]['total_quota'] += r['quota']

    # 计算总名额
    total_quota = sum(m['total_quota'] for m in ms_quotas.values())

    # 按比例估算考生人数
    estimates = {}
    for ms_code, info in ms_quotas.items():
        if total_quota > 0:
            estimated = int(district_total * info['total_quota'] / total_quota)
        else:
            estimated = 0
        estimates[ms_code] = {
            'name': info['name'],
            'total_quota': info['total_quota'],
            'estimated_students': estimated
        }

    return estimates

def main():
    print(f"读取文件: {INPUT_FILE}")
    content = INPUT_FILE.read_text(encoding='utf-8')

    # 解析数据
    records = parse_chongming_quota(content)
    print(f"解析到 {len(records)} 条名额分配记录")

    # 崇明区 2025 年考生人数
    district_total = 2590

    # 计算估算考生人数
    estimates = calculate_estimated_students(records, district_total)
    print(f"涉及 {len(estimates)} 所初中学校")

    # 生成 SQL
    sql_lines = [
        "-- 2025年崇明区名额分配到校数据导入",
        "-- 数据来源: 2025_quota_to_school_chongming.md",
        "",
        "-- 更新/插入初中学校信息",
    ]

    # 1. 更新初中学校
    for ms_code, info in estimates.items():
        name = info['name'].replace("'", "''")
        sql_lines.append(f"""
INSERT INTO ref_middle_school (code, name, district_id, is_active, data_year, estimated_student_count)
VALUES ('{ms_code}', '{name}', {DISTRICT_ID}, TRUE, 2025, {info['estimated_students']})
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
""".strip())

    sql_lines.append("")
    sql_lines.append("-- 插入名额分配到校记录")

    # 2. 插入名额分配记录
    for r in records:
        # 使用子查询获取 high_school_id 和 middle_school_id
        sql_lines.append(f"""
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year)
SELECT
    2025,
    {DISTRICT_ID},
    (SELECT id FROM ref_school WHERE code = '{r['hs_code']}' AND data_year = 2025 LIMIT 1),
    '{r['hs_code']}',
    (SELECT id FROM ref_middle_school WHERE code = '{r['ms_code']}' AND data_year = 2025 LIMIT 1),
    '{r['ms_name'].replace("'", "''")}',
    {r['quota']},
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '{r['hs_code']}' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
""".strip())

    # 写入文件
    OUTPUT_SQL.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_SQL.write_text('\n'.join(sql_lines), encoding='utf-8')

    print(f"\n输出: {OUTPUT_SQL}")
    print(f"\n统计:")
    print(f"  - 名额分配记录: {len(records)}")
    print(f"  - 初中学校数: {len(estimates)}")
    print(f"  - 区总考生数: {district_total}")

    # 显示估算结果
    print("\n各校估算考生人数:")
    for ms_code, info in sorted(estimates.items(), key=lambda x: -x[1]['estimated_students'])[:10]:
        print(f"  {info['name']}: {info['estimated_students']} (名额: {info['total_quota']})")

if __name__ == "__main__":
    main()
