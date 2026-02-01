<template>
  <view class="page">
    <scroll-view scroll-y class="scroll-container">
      <view class="container">
        <!-- 策略评分 -->
        <view class="card strategy-card">
          <text class="section-title">策略评分</text>
          <view class="strategy-score">
            <text
              class="strategy-score-value"
              :class="strategyScoreClass"
            >
              {{ strategyScore }}
            </text>
            <text class="strategy-score-label">分</text>
          </view>
          <view
            class="strategy-grade"
            :class="strategyGradeClass"
          >
            {{ strategyGrade.label }}
          </view>
        </view>

        <!-- 梯度分析 -->
        <view class="card">
          <text class="section-title">梯度分析</text>
          <view class="gradient-chart">
            <view class="gradient-item">
              <view class="gradient-bar risky">
                <text class="gradient-count">{{ gradient.reach }}</text>
              </view>
              <text class="gradient-label">冲刺</text>
            </view>
            <view class="gradient-item">
              <view class="gradient-bar moderate">
                <text class="gradient-count">{{ gradient.target }}</text>
              </view>
              <text class="gradient-label">稳妥</text>
            </view>
            <view class="gradient-item">
              <view class="gradient-bar safe">
                <text class="gradient-count">{{ gradient.safety }}</text>
              </view>
              <text class="gradient-label">保底</text>
            </view>
          </view>
        </view>

        <!-- 各志愿录取概率 -->
        <view class="card">
          <text class="section-title">各志愿录取概率</text>
          <view class="probability-list">
            <view
              v-for="prob in probabilities"
              :key="`${prob.batch}-${prob.schoolId}`"
              class="probability-item"
              @tap="showSchoolDetail(prob)"
            >
              <view class="probability-header">
                <text class="school-name">{{ prob.schoolName }}</text>
                <view
                  class="probability-tag"
                  :class="`probability-tag-${prob.riskLevel}`"
                >
                  {{ formatRiskLevel(prob.riskLevel) }}
                </view>
              </view>
              <view class="probability-bar-container">
                <view
                  class="probability-bar"
                  :style="{ width: `${prob.probability}%` }"
                ></view>
              </view>
              <view class="probability-value">
                <text class="percentage">{{ prob.probability }}%</text>
                <text v-if="prob.scoreDiff" class="score-diff">
                  {{ prob.scoreDiff > 0 ? '+' : '' }}{{ prob.scoreDiff }}
                </text>
              </view>
            </view>
          </view>
        </view>

        <!-- 建议与警告 -->
        <view v-if="suggestions.length || warnings.length" class="card">
          <text class="section-title">分析建议</text>

          <view v-if="warnings.length" class="warning-list">
            <view
              v-for="(warning, index) in warnings"
              :key="index"
              class="warning-item"
            >
              <text class="warning-icon">⚠️</text>
              <text class="warning-text">{{ warning }}</text>
            </view>
          </view>

          <view v-if="suggestions.length" class="suggestion-list">
            <view
              v-for="(suggestion, index) in suggestions"
              :key="index"
              class="suggestion-item"
            >
              <text class="suggestion-icon">💡</text>
              <text class="suggestion-text">{{ suggestion }}</text>
            </view>
          </view>
        </view>

        <!-- 操作按钮 -->
        <view class="actions">
          <button class="btn btn-default" @tap="goToHistory">历史记录</button>
          <button class="btn btn-primary" @tap="goToForm">重新分析</button>
        </view>

        <button class="btn btn-default btn-block" @tap="exportPDF">
          导出PDF报告
        </button>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useSimulationStore } from '@/stores/simulation';
import type { SimulationResult } from '@shared/types/simulation';
import { formatStrategyGrade } from '@/utils/format';

const simulationStore = useSimulationStore();

const result = ref<SimulationResult | null>(null);

const strategyScore = computed(() => result.value?.strategy.score || 0);
const gradient = computed(() => result.value?.strategy.gradient || { reach: 0, target: 0, safety: 0 });
const probabilities = computed(() => result.value?.probabilities || []);
const suggestions = computed(() => result.value?.strategy.suggestions || []);
const warnings = computed(() => result.value?.strategy.warnings || []);

const strategyScoreClass = computed(() => {
  const score = strategyScore.value;
  if (score >= 90) return 'score-excellent';
  if (score >= 75) return 'score-good';
  if (score >= 60) return 'score-fair';
  return 'score-poor';
});

const strategyGrade = computed(() => formatStrategyGrade(strategyScore.value));
const strategyGradeClass = computed(() => `strategy-grade-${strategyGrade.value.class}`);

onMounted(() => {
  // 从路由参数获取分析结果
  const pages = getCurrentPages();
  const currentPage = pages[pages.length - 1] as any;
  const options = currentPage.options;

  if (options.result) {
    try {
      result.value = JSON.parse(decodeURIComponent(options.result));
      simulationStore.setResult(result.value);
    } catch (error) {
      console.error('Failed to parse result:', error);
    }
  } else if (simulationStore.currentAnalysis.result) {
    result.value = simulationStore.currentAnalysis.result;
  }

  if (!result.value) {
    uni.showToast({
      title: '未找到分析结果',
      icon: 'none'
    });
    setTimeout(() => {
      uni.navigateBack();
    }, 1500);
  }
});

function formatRiskLevel(level: string): string {
  const map: Record<string, string> = {
    safe: '保底',
    moderate: '稳妥',
    risky: '冲刺',
    high_risk: '高风险',
  };
  return map[level] || level;
}

function showSchoolDetail(prob: any) {
  uni.showModal({
    title: prob.schoolName,
    content: `录取概率: ${prob.probability}%\n风险等级: ${formatRiskLevel(prob.riskLevel)}`,
    showCancel: false,
  });
}

function goToHistory() {
  uni.navigateTo({
    url: '/pages/history/index'
  });
}

function goToForm() {
  uni.redirectTo({
    url: '/pages/form/index'
  });
}

function exportPDF() {
  uni.showToast({
    title: '导出功能开发中',
    icon: 'none'
  });
}
</script>

<style lang="scss" scoped>
@import '@/styles/index.scss';

.scroll-container {
  height: 100vh;
}

.strategy {
  &-card {
    text-align: center;
    padding: 48rpx 24rpx;
  }

  &-score {
    display: flex;
    align-items: baseline;
    justify-content: center;
    margin: 32rpx 0;

    &-value {
      font-size: 120rpx;
      font-weight: 700;
      line-height: 1;

      &.score-excellent { color: #52c41a; }
      &.score-good { color: #1890ff; }
      &.score-fair { color: #faad14; }
      &.score-poor { color: #ff4d4f; }
    }

    &-label {
      font-size: 32rpx;
      color: #8c8c8c;
      margin-left: 8rpx;
    }
  }
}

.gradient {
  &-chart {
    display: flex;
    justify-content: space-around;
    padding: 32rpx 0;
  }

  &-item {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  &-bar {
    width: 120rpx;
    height: 120rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 16rpx;

    &.risky { background-color: #fff7e6; }
    &.moderate { background-color: #e6f7ff; }
    &.safe { background-color: #f6ffed; }
  }

  &-count {
    font-size: 48rpx;
    font-weight: 700;
  }

  &-label {
    font-size: 24rpx;
    color: #8c8c8c;
  }
}

.probability {
  &-list {
    display: flex;
    flex-direction: column;
    gap: 24rpx;
  }

  &-item {
    padding: 16rpx 0;
  }

  &-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12rpx;
  }

  &-tag {
    padding: 4rpx 12rpx;
    border-radius: 4rpx;
    font-size: 24rpx;

    &-safe { background-color: #f6ffed; color: #52c41a; }
    &-moderate { background-color: #e6f7ff; color: #1890ff; }
    &-risky { background-color: #fff7e6; color: #faad14; }
    &-high-risk { background-color: #fff1f0; color: #ff4d4f; }
  }

  &-bar-container {
    height: 16rpx;
    background-color: #f0f0f0;
    border-radius: 8rpx;
    overflow: hidden;
    margin-bottom: 8rpx;
  }

  &-bar {
    height: 100%;
    background: linear-gradient(90deg, #1890ff 0%, #52c41a 100%);
    border-radius: 8rpx;
    transition: width 0.3s;
  }

  &-value {
    display: flex;
    justify-content: space-between;
    font-size: 24rpx;
  }

  .percentage {
    font-weight: 600;
    color: #1890ff;
  }

  .score-diff {
    color: #8c8c8c;
  }
}

.warning {
  &-list {
    margin-bottom: 24rpx;
  }

  &-item {
    display: flex;
    align-items: flex-start;
    padding: 16rpx;
    background-color: #fff1f0;
    border-radius: 8rpx;
    margin-bottom: 12rpx;
  }

  &-icon {
    margin-right: 12rpx;
  }

  &-text {
    flex: 1;
    font-size: 26rpx;
    color: #cf1322;
    line-height: 1.5;
  }
}

.suggestion {
  &-item {
    display: flex;
    align-items: flex-start;
    padding: 16rpx;
    background-color: #f6ffed;
    border-radius: 8rpx;
    margin-bottom: 12rpx;
  }

  &-icon {
    margin-right: 12rpx;
  }

  &-text {
    flex: 1;
    font-size: 26rpx;
    color: #389e0d;
    line-height: 1.5;
  }
}

.actions {
  display: flex;
  gap: 16rpx;
  margin: 32rpx 0 16rpx;
}

.actions .btn {
  flex: 1;
}
</style>
