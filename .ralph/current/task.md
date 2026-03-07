# 任务

中考成绩"蘑菇云"背景动效设计

## 背景

用户希望基于原始数据中的蘑菇云分布图，设计一个视觉效果更好的背景动效。

当前的粒子特效完全不能表达我想要的效果。

## 目标
重新设计背景动效，用 Canvas 实现蘑菇云分布效果，满足以下要求:
1. 视觉冲击力: 一图看出中考竞争的激烈程度
2. 使用 canvas绘制蘑菇云
效果（而非简单的 HTML/CSS动画)
3. 每个区县的数据用气泡展示区县详情
4. 动态粒子从气泡效果, 每个粒子大小与该区人数动态变化
5. 篇文档顶部添加分数排名前20的区名
6. 悬停时高亮当前分数段并显示该区详细信息浮层
7. 点击分数段/分数详情页跳转到区详情页
8. 菜花配色方案参考 Anthropic 研究（蓝绿渐变)
   - 主色: Azure蓝 (#0091B)
   - 辅助色? 深紫(#8040c) 代表较低压力
     - 浅紫渐变到透明
   - 点击或高亮低分学校时，进入详情页
    - 点击返回按钮返回列表

9. 完成时显示成功消息

10. 所有功能完成后， Ralph Loop 自动归档当前任务

## 约束
- 每次迭代都是新会话
 每次迭代完成后， Ralph Loop 装入归档列表
  - 每次迭代开始前， Ralph 会：
   - 下载原始数据文件
   - irebase/validate` 任务完成
   - `firebase/validate` 超过20API获取已完成的任务文件
   - 裀理解蘑菇云数据结构
   - 每个功能只运行一次， AI 饮足够了解背景

   - 不要过早宣布完成

- AI 只能在声称完成时输出 `MISSION_COMPLETE`

    - 不要留下未提交的代码
    - 不要过早宣布任务完成（需要端到端验证)
    - 不要做与AI 提示无关的事情
    - AI 只允许修改 `passes`字段， 其他内容不得删除或修改
    - 只运行 `verify_command` 进行客观验证
    - 只验证通过的才标记 `passes: true`
    - 失败时， Ralph Loop 会继续下一轮迭代
- -. 失败信息追加到任务文件，任务将继续
    - Ralph Loop 2.0 会自动归档任务
        - `firebase/validate` -> 在循环中保持任务状态一致性

---

## 第 1 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[0;34m[1/3][0m 检查完成信号...
[0;32m✅ AI 已声称完成 (MISSION_COMPLETE)[0m

[0;34m[2/3][0m 检查工作区状态...
[1;33m⚠️  工作区有 1 个未提交的更改[0m

?? .ralph/current/task.md

[1;33m建议: AI 应该提交这些更改以保持干净状态[0m

[0;34m[3/3][0m 执行功能验证...

正在验证 passes:true 的功能...

  验证 [F001]: 文件存在检查...
    命令: test -f /etc/passwd
    [0;32m✅ 通过[0m

  验证 [F002]: 命令失败测试...
    命令: false
    [0;31m❌ 失败[0m

════════════════════════════════════════════════════════
[0;31m❌ 验证失败:        1 个功能未通过验证[0m

功能进度:        1 通过,        1 失败
```

**要求**: 修复上述错误后重新运行。


---

## 第 2 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[0;34m[1/3][0m 检查完成信号...
[0;31m❌ AI 未输出 MISSION_COMPLETE 信号[0m
   AI 需要在完成任务后输出 MISSION_COMPLETE
```

**要求**: 修复上述错误后重新运行。


---

## 第 3 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[0;34m[1/3][0m 检查完成信号...
[0;32m✅ AI 已声称完成 (MISSION_COMPLETE)[0m

[0;34m[2/3][0m 检查工作区状态...
[1;33m⚠️  工作区有 3 个未提交的更改[0m

 M .ralph/current/features.json
?? .ralph/current/progress.md
?? .ralph/current/task.md

[1;33m建议: AI 应该提交这些更改以保持干净状态[0m

[0;34m[3/3][0m 执行功能验证...

正在验证 passes:true 的功能...

  验证 [F001]: Vue组件ScoreCloudBackground.vue已创建并集成到Home...
    命令: test -f frontend/src/components/ScoreCloudBackground.vue
    [0;32m✅ 通过[0m

  验证 [F002]: Canvas蘑菇云形态视觉效果 - 粒子基于分数分布呈现蘑菇云形状...
    命令: grep -q 'canvas' frontend/src/components/ScoreCloudBackground.vue
    [0;32m✅ 通过[0m

  验证 [F003]: 区县数据展示 - 每个区县用气泡展示详情...
    命令: grep -q 'district' frontend/src/components/ScoreCloudBackground.vue
```

**要求**: 修复上述错误后重新运行。


---

## 第 4 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[0;34m[1/3][0m 检查完成信号...
[0;32m✅ AI 已声称完成 (MISSION_COMPLETE)[0m

[0;34m[2/3][0m 检查工作区状态...
[1;33m⚠️  工作区有 3 个未提交的更改[0m

 M .ralph/current/features.json
?? .ralph/current/progress.md
?? .ralph/current/task.md

[1;33m建议: AI 应该提交这些更改以保持干净状态[0m

[0;34m[3/3][0m 执行功能验证...

正在验证 passes:true 的功能...

  验证 [F001]: Vue组件ScoreCloudBackground.vue已创建并集成到Home...
    命令: test -f frontend/src/components/ScoreCloudBackground.vue
    [0;32m✅ 通过[0m

  验证 [F002]: Canvas蘑菇云形态视觉效果 - 粒子基于分数分布呈现蘑菇云形状...
    命令: grep -q 'canvas' frontend/src/components/ScoreCloudBackground.vue
    [0;32m✅ 通过[0m

  验证 [F003]: 区县数据展示 - 每个区县用气泡展示详情...
    命令: grep -q 'district' frontend/src/components/ScoreCloudBackground.vue
```

**要求**: 修复上述错误后重新运行。


---

## 第 5 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[0;34m[1/3][0m 检查完成信号...
[0;31m❌ AI 未输出 MISSION_COMPLETE 信号[0m
   AI 需要在完成任务后输出 MISSION_COMPLETE
```

**要求**: 修复上述错误后重新运行。


---

## 第 6 轮失败

```
════════════════════════════════════════════════════════
  Stop Hook: 验证
════════════════════════════════════════════════════════

[0;34m[1/3][0m 检查完成信号...
[0;32m✅ AI 已声称完成 (MISSION_COMPLETE)[0m

[0;34m[2/3][0m 检查工作区状态...
[0;32m✅ 工作区状态干净[0m

[0;34m[3/3][0m 执行功能验证...

正在验证 passes:true 的功能...

  验证 [F001]: Vue组件ScoreCloudBackground.vue已创建并集成到Home...
    命令: test -f frontend/src/components/ScoreCloudBackground.vue
    [0;32m✅ 通过[0m

  验证 [F002]: Canvas蘑菇云形态视觉效果 - 粒子基于分数分布呈现蘑菇云形状...
    命令: grep -q 'canvas' frontend/src/components/ScoreCloudBackground.vue
    [0;32m✅ 通过[0m

  验证 [F003]: 区县数据展示 - 每个区县用气泡展示详情...
    命令: grep -q 'district' frontend/src/components/ScoreCloudBackground.vue
    [0;32m✅ 通过[0m

  验证 [F004]: 悬停交互 - 高亮当前分数段并显示区县详细信息浮层...
    命令: grep -q 'hover\\|mouseover\\|mouseenter' frontend/src/components/ScoreCloudBackground.vue
    [0;31m❌ 失败[0m
```

**要求**: 修复上述错误后重新运行。

