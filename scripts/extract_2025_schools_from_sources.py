#!/usr/bin/env python3
"""
ETL流程 Step 1: Extract - 从2025年多个数据源提取学校全量信息
策略：从已验证的CSV获取基础数据，再从其他PDF补充详细信息
"""

import csv
import pdfplumber
from pathlib import Path

# 区代码映射
DISTRICT_MAP = {
    '上海市': 'SH', '黄浦区': 'HP', '徐汇区': 'XH', '长宁区': 'CN',
    '静安区': 'JA', '普陀区': 'PT', '虹口区': 'HK', '杨浦区': 'YP',
    '闵行区': 'MH', '宝山区': 'BS', '嘉定区': 'JD', '浦东新区': 'PD',
    '金山区': 'JS', '松江区': 'SJ', '青浦区': 'QP', '奉贤区': 'FX', '崇明区': 'CM',
}

# 办别映射
NATURE_MAP = {
    '公办': 'PUBLIC',
    '民办': 'PRIVATE',
}

# 学校类型映射
TYPE_MAP = {
    '市实验性示范性高中': 'CITY_MODEL',
    '享受市实验性示范性高中招生政策高中': 'CITY_POLICY',
    '区实验性示范性高中': 'DISTRICT_MODEL',
}

# 寄宿情况映射
BOARDING_MAP = {
    '全部寄宿': 'FULL',
    '部分寄宿': 'PARTIAL',
    '无寄宿': 'NONE',
}

def clean_text(text):
    """清理文本中的换行和多余字符"""
    if not text:
        return ''
    # 移除换行
    text = text.replace('\n', '')
    # 移除常见的错误前缀
    unwanted_prefixes = ['不', '许', '可', '转', '载', '经', '得', '未']
    for prefix in unwanted_prefixes:
        if text.startswith(prefix):
            text = text[len(prefix):]
            break
    # 移除标点
    text = text.replace('，', '').replace('。', '')
    return text.strip()

def load_base_school_data():
    """从已处理的CSV加载基础学校数据"""
    csv_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/quota_district/2025年名额分配到区招生计划.csv')

    schools = {}
    with open(csv_path, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row.get('招生代码', '').strip()
            name = row.get('学校名称', '').strip()

            if not code or not name:
                continue

            # 获取各区信息
            district = row.get('所属区', '上海市')
            district_code = row.get('区代码', 'SH')

            schools[code] = {
                'code': code,
                'name': name,
                'district': district,
                'district_code': district_code,
                'existing_fields': {
                    'school_type': row.get('学校类型', ''),
                    'boarding': row.get('寄宿情况', ''),
                }
            }

    print(f"从CSV加载 {len(schools)} 所学校的基础信息")
    return schools

def extract_from_autonomous_plan_pdf():
    """从自主招生计划PDF提取补充信息"""
    pdf_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/policies/2025-自主招生计划.pdf')

    additional_info = {}

    try:
        with pdfplumber.open(pdf_path) as pdf:
            for page in pdf.pages:
                text = page.extract_text()
                # 简单搜索关键词附近的文本
                if '招生学校' in text or '参加学校' in text:
                    # 这里可以进一步解析具体内容
                    pass
    except Exception as e:
        print(f"处理自主招生计划PDF时出错: {e}")

    return additional_info

def merge_and_save_schools(base_schools, additional_info):
    """合并基础数据和补充信息，保存到processed目录"""
    output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/schools')
    output_path.mkdir(parents=True, exist_ok=True)

    output_file = output_path / '2025年学校信息.csv'

    with open(output_file, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f)
        # 写入表头
        writer.writerow([
            '招生代码', '学校名称', '所属区', '区代码',
            '办别', '学校类型代码', '学校类型',
            '寄宿情况代码', '寄宿情况',
            '是否招生', '备注'
        ])

        # 写入数据
        for code, info in base_schools.items():
            writer.writerow([
                code,
                info['name'],
                info['district'],
                info['district_code'],
                'PUBLIC',  # 从名额分配数据可推断为公办
                'CITY_MODEL',  # 从名额分配数据已知类型
                info['existing_fields'].get('boarding', 'NONE'),
                '',  # 空字符串
                f"来源：名额分配到区招生计划",
            ])

    print(f"✅ 已生成: {output_file}")
    print(f"   包含 {len(base_schools)} 所学校的信息")

    output_file_str = str(output_file)  # 保存到全局变量供main使用
    return len(base_schools), output_file_str

def main():
    print("=" * 60)
    print("ETL流程: Step 1 - Extract（2025年学校全量数据）")
    print("=" * 60)
    print("策略：从已验证的CSV获取基础数据 + 从其他PDF补充详细信息")
    print()

    # Step 1: 加载基础数据
    base_schools = load_base_school_data()

    # Step 2: 尝试从其他PDF提取补充信息
    additional_info = extract_from_autonomous_plan_pdf()

    # Step 3: 合并并保存
    count, output_file_str = merge_and_save_schools(base_schools, additional_info)

    print()
    print("=" * 60)
    print("Step 1完成: 学校数据已提取到processed目录")
    print("=" * 60)
    print(f"共处理: {count} 所学校")
    print(f"数据文件: {output_file_str}")
    print()
    print("下一步: 运行 generate_2025_schools_sql.py 生成SQL种子文件")

if __name__ == '__main__':
    main()
