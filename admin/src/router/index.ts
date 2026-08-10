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

router.beforeEach((to) => {
  const auth = useAuthStore();
  if (!auth.loggedIn && to.path !== "/login") return "/login";
});

export default router;
