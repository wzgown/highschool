<template>
  <el-container style="height:100vh">
    <el-aside width="180px" style="background:#f5f7fa;padding:12px;display:flex;flex-direction:column">
      <h4 style="margin:8px 0">管理后台</h4>
      <el-menu :router="true" default-active="/sessions" style="flex:1;border-right:none">
        <el-menu-item index="/sessions">会话回放</el-menu-item>
        <el-menu-item index="/cost">成本审计</el-menu-item>
        <el-menu-item index="/alerts">告警</el-menu-item>
        <el-menu-item index="/flags">开关</el-menu-item>
      </el-menu>
      <el-button type="danger" plain style="margin-top:8px" @click="onLogout">退出登录</el-button>
    </el-aside>
    <el-main><router-view /></el-main>
  </el-container>
</template>
<script setup lang="ts">
import { ElContainer, ElAside, ElMain, ElMenu, ElMenuItem, ElButton } from "element-plus";
import { useRouter } from "vue-router";
import { useAuthStore } from "../stores/auth";

const router = useRouter();
const auth = useAuthStore();

async function onLogout() {
  await auth.logout();
  router.push("/login");
}
</script>
