# Shanghai District Reference

## District Code Mapping

| Chinese Name | Pinyin | Code | ID |
|-------------|--------|------|-----|
| 黄浦区 | Huangpu | HP | 1 |
| 徐汇区 | Xuhui | XH | 2 |
| 长宁区 | Changning | CN | 3 |
| 静安区 | Jing'an | JA | 4 |
| 普陀区 | Putuo | PT | 5 |
| 虹口区 | Hongkou | HK | 6 |
| 杨浦区 | Yangpu | YP | 7 |
| 闵行区 | Minhang | MH | 8 |
| 宝山区 | Baoshan | BS | 9 |
| 嘉定区 | Jiading | JD | 10 |
| 浦东新区 | Pudong | PD | 11 |
| 金山区 | Jinshan | JS | 12 |
| 松江区 | Songjiang | SJ | 13 |
| 青浦区 | Qingpu | QP | 14 |
| 奉贤区 | Fengxian | FX | 15 |
| 崇明区 | Chongming | CM | 16 |

## Usage in Python

```python
DISTRICT_MAP = {
    '黄浦': ('HP', 'Huangpu'),
    '徐汇': ('XH', 'Xuhui'),
    '长宁': ('CN', 'Changning'),
    '静安': ('JA', 'Jingan'),
    '普陀': ('PT', 'Putuo'),
    '虹口': ('HK', 'Hongkou'),
    '杨浦': ('YP', 'Yangpu'),
    '闵行': ('MH', 'Minhang'),
    '宝山': ('BS', 'Baoshan'),
    '嘉定': ('JD', 'Jiading'),
    '浦东': ('PD', 'Pudong'),
    '金山': ('JS', 'Jinshan'),
    '松江': ('SJ', 'Songjiang'),
    '青浦': ('QP', 'Qingpu'),
    '奉贤': ('FX', 'Fengxian'),
    '崇明': ('CM', 'Chongming'),
}

def normalize_district(name):
    """Normalize district name to code"""
    for zh, (code, pinyin) in DISTRICT_MAP.items():
        if zh in name or pinyin.lower() in name.lower():
            return code
    return None
```

## District Exam Population (2025)

Total: 127,156 students

| District | Count |
|----------|-------|
| Pudong | 24,957 |
| Minhang | 13,417 |
| Baoshan | 11,156 |
| Jiading | 8,597 |
| Yangpu | 7,846 |
| Songjiang | 7,673 |
| Qingpu | 6,665 |
| Xuhui | 6,552 |
| Jingan | 5,441 |
| Putuo | 5,421 |
| Huangpu | 4,605 |
| Hongkou | 4,535 |
| Jinshan | 4,191 |
| Changning | 3,846 |
| Fengxian | 4,047 |
| Chongming | 3,198 |
