import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 5173,
    proxy: {
      // Connect-RPC 服务路径
      '/highschool.v1': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
      // 健康检查路径
      '/health': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },

});
