<template>
  <view class="page">
    <!-- 头部 -->
    <view class="header">
      <image class="header-bg" src="/static/header-bg.png" mode="aspectFill" />
      <view class="header-content">
        <text class="header-title">上海中考招生模拟系统</text>
        <text class="header-subtitle">智能分析志愿填报策略</text>
      </view>
    </view>

    <!-- 功能卡片 -->
    <view class="container">
      <view class="feature-grid">
        <view class="feature-card" @tap="goToForm">
          <view class="feature-icon">📊</view>
          <text class="feature-title">志愿分析</text>
          <text class="feature-desc">输入成绩和志愿，获取录取概率分析</text>
        </view>

        <view class="feature-card" @tap="goToHistory">
          <view class="feature-icon">📋</view>
          <text class="feature-title">历史记录</text>
          <text class="feature-desc">查看历史分析记录</text>
        </view>

        <view class="feature-card" @tap="goToReference">
          <view class="feature-icon">📚</view>
          <text class="feature-title">参考数据</text>
          <text class="feature-desc">历年分数线和招生计划</text>
        </view>

        <view class="feature-card" @tap="goToAbout">
          <view class="feature-icon">ℹ️</view>
          <text class="feature-title">关于系统</text>
          <text class="feature-desc">了解系统功能和使用说明</text>
        </view>
      </view>

      <!-- 快速开始 -->
      <view class="quick-start">
        <text class="quick-start-title">快速开始</text>
        <text class="quick-start-desc">只需3步，获取专业志愿分析报告</text>

        <view class="steps">
          <view class="step">
            <view class="step-number">1</view>
            <text class="step-text">填写考生信息</text>
          </view>
          <view class="step-arrow">→</view>
          <view class="step">
            <view class="step-number">2</view>
            <text class="step-text">选择目标学校</text>
          </view>
          <view class="step-arrow">→</view>
          <view class="step">
            <view class="step-number">3</view>
            <text class="step-text">获取分析报告</text>
          </view>
        </view>

        <button class="btn btn-primary btn-block btn-large" @tap="goToForm">
          立即开始
        </button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { onLoad } from '@dcloudio/uni-app';

onLoad(() => {
  uni.setNavigationBarTitle({
    title: '首页'
  });
});

function goToForm() {
  uni.navigateTo({
    url: '/pages/form/index'
  });
}

function goToHistory() {
  uni.navigateTo({
    url: '/pages/history/index'
  });
}

function goToReference() {
  uni.showToast({
    title: '功能开发中',
    icon: 'none'
  });
}

function goToAbout() {
  uni.showToast({
    title: '功能开发中',
    icon: 'none'
  });
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background-color: #f5f5f5;
}

.header {
  position: relative;
  height: 400rpx;
  overflow: hidden;

  &-bg {
    width: 100%;
    height: 100%;
  }

  &-content {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: linear-gradient(180deg, rgba(24, 144, 255, 0.8) 0%, rgba(24, 144, 255, 0.6) 100%);
  }

  &-title {
    font-size: 48rpx;
    font-weight: 700;
    color: #fff;
    margin-bottom: 16rpx;
  }

  &-subtitle {
    font-size: 28rpx;
    color: rgba(255, 255, 255, 0.9);
  }
}

.container {
  padding: 24rpx;
  margin-top: -60rpx;
}

.feature {
  &-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24rpx;
  }

  &-card {
    background-color: #fff;
    border-radius: 16rpx;
    padding: 32rpx 24rpx;
    display: flex;
    flex-direction: column;
    align-items: center;
    box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.05);
  }

  &-icon {
    font-size: 64rpx;
    margin-bottom: 16rpx;
  }

  &-title {
    font-size: 28rpx;
    font-weight: 600;
    color: #1a1a1a;
    margin-bottom: 8rpx;
  }

  &-desc {
    font-size: 24rpx;
    color: #8c8c8c;
    text-align: center;
  }
}

.quick {
  &-start {
    background-color: #fff;
    border-radius: 16rpx;
    padding: 32rpx 24rpx;
    margin-top: 24rpx;
    box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.05);
  }

  &-start-title {
    font-size: 32rpx;
    font-weight: 600;
    color: #1a1a1a;
    display: block;
    margin-bottom: 8rpx;
  }

  &-start-desc {
    font-size: 24rpx;
    color: #8c8c8c;
    display: block;
    margin-bottom: 24rpx;
  }
}

.steps {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 32rpx;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;

  &-number {
    width: 56rpx;
    height: 56rpx;
    background: linear-gradient(135deg, #1890ff 0%, #096dd9 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28rpx;
    font-weight: 600;
    color: #fff;
    margin-bottom: 8rpx;
  }

  &-text {
    font-size: 24rpx;
    color: #595959;
  }
}

.step-arrow {
  font-size: 32rpx;
  color: #d9d9d9;
  margin: 0 8rpx;
}
</style>
