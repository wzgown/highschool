# 上海市2026年中考信息监控系统

## 系统说明

本系统使用 **AI Agent** 智能监控和收集上海市2026年中考相关信息，包括：
- 各区考生人数
- 各高中招生计划（分批次）
  - 自主招生
  - 名额分配到区
  - 名额分配到校
  - 统一招生

## 工作原理

系统不是简单的爬虫脚本，而是使用AI Agent智能分析和提取信息：

1. **智能访问**：Agent访问上海招考热线官网
2. **内容理解**：AI理解网页内容，识别2026年中考相关信息
3. **数据提取**：智能提取具体数字（考生人数、招生名额等）
4. **分类整理**：按批次和区域分类整理数据
5. **格式保存**：保存为结构化的CSV文件
6. **版本控制**：自动Git提交和推送数据变更

## 目录结构

```
/root/.openclaw/workspace/dev/personal/highschool/
├── scraper.py              # 主爬虫脚本
├── run_scraper.sh          # Cron执行脚本
├── scraper.log             # 运行日志
└── original_data/
    └── raw/
        └── 2026/
            ├── links_YYYYMMDD.csv          # 每日发现的链接
            ├── pdf_files_YYYYMMDD.csv      # 每日发现的PDF文件
            ├── candidates_district.csv     # 各区考生人数（待完善）
            ├── enrollment_autonomous.csv   # 自主招生计划（待完善）
            ├── enrollment_district.csv     # 名额分配到区（待完善）
            ├── enrollment_school.csv       # 名额分配到校（待完善）
            └── enrollment_unified.csv      # 统一招生计划（待完善）
```

## OpenClaw Cron配置

系统使用OpenClaw内置的cron功能，每天早上8点（Asia/Shanghai时区）自动运行。

### Git自动提交

系统会在每次抓取后自动将新数据提交到Git仓库：
- ✅ 自动 `git add` 新数据文件
- ✅ 自动 `git commit` 提交变更
- ✅ 自动 `git push` 推送到远程仓库（如已配置）

**配置远程仓库（首次使用）：**
```bash
cd /root/.openclaw/workspace
git remote add origin <你的仓库地址>
git push -u origin master
```

### 管理命令

查看cron配置：
```bash
openclaw cron list
```

手动触发运行（测试）：
```bash
openclaw cron run highschool-scraper
```

查看运行历史：
```bash
openclaw cron runs highschool-scraper
```

### 任务详情

- **任务名称**: highschool-scraper
- **执行时间**: 每天 08:00 (Asia/Shanghai)
- **执行模式**: isolated session（隔离环境，独立的AI Agent）
- **结果通知**: 自动发送到 #highschool Discord频道
- **Git提交**: 自动提交并推送数据变更

### 配置远程仓库（首次使用）

本目录已经是Git仓库，如需自动推送数据到远程仓库，请配置：

```bash
cd /root/.openclaw/workspace/dev/personal/highschool
git remote add origin <你的GitHub/GitLab仓库URL>
git push -u origin master
```

配置后，AI Agent会在每次收集数据后自动：
1. `git add` 新数据
2. `git commit` 提交变更
3. `git push` 推送到远程仓库

### Agent工作流程

每天早上8点，AI Agent会：

1. 🌐 访问上海招考热线网站
2. 🧠 智能分析网页内容
3. 📊 提取2026年中考数据：
   - 各区考生人数
   - 各高中招生计划（自主招生、名额分配、统一招生等）
4. 💾 保存为CSV文件（自动命名）
5. 📤 Git提交并推送到远程仓库
6. 📱 发送总结报告到Discord

### 手动测试

手动触发一次收集任务：
```bash
openclaw cron run highschool-scraper
```

## 数据格式

### links_YYYYMMDD.csv
发现的2026年相关链接：
- 日期：抓取日期
- 标题：链接标题
- 链接：完整URL
- 分类：自主招生/名额分配到区/名额分配到校/统一招生/考生信息/其他

### pdf_files_YYYYMMDD.csv
发现的PDF文件：
- 日期：发现日期
- 标题：PDF文件标题
- PDF链接：下载链接
- 分类：招生批次分类

## 后续改进计划

1. **PDF解析**：自动下载并解析PDF文件中的表格数据
2. **数据提取**：从页面中提取具体的考生人数和招生计划数字
3. **变更检测**：对比历史数据，检测新增或变更的信息
4. **通知机制**：发现重要更新时发送通知
5. **数据可视化**：创建数据统计和可视化报表

## 注意事项

- 脚本运行需要Python 3和以下库：requests, beautifulsoup4, lxml
- 请遵守网站的robots.txt和使用条款
- 建议不要过于频繁地访问，以免对服务器造成压力
- 当前设置每天运行一次，如有需要可以调整频率

## 维护日志

- 2026-02-28：系统创建，基础爬虫脚本完成
