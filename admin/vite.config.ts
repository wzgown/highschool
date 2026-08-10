import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  base: "/admin/",
  server: {
    port: 5174,
    proxy: {
      "/highschool.v1": { target: "http://localhost:3000", changeOrigin: true },
      "/admin/api": { target: "http://localhost:3000", changeOrigin: true },
    },
  },
  build: { outDir: "../backend/internal/api/v1/admin_dist", emptyOutDir: true },
});
