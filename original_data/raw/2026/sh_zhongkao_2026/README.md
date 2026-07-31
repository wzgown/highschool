# 2026 上海中考数据集

整合 2026 年上海市中考各类官方/民间数据，输出一个带自说明、字段字典与多维度分析的 Excel 工作簿
（`output/2026上海中考数据集.xlsx`，共 18 个 Sheet）。本目录为**可复现、结构化**的项目包。

---

## 1. 目录结构

```
sh_zhongkao_2026/
├── README.md                  # 本说明
├── raw/                       # 原始数据（不可变源，政府/机构发布的原件）
│   ├── plan/                  # 名额分配到校计划 PDF 原件（16 区）+ 虹口抓取 HTML
│   ├── to_district/           # 名额到区计划 PDF 原件（daoqu_plan.pdf）
│   └── xuhui_ocr/             # 徐汇 OCR 中间产物（png/tsv/txt，仅溯源用）
├── data/                      # 清洗好的结构化数据（CSV，build_workbook 的输入）
│   ├── to_school_plan_*.csv   #   到校计划（16 区：区,初中学校,招生学校,计划数）
│   ├── to_school_*.csv        #   到校录取线（16 区：含综评的 800 分制）
│   ├── parallel_*.csv         #   平行志愿录取线（16 区：750 分制）
│   ├── to_district_*.csv      #   到区录取线（16 区：含综评的 800 分制）
│   ├── citywide_到区计划.csv  #   到区计划（全市 77 所市重）
│   ├── junior_high_700plus.csv#   【派生】民间统计的初中校 700+ 分数段（见 §5）
│   ├── school_reputation.csv #   【派生】学校声誉/口碑分（见 §4，扩展只需编辑此文件）
│   └── district_score_proxy.csv#  【派生】各区平行志愿分数水平（区级代理）
├── scripts/                   # 脚本（输入/输出路径已对齐上面的目录）
│   ├── build_workbook.py      # ★ 主生成器：读 data/ → 写 output/
│   ├── parse/                 #   PDF/网页 → data/ 的 CSV（解析层）
│   │   ├── parse_all.py       #     解析闵行/嘉定/宝山/松江/到区 PDF
│   │   ├── parse_plan.py      #     解析青浦/奉贤/金山/崇明 计划 PDF
│   │   ├── parse_parallel.py  #     解析本地宝网页 → parallel_*.csv
│   │   ├── convert_xuhui.py   #     徐汇用户原始 CSV → to_school_plan_徐汇.csv
│   │   ├── pdf_download.py    #     下载闵行/嘉定/宝山/松江 计划 PDF 到 raw/plan
│   │   └── code2name.json     #     parse_all 用的「招生代码→校名」映射
│   ├── derive/                #   派生数据生成层
│   │   ├── make700.py         #     汇总单篇民间 700+ 统计
│   │   ├── merge700.py        #     合并多篇 → junior_high_700plus.csv
│   │   ├── region_proxy.py    #     计算 district_score_proxy.csv
│   │   └── build_reputation.py#     生成 school_reputation.csv（声誉/口碑分）
│   └── _archive/              #   探索/诊断脚本（历史溯源，非主线，勿依赖）
└── output/                    # 清洗好的导出产物（最终交付）
    ├── 2026上海中考数据集.xlsx #   ★ 主交付物（18 Sheet）
    ├── match_report_700plus.csv # 700+ 表逐校匹配审计（简称↔全称/方式）
    └── match_report_strength.csv# 录取线↔计划 校名统一审计
```

---

## 2. 数据来源与口径（重要）

- **到校计划 / 到校录取线 / 到区计划 / 平行志愿**：来自上海市教育考试院及各区教育局官网、
  上海本地宝等公开渠道发布的 2026 招生文件（原件见 `raw/`）。
- **`junior_high_700plus.csv`（初中校 700+ 分数段）**：来自**民间渠道**的多篇统计汇总
  （冯老师、锐思教育·坦途网、今日头条等），**非官方、非完整分数分布**，仅反映高分产出量级；
  各行的「可靠度」列已标注（多源一致 / 单一来源 / 网传存疑 / 仅最高分）。
- **两套分数制，切勿混用**：
  - 名额分配线（到校/到区，含综合测评 50 分）= **800 分制**；
  - 平行志愿线 = **750 分制**。
  `汇总透视` 中两者分列不同列，跨列比较前请注意口径。

---

## 3. 校名匹配（数据主键，已做稳健对齐）

校名是跨表 join 的主键。项目内已统一三套规范，避免数据碎片化：

1. **初中校名**：`build_workbook.py` 用「精确 → 人工别名(简称↔全称/分校) → 归一化子串(去歧义)」
   三档匹配，把 700+ 表缩写、录取线全称、计划全称统一到同一官方全称键；无法唯一确定的
   （推算表无该校 / 多候选歧义 / 数据缺口）一律留空并标注，绝不臆测。
2. **高中校名**：平行志愿文件系统性用缩写（`上海中学`/`交大附中`/`丰华高级`…），已由
   `HS_ALIAS` 统一到与其它来源一致的官方全称，使 `汇总透视·按高中汇总` 不再把同一校拆成多行。
3. 逐校审计见 `output/match_report_700plus.csv` 与 `output/match_report_strength.csv`，
   如需微调别名，改 `build_workbook.py` 的 `ALIAS` / `HS_ALIAS` 后重跑即可。

---

## 4. 初中排行榜方法论（含声誉口碑，重要）

> **核心原则：排名不能只依赖本项目内拿到的数据**——录取线、700+ 均为不完整/带噪数据，
> 单独使用会失真（例如嘉定区曾出现「戬浜学校」因录取线 z 分偏高而被排到
> 「交大附中附属嘉定德富/洪德中学」之前，违背公认口碑）。因此排行榜引入**声誉口碑**维度。

`初中学校排行榜(分区分榜)` 四档指标（均为区内归一化到 0–100）：

- **榜A 生源强度**：每所市重在该校「名额到校录取线」的初中间算标准分 z，某校取均值。
  消除市重难度差异，全量覆盖拿到到校名额的初中。**注意：录取线 z 分反映的是分配到哪所市重及
  同批录取生相对位次，并非学校实力的干净代理，权重已压低。**
- **榜B 高分产出**：`700+占比%(推算)` = 700+人数 ÷ 推算考生数（仅民间统计到的校有值）。
- **榜D 声誉口碑**：来自**用户提供/网页可检索的公开排名与口碑**（机构公众号梯队榜、家长论坛、百度百家号等），
  逐校标注来源与梯队，**属主观判断、仅供参考**。
  - 主数据 `data/school_tier_ranking.csv`：用户提供的 16 区机构梯队列（第一/二/三梯队 + 特色标签），覆盖 118 所。
  - 嘉定区叠加本轮**联网调研**详细依据（多源交叉：头条/百家号/57cha 等 2025 中考口碑）。
  - 排名由 `scripts/derive/build_reputation.py` 合并生成 `data/school_reputation.csv`（共 134 行，覆盖全部 16 区）。
- **综合得分(数据+声誉)** = `0.20×A + 0.15×B + 0.65×D`（**声誉主导**）。
  - **为何声誉权重最高**：项目内「名额到校录取线/700+」对**自招强校易失真**——尖子走四校自招、走名额到校的多为相对弱生，录取线 z 反而偏低（如华育 A 区内仅排 #27）。用户明确要求「排名不能只靠本项目内不完整数据」，故以公开口碑为主、项目数据为辅。
  - 校名可匹配到声誉数据者即用此三档式（缺 A/B 的维度取中性 50，数据不完整不惩罚）；
  - 无声誉数据者**回退**到原 `0.6×A + 0.4×B` 数据综合，并标「声誉待补」，不臆造。

**如何扩展声誉数据**（不用改代码）：编辑 `data/school_tier_ranking.csv`（机构梯队列，推荐）或
`data/school_reputation.csv`（最终声誉分），列为 `区,学校(plan官方全称),声誉分(0-100),梯队,依据`。
学校名必须与 `to_school_plan_*.csv` 的初中校名**完全一致**（可直接参考 `output/match_report_700plus.csv` 的「推算匹配校名(全称)」列）。
保存后重跑 `build_reputation.py` + `build_workbook.py` 即生效。

---

## 5. 如何重新生成（可复现）

> 运行环境：Python 3.11+，依赖 `openpyxl`（主生成器）、`pdfplumber`/`pandas`/`requests`（解析层）。
> 推荐用隔离 venv；脚本内部路径均已相对项目根解析，可在任意位置克隆后直接运行。

```bash
# ① 解析原始 PDF/网页 → data/ 的 CSV（仅在 raw/ 有更新时需要）
python scripts/parse/parse_all.py
python scripts/parse/parse_plan.py
python scripts/parse/parse_parallel.py
python scripts/parse/convert_xuhui.py        # 需先备好徐汇用户原始 CSV（见脚本内 src 注释）

# ② 生成派生数据
python scripts/derive/merge700.py            # → data/junior_high_700plus.csv
python scripts/derive/region_proxy.py        # → data/district_score_proxy.csv
python scripts/derive/build_reputation.py    # → data/school_reputation.csv（声誉/口碑，可手工扩展）

# ③ 生成最终工作簿 + 匹配审计表
python scripts/build_workbook.py
# 产物：output/2026上海中考数据集.xlsx
#       output/match_report_700plus.csv
#       output/match_report_strength.csv
```

仅想刷新最终工作簿（数据 CSV 不变）时，只需执行第 ③ 步。

---

## 6. 工作簿 Sheet 一览（18 个）

自说明与字段字典在每个 Sheet 顶部，含口径说明；主要 Sheet：
名额分配到校计划(逐校)、名额到校录取分数线、平行志愿分数线、名额到区录取分数线、
名额分配到区计划(市重77所)、各初中考生人数(推算)、初中校700分以上人数(民间统计)、
**初中学校排行榜(分区分榜)**（榜A 生源强度 / 榜B 700+占比 / 榜C 综合，含数据完整度标注）、
汇总透视（按高中 / 按区）、市重招生计划汇总、一分一段、最低投档线、分数代理、数据覆盖与缺口、字段字典。

> 注：`_archive/` 下为开发过程中的探索/诊断脚本，仅作溯源保留，不属于可复现主线，请勿依赖其接口。
