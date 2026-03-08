<template>
  <view class="result-view">
    <!-- 加载中 -->
    <view v-if="loading" class="loading-container">
      <view class="result-status">
        <uni-icons type="info" size="64" color="#409EFF" />
        <text class="status-title">分析进行中</text>
        <text class="status-subtitle">正在进行录取概率模拟计算，请稍候...</text>
        <text class="loading-hint">此过程可能需要 10-30 秒</text>
      </view>
      <view class="skeleton">
        <view class="skeleton-item" />
        <view class="skeleton-item short" />
        <view class="skeleton-item" />
      </view>
    </view>

    <!-- 错误 -->
    <view v-else-if="error" class="error-container">
      <view class="result-status">
        <uni-icons type="closeempty" size="64" color="#F56C6C" />
        <text class="status-title">分析失败</text>
        <text class="status-subtitle">{{ error }}</text>
      </view>
      <view class="action-buttons">
        <AppButton type="primary" @click="loadResult">重试</AppButton>
        <AppButton @click="goBack">返回</AppButton>
      </view>
    </view>

    <!-- 无数据 -->
    <view v-else-if="result && !result.results" class="error-container">
      <view class="result-status">
        <uni-icons type="info" size="64" color="#E6A23C" />
        <text class="status-title">暂无分析结果</text>
        <text class="status-subtitle">分析结果数据不完整</text>
      </view>
      <view class="action-buttons">
        <AppButton type="primary" @click="loadResult">重新加载</AppButton>
        <AppButton @click="goBack">返回</AppButton>
      </view>
    </view>

    <!-- 结果展示 -->
    <template v-else-if="result && result.results">
      <view class="result-header">
        <text class="result-title">志愿分析报告</text>
        <text class="result-time">生成时间：{{ formatTime(result.createdAt) }}</text>
      </view>

      <!-- 排名预测 -->
      <AppCard class="result-section">
        <template #header>
          <view class="section-header">
            <uni-icons type="bars" size="20" color="#409EFF" />
            <text class="section-title">区内排名预测</text>
          </view>
        </template>
        <view class="prediction-content">
          <view class="prediction-main">
            <text class="prediction-label">预测区内排名</text>
            <text class="prediction-value">{{ result.results.predictions?.districtRank }}</text>
            <view
              class="status-tag"
              :class="getConfidenceClass(result.results.predictions?.confidence)"
            >
              {{ getConfidenceText(result.results.predictions?.confidence) }}
            </view>
          </view>
          <text class="prediction-range">
            预测区间：{{ result.results.predictions?.districtRankRangeLow }} -
            {{ result.results.predictions?.districtRankRangeHigh }}
          </text>
        </view>
      </AppCard>

      <!-- 录取概率 -->
      <AppCard class="result-section">
        <template #header>
          <view class="section-header">
            <uni-icons type="chatbubble" size="20" color="#409EFF" />
            <text class="section-title">录取概率分析</text>
          </view>
        </template>
        <view class="probability-list">
          <view
            v-for="item in result.results.probabilities"
            :key="`${item.batch}-${item.schoolId}`"
            class="probability-item"
          >
            <view class="probability-info">
              <view class="probability-header">
                <view class="batch-tag" :class="getBatchClass(item.batch)">
                  {{ getBatchName(item.batch) }}
                </view>
                <text class="school-name">{{ item.schoolName }}</text>
              </view>
              <view class="probability-stats">
                <view class="progress-wrapper">
                  <view class="progress-bar">
                    <view
                      class="progress-inner"
                      :style="{ width: `${Math.round(item.probability)}%` }"
                      :class="getProgressClass(item.probability)"
                    />
                  </view>
                  <text class="progress-text">{{ Math.round(item.probability) }}%</text>
                </view>
                <view class="risk-tag" :class="getRiskClass(item.riskLevel)">
                  {{ getRiskText(item.riskLevel) }}
                </view>
              </view>
              <text v-if="item.scoreDiff !== undefined" class="score-diff">
                与历年分对比：{{ item.scoreDiff > 0 ? '+' : '' }}{{ item.scoreDiff.toFixed(0) }}分
              </text>
            </view>
          </view>
        </view>
      </AppCard>

      <!-- 策略分析 -->
      <AppCard class="result-section">
        <template #header>
          <view class="section-header">
            <uni-icons type="help" size="20" color="#409EFF" />
            <text class="section-title">志愿策略分析</text>
            <view class="score-tag" :class="getStrategyScoreClass(result.results.strategy?.score)">
              评分：{{ result.results.strategy?.score }}分
            </view>
          </view>
        </template>
        <view class="strategy-content">
          <view class="gradient-info">
            <text class="sub-title">志愿梯度分布</text>
            <view class="gradient-bars">
              <view class="gradient-item">
                <text class="gradient-label">冲刺</text>
                <view class="gradient-progress">
                  <view
                    class="gradient-fill reach"
                    :style="{ width: `${getGradientPercent('reach')}%` }"
                  />
                </view>
                <text class="gradient-count">{{ result.results.strategy?.gradient?.reach }}个</text>
              </view>
              <view class="gradient-item">
                <text class="gradient-label">稳妥</text>
                <view class="gradient-progress">
                  <view
                    class="gradient-fill target"
                    :style="{ width: `${getGradientPercent('target')}%` }"
                  />
                </view>
                <text class="gradient-count">{{ result.results.strategy?.gradient?.target }}个</text>
              </view>
              <view class="gradient-item">
                <text class="gradient-label">保底</text>
                <view class="gradient-progress">
                  <view
                    class="gradient-fill safety"
                    :style="{ width: `${getGradientPercent('safety')}%` }"
                  />
                </view>
                <text class="gradient-count">{{ result.results.strategy?.gradient?.safety }}个</text>
              </view>
            </view>
          </view>

          <view v-if="result.results.strategy?.suggestions.length" class="suggestions">
            <text class="sub-title">优化建议</text>
            <view class="list-items">
              <view
                v-for="(suggestion, index) in result.results.strategy?.suggestions"
                :key="index"
                class="list-item"
              >
                <uni-icons type="checkbox-filled" size="18" color="#67C23A" />
                <text class="item-text">{{ suggestion }}</text>
              </view>
            </view>
          </view>

          <view v-if="result.results.strategy?.warnings.length" class="warnings">
            <text class="sub-title">风险提示</text>
            <view class="list-items">
              <view
                v-for="(warning, index) in result.results.strategy?.warnings"
                :key="index"
                class="list-item warning"
              >
                <uni-icons type="info" size="18" color="#E6A23C" />
                <text class="item-text">{{ warning }}</text>
              </view>
            </view>
          </view>
        </view>
      </AppCard>

      <!-- 竞争对手分析 -->
      <AppCard class="result-section">
        <template #header>
          <view class="section-header">
            <uni-icons type="contact" size="20" color="#409EFF" />
            <text class="section-title">竞争态势分析</text>
          </view>
        </template>
        <view class="competitor-content">
          <text class="competitor-count">
            本次模拟生成 {{ result.results.competitors?.count }} 名虚拟竞争对手
          </text>
          <view class="distribution-chart">
            <text class="sub-title">竞争对手分数分布</text>
            <view
              v-for="dist in result.results.competitors?.scoreDistribution"
              :key="dist.range"
              class="distribution-item"
            >
              <text class="distribution-range">{{ dist.range }}分</text>
              <view class="distribution-progress">
                <view
                  class="distribution-fill"
                  :style="{ width: `${getDistributionPercent(dist.count)}%` }"
                />
              </view>
              <text class="distribution-count">{{ dist.count }}人</text>
            </view>
          </view>
        </view>
      </AppCard>

      <!-- 操作按钮 -->
      <view class="result-actions">
        <AppButton type="primary" @click="goBack">
          <uni-icons type="back" size="16" color="#fff" />
          <text>返回修改</text>
        </AppButton>
        <AppButton @click="viewHistory">
          <uni-icons type="clock" size="16" color="#606266" />
          <text>查看历史</text>
        </AppButton>
      </view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { onLoad } from '@dcloudio/uni-app';
import { AppButton, AppCard } from '@/components/common';
import { getAnalysisResult } from '@/api/candidate';
import type { AnalysisResult } from '@/api/candidate';

const result = ref<AnalysisResult | null>(null);
const loading = ref(true);
const error = ref<string | null>(null);
const analysisId = ref('');

// 计算最大分布数量
const maxDistributionCount = computed(() => {
  if (!result.value?.results?.competitors?.scoreDistribution) return 1;
  return Math.max(
    ...result.value.results.competitors.scoreDistribution.map(d => d.count)
  );
});

// 方法
async function loadResult() {
  loading.value = true;
  error.value = null;

  try {
    const data = await getAnalysisResult(analysisId.value);
    result.value = data;

    // 如果还在处理中，继续轮询
    if (data.status === 'pending' || data.status === 'processing') {
      setTimeout(loadResult, 3000);
    }
  } catch (e: any) {
    error.value = e.message || '获取分析结果失败';
  } finally {
    loading.value = false;
  }
}

function formatTime(time: string): string {
  return new Date(time).toLocaleString('zh-CN');
}

function getConfidenceClass(confidence?: string): string {
  const map: Record<string, string> = {
    high: 'success',
    medium: 'warning',
    low: 'info',
  };
  return map[confidence || ''] || 'info';
}

function getConfidenceText(confidence?: string): string {
  const map: Record<string, string> = {
    high: '准确度高',
    medium: '准确度中',
    low: '准确度低',
  };
  return map[confidence || ''] || '未知';
}

function getBatchClass(batch: string): string {
  if (batch.startsWith('UNIFIED')) return 'warning';
  const map: Record<string, string> = {
    QUOTA_DISTRICT: 'primary',
    QUOTA_SCHOOL: 'success',
  };
  return map[batch] || 'info';
}

function getBatchName(batch: string): string {
  if (batch.startsWith('UNIFIED')) return '统一招生';
  const map: Record<string, string> = {
    QUOTA_DISTRICT: '名额分配到区',
    QUOTA_SCHOOL: '名额分配到校',
  };
  return map[batch] || batch;
}

function getProgressClass(probability: number): string {
  if (probability >= 80) return 'success';
  if (probability >= 50) return 'normal';
  if (probability >= 30) return 'warning';
  return 'exception';
}

function getRiskClass(risk: string): string {
  const map: Record<string, string> = {
    safe: 'success',
    moderate: 'warning',
    risky: 'danger',
    high_risk: 'info',
  };
  return map[risk] || 'info';
}

function getRiskText(risk: string): string {
  const map: Record<string, string> = {
    safe: '安全',
    moderate: '稳妥',
    risky: '冲刺',
    high_risk: '高风险',
  };
  return map[risk] || risk;
}

function getStrategyScoreClass(score?: number): string {
  if (!score) return 'info';
  if (score >= 80) return 'success';
  if (score >= 60) return 'warning';
  return 'danger';
}

function getGradientPercent(type: 'reach' | 'target' | 'safety'): number {
  const gradient = result.value?.results?.strategy?.gradient;
  if (!gradient) return 0;
  const total = gradient.reach + gradient.target + gradient.safety;
  if (total === 0) return 0;
  return Math.round((gradient[type] / total) * 100);
}

function getDistributionPercent(count: number): number {
  if (maxDistributionCount.value === 0) return 0;
  return Math.round((count / maxDistributionCount.value) * 100);
}

function goBack() {
  uni.navigateTo({ url: '/pages/form/form' });
}

function viewHistory() {
  uni.navigateTo({ url: '/pages/history/history' });
}

// 初始化
onLoad((options) => {
  if (options?.id) {
    analysisId.value = options.id as string;
    loadResult();
  } else {
    error.value = '缺少分析ID参数';
    loading.value = false;
  }
});
</script>

<style lang="scss" scoped>
.result-view {
  padding: 30rpx;
  background-color: #f5f7fa;
  min-height: 100vh;
}

.loading-container,
.error-container {
  padding: 120rpx 40rpx;
  text-align: center;
}

.result-status {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 40rpx;
}

.status-title {
  font-size: 36rpx;
  font-weight: 600;
  color: #303133;
  margin-top: 24rpx;
  margin-bottom: 16rpx;
}

.status-subtitle {
  font-size: 28rpx;
  color: #606266;
  text-align: center;
}

.loading-hint {
  color: #909399;
  font-size: 24rpx;
  margin-top: 16rpx;
}

.skeleton {
  padding: 0 40rpx;
}

.skeleton-item {
  height: 32rpx;
  background: linear-gradient(90deg, #f2f2f2 25%, #e6e6e6 37%, #f2f2f2 63%);
  background-size: 400% 100%;
  animation: skeleton-loading 1.4s ease infinite;
  border-radius: 8rpx;
  margin-bottom: 24rpx;

  &.short {
    width: 60%;
  }
}

@keyframes skeleton-loading {
  0% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0 50%;
  }
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
  padding: 0 60rpx;
}

.result-header {
  text-align: center;
  margin-bottom: 40rpx;
}

.result-title {
  font-size: 40rpx;
  font-weight: 600;
  color: #303133;
  display: block;
  margin-bottom: 16rpx;
}

.result-time {
  color: #909399;
  font-size: 24rpx;
}

.result-section {
  margin-bottom: 30rpx;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 500;
  color: #303133;
}

.score-tag {
  margin-left: auto;
  padding: 8rpx 20rpx;
  border-radius: 8rpx;
  font-size: 24rpx;

  &.success {
    background-color: #f0f9eb;
    color: #67c23a;
  }

  &.warning {
    background-color: #fdf6ec;
    color: #e6a23c;
  }

  &.danger {
    background-color: #fef0f0;
    color: #f56c6c;
  }

  &.info {
    background-color: #f4f4f5;
    color: #909399;
  }
}

.prediction-content {
  padding: 20rpx;
}

.prediction-main {
  display: flex;
  align-items: center;
  gap: 20rpx;
  margin-bottom: 16rpx;
  flex-wrap: wrap;
}

.prediction-label {
  color: #606266;
  font-size: 28rpx;
}

.prediction-value {
  font-size: 56rpx;
  font-weight: bold;
  color: #409eff;
}

.status-tag {
  padding: 8rpx 20rpx;
  border-radius: 8rpx;
  font-size: 24rpx;

  &.success {
    background-color: #f0f9eb;
    color: #67c23a;
  }

  &.warning {
    background-color: #fdf6ec;
    color: #e6a23c;
  }

  &.info {
    background-color: #f4f4f5;
    color: #909399;
  }
}

.prediction-range {
  color: #909399;
  font-size: 26rpx;
}

.probability-list {
  display: flex;
  flex-direction: column;
  gap: 30rpx;
}

.probability-item {
  padding: 24rpx;
  background: #f5f7fa;
  border-radius: 16rpx;
}

.probability-header {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.batch-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  flex-shrink: 0;

  &.primary {
    background-color: #ecf5ff;
    color: #409eff;
  }

  &.success {
    background-color: #f0f9eb;
    color: #67c23a;
  }

  &.warning {
    background-color: #fdf6ec;
    color: #e6a23c;
  }

  &.info {
    background-color: #f4f4f5;
    color: #909399;
  }
}

.school-name {
  font-weight: 500;
  color: #303133;
  font-size: 28rpx;
}

.probability-stats {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.progress-wrapper {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.progress-bar {
  flex: 1;
  height: 24rpx;
  background-color: #ebeef5;
  border-radius: 12rpx;
  overflow: hidden;
}

.progress-inner {
  height: 100%;
  border-radius: 12rpx;
  transition: width 0.3s ease;

  &.success {
    background-color: #67c23a;
  }

  &.normal {
    background-color: #409eff;
  }

  &.warning {
    background-color: #e6a23c;
  }

  &.exception {
    background-color: #f56c6c;
  }
}

.progress-text {
  font-size: 26rpx;
  color: #606266;
  min-width: 80rpx;
  text-align: right;
}

.risk-tag {
  padding: 6rpx 16rpx;
  border-radius: 6rpx;
  font-size: 22rpx;
  flex-shrink: 0;

  &.success {
    background-color: #f0f9eb;
    color: #67c23a;
  }

  &.warning {
    background-color: #fdf6ec;
    color: #e6a23c;
  }

  &.danger {
    background-color: #fef0f0;
    color: #f56c6c;
  }

  &.info {
    background-color: #f4f4f5;
    color: #909399;
  }
}

.score-diff {
  margin-top: 12rpx;
  font-size: 24rpx;
  color: #909399;
}

.strategy-content {
  padding: 20rpx;
}

.sub-title {
  font-size: 28rpx;
  font-weight: 500;
  color: #303133;
  margin-bottom: 20rpx;
  display: block;
}

.gradient-info {
  margin-bottom: 40rpx;
}

.gradient-bars {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.gradient-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.gradient-label {
  width: 80rpx;
  color: #606266;
  font-size: 26rpx;
}

.gradient-progress {
  flex: 1;
  height: 20rpx;
  background-color: #ebeef5;
  border-radius: 10rpx;
  overflow: hidden;
}

.gradient-fill {
  height: 100%;
  border-radius: 10rpx;

  &.reach {
    background-color: #f56c6c;
  }

  &.target {
    background-color: #e6a23c;
  }

  &.safety {
    background-color: #67c23a;
  }
}

.gradient-count {
  width: 80rpx;
  text-align: right;
  color: #909399;
  font-size: 24rpx;
}

.suggestions,
.warnings {
  margin-top: 30rpx;
}

.list-items {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.list-item {
  display: flex;
  align-items: flex-start;
  gap: 12rpx;
  color: #606266;
  font-size: 26rpx;
  line-height: 1.5;

  &.warning {
    color: #e6a23c;
  }
}

.item-text {
  flex: 1;
}

.competitor-content {
  padding: 20rpx;
}

.competitor-count {
  color: #606266;
  font-size: 26rpx;
  margin-bottom: 30rpx;
  display: block;
}

.distribution-chart {
  margin-top: 20rpx;
}

.distribution-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.distribution-range {
  width: 160rpx;
  font-size: 24rpx;
  color: #606266;
}

.distribution-progress {
  flex: 1;
  height: 16rpx;
  background-color: #ebeef5;
  border-radius: 8rpx;
  overflow: hidden;
}

.distribution-fill {
  height: 100%;
  background-color: #409eff;
  border-radius: 8rpx;
}

.distribution-count {
  width: 80rpx;
  text-align: right;
  font-size: 24rpx;
  color: #909399;
}

.result-actions {
  display: flex;
  justify-content: center;
  gap: 30rpx;
  margin-top: 40rpx;
  padding: 30rpx 0;
}
</style>
