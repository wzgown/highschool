<template>
  <view class="content">
    <view class="header">
      <text class="title">{{ title }}</text>
      <text class="subtitle">志愿填报模拟系统</text>
    </view>
    <view class="text-area">
      <text class="welcome">欢迎使用上海中考招生模拟系统</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const title = ref('上海中考招生模拟')
</script>

<style>
.content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40rpx;
}

.header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 60rpx;
}

.title {
  font-size: 44rpx;
  font-weight: bold;
  color: #409EFF;
  margin-bottom: 16rpx;
}

.subtitle {
  font-size: 28rpx;
  color: #666;
}

.text-area {
  display: flex;
  justify-content: center;
}

.welcome {
  font-size: 32rpx;
  color: #333;
}
</style>
