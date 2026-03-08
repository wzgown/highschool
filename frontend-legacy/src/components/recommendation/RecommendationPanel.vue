<template>
  <div class="recommendation-panel">
    <!-- 分数转换信息 -->
    <el-card v-if="scoreConversion" class="score-conversion-card">
      <template #header>
        <div class="section-header">
          <el-icon><TrendCharts /></el-icon>
          <span>分数转换</span>
        </div>
      </template>
      <el-descriptions :column="3" border>
        <el-descriptions-item label="原始分数">
          {{ scoreConversion.originalScore?.toFixed(1) }} 分
        </el-descriptions-item>
        <el-descriptions-item label="原始总分">
          {{ scoreConversion.originalTotal?.toFixed(1) }} 分
        </el-descriptions-item>
        <el-descriptions-item label="区县">
          {{ scoreConversion.districtName }}
        </el-descriptions-item>
        <el-descriptions-item label="转换后750分制">
          <el-tag type="primary">{{ scoreConversion.convertedScore_750?.toFixed(1) }} 分</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="转换后800分制">
          <el-tag type="success">{{ scoreConversion.convertedScore_800?.toFixed(1) }} 分</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="估算区排名">
          第 {{ scoreConversion.estimatedRank }} 名
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 名额到区推荐 -->
    <el-card v-if="quotaDistrictRecommendations?.length" class="recommendation-card">
      <template #header>
        <div class="section-header">
          <el-icon><School /></el-icon>
          <span>名额分配到区推荐</span>
          <el-tag type="warning" size="small">可填1个志愿</el-tag>
        </div>
      </template>
      <div class="recommendation-list">
        <div
          v-for="school in quotaDistrictRecommendations"
          :key="school.schoolId"
          class="recommendation-item"
          :class="getRecommendationClass(school.recommendationType)"
        >
          <div class="school-info">
            <div class="school-header">
              <el-tag :type="getTypeTag(school.recommendationType)" size="small">
                {{ getTypeText(school.recommendationType) }}
              </el-tag>
              <span class="school-name">{{ school.schoolName }}</span>
              <el-tag v-if="school.quotaCount" size="small" type="info">
                名额: {{ school.quotaCount }}
              </el-tag>
            </div>
            <div class="school-details">
              <span class="estimated-score">预估分数线: {{ school.estimatedScore?.toFixed(1) }}</span>
              <span class="score-gap" :class="getGapClass(school.scoreGap)">
                {{ formatScoreGap(school.scoreGap) }}
              </span>
            </div>
            <div class="recommendation-reason">{{ school.recommendationReason }}</div>
          </div>
          <div class="confidence-indicator">
            <el-progress
              :percentage="getConfidencePercentage(school.confidence)"
              :status="getConfidenceStatus(school.confidence)"
              :stroke-width="8"
              :show-text="false"
            />
            <span class="confidence-text">{{ getConfidenceText(school.confidence) }}</span>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 名额到校推荐 -->
    <el-card v-if="quotaSchoolRecommendations?.length" class="recommendation-card">
      <template #header>
        <div class="section-header">
          <el-icon><School /></el-icon>
          <span>名额分配到校推荐</span>
          <el-tag type="warning" size="small">可填2个志愿</el-tag>
        </div>
      </template>
      <div class="recommendation-list">
        <div
          v-for="school in quotaSchoolRecommendations"
          :key="school.schoolId"
          class="recommendation-item"
          :class="getRecommendationClass(school.recommendationType)"
        >
          <div class="school-info">
            <div class="school-header">
              <el-tag :type="getTypeTag(school.recommendationType)" size="small">
                {{ getTypeText(school.recommendationType) }}
              </el-tag>
              <span class="school-name">{{ school.schoolName }}</span>
              <el-tag v-if="school.quotaCount" size="small" type="info">
                名额: {{ school.quotaCount }}
              </el-tag>
            </div>
            <div class="school-details">
              <span class="estimated-score">预估分数线: {{ school.estimatedScore?.toFixed(1) }}</span>
              <span class="score-gap" :class="getGapClass(school.scoreGap)">
                {{ formatScoreGap(school.scoreGap) }}
              </span>
            </div>
            <div class="recommendation-reason">{{ school.recommendationReason }}</div>
          </div>
          <div class="confidence-indicator">
            <el-progress
              :percentage="getConfidencePercentage(school.confidence)"
              :status="getConfidenceStatus(school.confidence)"
              :stroke-width="8"
              :show-text="false"
            />
            <span class="confidence-text">{{ getConfidenceText(school.confidence) }}</span>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 统一招生推荐 -->
    <el-card v-if="unifiedRecommendations?.length" class="recommendation-card">
      <template #header>
        <div class="section-header">
          <el-icon><List /></el-icon>
          <span>统一招生（1-15志愿）推荐</span>
          <el-tag type="info" size="small">共 {{ unifiedRecommendations.length }} 所学校</el-tag>
        </div>
      </template>
      <div class="unified-stats">
        <el-tag type="danger">冲刺: {{ countByType(unifiedRecommendations, 'REACH') }}</el-tag>
        <el-tag type="primary">稳妥: {{ countByType(unifiedRecommendations, 'TARGET') }}</el-tag>
        <el-tag type="success">保底: {{ countByType(unifiedRecommendations, 'SAFETY') }}</el-tag>
      </div>
      <el-table :data="unifiedRecommendations" style="width: 100%" max-height="500">
        <el-table-column label="推荐" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="getTypeTag(row.recommendationType)" size="small">
              {{ getTypeText(row.recommendationType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="schoolName" label="学校名称" min-width="200">
          <template #default="{ row }">
            <div class="school-cell">
              <span>{{ row.schoolName }}</span>
              <el-tag v-if="row.isDistrictSchool" size="small" type="success">本区</el-tag>
              <el-tag v-else size="small" type="info">外区</el-tag>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="预估分数线" width="120" align="center">
          <template #default="{ row }">
            {{ row.estimatedScore?.toFixed(1) }}
          </template>
        </el-table-column>
        <el-table-column label="分差" width="100" align="center">
          <template #default="{ row }">
            <span :class="getGapClass(row.scoreGap)">
              {{ formatScoreGap(row.scoreGap) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="置信度" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getConfidenceTag(row.confidence)" size="small">
              {{ getConfidenceText(row.confidence) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="recommendationReason" label="推荐理由" min-width="180" />
      </el-table>
    </el-card>

    <!-- 无推荐结果 -->
    <el-empty
      v-if="!hasAnyRecommendations"
      description="暂无推荐结果，请检查输入信息是否完整"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { TrendCharts, School, List } from '@element-plus/icons-vue'
import type { RecommendedSchool, ScoreConversion, RecommendationType, RecommendationConfidence } from '@/gen/highschool/v1/reference_service_pb'

interface Props {
  quotaDistrictRecommendations?: RecommendedSchool[]
  quotaSchoolRecommendations?: RecommendedSchool[]
  unifiedRecommendations?: RecommendedSchool[]
  scoreConversion?: ScoreConversion
}

const props = defineProps<Props>()

const hasAnyRecommendations = computed(() => {
  return (props.quotaDistrictRecommendations?.length ?? 0) > 0 ||
         (props.quotaSchoolRecommendations?.length ?? 0) > 0 ||
         (props.unifiedRecommendations?.length ?? 0) > 0
})

function getTypeText(type: RecommendationType): string {
  switch (type) {
    case 1: return '冲刺'
    case 2: return '稳妥'
    case 3: return '保底'
    default: return '未知'
  }
}

function getTypeTag(type: RecommendationType): string {
  switch (type) {
    case 1: return 'danger'
    case 2: return 'primary'
    case 3: return 'success'
    default: return 'info'
  }
}

function getRecommendationClass(type: RecommendationType): string {
  switch (type) {
    case 1: return 'recommendation-reach'
    case 2: return 'recommendation-target'
    case 3: return 'recommendation-safety'
    default: return ''
  }
}

function getGapClass(gap: number): string {
  if (gap > 10) return 'gap-positive'
  if (gap > 0) return 'gap-small-positive'
  if (gap === 0) return 'gap-zero'
  return 'gap-negative'
}

function formatScoreGap(gap: number): string {
  if (gap > 0) return `+${gap.toFixed(1)}`
  return gap.toFixed(1)
}

function getConfidenceText(confidence: RecommendationConfidence): string {
  switch (confidence) {
    case 1: return '高'
    case 2: return '中'
    case 3: return '低'
    default: return '未知'
  }
}

function getConfidencePercentage(confidence: RecommendationConfidence): number {
  switch (confidence) {
    case 1: return 90
    case 2: return 60
    case 3: return 30
    default: return 0
  }
}

function getConfidenceStatus(confidence: RecommendationConfidence): '' | 'success' | 'warning' | 'exception' {
  switch (confidence) {
    case 1: return 'success'
    case 2: return ''
    case 3: return 'warning'
    default: return 'exception'
  }
}

function getConfidenceTag(confidence: RecommendationConfidence): string {
  switch (confidence) {
    case 1: return 'success'
    case 2: return ''
    case 3: return 'warning'
    default: return 'info'
  }
}

function countByType(schools: RecommendedSchool[], typeStr: string): number {
  return schools.filter(s => {
    switch (typeStr) {
      case 'REACH': return s.recommendationType === 1
      case 'TARGET': return s.recommendationType === 2
      case 'SAFETY': return s.recommendationType === 3
      default: return false
    }
  }).length
}
</script>

<style scoped>
.recommendation-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.score-conversion-card {
  margin-bottom: 20px;
}

.recommendation-card {
  margin-bottom: 20px;
}

.recommendation-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.recommendation-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  transition: all 0.3s;
}

.recommendation-item:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.recommendation-reach {
  background-color: #fef0f0;
  border-color: #fde2e2;
}

.recommendation-target {
  background-color: #ecf5ff;
  border-color: #d9ecff;
}

.recommendation-safety {
  background-color: #f0f9eb;
  border-color: #e1f3d8;
}

.school-info {
  flex: 1;
}

.school-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.school-name {
  font-weight: 500;
  font-size: 16px;
}

.school-details {
  display: flex;
  gap: 16px;
  margin-bottom: 8px;
  font-size: 14px;
  color: #606266;
}

.estimated-score {
  color: #409eff;
}

.score-gap {
  font-weight: 500;
}

.gap-positive {
  color: #67c23a;
}

.gap-small-positive {
  color: #95d475;
}

.gap-zero {
  color: #909399;
}

.gap-negative {
  color: #f56c6c;
}

.recommendation-reason {
  font-size: 13px;
  color: #909399;
}

.confidence-indicator {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 80px;
}

.confidence-text {
  margin-top: 4px;
  font-size: 12px;
  color: #606266;
}

.unified-stats {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.school-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>
