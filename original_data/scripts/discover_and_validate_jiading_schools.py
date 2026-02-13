#!/usr/bin/env python3
"""
发现并验证嘉定区初中学校

特别关注：
1. 交大附中附属嘉定洪德中学
2. 上海师范大学附属中学嘉定新城分校
"""

import os
import re
from pathlib import Path

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MD_DIR = os.path.join(BASE_DIR, "raw", "2025", "quota_district", "markdown")
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")
SEEDS_DIR = os.path.join(BASE_DIR, "..", "db", "seeds")

Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)
Path(SEEDS_DIR).mkdir(parents=True, exist_ok=True)


def find_schools_in_jiading_md():
    """在嘉定区markdown文件中查找学校"""
    md_file = os.path.join(MD_DIR, "嘉定区名额分配到校.md")

    if not os.path.exists(md_file):
        print(f"错误：文件不存在 - {md_file}")
        return [], []

    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')

    # 查找所有学校名称
    middle_schools = set()
    high_schools = []

    # 目标学校
    target_schools = {
        '交大附中附属嘉定洪德中学': False,
        '交大附中附属嘉定德富中学': False,
        '上海师范大学附属中学嘉定新城分校': False,
    }

    for i, line in enumerate(lines):
        line = line.strip()

        # 查找初中学校（在列表部分）
        if '上海市嘉定区' in line and '中学' in line and '附属' not in line:
            middle_schools.add(line)

        # 查找目标学校
        for target in target_schools.keys():
            if target in line:
                target_schools[target] = True
                print(f"  ✓ 找到: {target} (行 {i+1})")

        # 查找高中代码
        if re.match(r'^\d{6}$', line):
            code = line
            if code not in [s[0] for s in high_schools]:
                # 查找代码后的学校名称
                if i + 1 < len(lines):
                    next_line = lines[i + 1].strip()
                    if '中学' in next_line:
                        high_schools.append((code, next_line))

    return list(middle_schools), high_schools, target_schools


def check_existing_database():
    """检查现有数据库中的学校"""
    seed_file = os.path.join(SEEDS_DIR, "002_seed_schools_2025_full.sql")

    if not os.path.exists(seed_file):
        print(f"警告：种子文件不存在 - {seed_file}")
        return set()

    with open(seed_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取所有学校名称
    schools = set()
    for match in re.finditer(r"'([^']+)'", content):
        school = match.group(1)
        if school and len(school) > 3:
            schools.add(school)

    return schools


def main():
    print("=" * 60)
    print("嘉定区初中学校发现与验证")
    print("=" * 60)

    # 1. 查找嘉定区markdown中的学校
    print("\n步骤1: 扫描嘉定区markdown文件...")
    middle_schools, high_schools, target_schools = find_schools_in_jiading_md()

    print(f"\n  初中学校总数: {len(middle_schools)}")
    print(f"  高中学校总数: {len(high_schools)}")

    # 2. 检查现有数据库
    print("\n步骤2: 检查现有数据库...")
    existing_schools = check_existing_database()
    print(f"  现有学校数: {len(existing_schools)}")

    # 3. 检查目标学校
    print("\n步骤3: 验证特别关注的学校...")
    for target, found in target_schools.items():
        status = "✓ 在markdown中找到" if found else "✗ 未找到"
        db_status = "✓ 在数据库中" if target in existing_schools else "✗ 不在数据库中"
        print(f"  {target}")
        print(f"    Markdown: {status}")
        print(f"    数据库: {db_status}")

    # 4. 发现新学校
    print("\n步骤4: 发现新初中学校...")
    new_schools = []
    for school in middle_schools:
        if school not in existing_schools:
            new_schools.append(school)

    if new_schools:
        print(f"  发现 {len(new_schools)} 所新学校:")
        for school in sorted(new_schools):
            print(f"    - {school}")
    else:
        print("  未发现新学校")

    # 5. 生成SQL
    print("\n步骤5: 生成SQL...")
    sql_lines = [
        "-- =============================================================================",
        "-- 嘉定区名额分配到校 - 初中学校发现",
        f"-- 生成时间: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "-- 新发现的初中学校",
    ]

    for school in new_schools:
        # 生成学校代码
        code = f"JD{len(new_schools):04d}"
        sql_lines.extend([
            f"-- 新学校: {school}",
            f"INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)",
            f"SELECT '{code}', '{school}', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP",
            f"FROM ref_district d WHERE d.code = 'JD';",
            "",
        ])

    # 验证SQL
    sql_lines.extend([
        "",
        "-- 验证特别关注的学校",
        "",
        "-- 交大附中附属嘉定洪德中学/德富中学",
        "SELECT id, code, name FROM ref_middle_school",
        "WHERE name LIKE '%交大附中附属嘉定%' AND district_id = (SELECT id FROM ref_district WHERE code = 'JD')",
        "  AND data_year = 2025;",
        "",
        "-- 上海师范大学附属中学嘉定新城分校",
        "SELECT id, code, name FROM ref_middle_school",
        "WHERE name LIKE '%上海师范大学附属中学嘉定新城%' AND district_id = (SELECT id FROM ref_district WHERE code = 'JD')",
        "  AND data_year = 2025;",
        "",
    ])

    sql_file = os.path.join(SEEDS_DIR, "011_discover_jiading_middle_schools_2025.sql")
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"  SQL文件: {sql_file}")

    print("\n" + "=" * 60)
    print("处理完成")
    print("=" * 60)
    print(f"\n总结:")
    print(f"  - 扫描的初中学校: {len(middle_schools)}")
    print(f"  - 新发现的学校: {len(new_schools)}")
    print(f"  - 特别关注的学校: {len(target_schools)}")
    print(f"\n生成的文件:")
    print(f"  - {sql_file}")


if __name__ == '__main__':
    main()
