import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "../stores/auth";

const router = createRouter({
  history: createWebHistory("/admin/"),
  routes: [
    { path: "/login", component: () => import("../views/Login.vue") },
    {
      path: "/",
      component: () => import("../layouts/AdminLayout.vue"),
      children: [
        { path: "sessions", component: () => import("../views/SessionList.vue") },
        { path: "replay/:id", component: () => import("../views/SessionReplay.vue") },
      ],
    },
  ],
});

// 启动探针：刷新后用 admin_sess cookie 复活登录态，避免误踢到 /login。
// probed 标志保证探针全程只跑一次（不会循环）。
router.beforeEach(async (to) => {
  const auth = useAuthStore();
  if (!auth.probed) {
    await auth.init();
  }
  if (!auth.loggedIn && to.path !== "/login") return "/login";
});

export default router;
