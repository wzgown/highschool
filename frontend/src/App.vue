<template>
  <view class="app">
    <router-view />
  </view>
</template>

<script setup lang="ts">
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app';

onLaunch(() => {
  console.log('App Launch');
  // 初始化设备指纹
  initDeviceFingerprint();
});

onShow(() => {
  console.log('App Show');
});

onHide(() => {
  console.log('App Hide');
});

// 初始化设备指纹
async function initDeviceFingerprint() {
  // 获取系统信息
  const systemInfo = uni.getSystemInfoSync();

  // 存储设备信息到本地
  const deviceInfo = {
    platform: systemInfo.uniPlatform || 'unknown',
    brand: systemInfo.brand,
    model: systemInfo.model,
    system: systemInfo.system,
    screenWidth: systemInfo.screenWidth,
    screenHeight: systemInfo.screenHeight,
  };

  uni.setStorageSync('deviceInfo', deviceInfo);

  // 生成设备ID（简化版，实际应该使用更复杂的算法）
  let deviceId = uni.getStorageSync('deviceId');

  if (!deviceId) {
    deviceId = `device-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    uni.setStorageSync('deviceId', deviceId);
  }
}
</script>

<style lang="scss">
@import './styles/index.scss';

.app {
  width: 100%;
  height: 100%;
}
</style>
