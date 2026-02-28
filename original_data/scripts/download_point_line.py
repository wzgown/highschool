import os
import requests
import pdfplumber
from concurrent.futures import ThreadPoolExecutor

# 配置参数（修正中文引号问题）
PDF_FILE = '2024年上海市高中学校名额分配招生录取最低分数线.pdf'
PDF_DIR = "招生录取分数线"
os.makedirs(PDF_DIR, exist_ok=True)

# 配置参数（更新为实际区数量）
EXPECTED_DISTRICTS = 16  # 上海16个行政区

def download_pdf(url, filename):
    """下载PDF文件并保存到本地"""
    try:
        res = requests.get(url, timeout=15)
        res.raise_for_status()
        with open(os.path.join(PDF_DIR, filename), 'wb') as f:
            f.write(res.content)
        return True, filename
    except Exception as e:
        return False, f"{filename} | 错误：{str(e)}"

# 提取完整表格数据（分页处理）
all_tables = []
with pdfplumber.open(PDF_FILE) as pdf:
    for page in pdf.pages:
        # 使用统一参数提取各页表格
        tables = page.extract_tables({
            "vertical_strategy": "lines",
            "horizontal_strategy": "text",
            "snap_tolerance": 8
        })
        all_tables.extend(tables)
        print(f"页面 {page.page_number} 发现 {len(tables)} 个表格")  # 调试输出

# 处理所有表格数据
districts = []
header_found = False  # 跨页表格标记
header_keywords = ['区名称', '区名', '区域']
district_col = None  # 区名称列位置

for table in all_tables:
    # 第一阶段：查找表头
    if not header_found:
        header_row = None
        for i, row in enumerate(table):
            if any(any(kw in str(cell) for kw in header_keywords) for cell in row):
                header_row = i
                print(f"发现表头行：{row}")  # 调试输出
                # 确定区名称列位置
                for idx, cell in enumerate(row):
                    if any(kw in str(cell) for kw in header_keywords):
                        district_col = idx
                        break
                header_found = True
                break
        if header_found:
            start_row = header_row + 1
        else:
            continue  # 跳过无表头表格
    else:
        start_row = 0  # 跨页表格延续部分
    
    # 第二阶段：提取数据
    for row in table[start_row:]:
        if district_col is not None and len(row) > district_col:
            district = str(row[district_col]).strip()
            if district.endswith('区') and district not in districts:
                districts.append(district)
                print(f"页面{all_tables.index(table)+1} 提取到：{district}")

# 最终校验前打印完整列表
print("识别到的完整区列表：")
for i, d in enumerate(districts, 1):
    print(f"{i:2d}. {d}")

# 验证区数量
if len(districts) != EXPECTED_DISTRICTS:
    raise ValueError(f"区数量错误：期望{EXPECTED_DISTRICTS}个，实际识别到{len(districts)}个")

# 超链接提取（新逻辑）
click_urls = []
with pdfplumber.open(PDF_FILE) as pdf:
    for page in pdf.pages:
        # 直接获取页面上的所有超链接
        for link in page.hyperlinks:
            if 'uri' in link:  # 确保链接有URL
                click_urls.append(link['uri'])
                print(f"发现链接：{link['uri']}")  # 调试输出

# 验证链接数量
if len(click_urls) != 2 * EXPECTED_DISTRICTS:
    print(f"警告：期望{2*EXPECTED_DISTRICTS}个链接，实际找到{len(click_urls)}个")
    # 输出前3个链接用于验证
    print("前3个链接示例：")
    for i, url in enumerate(click_urls[:3]):
        print(f"{i+1}. {url}")

# 生成下载任务
tasks = []
for i, district in enumerate(districts):
    if i*2 + 1 < len(click_urls):  # 确保有足够的链接
        # 生成分配到区文件名和URL
        qu_filename = f"2024年上海市高中学校名额分配到区招生录取最低分数线（{district}）.pdf"
        qu_url = click_urls[i*2]
        tasks.append((qu_url, qu_filename))
        
        # 生成分配到校文件名和URL
        xiao_filename = f"2024年上海市高中学校名额分配到校招生录取最低分数线（{district}）.pdf"
        xiao_url = click_urls[i*2+1]
        tasks.append((xiao_url, xiao_filename))

# 执行下载（最大5线程）
with ThreadPoolExecutor(max_workers=5) as executor:
    futures = [executor.submit(download_pdf, url, name) for url, name in tasks]
    for future in futures:
        success, msg = future.result()
        if success:
            print(f"✅ 已下载：{msg}")
        else:
            print(f"❌ 下载失败：{msg}")

print("\n全部处理完成，请检查输出目录。")
