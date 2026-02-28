<template>
  <header class="app-header">
    <div class="header-content">
      <div class="logo" @click="goHome">
        <el-icon :size="28" color="#409EFF"><School /></el-icon>
        <span class="title">中考志愿模拟</span>
      </div>
      
      <nav class="nav-menu" v-if="!isMobile">
        <router-link to="/" class="nav-link" :class="{ active: $route.path === '/' }">
          首页
        </router-link>
        <router-link to="/form" class="nav-link" :class="{ active: $route.path === '/form' }">
          志愿填报
        </router-link>
        <router-link to="/history" class="nav-link" :class="{ active: $route.path === '/history' }">
          历史记录
        </router-link>
      </nav>
      
      <el-button 
        v-if="isMobile" 
        :icon="Menu" 
        circle 
        @click="drawerVisible = true"
      />
    </div>
    
    <!-- 移动端导航抽屉 -->
    <el-drawer
      v-model="drawerVisible"
      title="菜单"
      size="60%"
      direction="rtl"
    >
      <div class="mobile-nav">
        <router-link to="/" class="mobile-nav-link" @click="drawerVisible = false">
          <el-icon><HomeFilled /></el-icon>
          <span>首页</span>
        </router-link>
        <router-link to="/form" class="mobile-nav-link" @click="drawerVisible = false">
          <el-icon><EditPen /></el-icon>
          <span>志愿填报</span>
        </router-link>
        <router-link to="/history" class="mobile-nav-link" @click="drawerVisible = false">
          <el-icon><Clock /></el-icon>
          <span>历史记录</span>
        </router-link>
      </div>
    </el-drawer>
  </header>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Menu, School, HomeFilled, EditPen, Clock } from '@element-plus/icons-vue';

const route = useRoute();
const router = useRouter();
const drawerVisible = ref(false);

const isMobile = computed(() => window.innerWidth < 768);

function goHome() {
  router.push('/');
}
</script>

<style lang="scss" scoped>
.app-header {
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  
  .title {
    font-size: 20px;
    font-weight: 600;
    color: #303133;
  }
}

.nav-menu {
  display: flex;
  gap: 30px;
}

.nav-link {
  text-decoration: none;
  color: #606266;
  font-size: 15px;
  padding: 8px 16px;
  border-radius: 4px;
  transition: all 0.3s;
  
  &:hover {
    color: #409EFF;
    background: #ecf5ff;
  }
  
  &.active {
    color: #409EFF;
    font-weight: 500;
  }
}

.mobile-nav {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.mobile-nav-link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px;
  text-decoration: none;
  color: #303133;
  font-size: 16px;
  border-radius: 8px;
  transition: background 0.3s;
  
  &:hover {
    background: #f5f7fa;
  }
}
</style>
