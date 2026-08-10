import { defineStore } from "pinia";
import { ref } from "vue";
import { login as doLogin, logout as doLogout, adminClient } from "../api/client";

export const useAuthStore = defineStore("auth", () => {
  const loggedIn = ref(false);
  // 是否已完成启动探针（防止重复探针 + 给 router/UI 一个 ready 信号）
  const probed = ref(false);

  async function login(password: string) {
    await doLogin(password);
    loggedIn.value = true;
  }
  async function logout() {
    try { await doLogout(); } catch { /* best-effort：cookie 失效或网络错误都忽略 */ }
    loggedIn.value = false;
  }

  // 启动时一次性探针：用 listAgentSessions 探测 admin_sess cookie 是否仍有效。
  // 200 → loggedIn=true；401/错误 → 保持 false（留在 /login）。
  // 幂等：probed 为真则直接返回，避免循环。
  async function init() {
    if (probed.value) return;
    try {
      await adminClient.listAgentSessions({ page: 1, pageSize: 1 });
      loggedIn.value = true;
    } catch {
      loggedIn.value = false;
    } finally {
      probed.value = true;
    }
  }

  return { loggedIn, probed, login, logout, init };
});
