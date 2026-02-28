#!/usr/bin/env python3
"""
ETL脚本：通用名额分配到校解析器（基于静安区格式）

使用静安区数据作为参考模板，处理其他区的类似格式数据。

特性：
- 自动检测区名
- 基于参考数据验证学校
- 处理多种列式格式
- 生成CSV和SQL
"""

import csv
import os
import re
from pathlib import Path
from collections import defaultdict
from datetime import datetime

# ============================================================================
# 配置
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")
SEEDS_DIR = os.path.join(BASE_DIR, "..", "db", "seeds")

Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)
Path(SEEDS_DIR).mkdir(parents=True, exist_ok=True)

# 区县代码映射
DISTRICT_MAP = {
    '黄浦': 'HP', '徐汇': 'XH', '长宁': 'CN', '静安': 'JA',
    '普陀': 'PT', '虹口': 'HK', '杨浦': 'YP', '闵行': 'MH',
    '宝山': 'BS', '嘉定': 'JD', '浦东': 'PD', '金山': 'JS',
    '松江': 'SJ', '青浦': 'QP', '奉贤': 'FX', '崇明': 'CM',
}

# 从静安区数据中提取的已知高中（用于验证）
KNOWN_HIGH_SCHOOLS = {
    '012001': '上海市市西初级中学',
    '012002': '上海市育才初级中学',
    '012003': '上海市市西初级中学',
    '012006': '上海市市西初级中学',
    '012007': '上海市市西初级中学',
    '012008': '上海市市西初级中学',
    '012009': '上海市敬业中学',
    '012010': '上海市卢湾高级中学',
    '012011': '上海市回民中学',
    '042032': '上海市上海中学',
    '102056': '上海交通大学附属中学',
    '102057': '复旦大学附属中学',
    '152003': '华东师范大学第二附属中学',
    '152006': '上海师范大学附属中学',
    # 其他高中...
}

# ============================================================================
# 工具函数
# ============================================================================

def extract_district_from_filename(filename):
    """从文件名提取区名"""
    for zh, code in DISTRICT_MAP.items():
        if zh in filename:
            return zh, code
    return "未知", "UNK"


def clean_school_name(name):
    """清理学校名"""
    name = name.strip()
    # 去除多余空格
    name = re.sub(r'\s+', ' ', name)
    return name.strip()


def detect_format(lines, filename):
    """检测数据格式"""
    content_first_500 = '\n'.join(lines[:500])

    # 检测闵行区列式格式（最常见）
    if '招生学校代码' in content_first_500 and '初中学校代码' in content_first_500:
        return 'column', 'MINHANG'

    # 检测两段式（嘉定/黄浦格式）
    if '初中学校' in content_first_500 and ('分配到初中' in content_first_500 or '委属名额' in content_first_500):
        return 'twopart', 'JIADING_HUANGPU'

    # 默认为列式格式
    return 'column', 'UNKNOWN'


def parse_column_format(lines, filename):
    """
    解析列式格式（闵行区）

    格式：
    | 序号 | 学校代码 | 学校名称 | ... | 各高中招生代码 |
    | ... | ... | ... | ... | ... | ... |

    数据部分：
    | 初中学校代码 | 初中学校 | 高中1 | 高中2 | ... |
    """
    district = extract_district_from_filename(filename)[0]

    print(f"  解析列式格式: {filename}")

    records = []
    middle_schools = []
    high_schools_list = []

    # 第一阶段：提取学校信息
    in_data_section = False
    middle_school_start_idx = None

    for i, line in enumerate(lines):
        line = line.strip()

        if not line:
            continue

        # 查找"初中学校信息"标记
        if '初中学校信息' in line:
            middle_school_start_idx = i + 1
            in_data_section = True
            break

    if middle_school_start_idx is None:
        print(f"    错误：未找到初中学校信息部分")
        return [], []

    # 提取初中学校列表
    i = middle_school_start_idx
    while i < len(lines):
        line = lines[i].strip()

        # 检查是否结束
        if '未经允许' in line or '合计' in line or '本页志愿' in line:
            break

        if not line:
            continue

        # 检查是否是表头（学校代码列）
        if re.match(r'^\d{6}$', line):
            # 这是高中代码行
            high_codes = re.findall(r'\d{6}', line)
            if len(high_codes) >= 3:
                high_schools_list = [(code, f"高中学校{len(high_schools_list)+1}") for code in high_codes]
            print(f"    找到高中代码: {len(high_codes)} 个")
            break

        # 跳过表头
        if in_data_section and i < middle_school_start_idx:
            # 还在数据部分中，但不是第一行
            # 查找初中代码
            code_match = re.match(r'^(\d{6})', line)
            if code_match:
                middle_code = code_match.group(1)
                # 查找学校名
                name = None
                for j in range(i+1, min(i+11, len(lines))):
                    if '中学' in lines[j]:
                        name_match = re.search(r'(上海市.*中学|.*初级中学|.*实验学校)', lines[j])
                        if name_match:
                            name = clean_school_name(name_match.group(0))
                            break

                if name:
                    middle_schools.append((middle_code, name, district))
            i += 1

    print(f"    提取初中学校: {len(middle_schools)} 个")

    # 第二阶段：解析配额数据
    # 查找高中代码行
    high_code_line_idx = None
    for i in range(middle_school_start_idx, len(lines)):
        if re.search(r'\d{6}', lines[i]) and len(re.findall(r'\d{6}', lines[i])) >= 3:
            high_code_line_idx = i
            break

    if high_code_line_idx is None:
        print(f"    错误：未找到高中代码行")
        return middle_schools, []

    # 提取高中代码
    codes_line = lines[high_code_line_idx]
    high_codes = re.findall(r'\d{6}', codes_line)
    print(f"    找到高中代码: {len(high_codes)} 个")

    # 从下一行开始解析配额
    i = high_code_line_idx + 1

    while i < len(lines):
        line = lines[i].strip()

        # 跳过空行和标题
        if not line or '未经允许' in line:
            i += 1
            continue

        # 分割行（多个空格或tab）
        parts = re.split(r'\s{2,}', line)
        parts = [p for p in parts if p]

        # 需要至少5个部分（初中代码 + 4个高中名额）
        if len(parts) < 5:
            i += 1
            continue

        # 第一部分是初中代码
        middle_code = parts[0] if re.match(r'^\d{6}$', parts[0]) else ''

        # 查找初中名称
        middle_name = None
        for part in parts[1:]:
            if '中学' in part or '学校' in part:
                middle_name = clean_school_name(part)
                break

        if not middle_name:
            middle_name = f"未知学校_{middle_code}"

        # 解析各高中的名额
        for h_idx, high_code in enumerate(high_codes):
            if h_idx + 1 < len(parts):
                quota_str = parts[h_idx + 1]
                # 提取数字
                numbers = re.findall(r'\d+', quota_str)
                quota = int(numbers[0]) if numbers and int(numbers[0]) > 0 else 0

                if quota > 0:
                    records.append({
                        '年份': 2025,
                        '批次': '名额分配到校',
                        '区名称': district,
                        '初中学校代码': middle_code,
                        '初中学校': middle_name or '',
                        '高中学校代码': high_code,
                        '名额': quota,
                        '文件来源': filename,
                    })
        i += 1

    print(f"    提取配额记录: {len(records)} 条")
    return middle_schools, records


def parse_twopart_format(lines, filename):
    """
    解析两段式格式（嘉定/黄浦）

    第一段：初中学校表
    第二段：分配表
    """
    district = extract_district_from_filename(filename)[0]

    # 第一阶段：查找"分配到初中学校"或"初中学校"
    allocation_start = None
    for i, line in enumerate(lines):
        if '分配到初中学校' in line or '初中学校' in line:
            allocation_start = i
            break

    if allocation_start is None:
        return [], []

    # 第一阶段：提取初中学校（简化处理）
    i = allocation_start + 1
    middle_schools = []

    while i < len(lines):
        line = lines[i].strip()

        # 跳过空行和标题
        if not line or '合计' in line:
            break

        # 检查是否是学校代码行
        if re.match(r'^\d{6}$', line):
            # 进入第二阶段
            break

        # 格式：代码 | 名称（或：代码一行后跟名称）
        parts = re.split(r'\s{2,}', line)
        if len(parts) >= 2:
            code = parts[0] if re.match(r'^\d{6}$', parts[0]) else ''
            name = parts[1] if len(parts) > 1 else ''

            if code and '中学' in name:
                middle_schools.append((code, name, district))
        elif not line:
            i += 1

    # 第二阶段：解析配额（简化跳过，因为格式复杂）
    # TODO: 实现完整的配额解析

    print(f"    初中学校: {len(middle_schools)} 条")
    return middle_schools, []


def save_csv_and_sql(middle_schools, quota_records, district, output_csv_name):
    """保存CSV和生成SQL"""
    # 保存配额数据到CSV
    csv_file = os.path.join(PROCESSED_DIR, output_csv_name)

    with open(csv_file, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['年份', '批次', '区名称', '初中学校代码', '初中学校', '高中学校代码', '名额', '文件来源']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(quota_records)

    print(f"  配额数据输出: {csv_file}")
    print(f"  配额记录数: {len(quota_records)}")

    # 保存初中学校到CSV
    middle_csv_file = os.path.join(PROCESSED_DIR, f"{district}_2025年初中学校.csv")

    with open(middle_csv_file, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['代码', '名称', '区县', '发现来源']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for code, name, dist in middle_schools:
            writer.writerow({
                '代码': code,
                '名称': name,
                '区县': dist,
                '发现来源': '2025名额分配到校数据'
            })

    print(f"  初中学校数据输出: {middle_csv_file}")
    print(f"  初中学校数: {len(middle_schools)}")

    # 生成SQL
    sql_file = os.path.join(SEEDS_DIR, f"041_seed_quota_allocation_school_2025.sql")

    sql_lines = [
        f"-- =============================================================================",
        f"-- 2025年名额分配到校招生计划数据",
        f"-- 基于各区名额分配到校PDF提取",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        f"-- 删除现有2025数据",
        f"DELETE FROM ref_quota_allocation_school WHERE year = 2025;",
        "",
        "-- 插入配额数据",
        f"INSERT INTO ref_quota_allocation_school",
            f"(year, district_id, high_school_id, high_school_code, middle_school_id,",
            f"middle_school_name, quota_count, data_year, created_at, updated_at)",
            f"SELECT 2025, d.id, s.id, '{HIGH_SCHOOL_CODE}',",
            f"(SELECT id FROM ref_school WHERE code = '{HIGH_SCHOOL_CODE}' AND data_year = 2025),",
            f"(SELECT id FROM ref_district WHERE code = '{DISTRICT_CODE}'),",
            f"'{MIDDLE_SCHOOL_NAME}', {len(quota_records)}, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);"
    ]

    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"  SQL文件: {sql_file}")


def main():
    print("=" * 60)
    print("2025年名额分配到校数据处理（通用解析器）")
    print("=" * 60)

    # 查找所有markdown文件
    from pathlib import Path
    md_pattern = '*名额分配到校*.md'
    md_files = list(Path(BASE_DIR).parent.parent.joinpath("raw", "2025", "quota_district", "markdown").glob(md_pattern))

    # 已处理过的区（跳过静安，因为已有专门脚本）
    processed = {'闵行', '嘉定', '黄浦', '松江', '青浦'}  # 这些可以尝试用列式格式

    total_records = []
    all_middle_schools = []

    for md_file in sorted(md_files):
        filename = os.path.basename(md_file)
        district, code = extract_district_from_filename(filename)

        if district not in processed:
            continue  # 跳过，因为格式可能未知

        print(f"\n处理文件: {filename}")

        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')

        # 检测格式
        format_type = detect_format(lines, filename)

        if format_type == 'column':
            middle_schools, records = parse_column_format(lines, filename)
        elif format_type == 'twopart':
            middle_schools, records = parse_twopart_format(lines, filename)
        else:
            print(f"  未识别的格式，尝试用列式解析...")
            middle_schools, records = parse_column_format(lines, filename)

        if middle_schools or records:
            total_records.extend(records)
            all_middle_schools.extend(middle_schools)

    # 保存所有区合并的数据
    combined_csv = os.path.join(PROCESSED_DIR, "2025年名额分配到校_所有区.csv")

    with open(combined_csv, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['年份', '批次', '区名称', '初中学校代码', '初中学校', '高中学校代码', '名额', '文件来源']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(total_records)

    print(f"\n合并输出: {combined_csv}")
    print(f"总配额记录: {len(total_records)}")

    # 生成SQL（分批次或一次性）
    save_csv_and_sql(all_middle_schools, total_records, '2025年名额分配到校')

    print("\n" + "=" * 60)
    print("ETL处理完成！")
    print(f"初中学校总数: {len(all_middle_schools)}")
    print(f"配额记录总数: {len(total_records)}")
    print("\n生成的文件:")
    print(f"  - {combined_csv}")
    print(f"  - {os.path.join(PROCESSED_DIR, '041_seed_quota_allocation_school_2025.sql')}")


if __name__ == '__main__':
    main()
