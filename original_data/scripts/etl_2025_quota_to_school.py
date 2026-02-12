#!/usr/bin/env python3
"""
ETL脚本：提取2025年名额分配到校数据

PDF格式说明：
- 第一行：高中学校代码（多个）
- 第二行：高中学校名称（多个）
- 后续行：每一行是一个初中，包含代码、名称、以及分配到各个高中的名额数

输出：processed/2025/quota_school/2025年名额分配到校.csv
"""

import csv
import os
import re
from pathlib import Path
import pdfplumber
from glob import glob

# ============================================================================
# 配置
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DIR = os.path.join(BASE_DIR, "raw", "2025", "quota_district")
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")

# 确保输出目录存在
Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)

# 区名到文件的映射（使用模式匹配）
DISTRICT_PATTERNS = {
    '静安': '*静安*到校*.pdf',
    '松江': '*松江*到校*.pdf',
    '闵行': '*闵行*到校*.pdf',
    '黄浦': '*黄浦*到校*.pdf',
    '崇明': '*崇明*到校*.mhtml',
    '虹口': '*虹口*到校*.mhtml',
}

# ============================================================================
# 工具函数
# ============================================================================

def find_quota_school_files():
    """使用模式匹配查找所有名额分配到校文件"""
    found_files = {}

    for district, pattern in DISTRICT_PATTERNS.items():
        full_pattern = os.path.join(RAW_DIR, pattern)
        matches = glob(full_pattern)
        if matches:
            found_files[district] = matches[0]  # 取第一个匹配
        else:
            print(f"  未找到: {district} ({pattern})")

    return found_files


def extract_district_from_filename(filename):
    """从文件名提取区名"""
    district_patterns = [
        r'（(.*?)区',
        r'(黄浦|徐汇|长宁|静安|普陀|虹口|杨浦|闵行|宝山|嘉定|浦东|金山|松江|青浦|奉贤|崇明)',
    ]
    for pattern in district_patterns:
        match = re.search(pattern, filename)
        if match:
            return match.group(1)
    return "未知"


def parse_quota_school_pdf(pdf_path):
    """
    解析名额分配到校PDF

    PDF结构：
    - 第1-3行：高中代码和名称（可能跨多行）
    - 后续行：初中信息 + 各高中名额
    """
    filename = os.path.basename(pdf_path)
    print(f"  解析: {filename}")

    try:
        pdf = pdfplumber.open(pdf_path)
        district = extract_district_from_filename(pdf_path)

        # 收集所有页面文本
        all_lines = []
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                # 分割成行
                lines = text.split('\n')
                # 过滤空行和过短的行
                for line in lines:
                    line = line.strip()
                    if line and len(line) > 3:
                        all_lines.append(line)
        pdf.close()

        # 查找高中代码行（连续的6位代码）
        high_codes = []
        for i, line in enumerate(all_lines):
            # 匹配多个6位代码（至少3个）
            codes = re.findall(r'\b\d{6}\b', line)
            if len(codes) >= 3:
                high_codes = codes
                print(f"    找到 {len(high_codes)} 个高中代码 (行 {i})")
                break

        if not high_codes:
            print(f"    警告: 未找到高中代码行")
            return []

        # 查找初中数据行（以6位数字开头，后面有学校名和数字）
        records = []
        for i, line in enumerate(all_lines):
            # 跳过明显的高中名称行
            if any(name in line for name in ['附属', '交大', '华东师', '复旦', '上海中学']):
                # 检查是否同时有代码，如果有则是数据行
                if not re.match(r'^\d{6}', line):
                    continue

            # 匹配初中数据行：代码 + 学校名 + 名额数字
            # 格式: 171001 上海市松江区第七中学 15 14 15 6 1 51
            match = re.match(r'^(\d{6})\s+(.{2,}?)(?:中学|初级|学校).*?(\d.*)$', line)
            if match:
                middle_code = match.group(1)
                middle_name_part = match.group(2)
                quotas_str = match.group(3)

                # 完整的初中名称
                # 在原始行中查找完整学校名（包含"中学"）
                full_name_match = re.search(r'(\S.*?中学|\S.*?初级中学|\S.*?实验学校)', line)
                if full_name_match:
                    middle_name = full_name_match.group(1)
                else:
                    middle_name = middle_name_part

                # 清理OCR错误
                middle_name = clean_school_name(middle_name)

                # 解析所有数字（名额）
                quotas = re.findall(r'\d+', quotas_str)

                # 为每个高中创建记录
                for j, quota in enumerate(quotas):
                    if j < len(high_codes):
                        high_code = high_codes[j]
                        try:
                            quota_num = int(quota)
                        except:
                            continue

                        if quota_num > 0:
                            records.append({
                                '年份': 2025,
                                '批次': '名额分配到校',
                                '区名称': district,
                                '初中学校代码': middle_code,
                                '初中学校': middle_name,
                                '高中学校代码': high_code,
                                '名额': quota_num,
                                '文件来源': filename,
                            })

        print(f"    提取 {len(records)} 条记录")
        return records

    except Exception as e:
        print(f"    错误: {e}")
        import traceback
        traceback.print_exc()
        return []


def clean_school_name(name):
    """清理学校名中的OCR错误"""
    name = name.strip()

    # 去除"院"前缀
    if name.startswith('院'):
        name = name[1:].strip()

    # 去除"院"后缀
    if name.endswith('院') and not name.endswith('学院'):
        name = name[:-1].strip()

    # 清理多余空格
    name = re.sub(r'\s+', '', name)

    return name


# ============================================================================
# 主函数
# ============================================================================

def main():
    print("=" * 60)
    print("2025年名额分配到校数据提取")
    print("=" * 60)

    all_records = []
    districts_processed = []

    # 查找文件
    files_map = find_quota_school_files()
    print(f"\n找到 {len(files_map)} 个区的文件")

    # 处理 PDF 文件
    for district, pdf_path in files_map.items():
        if not os.path.exists(pdf_path):
            print(f"  跳过（文件不存在）: {pdf_path}")
            continue

        # 暂时跳过 mhtml 文件
        if pdf_path.endswith('.mhtml'):
            print(f"  跳过（mhtml暂不支持）: {os.path.basename(pdf_path)}")
            districts_processed.append(district)
            continue

        try:
            records = parse_quota_school_pdf(pdf_path)
            all_records.extend(records)
            if records:
                districts_processed.append(district)
        except Exception as e:
            print(f"  错误: {e}")

    # 保存到 CSV
    if all_records:
        output_file = os.path.join(PROCESSED_DIR, "2025年名额分配到校.csv")
        with open(output_file, 'w', encoding='utf-8', newline='') as f:
            fieldnames = ['年份', '批次', '区名称', '初中学校代码', '初中学校',
                        '高中学校代码', '名额', '文件来源']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(all_records)

        print(f"\n{'=' * 60}")
        print(f"输出: {output_file}")
        print(f"总记录数: {len(all_records)}")
        print(f"处理区县: {', '.join(districts_processed)}")

        # 统计每个区的记录数
        from collections import Counter
        district_counts = Counter(r['区名称'] for r in all_records)
        print(f"\n各区记录数:")
        for district, count in sorted(district_counts.items()):
            print(f"  {district}: {count}")
    else:
        print("\n没有提取到任何数据")


if __name__ == '__main__':
    main()
