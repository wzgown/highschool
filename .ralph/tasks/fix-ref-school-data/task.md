# 任务：检查并修正 ref_school 关联表数据一致性

## 背景

前一个任务已修正 `ref_school` 表数据：
- **代码修正**：3所学校（嘉一实验、上大附属嘉定、宋庆龄）
- **新增学校**：4所（友谊中学、师大附属嘉定高中、安亭高级中学、张堰中学）
- **标记不活跃**：1所（五爱高级中学）

现在需要检查并修正与 `ref_school` 关联的表，确保数据一致性。

## 关联表（根据 ER 图）

| 表名 | 关联字段 | 说明 |
|------|----------|------|
| `ref_admission_plan_summary` | school_id, school_code, school_name | 招生计划汇总 |
| `ref_admission_score_unified` | school_id, school_name | 统一招生分数线 |
| `ref_admission_score_quota_district` | school_id, school_name | 名额到区分数线 |
| `ref_admission_score_quota_school` | school_id, school_name | 名额到校分数线 |
| `ref_quota_allocation_district` | school_id, school_name | 名额到区计划 |
| `ref_quota_allocation_school` | high_school_id, high_school_name | 名额到校计划 |

## 成功标准

- [ ] 检查所有关联表与 ref_school 的一致性
- [ ] 识别并记录所有不一致数据
- [ ] 修正不一致数据（更新 school_name、处理无效引用）
- [ ] 生成一致性报告
- [ ] 验证修正后数据一致

## 验证脚本

```bash
#!/bin/bash
set -e

PROJECT_ROOT="/Users/lance.wang/workspace/wzgown/highschool_new"
REPORT_FILE="$PROJECT_ROOT/.ralph/current/related_tables_fix_report.md"

echo "=== 关联表数据一致性验证 ==="
echo ""

# 1. 检查数据库连接
if ! docker exec highschool_postgres pg_isready -U highschool -d highschool > /dev/null 2>&1; then
    echo "❌ 数据库连接失败"
    exit 1
fi
echo "✅ 数据库连接正常"

# 2. 检查报告文件
if [ ! -f "$REPORT_FILE" ]; then
    echo "❌ 修正报告未生成: $REPORT_FILE"
    exit 1
fi

# 3. 检查是否还有不一致
if grep -q "## 未修复问题" "$REPORT_FILE" && ! grep -q "无未修复问题" "$REPORT_FILE"; then
    echo ""
    echo "❌ 仍有数据不一致，请查看报告"
    head -80 "$REPORT_FILE"
    exit 1
fi

# 4. 检查一致性验证结果
if ! grep -q "✅ 所有关联表数据一致" "$REPORT_FILE"; then
    echo ""
    echo "❌ 一致性验证未通过"
    head -80 "$REPORT_FILE"
    exit 1
fi

echo ""
echo "✅ 关联表数据一致性检查通过"
echo "✅ 报告: $REPORT_FILE"
```

## 实现计划

- [ ] **T1**: 查询 `ref_school` 中变更的学校列表（参考前一个任务的报告）
- [ ] **T2**: 检查每个关联表中是否存在不一致：
  - school_name 与 ref_school.full_name 不匹配
  - school_code 与 ref_school.code 不匹配
  - 引用了 is_active=false 的学校
- [ ] **T3**: 生成不一致数据清单
- [ ] **T4**: 执行修正：
  - 更新 school_name 与 ref_school 一致
  - 更新 school_code 与 ref_school 一致
  - 对于引用不活跃学校的记录，标记或删除
- [ ] **T5**: 验证修正后所有关联表与 ref_school 一致
- [ ] **T6**: 生成修正报告到 `.ralph/current/related_tables_fix_report.md`

## 数据库连接

```bash
docker exec highschool_postgres psql -U highschool -d highschool
```

## 检查 SQL 示例

```sql
-- 检查 ref_admission_plan_summary 中 school_name 不一致的记录
SELECT p.id, p.school_id, p.school_code, p.school_name, s.full_name as correct_name
FROM ref_admission_plan_summary p
JOIN ref_school s ON p.school_id = s.id
WHERE p.school_name != s.full_name
AND p.data_year = 2025;

-- 检查引用了不活跃学校的记录
SELECT p.id, p.school_id, p.school_name, s.is_active
FROM ref_admission_plan_summary p
JOIN ref_school s ON p.school_id = s.id
WHERE s.is_active = false
AND p.data_year = 2025;
```

## 修正策略

### 名称/代码不一致
```sql
UPDATE ref_admission_plan_summary p
SET school_name = s.full_name, school_code = s.code
FROM ref_school s
WHERE p.school_id = s.id
AND (p.school_name != s.full_name OR p.school_code != s.code)
AND p.data_year = 2025;
```

### 引用不活跃学校
- 如果数据有效（其他来源），保留但标记
- 如果数据无效，删除或标记

## 约束

**必须：**
- 以 ref_school 为准（权威来源）
- 修正前记录原始数据
- 生成可审计的修正报告

**禁止：**
- 修改 ref_school 数据（已在前一个任务完成）
- 删除有价值的历史数据（谨慎处理）

## 完成信号

**检查并修正完成后，输出：**

```
MISSION_COMPLETE
```

---

<!-- ════════════════════════════════════════════════════════ -->
<!-- 以下由 Ralph Loop 自动追加 -->
<!-- ════════════════════════════════════════════════════════ -->

## 失败日志

<!-- 每轮失败后自动追加 -->
