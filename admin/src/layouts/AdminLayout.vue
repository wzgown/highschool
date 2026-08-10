<template>
  <el-container style="height:100vh">
    <el-aside width="180px" style="background:#f5f7fa;padding:12px">
      <h4 style="margin:8px 0">管理后台</h4>
      <el-menu :router="true" default-active="/sessions">
        <el-menu-item index="/sessions">会话回放</el-menu-item>
      </el-menu>
    </el-aside>
    <el-main><router-view /></el-main>
  </el-container>
</template>
<script setup lang="ts">
import { ElContainer, ElAside, ElMain, ElMenu, ElMenuItem } from "element-plus";
</script>
