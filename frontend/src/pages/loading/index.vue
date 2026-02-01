<template>
  <view class="page loading-page">
    <view class="loading-content">
      <!-- 动画 -->
      <view class="loading-spinner"></view>

      <!-- 状态文本 -->
      <text class="loading-text">{{ loadingText }}</text>

      <!-- 进度条 -->
      <view class="progress-bar-container">
        <view class="progress-bar" :style="{ width: `${progress}%` }"></view>
      </view>
      <text class="progress-text">{{ progress }}%</text>

      <!-- 当前阶段 -->
      <view class="stage-list">
        <view
          v-for="(stage, index) in stages"
          :key="index"
          class="stage-item"
          :class="{
            active: currentStage === index,
            completed: currentStage > index
          }"
        >
          <view class="stage-icon">
            <text v-if="currentStage > index">✓</text>
            <text v-else>{{ index + 1 }}</text>
          </view>
          <text class="stage-text">{{ stage }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { submitAnalysis } from '@/api';
import type { SubmitAnalysisRequest } from '@shared/types/simulation';

const loadingText = ref('正在分析中...');
const progress = ref(0);
const currentStage = ref(0);

const stages = [
  '验证数据',
  '预测排名',
  '生成竞争对手',
  '执行模拟',
  '分析策略',
  '生成报告'
];

let analysisId: string | null = null;
let progressTimer: number | null = null;

onMounted(async () => {
  // 获取传递的数据
  const pages = getCurrentPages();
  const currentPage = pages[pages.length - 1] as any;
  const options = currentPage.options;

  let data: SubmitAnalysisRequest | null = null;

  if (options.data) {
    try {
      data = JSON.parse(decodeURIComponent(options.data));
    } catch (error) {
      console.error('Failed to parse data:', error);
      uni.showToast({
        title: '数据解析失败',
        icon: 'none'
      });
      setTimeout(() => {
        uni.navigateBack();
      }, 1500);
      return;
    }
  }

  if (!data) {
    uni.showToast({
      title: '缺少数据',
      icon: 'none'
    });
    setTimeout(() => {
      uni.navigateBack();
    }, 1500);
    return;
  }

  // 开始模拟进度
  startProgressSimulation();

  // 提交分析请求
  try {
    const response = await submitAnalysis(data);
    analysisId = response.id;

    if (response.status === 'completed' && response.results) {
      // 分析完成，跳转到结果页
      goToResult(response.results);
    } else if (response.status === 'processing') {
      // 等待WebSocket更新（这里简化处理）
      // 实际应该通过WebSocket监听进度
      waitForCompletion();
    }
  } catch (error: any) {
    uni.showToast({
      title: error.message || '分析失败',
      icon: 'none'
    });
    setTimeout(() => {
      uni.navigateBack();
    }, 2000);
  }
});

function startProgressSimulation() {
  let currentProgress = 0;
  progress.value = 0;
  currentStage.value = 0;

  progressTimer = setInterval(() => {
    if (currentProgress >= 100) {
      if (progressTimer) {
        clearInterval(progressTimer);
        progressTimer = null;
      }
      return;
    }

    // 随机增加进度
    const increment = Math.random() * 5 + 1;
    currentProgress = Math.min(100, currentProgress + increment);
    progress.value = Math.round(currentProgress);

    // 更新阶段
    if (currentProgress > 80) {
      currentStage.value = 5;
      loadingText.value = '正在生成报告...';
    } else if (currentProgress > 60) {
      currentStage.value = 4;
      loadingText.value = '正在分析策略...';
    } else if (currentProgress > 40) {
      currentStage.value = 3;
      loadingText.value = '正在执行模拟...';
    } else if (currentProgress > 20) {
      currentStage.value = 2;
      loadingText.value = '正在生成竞争对手...';
    } else if (currentProgress > 10) {
      currentStage.value = 1;
      loadingText.value = '正在预测排名...';
    } else {
      currentStage.value = 0;
      loadingText.value = '正在验证数据...';
    }
  }, 500);
}

async function waitForCompletion() {
  // 简化处理：定时检查结果
  // 实际应该使用WebSocket
  const { getAnalysisResult } = await import('@/api');

  const checkInterval = setInterval(async () => {
    if (!analysisId) {
      clearInterval(checkInterval);
      return;
    }

    try {
      const response = await getAnalysisResult(analysisId);

      if (response.status === 'completed' && response.results) {
        clearInterval(checkInterval);
        goToResult(response.results);
      } else if (response.status === 'failed') {
        clearInterval(checkInterval);
        uni.showToast({
          title: response.error || '分析失败',
          icon: 'none'
        });
        setTimeout(() => {
          uni.navigateBack();
        }, 2000);
      }
    } catch (error) {
      console.error('Failed to check result:', error);
    }
  }, 2000);
}

function goToResult(result: any) {
  if (progressTimer) {
    clearInterval(progressTimer);
    progressTimer = null;
  }

  progress.value = 100;
  currentStage.value = 5;

  setTimeout(() => {
    uni.redirectTo({
      url: `/pages/result/index?result=${encodeURIComponent(JSON.stringify(result))}`
    });
  }, 500);
}
</script>

<style lang="scss" scoped>
@import '@/styles/index.scss';

.loading {
  &-page {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  &-content {
    width: 600rpx;
    padding: 48rpx;
    background-color: rgba(255, 255, 255, 0.95);
    border-radius: 24rpx;
    box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.1);
  }
}

.spinner {
  width: 80rpx;
  height: 80rpx;
  margin: 0 auto 32rpx;
  border: 4rpx solid rgba(24, 144, 255, 0.2);
  border-top-color: #1890ff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.loading-text {
  display: block;
  text-align: center;
  font-size: 32rpx;
  font-weight: 500;
  color: #1a1a1a;
  margin-bottom: 32rpx;
}

.progress {
  &-bar-container {
    height: 16rpx;
    background-color: #f0f0f0;
    border-radius: 8rpx;
    overflow: hidden;
    margin-bottom: 12rpx;
  }

  &-bar {
    height: 100%;
    background: linear-gradient(90deg, #1890ff 0%, #52c41a 100%);
    border-radius: 8rpx;
    transition: width 0.3s ease;
  }

  &-text {
    display: block;
    text-align: center;
    font-size: 24rpx;
    color: #8c8c8c;
    margin-bottom: 32rpx;
  }
}

.stage {
  &-list {
    display: flex;
    flex-direction: column;
    gap: 16rpx;
  }

  &-item {
    display: flex;
    align-items: center;
    padding: 16rpx;
    border-radius: 8rpx;
    background-color: #f5f5f5;
    transition: all 0.3s;

    &.active {
      background-color: #e6f7ff;
      border: 1rpx solid #1890ff;
    }

    &.completed {
      background-color: #f6ffed;
      border: 1rpx solid #52c41a;

      .stage-icon {
        background-color: #52c41a;
        color: #fff;
      }
    }
  }

  &-icon {
    width: 48rpx;
    height: 48rpx;
    border-radius: 50%;
    background-color: #d9d9d9;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24rpx;
    font-weight: 600;
    color: #fff;
    margin-right: 16rpx;
  }

  &-text {
    font-size: 28rpx;
    color: #595959;
  }

  &-item.active .stage-text {
    color: #1890ff;
  }

  &-item.completed .stage-text {
    color: #52c41a;
  }
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
