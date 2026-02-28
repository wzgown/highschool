# 任务：修正 ref_school 表数据与 PDF 一致

## 背景

数据库 `public.ref_school` 表中的学校数据需要与官方 PDF 文件完全一致。以 PDF 为权威来源，修正数据库中的任何差异。

## 成功标准

- [ ] 从 PDF 提取所有学校数据（权威来源）
- [ ] 对比数据库，识别所有差异
- [ ] 修正数据库中的错误数据
- [ ] 验证修正后数据库与 PDF 完全一致
- [ ] 生成修正报告

## 验证脚本

```bash
#!/bin/bash
set -e

PROJECT_ROOT="/Users/lance.wang/workspace/wzgown/highschool_new"
REPORT_FILE="$PROJECT_ROOT/.ralph/current/data_fix_report.md"

echo "=== 数据修正验证 ==="
echo ""

# 1. 检查数据库连接
if ! docker exec highschool_postgres pg_isready -U highschool -d highschool > /dev/null 2>&1; then
    echo "❌ 数据库连接失败"
    exit 1
fi
echo "✅ 数据库连接正常"

# 2. 检查修正报告
if [ ! -f "$REPORT_FILE" ]; then
    echo "❌ 修正报告未生成: $REPORT_FILE"
    exit 1
fi

# 3. 检查报告是否显示"完全一致"
if ! grep -q "完全一致" "$REPORT_FILE"; then
    echo ""
    echo "❌ 数据尚未完全一致，请查看报告"
    head -50 "$REPORT_FILE"
    exit 1
fi

echo ""
echo "✅ 数据修正完成，与 PDF 完全一致"
echo "✅ 报告: $REPORT_FILE"
```

## 实现计划

- [ ] **T1**: 使用 PDF 技能读取 `original_data/raw/2025/2025 年上海市高中招生学校名单.pdf`，提取所有学校数据（代码、名称、区县）
- [ ] **T2**: 从数据库 `ref_school` 表查询所有 2025 年学校数据
- [ ] **T3**: 对比识别差异：
  - PDF 有但数据库没有 → 需要插入
  - 数据库有但 PDF 没有 → 需要删除或标记
  - 名称/代码不一致 → 需要更新
- [ ] **T4**: 生成 SQL 修正脚本，执行数据修正
- [ ] **T5**: 验证修正后数据与 PDF 完全一致
- [ ] **T6**: 生成修正报告到 `.ralph/current/data_fix_report.md`

## 数据源

### 权威来源：PDF 文件
- 路径: `original_data/raw/2025/2025 年上海市高中招生学校名单.pdf`
- 这是**唯一权威来源**

### 待修正：数据库表
- 表名: `public.ref_school`
- 关键字段:
  - `code`: 学校代码（必须与 PDF 一致）
  - `full_name`: 学校全名（必须与 PDF 一致）
  - `district_id`: 区县ID
  - `data_year`: 数据年份 (2025)
- 当前记录数: 293 条

### 数据库连接
```bash
docker exec highschool_postgres psql -U highschool -d highschool
```

## 修正策略

### 新增学校（PDF 有，数据库没有）
```sql
INSERT INTO ref_school (code, full_name, district_id, school_nature_id, data_year)
VALUES (...);
```

### 删除/标记无效学校（数据库有，PDF 没有）
```sql
-- 方案1：标记为不活跃
UPDATE ref_school SET is_active = false WHERE code = '...';

-- 方案2：删除（如果没有外键引用）
DELETE FROM ref_school WHERE code = '...' AND data_year = 2025;
```

### 更新不一致数据
```sql
UPDATE ref_school
SET full_name = '正确名称'
WHERE code = '...' AND data_year = 2025;
```

## 约束

**必须：**
- PDF 是唯一权威来源
- 修正前先备份或记录原始数据
- 生成可审计的修正报告
- 修正后验证完全一致

**禁止：**
- 修改 PDF 数据（这是只读的权威来源）
- 跳过任何差异的修正
- 在没有验证的情况下提交修正

## 注意事项

### 外键约束
`ref_school` 表被多个表引用：
- `ref_admission_plan_summary`
- `ref_admission_score_unified`
- `ref_admission_score_quota_district`
- 等

删除学校前需要检查是否有外键引用。

### 区县 ID 映射
PDF 中是区县名称，需要映射到 `ref_district.id`。

## 完成信号

**数据修正完成且验证通过后，输出：**

```
MISSION_COMPLETE
```

---

<!-- ════════════════════════════════════════════════════════ -->
<!-- 以下由 Ralph Loop 自动追加 -->
<!-- ════════════════════════════════════════════════════════ -->

## 失败日志

<!-- 每轮失败后自动追加 -->
