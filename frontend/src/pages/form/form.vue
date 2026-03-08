<template>
  <view class="page-container">
    <view class="placeholder">
      <uni-icons type="compose" size="64" color="#409EFF" />
      <text class="placeholder-title">志愿填报</text>
      <text class="placeholder-desc">该功能正在开发中，敬请期待...</text>
      <AppButton type="primary" @click="goBack">返回首页</AppButton>
    </view>
  </view>
</template>

<script setup lang="ts">
import { AppButton } from '@/components/common'

function goBack() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 40rpx;
  background-color: #f5f7fa;
}

.placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.placeholder-title {
  font-size: 36rpx;
  font-weight: 600;
  color: #303133;
  margin-top: 24rpx;
  margin-bottom: 16rpx;
}

.placeholder-desc {
  font-size: 28rpx;
  color: #909399;
  margin-bottom: 40rpx;
}
</style>
