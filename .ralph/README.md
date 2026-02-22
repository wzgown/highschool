# Ralph Loop 脚手架

> 多任务复用的循环框架
> 每个任务 = task.md + verify.sh

## 目录结构

```
.ralph/
├── scripts/
│   ├── run-ralph.sh      # 主循环脚本
│   └── stop-hook.sh      # 执行 verify.sh
│
├── templates/
│   ├── task-template.md  # 任务模板
│   └── verify.sh         # 验证脚本模板
│
├── current/              # 当前任务
│   ├── task.md           # 任务描述
│   └── verify.sh         # 验证脚本 ⬅️ 必须存在
│
├── tasks/                # 历史任务归档
└── logs/                 # 循环日志
```

## 核心设计

### 每个任务两个文件

| 文件 | 用途 |
|------|------|
| `task.md` | AI 读取的任务描述 |
| `verify.sh` | Stop Hook 执行的验证脚本 |

### 工作流程

```
┌─────────────────────────────────────────────┐
│  1. 创建任务                                 │
│     - current/task.md    (任务描述)         │
│     - current/verify.sh  (验证脚本)         │
│                                             │
│  2. 运行循环                                │
│     ↓                                       │
│  ┌───────────────────────────────────────┐ │
│  │ while 未达到 MAX_ITERATIONS:          │ │
│  │                                       │ │
│  │   # AI 读取 task.md                   │ │
│  │   claude -p task.md                   │ │
│  │                                       │ │
│  │   # 执行 verify.sh（客观验证）        │ │
│  │   bash stop-hook.sh                   │ │
│  │   if 通过: break                      │ │
│  │                                       │ │
│  │   # 追加失败日志到 task.md            │ │
│  └───────────────────────────────────────┘ │
│     ↓                                       │
│  3. 自动归档到 tasks/                       │
└─────────────────────────────────────────────┘
```

## 使用方法

### 创建新任务

```bash
# 1. 复制模板
cp .ralph/templates/task-template.md .ralph/current/task.md
cp .ralph/templates/verify.sh .ralph/current/verify.sh

# 2. 编辑任务描述
vim .ralph/current/task.md

# 3. 编辑验证脚本 ⬅️ 关键！
vim .ralph/current/verify.sh

# 4. 运行循环
./.ralph/scripts/run-ralph.sh
```

### verify.sh 示例

```bash
#!/bin/bash
set -e

echo "=== 验证数据一致性 ==="

# 直接查询数据库
MISMATCH=$(docker exec db psql -t -c "
SELECT COUNT(*) FROM table_a a
JOIN table_b b ON a.id = b.a_id
WHERE a.name != b.name;
")

if [ "$MISMATCH" -gt 0 ]; then
    echo "❌ 发现 $MISMATCH 条不一致"
    exit 1
fi

echo "✅ 验证通过"
```

## 命令参考

```bash
./.ralph/scripts/run-ralph.sh              # 运行当前任务
./.ralph/scripts/run-ralph.sh --new        # 创建新任务
./.ralph/scripts/run-ralph.sh --status     # 显示状态
./.ralph/scripts/run-ralph.sh --archive    # 归档当前任务
./.ralph/scripts/run-ralph.sh --reset      # 重置失败日志
./.ralph/scripts/run-ralph.sh --help       # 显示帮助
```

## 关键要点

1. **verify.sh 必须存在** - 没有 verify.sh 会报错
2. **验证脚本直接检查数据** - 不依赖报告文件
3. **返回 0 = 通过，非 0 = 失败** - 标准 bash 退出码
4. **MISSION_COMPLETE** - AI 必须输出这个完成信号
