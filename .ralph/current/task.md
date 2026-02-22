# 任务：检查并修正 ref_school 关联表数据一致性

## 背景

前一个任务已修正 `ref_school` 表数据：
- **代码修正**：3所学校（嘉一实验、上大附属嘉定、宋庆龄）
- **新增学校**：4所（友谊中学、师大附属嘉定高中、安亭高级中学、张堰中学）
- **标记不活跃**：1所（五爱高级中学）

现在需要检查并修正与 `ref_school` 关联的表，确保数据一致性。

## 关联表

| 表名 | 关联字段 | 说明 |
|------|----------|------|
| `ref_admission_plan_summary` | school_id, school_name | 招生计划 |
| `ref_admission_score_unified` | school_id, school_name | 统一招生分数线 |
| `ref_admission_score_quota_district` | school_id, school_name | 名额到区分数线 |
| `ref_admission_score_quota_school` | school_id, school_name | 名额到校分数线 |
| `ref_quota_allocation_district` | school_id, school_code | 名额到区计划 |
| `ref_quota_allocation_school` | high_school_id, high_school_code | 名额到校计划 |

## 成功标准

- [ ] 检查所有关联表一致性
- [ ] 修正不一致数据
- [ ] 验证通过 verify.sh

## 实现计划

- [ ] **T1**: 查询不一致数据
- [ ] **T2**: 执行修正 SQL
- [ ] **T3**: 验证修正结果

## 约束

**必须：**
- 以 ref_school 为准
- 执行 verify.sh 验证

**禁止：**
- 修改 ref_school 数据

## 完成信号

任务完成后输出：

```
MISSION_COMPLETE
```
