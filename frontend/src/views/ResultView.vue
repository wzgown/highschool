<template>
  <div class="result-view">
    <!-- 加载中 -->
    <div v-if="loading" class="loading-container">
      <el-result icon="info" title="分析进行中">
        <template #sub-title>
          <p>正在进行录取概率模拟计算，请稍候...</p>
          <p class="loading-hint">此过程可能需要 10-30 秒</p>
        </template>
        <template #extra>
          <el-skeleton :rows="3" animated />
        </template>
      </el-result>
    </div>

    <!-- 错误 -->
    <div v-else-if="error" class="error-container">
      <el-result icon="error" title="分析失败" :sub-title="error">
        <template #extra>
          <el-button type="primary" @click="loadResult">重试</el-button>
          <el-button @click="goBack">返回</el-button>
        </template>
      </el-result>
    </div>

    <!-- 结果展示 -->
    <template v-else-if="result">
      <div class="result-header">
        <h1 class="result-title">志愿分析报告</h1>
        <p class="result-time">生成时间：{{ formatTime(result.createdAt) }}</p>
      </div>

      <!-- 排名预测 -->
      <el-card class="result-section">
        <template #header>
          <div class="section-header">
            <el-icon><TrendCharts /></el-icon>
            <span>区内排名预测</span>
          </div>
        </template>
        <div class="prediction-content">
          <div class="prediction-main">
            <span class="prediction-label">预测区内排名</span>
            <span class="prediction-value">{{ result.results?.predictions.districtRank }}</span>
            <el-tag
              :type="getConfidenceType(result.results?.predictions.confidence)"
              size="small"
            >
              {{ getConfidenceText(result.results?.predictions.confidence) }}
            </el-tag>
          </div>
          <p class="prediction-range">
            预测区间：{{ result.results?.predictions.districtRankRange[0] }} - 
            {{ result.results?.predictions.districtRankRange[1] }}
          </p>
        </div>
      </el-card>

      <!-- 录取概率 -->
      <el-card class="result-section">
        <template #header>
          <div class="section-header">
            <el-icon><DataAnalysis /></el-icon>
            <span>录取概率分析</span>
          </div>
        </template>
        <div class="probability-list">
          <div
            v-for="item in result.results?.probabilities"
            :key="`${item.batch}-${item.schoolId}`"
            class="probability-item"
          >
            <div class="probability-info">
              <div class="probability-header">
                <el-tag :type="getBatchType(item.batch)" size="small">
                  {{ getBatchName(item.batch) }}
                </el-tag>
                <span class="school-name">{{ item.schoolName }}</span>
              </div>
              <div class="probability-stats">
                <el-progress
                  :percentage="Math.round(item.probability)"
                  :status="getProbabilityStatus(item.probability)"
                  :stroke-width="12"
                  class="probability-progress"
                />
                <el-tag
                  :type="getRiskType(item.riskLevel)"
                  size="small"
                  class="risk-tag"
                >
                  {{ getRiskText(item.riskLevel) }}
                </el-tag>
              </div>
              <p v-if="item.scoreDiff !== null" class="score-diff">
                与历年分对比：{{ item.scoreDiff > 0 ? '+' : '' }}{{ item.scoreDiff }}分
              </p>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 策略分析 -->
      <el-card class="result-section">
        <template #header>
          <div class="section-header">
            <el-icon><Histogram /></el-icon>
            <span>志愿策略分析</span>
            <el-tag :type="getStrategyScoreType(result.results?.strategy.score)" class="score-tag">
              评分：{{ result.results?.strategy.score }}分
            </el-tag>
          </div>
        </template>
        <div class="strategy-content">
          <div class="gradient-info">
            <h4>志愿梯度分布</h4>
            <div class="gradient-bars">
              <div class="gradient-item">
                <span class="gradient-label">冲刺</span>
                <el-progress
                  :percentage="getGradientPercent('reach')"
                  :show-text="false"
                  color="#F56C6C"
                />
                <span class="gradient-count">{{ result.results?.strategy.gradient.reach }}个</span>
              </div>
              <div class="gradient-item">
                <span class="gradient-label">稳妥</span>
                <el-progress
                  :percentage="getGradientPercent('target')"
                  :show-text="false"
                  color="#E6A23C"
                />
                <span class="gradient-count">{{ result.results?.strategy.gradient.target }}个</span>
              </div>
              <div class="gradient-item">
                <span class="gradient-label">保底</span>
                <el-progress
                  :percentage="getGradientPercent('safety')"
                  :show-text="false"
                  color="#67C23A"
                />
                <span class="gradient-count">{{ result.results?.strategy.gradient.safety }}个</span>
              </div>
            </div>
          </div>

          <div v-if="result.results?.strategy.suggestions.length" class="suggestions">
            <h4>优化建议</h4>
            <ul>
              <li
                v-for="(suggestion, index) in result.results?.strategy.suggestions"
                :key="index"
                class="suggestion-item"
              >
                <el-icon color="#67C23A"><CircleCheck /></el-icon>
                <span>{{ suggestion }}</span>
              </li>
            </ul>
          </div>

          <div v-if="result.results?.strategy.warnings.length" class="warnings">
            <h4>风险提示</h4>
            <ul>
              <li
                v-for="(warning, index) in result.results?.strategy.warnings"
                :key="index"
                class="warning-item"
              >
                <el-icon color="#E6A23C"><Warning /></el-icon>
                <span>{{ warning }}</span>
              </li>
            </ul>
          </div>
        </div>
      </el-card>

      <!-- 竞争对手分析 -->
      <el-card class="result-section">
        <template #header>
          <div class="section-header">
            <el-icon><User /></el-icon>
            <span>竞争态势分析</span>
          </div>
        </template>
        <div class="competitor-content">
          <p class="competitor-count">
            本次模拟生成 {{ result.results?.competitors.count }} 名虚拟竞争对手
          </p>
          <div class="distribution-chart">
            <h4>竞争对手分数分布</h4>
            <div
              v-for="dist in result.results?.competitors.scoreDistribution"
              :key="dist.range"
              class="distribution-item"
            >
              <span class="distribution-range">{{ dist.range }}分</span>
              <el-progress
                :percentage="getDistributionPercent(dist.count)"
                :show-text="false"
              />
              <span class="distribution-count">{{ dist.count }}人</span>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 操作按钮 -->
      <div class="result-actions">
        <el-button type="primary" @click="goBack">
          <el-icon><ArrowLeft /></el-icon>
          返回修改
        </el-button>
        <el-button @click="viewHistory">
          <el-icon><Clock /></el-icon>
          查看历史
        </el-button>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import {
  TrendCharts,
  DataAnalysis,
  Histogram,
  User,
  CircleCheck,
  Warning,
  ArrowLeft,
  Clock,
} from '@element-plus/icons-vue';
import { ElMessage } from 'element-plus';
import { getAnalysisResult } from '@/api/candidate';
import type { AnalysisResult } from '@/api/candidate';

const props = defineProps<{
  id: string;
}>();

const router = useRouter();
const result = ref<AnalysisResult | null>(null);
const loading = ref(true);
const error = ref<string | null>(null);

// 计算最大分布数量
const maxDistributionCount = computed(() => {
  if (!result.value?.results?.competitors.scoreDistribution) return 1;
  return Math.max(
    ...result.value.results.competitors.scoreDistribution.map(d => d.count)
  );
});

// 方法
async function loadResult() {
  loading.value = true;
  error.value = null;
  
  try {
    const data = await getAnalysisResult(props.id);
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

function getConfidenceType(confidence?: string): 'success' | 'warning' | 'info' {
  const map: Record<string, 'success' | 'warning' | 'info'> = {
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

function getBatchType(batch: string): 'primary' | 'success' | 'warning' {
  const map: Record<string, 'primary' | 'success' | 'warning'> = {
    QUOTA_DISTRICT: 'primary',
    QUOTA_SCHOOL: 'success',
    UNIFIED: 'warning',
  };
  return map[batch] || 'info';
}

function getBatchName(batch: string): string {
  const map: Record<string, string> = {
    QUOTA_DISTRICT: '名额分配到区',
    QUOTA_SCHOOL: '名额分配到校',
    UNIFIED: '统一招生',
  };
  return map[batch] || batch;
}

function getProbabilityStatus(probability: number): '' | 'success' | 'exception' | 'warning' {
  if (probability >= 80) return 'success';
  if (probability >= 50) return '';
  if (probability >= 30) return 'warning';
  return 'exception';
}

function getRiskType(risk: string): 'success' | 'warning' | 'danger' | 'info' {
  const map: Record<string, 'success' | 'warning' | 'danger' | 'info'> = {
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

function getStrategyScoreType(score?: number): 'success' | 'warning' | 'danger' {
  if (!score) return 'info';
  if (score >= 80) return 'success';
  if (score >= 60) return 'warning';
  return 'danger';
}

function getGradientPercent(type: 'reach' | 'target' | 'safety'): number {
  const gradient = result.value?.results?.strategy.gradient;
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
  router.push('/form');
}

function viewHistory() {
  router.push('/history');
}

// 初始化
onMounted(() => {
  loadResult();
});
</script>

<style lang="scss" scoped>
.result-view {
  max-width: 900px;
  margin: 0 auto;
}

.loading-container,
.error-container {
  padding: 60px 20px;
  text-align: center;
}

.loading-hint {
  color: #909399;
  font-size: 14px;
  margin-top: 8px;
}

.result-header {
  text-align: center;
  margin-bottom: 30px;
}

.result-title {
  font-size: 28px;
  color: #303133;
  margin-bottom: 8px;
}

.result-time {
  color: #909399;
  font-size: 14px;
}

.result-section {
  margin-bottom: 20px;

  :deep(.el-card__header) {
    padding: 16px 20px;
  }
}

.section-header {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 500;
}

.score-tag {
  margin-left: auto;
}

.prediction-content {
  padding: 10px;
}

.prediction-main {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 10px;
}

.prediction-label {
  color: #606266;
  font-size: 14px;
}

.prediction-value {
  font-size: 32px;
  font-weight: bold;
  color: #409EFF;
}

.prediction-range {
  color: #909399;
  font-size: 14px;
}

.probability-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.probability-item {
  padding: 15px;
  background: #f5f7fa;
  border-radius: 8px;
}

.probability-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.school-name {
  font-weight: 500;
  color: #303133;
}

.probability-stats {
  display: flex;
  align-items: center;
  gap: 15px;
}

.probability-progress {
  flex: 1;
}

.risk-tag {
  flex-shrink: 0;
}

.score-diff {
  margin-top: 8px;
  font-size: 13px;
  color: #909399;
}

.strategy-content {
  padding: 10px;
}

.gradient-info {
  margin-bottom: 25px;

  h4 {
    margin-bottom: 15px;
    color: #303133;
  }
}

.gradient-bars {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.gradient-item {
  display: flex;
  align-items: center;
  gap: 10px;

  .el-progress {
    flex: 1;
  }
}

.gradient-label {
  width: 50px;
  color: #606266;
  font-size: 14px;
}

.gradient-count {
  width: 50px;
  text-align: right;
  color: #909399;
  font-size: 13px;
}

.suggestions,
.warnings {
  margin-top: 20px;

  h4 {
    margin-bottom: 12px;
    color: #303133;
  }

  ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }
}

.suggestion-item,
.warning-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 8px 0;
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
}

.competitor-content {
  padding: 10px;
}

.competitor-count {
  color: #606266;
  margin-bottom: 20px;
}

.distribution-chart {
  h4 {
    margin-bottom: 15px;
    color: #303133;
  }
}

.distribution-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.distribution-range {
  width: 100px;
  font-size: 13px;
  color: #606266;
}

.distribution-count {
  width: 50px;
  text-align: right;
  font-size: 13px;
  color: #909399;
}

.result-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 30px;
  padding: 20px;
}

@media (max-width: 768px) {
  .result-title {
    font-size: 22px;
  }

  .prediction-main {
    flex-wrap: wrap;
  }

  .prediction-value {
    font-size: 24px;
  }

  .probability-stats {
    flex-wrap: wrap;
  }

  .result-actions {
    flex-direction: column;

    .el-button {
      width: 100%;
    }
  }
}
</style>
