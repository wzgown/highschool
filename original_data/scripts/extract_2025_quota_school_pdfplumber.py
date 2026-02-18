#!/usr/bin/env python3
"""
ETL脚本：使用pdfplumber提取2025年名额分配到校数据

支持多种格式：
1. 闵行区格式 - 横向表格，高中代码在表头第二行
2. 宝山区格式 - 横向表格，没有代码行
3. 浦东新区格式 - 横向表格
4. 长宁区格式 - 横向表格，代码在括号内
5. 杨浦区格式 - 横向表格
6. 青浦区格式 - 竖向表格（代码|名称|初中代码|初中名称|计划数）
7. 松江区格式 - 横向表格，两行表头

输出CSV格式：
year,district,district_code,middle_school_name,high_school_code,high_school_name,quota_count,source
"""

import csv
import os
import re
from pathlib import Path
from datetime import datetime

try:
    import pdfplumber
except ImportError:
    print("请先安装pdfplumber: pip install pdfplumber")
    exit(1)

# ============================================================================
# 配置
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DIR = os.path.join(BASE_DIR, "raw", "2025", "quota_district")
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")

Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)

# 文件名中的英文关键词 -> (中文名, 代码)
FILENAME_TO_DISTRICT = {
    'baoshan': ('宝山区', 'BS'),
    'changning': ('长宁区', 'CN'),
    'fengxian': ('奉贤区', 'FX'),
    'huangpu': ('黄浦区', 'HP'),
    'hongkou': ('虹口区', 'HK'),
    'jiading': ('嘉定区', 'JD'),
    'jingan': ('静安区', 'JA'),
    'jinshan': ('金山区', 'JS'),
    'minhang': ('闵行区', 'MH'),
    'pudong': ('浦东新区', 'PD'),
    'putuo': ('普陀区', 'PT'),
    'qingpu': ('青浦区', 'QP'),
    'songjiang': ('松江区', 'SJ'),
    'xuhui': ('徐汇区', 'XH'),
    'yangpu': ('杨浦区', 'YP'),
    'chongming': ('崇明区', 'CM'),
}

# 已知高中代码到名称映射
KNOWN_HIGH_SCHOOLS = {
    '042032': '上海市上海中学',
    '102056': '上海交通大学附属中学',
    '102057': '复旦大学附属中学',
    '152003': '华东师范大学第二附属中学',
    '152006': '上海师范大学附属中学',
    '012001': '上海市格致中学',
    '012002': '上海市格致中学（奉贤校区）',
    '012003': '上海市大同中学',
    '012005': '上海市向明中学',
    '012006': '上海市向明中学（浦江校区）',
    '012007': '上海外国语大学附属大境中学',
    '012008': '上海市光明中学',
    '012009': '上海市敬业中学',
    '012010': '上海市卢湾高级中学',
    '052001': '上海市第三女子中学',
    '052002': '上海市延安中学',
    '053004': '上海市复旦中学',
    '062001': '上海市市西中学',
    '062002': '上海市育才中学',
    '062003': '上海市新中高级中学',
    '062004': '上海市市北中学',
    '062011': '上海市回民中学',
    '063004': '上海市第六十中学',
    '064001': '上海市华东模范中学',
    '072001': '上海市晋元高级中学',
    '072002': '上海市曹杨第二中学',
    '073003': '上海市宜川中学',
    '073082': '华东师范大学第二附属中学（普陀校区）',
    '092001': '复旦大学附属复兴中学',
    '092002': '华东师范大学第一附属中学',
    '093001': '上海财经大学附属北郊高级中学',
    '102004': '上海市杨浦高级中学',
    '102032': '上海市控江中学',
    '103002': '同济大学第一附属中学',
    '122001': '上海市七宝中学',
    '123001': '上海市闵行中学',
    '122002': '华东师范大学第二附属中学闵行紫竹分校',
    '122003': '上海师范大学附属中学闵行分校',
    '122004': '上海交通大学附属中学闵行分校',
    '132001': '上海市行知中学',
    '132002': '上海大学附属中学',
    '133001': '上海市吴淞中学',
    '132003': '上海师范大学附属中学宝山分校',
    '133002': '上海师范大学附属中学宝山罗店中学',
    '133003': '华东师范大学第二附属中学（宝山校区）',
    '142001': '上海市嘉定区第一中学',
    '142002': '上海交通大学附属中学嘉定分校',
    '142004': '上海师范大学附属中学嘉定新城分校',
    '152001': '上海市建平中学',
    '152002': '上海市进才中学',
    '152004': '上海南汇中学',
    '153001': '上海市洋泾中学',
    '153004': '上海市高桥中学',
    '153005': '上海市川沙中学',
    '151078': '上海中学东校',
    '152005': '上海市浦东复旦附中分校',
    '162000': '上海市金山中学',
    '163002': '华东师范大学第三附属中学',
    '172001': '上海市松江二中',
    '173001': '上海市松江一中',
    '172002': '华东师范大学第二附属中学松江分校',
    '172004': '上海师范大学附属中学松江分校',
    '174003': '上海外国语大学附属外国语学校松江云间中学',
    '182001': '上海市青浦高级中学',
    '182002': '复旦大学附属中学青浦分校',
    '183002': '上海市朱家角中学',
    '202001': '上海市奉贤中学',
    '202002': '华东师范大学第二附属中学临港奉贤分校',
    '512000': '上海市崇明中学',
    '042002': '上海市第二中学（梅陇校区）',
    # 委属高中
    '151078': '上海市实验学校',
}

# 各区高中代码列表（按表格顺序）
DISTRICT_HIGH_SCHOOLS = {
    '闵行区': ['122001', '123001', '122002', '122003', '122004', '012006', '042002', '042032', '102056', '102057', '152003', '152006'],
    '宝山区': ['132001', '133001', '132002', '133003', '132003', '042032', '152003', '102057', '102056'],
    '浦东新区': ['042032', '152003', '102057', '102056', '152006', '151078', '152001', '152002', '153001', '153005', '152004', '153004', '152005', '151078', '202002'],
    '长宁区': ['052002', '053004', '052001', '042032', '102057', '102056', '152003', '152006'],
    '杨浦区': ['102032', '102004', '103002', '102056', '102057', '152003', '042032'],
    '松江区': ['172001', '173001', '174003', '172002', '172004', '042032', '102056', '102057', '152003', '152006'],
    '青浦区': ['182001', '183002', '182002', '042032', '102056', '102057', '152003', '152006'],
    '静安区': ['062001', '062002', '062003', '062004', '062011', '063004', '064001', '042032', '102056', '102057', '152003', '152006'],
    '黄浦区': ['012001', '012003', '012005', '012007', '012008', '012009', '012010', '042032', '102056', '102057', '152003', '152006'],
    '虹口区': ['092001', '092002', '093001', '042032', '102056', '102057', '152003', '152006'],
    '奉贤区': ['202001', '202002', '012002', '042032', '102056', '102057', '152003', '152006'],
}


def clean_text(text):
    """清理文本，去除换行和多余空格"""
    if not text:
        return ""
    return str(text).replace('\n', '').replace('\r', '').strip()


def extract_code_from_text(text):
    """从文本中提取6位数字代码"""
    if not text:
        return None
    text = clean_text(text)
    match = re.search(r'(\d{6})', text)
    if match:
        return match.group(1)
    return None


def is_quota_number(value):
    """检查是否是有效的名额数字"""
    if value is None:
        return False
    try:
        num = int(str(value).strip())
        return 0 <= num <= 500
    except (ValueError, TypeError):
        return False


def extract_district_from_filename(filename):
    """从文件名提取区名和代码"""
    filename_lower = filename.lower()
    for key, (zh_name, code) in FILENAME_TO_DISTRICT.items():
        if key in filename_lower:
            return zh_name, code
    return "未知区", "UNK"


def extract_minhang_format(pdf_path, district, district_code):
    """
    闵行区格式：横向表格
    行0: 高中名称
    行1: 高中代码（格式如"招生代码\n122001"）
    行2+: 初中代码 | 初中名称 | 名额1 | 名额2 | ...
    """
    records = []
    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

    print(f"  解析闵行区格式")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 3:
                    continue

                # 从第二行提取高中代码
                if len(table) > 1:
                    extracted_codes = []
                    row1 = table[1]
                    for cell in row1[2:]:
                        code = extract_code_from_text(cell)
                        if code:
                            extracted_codes.append(code)
                    if extracted_codes:
                        high_codes = extracted_codes

                if not high_codes:
                    continue

                # 从第三行开始解析数据
                for row_idx in range(2, len(table)):
                    row = table[row_idx]
                    if not row or len(row) < 3:
                        continue

                    middle_name = clean_text(row[1]) if len(row) > 1 else ""
                    if not middle_name or '中学' not in middle_name:
                        continue
                    if '合计' in middle_name or '初中学校' in middle_name:
                        continue

                    for col_idx, high_code in enumerate(high_codes):
                        data_col = col_idx + 2
                        if data_col < len(row) and is_quota_number(row[data_col]):
                            quota = int(str(row[data_col]).strip())
                            if quota > 0:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                records.append({
                                    'year': 2025, 'district': district, 'district_code': district_code,
                                    'middle_school_name': middle_name, 'high_school_code': high_code,
                                    'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_baoshan_format(pdf_path, district, district_code):
    """
    宝山区格式：横向表格（没有代码行）
    行0: 序号 | 学校代码 | 学校名称 | 高中1 | 高中2 | ...
    行1+: 1 | 131002 | 上海市淞谊中学 | 8 | 8 | ...
    """
    records = []
    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

    print(f"  解析宝山区格式")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 2:
                    continue

                for row in table[1:]:  # 跳过表头
                    if not row or len(row) < 4:
                        continue

                    middle_name = clean_text(row[2]) if len(row) > 2 else ""
                    if not middle_name or '中学' not in middle_name:
                        continue
                    if '合计' in middle_name:
                        continue

                    for col_idx, high_code in enumerate(high_codes):
                        data_col = col_idx + 3  # 数据从第4列开始
                        if data_col < len(row) and is_quota_number(row[data_col]):
                            quota = int(str(row[data_col]).strip())
                            if quota > 0:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                records.append({
                                    'year': 2025, 'district': district, 'district_code': district_code,
                                    'middle_school_name': middle_name, 'high_school_code': high_code,
                                    'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_huangpu_format(pdf_path, district, district_code):
    """
    黄浦区格式：横向表格
    行0: 学校代码名称 | 格致 (012001) | 格致奉贤 (012002) | ...
    行1+: 011001 格致初级中学 | 21 | 8 | ...

    特点：初中代码和名称合在一起，高中代码在括号内
    """
    records = []

    print(f"  解析黄浦区格式")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 2:
                    continue

                # 从表头提取高中代码
                high_codes = []
                if table[0]:
                    for cell in table[0][1:]:  # 跳过第一列
                        code = extract_code_from_text(cell)
                        if code:
                            high_codes.append(code)

                if not high_codes:
                    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

                # 解析所有行（包括第一行，因为可能包含数据）
                for row in table:
                    if not row or len(row) < 2:
                        continue

                    # 第一列是初中代码+名称
                    first_cell = clean_text(row[0]) if row[0] else ""

                    # 提取初中名称（跳过代码和乱码前缀）
                    middle_name = re.sub(r'^\d{6}\s*', '', first_cell)  # 去除开头的6位代码
                    middle_name = re.sub(r'^未\s*', '', middle_name)  # 去除"未"
                    middle_name = re.sub(r'^经\s*', '', middle_name)  # 去除"经"
                    middle_name = re.sub(r'^许\s*', '', middle_name)  # 去除"许"
                    middle_name = re.sub(r'^得\s*', '', middle_name)  # 去除"得"
                    middle_name = re.sub(r'^，\s*', '', middle_name)  # 去除"，"
                    middle_name = re.sub(r'^允\s*', '', middle_name)  # 去除"允"
                    middle_name = re.sub(r'^不\s*', '', middle_name)  # 去除"不"
                    middle_name = re.sub(r'^转\s*', '', middle_name)  # 去除"转"
                    middle_name = re.sub(r'^载\s*', '', middle_name)  # 去除"载"
                    middle_name = clean_text(middle_name)

                    if not middle_name or '中学' not in middle_name:
                        continue
                    if '合计' in middle_name or '招生学校' in middle_name:
                        continue

                    for col_idx, high_code in enumerate(high_codes):
                        data_col = col_idx + 1  # 数据从第2列开始
                        if data_col < len(row):
                            cell_value = clean_text(row[data_col])
                            # 去除可能的乱码前缀
                            cell_value = re.sub(r'^(未|经|许|得|，|允|不|转|载)\s*', '', cell_value)
                            if is_quota_number(cell_value):
                                quota = int(str(cell_value).strip())
                                if quota > 0:
                                    high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                    records.append({
                                        'year': 2025, 'district': district, 'district_code': district_code,
                                        'middle_school_name': middle_name, 'high_school_code': high_code,
                                        'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                    })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_jingan_format(pdf_path, district, district_code):
    """
    静安区格式：横向表格（两行表头）
    行0: 招生学校 初中毕业学校 | | 062001 | 062002 | ...
    行1: | | 上海市市西中学 | 上海市育才中学 | ...
    行2+: 061001 | 上海市市西初级中学 | 10 | 9 | ...
    """
    records = []

    print(f"  解析静安区格式")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 3:
                    continue

                # 从第一行提取高中代码
                high_codes = []
                if table[0]:
                    for cell in table[0][2:]:  # 跳过前两列
                        code = extract_code_from_text(cell)
                        if code:
                            high_codes.append(code)

                if not high_codes:
                    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

                # 从第三行开始解析数据
                for row in table[2:]:
                    if not row or len(row) < 3:
                        continue

                    middle_name = clean_text(row[1]) if len(row) > 1 else ""
                    if not middle_name or '中学' not in middle_name:
                        continue
                    if '合计' in middle_name:
                        continue

                    for col_idx, high_code in enumerate(high_codes):
                        data_col = col_idx + 2  # 数据从第3列开始
                        if data_col < len(row) and is_quota_number(row[data_col]):
                            quota = int(str(row[data_col]).strip())
                            if quota > 0:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                records.append({
                                    'year': 2025, 'district': district, 'district_code': district_code,
                                    'middle_school_name': middle_name, 'high_school_code': high_code,
                                    'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_changning_format(pdf_path, district, district_code):
    """
    长宁区格式：横向表格（代码在表头括号内）
    行0: 序号 | 招生学校简称、代码 初中学校 | 延安中学 (052002) | ...
    行1+: 1 | 上海市第三女子初级中学 | 10 | ...
    """
    records = []
    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

    print(f"  解析长宁区格式")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 2:
                    continue

                # 从表头提取高中代码
                if table[0]:
                    extracted_codes = []
                    for cell in table[0][2:]:
                        code = extract_code_from_text(cell)
                        if code:
                            extracted_codes.append(code)
                    if extracted_codes:
                        high_codes = extracted_codes

                for row in table[1:]:  # 跳过表头
                    if not row or len(row) < 3:
                        continue

                    middle_name = clean_text(row[1]) if len(row) > 1 else ""
                    if not middle_name or '中学' not in middle_name:
                        continue
                    if '合计' in middle_name:
                        continue

                    for col_idx, high_code in enumerate(high_codes):
                        data_col = col_idx + 2
                        if data_col < len(row) and is_quota_number(row[data_col]):
                            quota = int(str(row[data_col]).strip())
                            if quota > 0:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                records.append({
                                    'year': 2025, 'district': district, 'district_code': district_code,
                                    'middle_school_name': middle_name, 'high_school_code': high_code,
                                    'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_pudong_format(pdf_path, district, district_code):
    """
    浦东新区格式：横向表格
    行0: 序号 | 初中学校名称 | 高中1 | 高中2 | ...
    行1+: 1 | 上海市建平中学西校 | 0 | 1 | ...
    """
    records = []
    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

    print(f"  解析浦东新区格式")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 2:
                    continue

                for row in table[1:]:  # 跳过表头
                    if not row or len(row) < 3:
                        continue

                    middle_name = clean_text(row[1]) if len(row) > 1 else ""
                    # 去除可能的乱码前缀
                    middle_name = re.sub(r'^[^\u4e00-\u9fa5]+', '', middle_name)
                    if not middle_name or '中学' not in middle_name:
                        continue
                    if '合计' in middle_name:
                        continue

                    for col_idx, high_code in enumerate(high_codes):
                        data_col = col_idx + 2
                        if data_col < len(row) and is_quota_number(row[data_col]):
                            quota = int(str(row[data_col]).strip())
                            if quota > 0:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                records.append({
                                    'year': 2025, 'district': district, 'district_code': district_code,
                                    'middle_school_name': middle_name, 'high_school_code': high_code,
                                    'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_qingpu_format(pdf_path, district, district_code):
    """
    青浦区格式：竖向表格（合并单元格）
    每行: 招生学校代码 | 招生学校名称 | 初中学校代码 | 初中学校名称 | 计划数

    注意：高中代码和名称可能在前一行中（合并单元格时为空）
    """
    records = []

    print(f"  解析青浦区格式（竖向表格）")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 2:
                    continue

                # 当前高中代码和名称（用于合并单元格）
                current_high_code = None
                current_high_name = ""

                for row in table[1:]:  # 跳过表头
                    if not row or len(row) < 5:
                        continue

                    # 提取高中代码和名称
                    high_code_cell = clean_text(row[0]) if len(row) > 0 else ""
                    high_name_cell = clean_text(row[1]) if len(row) > 1 else ""

                    # 如果高中代码不为空，更新当前高中
                    if high_code_cell:
                        code = extract_code_from_text(high_code_cell)
                        if code:
                            current_high_code = code
                            current_high_name = high_name_cell

                    middle_name = clean_text(row[3]) if len(row) > 3 else ""
                    quota_value = row[4] if len(row) > 4 else None

                    if not current_high_code or not middle_name:
                        continue

                    if '中学' not in middle_name:
                        continue

                    if is_quota_number(quota_value):
                        quota = int(str(quota_value).strip())
                        if quota > 0:
                            if not current_high_name:
                                current_high_name = KNOWN_HIGH_SCHOOLS.get(current_high_code, f"高中{current_high_code}")
                            records.append({
                                'year': 2025, 'district': district, 'district_code': district_code,
                                'middle_school_name': middle_name, 'high_school_code': current_high_code,
                                'high_school_name': current_high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                            })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_songjiang_format(pdf_path, district, district_code):
    """
    松江区格式：横向表格（两行表头）
    行0: 学校代码 | 学校 | 委属名额 | 区属名额数 | ... | ...
    行1: | | | 松江二中 | 松江一中 | ...
    行2+: 171001 | 上海市松江区第七中学 | | 15 | 14 | ...
    """
    records = []
    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

    print(f"  解析松江区格式")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 3:
                    continue

                # 松江区格式：第三行开始是数据
                for row in table[2:]:
                    if not row or len(row) < 4:
                        continue

                    middle_name = clean_text(row[1]) if len(row) > 1 else ""
                    if not middle_name or '中学' not in middle_name:
                        continue
                    if '合计' in middle_name:
                        continue

                    # 松江区名额从第4列开始（跳过学校代码、学校名称、委属名额）
                    for col_idx, high_code in enumerate(high_codes):
                        data_col = col_idx + 3  # 区属名额从第4列开始
                        if data_col < len(row) and is_quota_number(row[data_col]):
                            quota = int(str(row[data_col]).strip())
                            if quota > 0:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                records.append({
                                    'year': 2025, 'district': district, 'district_code': district_code,
                                    'middle_school_name': middle_name, 'high_school_code': high_code,
                                    'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_fengxian_format(pdf_path, district, district_code):
    """
    奉贤区格式：竖向表格（合并单元格）
    每行: 序号 | 初中学校代码 | 初中学校名称 | 招生学校代码 | 学校名称 | 所属区 | 计划数

    注意：初中代码和名称可能在前一行中（合并单元格时为空）
    """
    records = []

    print(f"  解析奉贤区格式（竖向表格）")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 2:
                    continue

                # 当前初中代码和名称（用于合并单元格）
                current_middle_code = None
                current_middle_name = ""

                for row in table:
                    if not row or len(row) < 7:
                        continue

                    # 跳过表头
                    if row[0] and '序号' in str(row[0]):
                        continue

                    # 提取初中代码和名称
                    middle_code_cell = clean_text(row[1]) if len(row) > 1 else ""
                    middle_name_cell = clean_text(row[2]) if len(row) > 2 else ""

                    # 如果初中代码不为空，更新当前初中
                    if middle_code_cell:
                        current_middle_code = middle_code_cell
                        current_middle_name = middle_name_cell

                    # 提取高中代码和名称
                    high_code = extract_code_from_text(row[3]) if len(row) > 3 else None
                    high_name = clean_text(row[4]) if len(row) > 4 else ""
                    quota_value = row[6] if len(row) > 6 else None

                    if not current_middle_name or not high_code:
                        continue

                    if '中学' not in current_middle_name:
                        continue

                    if is_quota_number(quota_value):
                        quota = int(str(quota_value).strip())
                        if quota > 0:
                            if not high_name:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                            records.append({
                                'year': 2025, 'district': district, 'district_code': district_code,
                                'middle_school_name': current_middle_name, 'high_school_code': high_code,
                                'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                            })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_chongming_from_markdown(district, district_code):
    """
    从markdown文件提取崇明区数据
    """
    records = []

    print(f"  从markdown文件解析崇明区数据")

    md_path = os.path.join(RAW_DIR, "markdown", "2025_quota_to_school_chongming.md")

    if not os.path.exists(md_path):
        print(f"    未找到markdown文件: {md_path}")
        return records

    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 解析表格
    lines = content.split('\n')

    # 高中代码列表（从表头提取）
    high_codes = ['512000', '512001', '042032', '152003', '102057', '102056']

    for line in lines:
        # 跳过空行和分隔线
        if not line.strip() or line.strip().startswith('|--') or line.strip().startswith('| 序号'):
            continue

        # 解析表格行
        if line.startswith('|'):
            cells = [c.strip() for c in line.split('|')]
            cells = [c for c in cells if c]  # 去除空单元格

            if len(cells) < 4:
                continue

            # 跳过表头
            if '学校代码' in cells[1] or '学校名称' in cells[2]:
                continue

            # 跳过合计行
            if '合计' in line:
                continue

            middle_name = cells[2] if len(cells) > 2 else ""

            if not middle_name or '中学' not in middle_name:
                continue

            # 提取名额（从第4列开始）
            for col_idx, high_code in enumerate(high_codes):
                data_col = col_idx + 3
                if data_col < len(cells):
                    value = cells[data_col]
                    # 跳过"多"等非数字
                    if value and value.isdigit():
                        quota = int(value)
                        if quota > 0:
                            high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                            records.append({
                                'year': 2025, 'district': district, 'district_code': district_code,
                                'middle_school_name': middle_name, 'high_school_code': high_code,
                                'high_school_name': high_name, 'quota_count': quota, 'source': 'markdown'
                            })

    print(f"    提取 {len(records)} 条记录")
    return records


def extract_generic_horizontal(pdf_path, district, district_code):
    """
    通用横向表格解析器
    """
    records = []
    high_codes = DISTRICT_HIGH_SCHOOLS.get(district, [])

    print(f"  使用通用横向格式解析")

    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, 1):
            tables = page.extract_tables()
            for table in tables:
                if not table or len(table) < 2:
                    continue

                for row in table[1:]:  # 跳过可能的表头
                    if not row or len(row) < 3:
                        continue

                    # 查找初中名称
                    middle_name = None
                    name_col = 0
                    for i, cell in enumerate(row):
                        cell_text = clean_text(cell)
                        if cell_text and ('中学' in cell_text or '学校' in cell_text):
                            if '合计' not in cell_text and '初中学校' not in cell_text:
                                middle_name = cell_text
                                name_col = i
                                break

                    if not middle_name:
                        continue

                    # 提取后续的数字作为名额
                    for col_idx, high_code in enumerate(high_codes):
                        data_col = name_col + 1 + col_idx
                        if data_col < len(row) and is_quota_number(row[data_col]):
                            quota = int(str(row[data_col]).strip())
                            if quota > 0:
                                high_name = KNOWN_HIGH_SCHOOLS.get(high_code, f"高中{high_code}")
                                records.append({
                                    'year': 2025, 'district': district, 'district_code': district_code,
                                    'middle_school_name': middle_name, 'high_school_code': high_code,
                                    'high_school_name': high_name, 'quota_count': quota, 'source': f'page_{page_num}'
                                })

    print(f"    提取 {len(records)} 条记录")
    return records


def save_to_csv(records, district, district_code):
    """保存数据到CSV文件"""
    if not records:
        print(f"  警告：{district}没有提取到任何记录")
        return None

    output_file = os.path.join(PROCESSED_DIR, f"{district}_2025_名额分配到校.csv")

    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['year', 'district', 'district_code', 'middle_school_name',
                      'high_school_code', 'high_school_name', 'quota_count', 'source']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)

    print(f"  输出文件: {output_file}")
    return output_file


def process_district(pdf_path):
    """处理单个区的PDF文件"""
    district, district_code = extract_district_from_filename(pdf_path)

    print(f"\n处理区: {district} ({district_code})")
    print(f"  文件: {os.path.basename(pdf_path)}")

    # 根据区选择解析器
    if district == '闵行区':
        records = extract_minhang_format(pdf_path, district, district_code)
    elif district == '宝山区':
        records = extract_baoshan_format(pdf_path, district, district_code)
    elif district == '长宁区':
        records = extract_changning_format(pdf_path, district, district_code)
    elif district == '浦东新区':
        records = extract_pudong_format(pdf_path, district, district_code)
    elif district == '杨浦区':
        records = extract_minhang_format(pdf_path, district, district_code)  # 杨浦和闵行格式类似
    elif district == '松江区':
        records = extract_songjiang_format(pdf_path, district, district_code)
    elif district == '青浦区':
        records = extract_qingpu_format(pdf_path, district, district_code)
    elif district == '黄浦区':
        records = extract_huangpu_format(pdf_path, district, district_code)
    elif district == '静安区':
        records = extract_jingan_format(pdf_path, district, district_code)
    elif district == '奉贤区':
        records = extract_fengxian_format(pdf_path, district, district_code)
    elif district == '虹口区':
        records = extract_baoshan_format(pdf_path, district, district_code)  # 类似宝山格式
    elif district == '崇明区':
        records = extract_chongming_from_markdown(district, district_code)  # 从markdown提取
    else:
        records = extract_generic_horizontal(pdf_path, district, district_code)

    # 保存结果
    output_file = save_to_csv(records, district, district_code)

    return {
        'district': district,
        'district_code': district_code,
        'record_count': len(records),
        'output_file': output_file
    }


def main():
    print("=" * 70)
    print("2025年名额分配到校数据提取 (pdfplumber)")
    print(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)

    # 查找所有名额分配到校的PDF文件
    pdf_files = []
    for filename in os.listdir(RAW_DIR):
        if filename.endswith('.pdf') and 'quota_to_school' in filename:
            pdf_files.append(os.path.join(RAW_DIR, filename))

    # 跳过已处理的区（嘉定区）
    skip_keywords = ['jiading']

    pdf_files = sorted(pdf_files)
    print(f"\n找到 {len(pdf_files)} 个PDF文件")

    results = []

    for pdf_path in pdf_files:
        # 跳过已处理的区
        skip = False
        for keyword in skip_keywords:
            if keyword.lower() in pdf_path.lower():
                skip = True
                break

        if skip:
            district, _ = extract_district_from_filename(pdf_path)
            print(f"\n跳过已处理: {district}")
            continue

        try:
            result = process_district(pdf_path)
            results.append(result)
        except Exception as e:
            print(f"  错误: {e}")
            import traceback
            traceback.print_exc()

    # 汇总结果
    print("\n" + "=" * 70)
    print("处理结果汇总")
    print("=" * 70)

    total_records = 0
    for result in results:
        print(f"{result['district']}: {result['record_count']} 条记录")
        total_records += result['record_count']

    # 处理崇明区（从markdown文件）
    print("\n处理崇明区（从markdown文件）:")
    chongming_records = extract_chongming_from_markdown('崇明区', 'CM')
    if chongming_records:
        output_file = save_to_csv(chongming_records, '崇明区', 'CM')
        print(f"崇明区: {len(chongming_records)} 条记录")
        total_records += len(chongming_records)

    print(f"\n总记录数: {total_records}")
    print(f"输出目录: {PROCESSED_DIR}")


if __name__ == '__main__':
    main()
