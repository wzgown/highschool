#!/usr/bin/env python3
"""
ETL script: 从 2025 年名额到校数据中提取初中学校信息

用途：
1. 解析 markdown 格式的名额到校数据
2. 提取初中学校代码和名称
3. 生成 SQL 更新语句

使用方法：
    python scripts/etl_2025_middle_schools_from_quota.py
"""

import re
import os
from pathlib import Path
from collections import defaultdict

# 配置
MARKDOWN_DIR = Path("original_data/raw/2025/quota_district/markdown")
OUTPUT_FILE = Path("db/seeds/051_update_middle_schools_from_2025_quota.sql")

# 区名映射
DISTRICT_MAP = {
    "黄浦": 1, "静安": 2, "徐汇": 3, "长宁": 4, "普陀": 5,
    "虹口": 6, "杨浦": 7, "闵行": 8, "宝山": 9, "嘉定": 10,
    "浦东": 11, "金山": 12, "松江": 13, "青浦": 14, "奉贤": 15, "崇明": 16
}

def extract_district_from_filename(filename: str) -> tuple[int, str] | None:
    """从文件名提取区ID"""
    # 匹配 2025_quota_to_school_{区名}.md
    match = re.search(r'2025_quota_to_school_(\w+)\.md', filename)
    if match:
        district_key = match.group(1)
        # 处理特殊区名
        district_name_map = {
            "huangpu": "黄浦", "jingan": "静安", "xuhui": "徐汇",
            "changning": "长宁", "putuo": "普陀", "hongkou": "虹口",
            "yangpu": "杨浦", "minhang": "闵行", "baoshan": "宝山",
            "jiading": "嘉定", "pudong": "浦东", "jinshan": "金山",
            "songjiang": "松江", "qingpu": "青浦", "fengxian": "奉贤",
            "chongming": "崇明"
        }
        cn_name = district_name_map.get(district_key)
        if cn_name and cn_name in DISTRICT_MAP:
            return DISTRICT_MAP[cn_name], cn_name
    return None

def parse_markdown_table(content: str) -> list[dict]:
    """解析 markdown 表格，提取初中学校信息"""
    schools = []
    lines = content.split('\n')

    in_table = False
    header_cols = []

    for line in lines:
        # 跳过分隔行
        if re.match(r'^\|[\s\-:|]+\|$', line):
            continue

        # 检测表格行
        if line.startswith('|') and line.endswith('|'):
            cells = [c.strip() for c in line[1:-1].split('|')]

            # 检测表头（包含"学校"或"序号"）
            if not in_table and ('序号' in cells[0] or '学校代码' in ''.join(cells)):
                in_table = True
                header_cols = cells
                continue

            # 解析数据行
            if in_table and len(cells) >= 3:
                # 尝试提取学校代码和名称
                school_code = None
                school_name = None

                for i, cell in enumerate(cells):
                    # 学校代码：6位数字
                    if re.match(r'^\d{6}$', cell):
                        school_code = cell
                        # 名称通常在代码后面
                        if i + 1 < len(cells) and cells[i + 1]:
                            school_name = cells[i + 1]
                        break

                # 如果没有找到6位代码，尝试其他格式
                if not school_code:
                    # 格式：序号 | 代码 | 名称 | ...
                    for i, cell in enumerate(cells):
                        if re.match(r'^\d{5,6}$', cell):
                            school_code = cell
                            if i + 1 < len(cells):
                                school_name = cells[i + 1]
                            break

                # 计算总名额（排除序号、代码、名称列后的数字列）
                total_quota = 0
                if school_code and school_name:
                    for cell in cells[3:]:  # 跳过前几列
                        # 提取数字
                        nums = re.findall(r'\d+', cell)
                        for n in nums:
                            if int(n) < 1000:  # 排除学校代码
                                total_quota += int(n)

                if school_code and school_name:
                    schools.append({
                        'code': school_code,
                        'name': school_name,
                        'total_quota': total_quota
                    })

    return schools

def main():
    all_schools = {}  # code -> {name, district_id, quotas}

    # 遍历所有名额到校 markdown 文件
    for md_file in MARKDOWN_DIR.glob("2025_quota_to_school_*.md"):
        result = extract_district_from_filename(md_file.name)
        if not result:
            print(f"无法识别区名: {md_file.name}")
            continue

        district_id, district_name = result
        print(f"处理: {md_file.name} -> {district_name}")

        content = md_file.read_text(encoding='utf-8')
        schools = parse_markdown_table(content)

        for school in schools:
            code = school['code']
            if code not in all_schools:
                all_schools[code] = {
                    'name': school['name'],
                    'district_id': district_id,
                    'district_name': district_name,
                    'quotas': school['total_quota']
                }
            else:
                # 累加名额
                all_schools[code]['quotas'] += school['total_quota']

        print(f"  找到 {len(schools)} 所学校")

    # 生成 SQL
    sql_lines = [
        "-- 从 2025 年名额到校数据更新初中学校",
        "-- 生成时间: 自动生成",
        "",
        "-- 更新/插入学校信息",
    ]

    for code, info in sorted(all_schools.items(), key=lambda x: int(x[0])):
        name = info['name'].replace("'", "''")  # SQL 转义
        district_id = info['district_id']

        sql_lines.append(f"""
INSERT INTO ref_middle_school (code, name, district_id, is_active, data_year)
VALUES ('{code}', '{name}', {district_id}, TRUE, 2025)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE;
""".strip())

    # 写入文件
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text('\n'.join(sql_lines), encoding='utf-8')

    print(f"\n总计: {len(all_schools)} 所初中学校")
    print(f"输出: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
