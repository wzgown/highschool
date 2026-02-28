# 开发笔记

## 已知问题和解决方案

### Proto 生成问题

**问题**：修改 `.proto` 文件后，前后端类型不同步
**解决**：每次修改 proto 后必须运行 `cd proto && buf generate`

### 数据库连接

**问题**：开发环境数据库未启动
**解决**：`docker compose up -d` 启动 PostgreSQL 和 Redis

### 成绩校验

**问题**：用户输入的总分与各科成绩之和不匹配
**解决**：前端实时校验，后端再次校验

## 开发约定

### 代码风格

- Go：使用 `gofmt` 格式化，`golangci-lint` 检查
- TypeScript：使用 `vue-tsc` 进行类型检查

### Git 提交

- feat: 新功能
- fix: 修复 bug
- refactor: 重构
- test: 测试相关
- docs: 文档更新

### 分支策略

- main: 主分支，保持稳定
- feature/*: 功能开发分支
- fix/*: bug 修复分支

## 环境变量

### 后端配置 (`config.yaml`)

```yaml
server:
  host: 0.0.0.0
  port: 3000

database:
  host: localhost
  port: 5432
  name: highschool
  user: highschool
  password: HS2025!db#SecurePass88
```

### 数据库 Docker 配置

- PostgreSQL 15 Alpine
- 默认用户：highschool
- 默认密码：HS2025!db#SecurePass88
- 默认数据库：highschool

## 性能指标

- 单次模拟分析响应时间 < 5秒
- 支持 1000 次蒙特卡洛模拟
- 并发用户数 > 100
