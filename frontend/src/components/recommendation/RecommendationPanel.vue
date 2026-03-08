<template>
  <view class="recommendation-panel">
    <!-- 分数转换信息 -->
    <AppCard v-if="scoreConversion" class="score-conversion-card">
      <template #header>
        <view class="section-header">
          <uni-icons type="staff-filled" size="18" color="#409eff" />
          <text class="section-title">分数转换</text>
        </view>
      </template>
      <view class="conversion-grid">
        <view class="conversion-item">
          <text class="conversion-label">原始分数</text>
          <text class="conversion-value">{{ scoreConversion.originalScore?.toFixed(1) }} 分</text>
        </view>
        <view class="conversion-item">
          <text class="conversion-label">原始总分</text>
          <text class="conversion-value">{{ scoreConversion.originalTotal?.toFixed(1) }} 分</text>
        </view>
        <view class="conversion-item">
          <text class="conversion-label">区县</text>
          <text class="conversion-value">{{ scoreConversion.districtName }}</text>
        </view>
        <view class="conversion-item">
          <text class="conversion-label">转换后750分制</text>
          <view class="tag tag-primary">{{ scoreConversion.convertedScore750?.toFixed(1) }} 分</view>
        </view>
        <view class="conversion-item">
          <text class="conversion-label">转换后800分制</text>
          <view class="tag tag-success">{{ scoreConversion.convertedScore800?.toFixed(1) }} 分</view>
        </view>
        <view class="conversion-item">
          <text class="conversion-label">估算区排名</text>
          <text class="conversion-value">第 {{ scoreConversion.estimatedRank }} 名</text>
        </view>
      </view>
    </AppCard>

    <!-- 名额到区推荐 -->
    <AppCard v-if="quotaDistrictRecommendations?.length" class="recommendation-card">
      <template #header>
        <view class="section-header">
          <uni-icons type="home-filled" size="18" color="#e6a23c" />
          <text class="section-title">名额分配到区推荐</text>
          <view class="tag tag-warning">可填1个志愿</view>
        </view>
      </template>
      <view class="recommendation-list">
        <view
          v-for="school in quotaDistrictRecommendations"
          :key="school.schoolId"
          class="recommendation-item"
          :class="getRecommendationClass(school.recommendationType)"
        >
          <view class="school-info">
            <view class="school-header">
              <view class="tag" :class="getTypeTagClass(school.recommendationType)">
                {{ getTypeText(school.recommendationType) }}
              </view>
              <text class="school-name">{{ school.schoolName }}</text>
              <view v-if="school.quotaCount" class="tag tag-info">
                名额: {{ school.quotaCount }}
              </view>
            </view>
            <view class="school-details">
              <text class="estimated-score">预估分数线: {{ school.estimatedScore?.toFixed(1) }}</text>
              <text class="score-gap" :class="getGapClass(school.scoreGap)">
                {{ formatScoreGap(school.scoreGap) }}
              </text>
            </view>
            <text class="recommendation-reason">{{ school.recommendationReason }}</text>
          </view>
          <view class="confidence-indicator">
            <view class="progress-bar">
              <view
                class="progress-fill"
                :style="{ width: getConfidencePercentage(school.confidence) + '%' }"
                :class="getConfidenceClass(school.confidence)"
              />
            </view>
            <text class="confidence-text">{{ getConfidenceText(school.confidence) }}</text>
          </view>
        </view>
      </view>
    </AppCard>

    <!-- 名额到校推荐 -->
    <AppCard v-if="quotaSchoolRecommendations?.length" class="recommendation-card">
      <template #header>
        <view class="section-header">
          <uni-icons type="home-filled" size="18" color="#e6a23c" />
          <text class="section-title">名额分配到校推荐</text>
          <view class="tag tag-warning">可填2个志愿</view>
        </view>
      </template>
      <view class="recommendation-list">
        <view
          v-for="school in quotaSchoolRecommendations"
          :key="school.schoolId"
          class="recommendation-item"
          :class="getRecommendationClass(school.recommendationType)"
        >
          <view class="school-info">
            <view class="school-header">
              <view class="tag" :class="getTypeTagClass(school.recommendationType)">
                {{ getTypeText(school.recommendationType) }}
              </view>
              <text class="school-name">{{ school.schoolName }}</text>
              <view v-if="school.quotaCount" class="tag tag-info">
                名额: {{ school.quotaCount }}
              </view>
            </view>
            <view class="school-details">
              <text class="estimated-score">预估分数线: {{ school.estimatedScore?.toFixed(1) }}</text>
              <text class="score-gap" :class="getGapClass(school.scoreGap)">
                {{ formatScoreGap(school.scoreGap) }}
              </text>
            </view>
            <text class="recommendation-reason">{{ school.recommendationReason }}</text>
          </view>
          <view class="confidence-indicator">
            <view class="progress-bar">
              <view
                class="progress-fill"
                :style="{ width: getConfidencePercentage(school.confidence) + '%' }"
                :class="getConfidenceClass(school.confidence)"
              />
            </view>
            <text class="confidence-text">{{ getConfidenceText(school.confidence) }}</text>
          </view>
        </view>
      </view>
    </AppCard>

    <!-- 统一招生推荐 -->
    <AppCard v-if="unifiedRecommendations?.length" class="recommendation-card">
      <template #header>
        <view class="section-header">
          <uni-icons type="list" size="18" color="#909399" />
          <text class="section-title">统一招生（1-15志愿）推荐</text>
          <view class="tag tag-info">共 {{ unifiedRecommendations.length }} 所学校</view>
        </view>
      </template>
      <view class="unified-stats">
        <view class="tag tag-danger">冲刺: {{ countByType(unifiedRecommendations, 'REACH') }}</view>
        <view class="tag tag-primary">稳妥: {{ countByType(unifiedRecommendations, 'TARGET') }}</view>
        <view class="tag tag-success">保底: {{ countByType(unifiedRecommendations, 'SAFETY') }}</view>
      </view>
      <scroll-view scroll-x class="unified-table-wrapper">
        <view class="unified-table">
          <view class="table-header">
            <view class="table-cell cell-type">推荐</view>
            <view class="table-cell cell-name">学校名称</view>
            <view class="table-cell cell-score">预估线</view>
            <view class="table-cell cell-gap">分差</view>
            <view class="table-cell cell-conf">置信度</view>
          </view>
          <view
            v-for="school in unifiedRecommendations"
            :key="school.schoolId"
            class="table-row"
          >
            <view class="table-cell cell-type">
              <view class="tag tag-small" :class="getTypeTagClass(school.recommendationType)">
                {{ getTypeText(school.recommendationType) }}
              </view>
            </view>
            <view class="table-cell cell-name">
              <view class="school-cell">
                <text class="school-name-text">{{ school.schoolName }}</text>
                <view v-if="school.isDistrictSchool" class="tag tag-success tag-small">本区</view>
                <view v-else class="tag tag-info tag-small">外区</view>
              </view>
            </view>
            <view class="table-cell cell-score">
              {{ school.estimatedScore?.toFixed(1) }}
            </view>
            <view class="table-cell cell-gap">
              <text class="score-gap" :class="getGapClass(school.scoreGap)">
                {{ formatScoreGap(school.scoreGap) }}
              </text>
            </view>
            <view class="table-cell cell-conf">
              <view class="tag tag-small" :class="getConfidenceTagClass(school.confidence)">
                {{ getConfidenceText(school.confidence) }}
              </view>
            </view>
          </view>
        </view>
      </scroll-view>
    </AppCard>

    <!-- 无推荐结果 -->
    <view v-if="!hasAnyRecommendations" class="empty-state">
      <uni-icons type="info" size="48" color="#c0c4cc" />
      <text class="empty-text">暂无推荐结果，请检查输入信息是否完整</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { AppCard } from '@/components/common'
import type {
  RecommendedSchool,
  ScoreConversion,
  RecommendationType,
  RecommendationConfidence,
} from '@/gen/highschool/v1/reference_service_pb'

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

function getTypeTagClass(type: RecommendationType): string {
  switch (type) {
    case 1: return 'tag-danger'
    case 2: return 'tag-primary'
    case 3: return 'tag-success'
    default: return 'tag-info'
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

function getConfidenceClass(confidence: RecommendationConfidence): string {
  switch (confidence) {
    case 1: return 'fill-success'
    case 2: return 'fill-primary'
    case 3: return 'fill-warning'
    default: return 'fill-info'
  }
}

function getConfidenceTagClass(confidence: RecommendationConfidence): string {
  switch (confidence) {
    case 1: return 'tag-success'
    case 2: return 'tag-primary'
    case 3: return 'tag-warning'
    default: return 'tag-info'
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

<style lang="scss" scoped>
.recommendation-panel {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.section-title {
  font-size: 30rpx;
  font-weight: 500;
  color: #303133;
}

/* Tag styles */
.tag {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 4rpx 16rpx;
  border-radius: 8rpx;
  font-size: 24rpx;
  line-height: 1.5;
}

.tag-small {
  padding: 2rpx 12rpx;
  font-size: 22rpx;
}

.tag-primary {
  background-color: #ecf5ff;
  color: #409eff;
}

.tag-success {
  background-color: #f0f9eb;
  color: #67c23a;
}

.tag-warning {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.tag-danger {
  background-color: #fef0f0;
  color: #f56c6c;
}

.tag-info {
  background-color: #f4f4f5;
  color: #909399;
}

/* Score conversion grid */
.conversion-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20rpx;
}

.conversion-item {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.conversion-label {
  font-size: 24rpx;
  color: #909399;
}

.conversion-value {
  font-size: 28rpx;
  font-weight: 500;
  color: #303133;
}

/* Recommendation list */
.recommendation-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.recommendation-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx;
  border-radius: 16rpx;
  border: 2rpx solid #e4e7ed;
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
  flex-wrap: wrap;
  gap: 12rpx;
  margin-bottom: 12rpx;
}

.school-name {
  font-weight: 500;
  font-size: 30rpx;
  color: #303133;
}

.school-details {
  display: flex;
  gap: 24rpx;
  margin-bottom: 12rpx;
  font-size: 26rpx;
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
  font-size: 24rpx;
  color: #909399;
}

.confidence-indicator {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 120rpx;
  margin-left: 20rpx;
}

.progress-bar {
  width: 100%;
  height: 12rpx;
  background-color: #ebeef5;
  border-radius: 6rpx;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 6rpx;
  transition: width 0.3s;
}

.fill-primary {
  background-color: #409eff;
}

.fill-success {
  background-color: #67c23a;
}

.fill-warning {
  background-color: #e6a23c;
}

.fill-info {
  background-color: #909399;
}

.confidence-text {
  margin-top: 8rpx;
  font-size: 22rpx;
  color: #606266;
}

/* Unified stats */
.unified-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

/* Unified table */
.unified-table-wrapper {
  width: 100%;
  white-space: nowrap;
}

.unified-table {
  display: table;
  min-width: 100%;
}

.table-header {
  display: table-row;
  background-color: #f5f7fa;
}

.table-row {
  display: table-row;
  border-bottom: 2rpx solid #ebeef5;
}

.table-cell {
  display: table-cell;
  padding: 20rpx 16rpx;
  vertical-align: middle;
  font-size: 26rpx;
  color: #606266;
}

.cell-type {
  width: 100rpx;
  text-align: center;
}

.cell-name {
  min-width: 280rpx;
}

.cell-score {
  width: 120rpx;
  text-align: center;
}

.cell-gap {
  width: 100rpx;
  text-align: center;
}

.cell-conf {
  width: 100rpx;
  text-align: center;
}

.school-cell {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.school-name-text {
  white-space: normal;
  word-break: break-all;
}

/* Empty state */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 0;
}

.empty-text {
  margin-top: 20rpx;
  font-size: 28rpx;
  color: #909399;
}
</style>
