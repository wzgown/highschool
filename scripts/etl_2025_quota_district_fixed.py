#!/usr/bin/env python3
"""
ETL流程 Step 1: Extract - 从PDF提取2025年名额分配到区数据
遵循 ETL_PIPELINE_SOP.md 规范
"""

import csv
import pdfplumber
from pathlib import Path

# 区代码映射
DISTRICT_MAP = {
    '上海市': 'SH',
    '黄浦区': 'HP',
    '徐汇区': 'XH',
    '长宁区': 'CN',
    '静安区': 'JA',
    '普陀区': 'PT',
    '虹口区': 'HK',
    '杨浦区': 'YP',
    '闵行区': 'MH',
    '宝山区': 'BS',
    '嘉定区': 'JD',
    '浦东新区': 'PD',
    '金山区': 'JS',
    '松江区': 'SJ',
    '青浦区': 'QP',
    '奉贤区': 'FX',
    '崇明区': 'CM',
}

def clean_text(text):
    """清理文本中的换行符和多余字符"""
    if not text:
        return ''
    text = text.replace('\n', '')
    # 移除常见的错误前缀字符
    unwanted_prefixes = ['不', '许', '可', '转', '载', '经', '得', '未']
    for prefix in unwanted_prefixes:
        if text.startswith(prefix):
            text = text[len(prefix):]
            break
    # 移除多余的标点
    text = text.replace('，', '').replace('。', '')
    return text.strip()

def parse_row(row):
    """解析表格行，返回学校信息字典"""
    if len(row) < 9:
        return None

    # 清理所有单元格
    cleaned = [clean_text(str(cell)) if cell else '' for cell in row]

    seq_no = cleaned[0]
    code = cleaned[1]
    name = cleaned[2]
    district = cleaned[3]
    school_type = cleaned[5]
    lodging = cleaned[6]
    plan_area = cleaned[7]
    plan_count = cleaned[8]

    # 验证必要字段
    if not code or not name or not district:
        return None

    # 确保代码是数字
    if not code.isdigit():
        return None

    # 确保计划数是数字
    if not plan_count or not plan_count.isdigit():
        return None

    return {
        'seq_no': seq_no,
        'code': code,
        'name': name,
        'district': district,
        'district_code': DISTRICT_MAP.get(district, 'SH'),
        'school_type': school_type,
        'lodging': lodging,
        'plan_area': plan_area,
        'plan_count': int(plan_count),
    }

def extract_pdf_to_csv(pdf_path, csv_output_path):
    """从PDF提取数据到CSV (Extract步骤)"""
    print(f"正在提取: {pdf_path}")

    all_schools = []

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            tables = page.extract_tables()

            for table_num, table in enumerate(tables):
                print(f"第{page_num + 1}页表格{table_num + 1}")

                # 跳过标题行
                for row in table[1:]:
                    school = parse_row(row)
                    if school:
                        all_schools.append(school)

    print(f"总共提取到 {len(all_schools)} 条记录")

    # 去重（按代码+名称）
    unique_schools = {}
    for school in all_schools:
        key = f"{school['code']}_{school['name']}"
        if key not in unique_schools:
            unique_schools[key] = school

    print(f"去重后: {len(unique_schools)} 所学校")

    # 写入processed目录的CSV文件
    csv_output_path.mkdir(parents=True, exist_ok=True)
    output_file = csv_output_path / '2025年名额分配到区招生计划.csv'

    with open(output_file, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f)
        # 写入表头
        writer.writerow(['序号', '招生代码', '学校名称', '所属区', '区代码', '学校类型', '寄宿情况', '计划区域', '计划数'])

        # 写入数据
        for school in unique_schools.values():
            writer.writerow([
                school['seq_no'],
                school['code'],
                school['name'],
                school['district'],
                school['district_code'],
                school['school_type'],
                school['lodging'],
                school['plan_area'],
                school['plan_count'],
            ])

    print(f"✅ 已生成: {output_file}")
    print(f"   总计名额: {sum(s['plan_count'] for s in unique_schools.values())}")
    return len(unique_schools)

def main():
    # 输入：policies目录的PDF文件
    pdf_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/policies/2025-名额分配到区招生计划.pdf')

    # 输出：processed目录的CSV文件
    csv_output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/quota_district')

    print("=" * 60)
    print("ETL流程: Step 1 - Extract")
    print("=" * 60)
    print(f"输入: {pdf_path}")
    print(f"输出: {csv_output_path}")
    print()

    school_count = extract_pdf_to_csv(pdf_path, csv_output_path)

    print()
    print("=" * 60)
    print("Step 1完成: 数据已提取到processed目录")
    print("=" * 60)
    print(f"共处理: {school_count} 所学校")
    print()
    print("下一步: 运行 generate_2025_quota_district_sql.py 生成SQL文件")

if __name__ == '__main__':
    main()
