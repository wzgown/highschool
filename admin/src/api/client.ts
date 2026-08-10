import { createClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-web";
import { AdminService } from "../gen/highschool/v1/admin_service_connect";

const transport = createConnectTransport({
  baseUrl: "/",
  credentials: "include" as RequestCredentials,
});

export const adminClient = createClient(AdminService, transport);

export async function login(password: string): Promise<void> {
  const res = await fetch("/admin/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify({ password }),
  });
  if (!res.ok) throw new Error("登录失败：" + res.status);
}

export async function logout(): Promise<void> {
  const res = await fetch("/admin/api/logout", {
    method: "POST",
    credentials: "include",
  });
  if (!res.ok) throw new Error("logout failed: " + res.status);
}
