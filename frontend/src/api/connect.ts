// Connect-RPC 客户端
import { createConnectTransport } from "@connectrpc/connect-web";
import { createClient, type Client } from "@connectrpc/connect";
import { ReferenceService } from "@/gen/highschool/v1/reference_service_connect";
import { CandidateService } from "@/gen/highschool/v1/candidate_service_connect";

// 创建传输层
const transport = createConnectTransport({
  baseUrl: import.meta.env.VITE_API_BASE_URL || "",
  // 使用 fetch 的 credentials: "include" 来支持跨域 cookies
  fetchOptions: {
    credentials: "include",
  },
});

// 创建 ReferenceService 客户端
export const referenceClient = createClient(ReferenceService, transport);

// 创建 CandidateService 客户端
export const candidateClient = createClient(CandidateService, transport);

// 导出类型
export type { Client };
