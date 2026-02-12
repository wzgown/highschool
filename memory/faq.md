# 常见问题

## 开发相关

### Q: 如何调试 Connect-RPC 请求？

A: 可以使用 curl 测试 HTTP/JSON 接口：

```bash
curl -X POST http://localhost:3000/highschool.v1.ReferenceService/GetDistricts \
  -H "Content-Type: application/json" \
  -H "Connect-Protocol-Version: 1" \
  -d '{}'
```

### Q: 如何查看数据库中的数据？

A: 使用 psql 连接：

```bash
psql -U highschool -d highschool
\dt           # 查看所有表
SELECT * FROM districts;
```

### Q: 前端如何调用后端 API？

A: 使用生成的 Connect-RPC 客户端：

```typescript
import { createPromiseClient } from '@connectrpc/connect';
import { ReferenceService } from '@/gen/highschool/v1/reference_connect';

const client = createPromiseClient(ReferenceService, transport);
const districts = await client.getDistricts({});
```

## 架构相关

### Q: 为什么使用 Connect-RPC 而不是 REST？

A:
- 类型安全：前后端共享 Protobuf 定义
- 支持 HTTP/JSON 和 gRPC 两种传输
- 自动生成客户端代码

### Q: Repository 层为什么使用接口？

A:
- 方便单元测试时使用 Mock
- 解耦具体数据库实现
- 符合依赖倒置原则

## 业务相关

### Q: 什么是名额分配到区/到校？

A:
- **名额分配到区**：市重点高中将部分招生计划分配到各区，全区排名竞争
- **名额分配到校**：市重点高中将部分招生计划分配到各初中，校内排名竞争

### Q: 同分如何比较？

A: 按6位序规则依次比较：
1. 同分优待 → 2. 综合素质评价 → 3. 语数外合计 → 4. 数学 → 5. 语文 → 6. 综合测试

### Q: 什么是平行志愿？

A: "分数优先、遵循志愿、一轮投档"的志愿填报方式
- 分数优先：高分考生优先投档
- 遵循志愿：按考生填报的志愿顺序检索
- 一轮投档：每个考生只有一次投档机会
