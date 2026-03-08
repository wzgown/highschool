<template>
  <div class="not-found-view">
    <el-result
      icon="warning"
      title="404"
      sub-title="抱歉，您访问的页面不存在"
    >
      <template #extra>
        <el-button type="primary" @click="goHome">
          <el-icon><HomeFilled /></el-icon>
          返回首页
        </el-button>
      </template>
    </el-result>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';
import { HomeFilled } from '@element-plus/icons-vue';

const router = useRouter();

function goHome() {
  router.push('/');
}
</script>

<style lang="scss" scoped>
.not-found-view {
  padding: 60px 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}
</style>
