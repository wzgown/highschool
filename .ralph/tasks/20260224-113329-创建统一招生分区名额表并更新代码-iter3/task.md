# 任务：创建统一招生分区名额表并更新代码

## 背景

当前系统 `ref_admission_plan_summary` 表中的 `unified_count` 是学校整体的统一招生名额，没有按区细分。实际上统一招生批次的名额是按区分的（某些学校可能只面向部分区招生）。

需要创建类似 `ref_quota_allocation_district` 的新表 `ref_quota_unified_allocation_district`，用于维护统一招生批次的各区名额数量。

## 任务步骤

### 第一步：创建新表

在 `db/migrations/` 中创建新迁移文件 `007_create_quota_unified_allocation_district.sql`：

```sql
CREATE TABLE IF NOT EXISTS ref_quota_unified_allocation_district (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    school_id INTEGER NOT NULL REFERENCES ref_school(id),
    school_code VARCHAR(20) NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    quota_count INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, school_code, district_id)
);
```

### 第二步：从原始数据解析 2025 年统一招生分区数据

数据源位置：
- `original_data/raw/2025/2025年上海市高中招生学校名单.pdf`
- `original_data/raw/2025/quota_district/` 目录

使用 ETL 技能解析数据：
1. 从 PDF 中提取统一招生批次的分区名额数据
2. 生成 SQL seed 文件 `db/seeds/070_seed_unified_allocation_district_2025.sql`
3. 执行 SQL 导入数据

### 第三步：更新 Go 代码

#### 3.1 更新 `quota_repository.go`

修改 `QuotaRepository` 接口：
```go
// GetUnifiedPlan 获取统一招生计划数（旧方法 - 保留向后兼容）
GetUnifiedPlan(ctx context.Context, schoolID int32, year int) (int, error)

// GetUnifiedPlanByDistrict 获取统一招生计划数（新方法 - 按区）
GetUnifiedPlanByDistrict(ctx context.Context, schoolID int32, districtID int32, year int) (int, error)
```

#### 3.2 更新 `school_repository.go`

修改 `GetSchoolsForUnified` 方法：
- 改为从 `ref_quota_unified_allocation_district` 表查询
- JOIN 条件从 `ref_admission_plan_summary` 改为新表

#### 3.3 更新模拟录取引擎

确保录取逻辑使用新的 `GetUnifiedPlanByDistrict` 方法。

### 第四步：验证

1. 运行数据库迁移
2. 验证数据导入正确
3. 运行后端测试：`cd backend && make test`
4. 手动测试统一招生志愿填报功能

## 验收标准

1. 新表 `ref_quota_unified_allocation_district` 创建成功
2. 2025 年数据正确导入（所有学校-区组合）
3. `GetSchoolsForUnified` 返回正确结果
4. 模拟录取使用正确的分区名额
5. 所有测试通过

## 技术要点

- 表结构参考 `ref_quota_allocation_district`
- 缓存结构需要增加 district 维度
- 保持向后兼容（可选）

---

## 第 1 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[1/2] 检查完成信号...
❌ AI 未输出 MISSION_COMPLETE 信号
   AI 需要在完成任务后输出 MISSION_COMPLETE
```

**要求**: 修复上述错误后重新运行。


---

## 第 2 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[1/2] 检查完成信号...
✅ AI 已声称完成 (MISSION_COMPLETE)

[2/2] 执行客观验证...

=== 验证开始 ===

❌ PostgreSQL 容器未运行

════════════════════════════════════════════════════════
❌ 验证失败 (exit code: 1)
════════════════════════════════════════════════════════
```

**要求**: 修复上述错误后重新运行。

