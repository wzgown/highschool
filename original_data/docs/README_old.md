# 上海中考数据集

## 目录结构

```
shanghai-zhongkao/
├── policies/          # 政策文件 (markdown)
├── quota/             # 名额分配数据 (csv)
├── scores/            # 录取分数线 (csv)
├── docs/              # 分析报告 (markdown)
├── scripts/           # 数据处理脚本 (python)
└── external_data/     # 原始数据（来自GitHub）
```

## 数据来源

- GitHub: https://github.com/wzgown/highschool/tree/main/original_data
- 上海教育考试院 (shmeea.edu.cn)
- 上海市教委
- 各区教育局官网

## 已整理数据

### 参考人数 (quota/)
- ✅ **exam_counts_2025.csv**: 2025年各区中考人数（16个区）

### 名额分配 (quota/)
- ✅ **quota_to_district_2024.csv**: 2024年名额分配到区数据（74所高中）
- ✅ **quota_to_school_2024.csv**: 2024年名额分配到校数据（全部初中）

### 录取分数线 (scores/)
- ✅ **cutoff_scores_2024.csv**: 2024年1-15志愿录取分数线（16个区，906条记录）

## 原始数据 (external_data/)

### 2024年数据（最完整）
- ✅ 1-15志愿分数线（全部16个区）
- ✅ 名额分配到区/到校分数线（全部16个区）
- ✅ 名额分配到区/到校计划数（全部16个区）
- ✅ 高中招生学校名单

### 2025年数据
- ✅ 各区中考人数

### 2023年数据
- ✅ 中考分数线（Excel）
- ✅ 各区名额分配到区/到校录取最低分数线（PDF）

### 2022年数据
- ✅ 中考分数线（Excel）
- ✅ 高中招生学校名单（PDF）

## 待整理数据

- ⚠️ 2022-2023年录取分数线（需从Excel/PDF提取）
- ⚠️ 2022-2024年各区参考人数（仅2025年完整）
- ❌ 历年得分分布趋势（暂无数据）

## 数据格式规范

### CSV 格式
- 使用 UTF-8 编码
- 第一行为列名
- 数字列不包含千分位分隔符
- 日期格式: YYYY-MM-DD

### Markdown 格式
- 使用标准 markdown 语法
- 政策文件保留原文链接
- 标注数据来源和更新时间

## 使用说明

### 查看数据整理进度
```bash
cat docs/data_report.md
```

### 查看数据统计
```bash
wc -l quota/*.csv scores/*.csv
```

### 重新整理数据
```bash
cd scripts
python3 organize_data.py
```

## 更新日志

- 2026-02-08: 完成第一阶段数据整理（2024年数据 + 2025年参考人数）
- 2026-02-07: 初始化项目，创建目录结构
