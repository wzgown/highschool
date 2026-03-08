<template>
  <view class="app-loading" :class="{ 'app-loading--fullscreen': fullscreen }">
    <view v-if="type === 'spinner'" class="app-loading__spinner">
      <view class="spinner" />
    </view>

    <view v-else-if="type === 'dots'" class="app-loading__dots">
      <view class="dot dot--1" />
      <view class="dot dot--2" />
      <view class="dot dot--3" />
    </view>

    <text v-if="text" class="app-loading__text">{{ text }}</text>
  </view>
</template>

<script setup lang="ts">
type LoadingType = 'spinner' | 'dots'

interface Props {
  type?: LoadingType
  text?: string
  fullscreen?: boolean
}

withDefaults(defineProps<Props>(), {
  type: 'spinner',
  text: '',
  fullscreen: false
})
</script>

<style lang="scss" scoped>
.app-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32rpx;

  &--fullscreen {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(255, 255, 255, 0.9);
    z-index: 9999;
  }
}

.app-loading__spinner {
  .spinner {
    width: 64rpx;
    height: 64rpx;
    border: 4rpx solid #f3f3f3;
    border-top: 4rpx solid #409eff;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.app-loading__dots {
  display: flex;
  gap: 12rpx;

  .dot {
    width: 16rpx;
    height: 16rpx;
    background-color: #409eff;
    border-radius: 50%;
    animation: bounce 1.4s ease-in-out infinite both;

    &--1 {
      animation-delay: -0.32s;
    }

    &--2 {
      animation-delay: -0.16s;
    }

    &--3 {
      animation-delay: 0s;
    }
  }
}

@keyframes bounce {
  0%,
  80%,
  100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.app-loading__text {
  margin-top: 16rpx;
  font-size: 28rpx;
  color: #909399;
}
</style>
