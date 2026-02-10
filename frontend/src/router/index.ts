import { createRouter, createWebHistory } from 'vue-router';
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/HomeView.vue'),
    meta: { title: '首页' },
  },
  {
    path: '/form',
    name: 'Form',
    component: () => import('@/views/FormView.vue'),
    meta: { title: '志愿填报' },
  },
  {
    path: '/result/:id',
    name: 'Result',
    component: () => import('@/views/ResultView.vue'),
    props: true,
    meta: { title: '分析结果' },
  },
  {
    path: '/history',
    name: 'History',
    component: () => import('@/views/HistoryView.vue'),
    meta: { title: '历史记录' },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFoundView.vue'),
    meta: { title: '页面不存在' },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// 路由守卫 - 更新页面标题
router.beforeEach((to, from, next) => {
  const title = to.meta.title as string;
  if (title) {
    document.title = `${title} - 上海中考招生模拟系统`;
  }
  next();
});

export default router;
