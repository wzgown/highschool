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
- [ ] 验证修正后数据一致

## 实现计划

- [ ] **T1**: 查询 `ref_school` 中变更的学校列表
- [ ] **T2**: 检查每个关联表中是否存在不一致
- [ ] **T3**: 生成不一致数据清单
- [ ] **T4**: 执行修正 SQL
- [ ] **T5**: 验证修正后所有关联表与 ref_school 一致
- [ ] **T6**: 生成修正报告

## 数据库连接

```bash
docker exec highschool_postgres psql -U highschool -d highschool
```

## 修正策略

### 名称不一致
```sql
UPDATE ref_admission_plan_summary p
SET school_name = s.full_name, school_code = s.code
FROM ref_school s
WHERE p.school_id = s.id
AND (p.school_name != s.full_name OR p.school_code != s.code)
AND p.data_year = 2025;
```

### 引用不活跃学校
- 如果数据有效，保留但标记
- 如果数据无效，删除或标记

## 约束

**必须：**
- 以 ref_school 为准（权威来源）
- 修正前记录原始数据

**禁止：**
- 修改 ref_school 数据（已在前一个任务完成）
- 删除有价值的历史数据

## 完成信号

**检查并修正完成后，输出：**

```
MISSION_COMPLETE
```

---

<!-- 以下由 Ralph Loop 自动追加 -->

## 失败日志

<!-- 每轮失败后自动追加 -->
