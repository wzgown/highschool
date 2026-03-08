<template>
  <view class="page-container">
    <!-- 步骤指示器 -->
    <view class="steps-container">
      <view
        v-for="(step, index) in steps"
        :key="index"
        class="step-item"
        :class="{ active: currentStep >= index, completed: currentStep > index }"
      >
        <view class="step-circle">
          <uni-icons v-if="currentStep > index" type="checkmarkempty" size="14" color="#fff" />
          <text v-else class="step-number">{{ index + 1 }}</text>
        </view>
        <text class="step-title">{{ step.title }}</text>
        <view v-if="index < steps.length - 1" class="step-line" :class="{ completed: currentStep > index }" />
      </view>
    </view>

    <!-- 步骤 1: 基本信息 -->
    <view v-show="currentStep === 0" class="step-content">
      <AppCard>
        <template #header>
          <view class="card-header">
            <uni-icons type="person-filled" size="20" color="#409eff" />
            <text class="card-title">考生基本信息</text>
          </view>
        </template>

        <view class="form-body">
          <!-- 所属区县 -->
          <view class="form-item">
            <text class="form-label required">所属区县</text>
            <picker
              mode="selector"
              :range="districts"
              range-key="name"
              @change="onDistrictChange"
            >
              <view class="picker-input" :class="{ placeholder: !form.districtId }">
                {{ districtName || '请选择所属区县' }}
                <uni-icons type="bottom" size="14" color="#c0c4cc" />
              </view>
            </picker>
          </view>

          <!-- 初中学校 -->
          <view class="form-item">
            <text class="form-label">初中学校</text>
            <picker
              mode="selector"
              :range="middleSchools"
              range-key="name"
              :disabled="!form.districtId || middleSchoolsLoading"
              @change="onMiddleSchoolChange"
            >
              <view class="picker-input" :class="{ placeholder: !form.middleSchoolId, disabled: !form.districtId }">
                {{ middleSchoolName || '请先选择区县（选填，用于名额到校推荐）' }}
                <uni-icons type="bottom" size="14" color="#c0c4cc" />
              </view>
            </picker>
          </view>

          <!-- 名额到校资格 -->
          <view class="form-item checkbox-item">
            <checkbox
              :checked="form.hasQuotaSchoolEligibility"
              color="#409eff"
              @click="form.hasQuotaSchoolEligibility = !form.hasQuotaSchoolEligibility"
            />
            <text class="checkbox-label" @click="form.hasQuotaSchoolEligibility = !form.hasQuotaSchoolEligibility">
              具备名额分配到校填报资格
            </text>
          </view>
          <view class="form-tip">
            仅限"不选择生源初中在籍在读满3年的应届初三学生"
          </view>
        </view>
      </AppCard>
    </view>

    <!-- 步骤 2: 模考成绩 -->
    <view v-show="currentStep === 1" class="step-content">
      <!-- 成绩录入说明 -->
      <view class="info-banner">
        <uni-icons type="info" size="18" color="#409eff" />
        <view class="info-content">
          <text class="info-title">成绩录入说明</text>
          <text class="info-text">请填写一模、二模成绩（至少填写一项）。各区总分不同，系统将自动转换为中考等效分数。</text>
        </view>
      </view>

      <view class="score-cards">
        <!-- 一模成绩卡片 -->
        <AppCard class="score-card">
          <template #header>
            <view class="score-card-header">
              <view class="title-row">
                <view class="tag tag-primary">一模成绩</view>
                <text class="total-hint">{{ districtName }}一模总分：{{ firstMockTotal }}分</text>
              </view>
              <checkbox
                :checked="form.firstMock.hasScore"
                color="#409eff"
                @click="form.firstMock.hasScore = !form.firstMock.hasScore"
              />
            </view>
          </template>

          <view v-if="form.firstMock.hasScore" class="score-form">
            <view class="form-row">
              <view class="form-item half">
                <text class="form-label">一模总分</text>
                <input
                  v-model="form.firstMock.totalScore"
                  type="number"
                  class="number-input"
                  :placeholder="`0-${firstMockTotal}`"
                />
              </view>
              <view class="form-item half">
                <text class="form-label">区排名（选填）</text>
                <input
                  v-model="form.firstMock.districtRank"
                  type="number"
                  class="number-input"
                  placeholder="请输入"
                />
              </view>
            </view>

            <view v-if="form.firstMock.totalScore > 0" class="score-result success">
              <uni-icons type="checkmarkempty" size="16" color="#67c23a" />
              <text>预估中考等效：约 {{ firstMockConverted.toFixed(1) }} 分（750分制）</text>
            </view>
          </view>
          <view v-else class="empty-state">
            <uni-icons type="info" size="40" color="#c0c4cc" />
            <text class="empty-text">未参加一模或成绩暂未公布</text>
          </view>
        </AppCard>

        <!-- 二模成绩卡片 -->
        <AppCard class="score-card">
          <template #header>
            <view class="score-card-header">
              <view class="title-row">
                <view class="tag tag-success">二模成绩</view>
                <text class="total-hint">{{ districtName }}二模总分：{{ secondMockTotal }}分</text>
              </view>
              <checkbox
                :checked="form.secondMock.hasScore"
                color="#409eff"
                @click="form.secondMock.hasScore = !form.secondMock.hasScore"
              />
            </view>
          </template>

          <view v-if="form.secondMock.hasScore" class="score-form">
            <view class="form-row">
              <view class="form-item half">
                <text class="form-label">二模总分</text>
                <input
                  v-model="form.secondMock.totalScore"
                  type="number"
                  class="number-input"
                  :placeholder="`0-${secondMockTotal}`"
                />
              </view>
              <view class="form-item half">
                <text class="form-label">区排名（选填）</text>
                <input
                  v-model="form.secondMock.districtRank"
                  type="number"
                  class="number-input"
                  placeholder="请输入"
                />
              </view>
            </view>

            <view v-if="form.secondMock.totalScore > 0" class="score-result success">
              <uni-icons type="checkmarkempty" size="16" color="#67c23a" />
              <text>预估中考等效：约 {{ secondMockConverted.toFixed(1) }} 分（750分制）</text>
            </view>
          </view>
          <view v-else class="empty-state">
            <uni-icons type="info" size="40" color="#c0c4cc" />
            <text class="empty-text">未参加二模或成绩暂未公布</text>
          </view>
        </AppCard>
      </view>
    </view>

    <!-- 步骤 3: 推荐结果 -->
    <view v-show="currentStep === 2" class="step-content">
      <view v-if="loading" class="loading-container">
        <view class="loading-spinner">
          <view class="spinner" />
        </view>
        <text class="loading-text">正在生成智能推荐...</text>
      </view>

      <view v-else-if="hasAnyRecommendations" class="recommendations-container">
        <!-- Tab 切换一模/二模推荐结果 -->
        <view class="segment-control">
          <view
            v-if="firstMockResults.hasData"
            class="segment-item"
            :class="{ active: activeResultTab === 'firstMock' }"
            @click="activeResultTab = 'firstMock'"
          >
            <view class="tag tag-primary tag-small">一模</view>
            <text>推荐结果</text>
          </view>
          <view
            v-if="secondMockResults.hasData"
            class="segment-item"
            :class="{ active: activeResultTab === 'secondMock' }"
            @click="activeResultTab = 'secondMock'"
          >
            <view class="tag tag-success tag-small">二模</view>
            <text>推荐结果</text>
          </view>
        </view>

        <!-- 一模推荐结果 -->
        <view v-show="activeResultTab === 'firstMock' && firstMockResults.hasData">
          <AppCard v-if="firstMockResults.scoreConversion" class="conversion-card">
            <template #header>
              <view class="card-header">
                <uni-icons type="staff-filled" size="18" color="#409eff" />
                <text class="card-title">一模分数转换</text>
              </view>
            </template>
            <view class="conversion-grid">
              <view class="conversion-item">
                <text class="conversion-label">原始分数</text>
                <text class="conversion-value">{{ firstMockResults.scoreConversion.originalScore?.toFixed(1) }} 分</text>
              </view>
              <view class="conversion-item">
                <text class="conversion-label">转换后750分制</text>
                <view class="tag tag-primary">{{ firstMockResults.scoreConversion.convertedScore750?.toFixed(1) }} 分</view>
              </view>
              <view class="conversion-item">
                <text class="conversion-label">转换后800分制</text>
                <view class="tag tag-success">{{ firstMockResults.scoreConversion.convertedScore800?.toFixed(1) }} 分</view>
              </view>
            </view>
          </AppCard>

          <RecommendationPanel
            :quota-district-recommendations="firstMockResults.quotaDistrictRecommendations"
            :quota-school-recommendations="firstMockResults.quotaSchoolRecommendations"
            :unified-recommendations="firstMockResults.unifiedRecommendations"
            :score-conversion="firstMockResults.scoreConversion"
          />
        </view>

        <!-- 二模推荐结果 -->
        <view v-show="activeResultTab === 'secondMock' && secondMockResults.hasData">
          <AppCard v-if="secondMockResults.scoreConversion" class="conversion-card">
            <template #header>
              <view class="card-header">
                <uni-icons type="staff-filled" size="18" color="#409eff" />
                <text class="card-title">二模分数转换</text>
              </view>
            </template>
            <view class="conversion-grid">
              <view class="conversion-item">
                <text class="conversion-label">原始分数</text>
                <text class="conversion-value">{{ secondMockResults.scoreConversion.originalScore?.toFixed(1) }} 分</text>
              </view>
              <view class="conversion-item">
                <text class="conversion-label">转换后750分制</text>
                <view class="tag tag-primary">{{ secondMockResults.scoreConversion.convertedScore750?.toFixed(1) }} 分</view>
              </view>
              <view class="conversion-item">
                <text class="conversion-label">转换后800分制</text>
                <view class="tag tag-success">{{ secondMockResults.scoreConversion.convertedScore800?.toFixed(1) }} 分</view>
              </view>
            </view>
          </AppCard>

          <RecommendationPanel
            :quota-district-recommendations="secondMockResults.quotaDistrictRecommendations"
            :quota-school-recommendations="secondMockResults.quotaSchoolRecommendations"
            :unified-recommendations="secondMockResults.unifiedRecommendations"
            :score-conversion="secondMockResults.scoreConversion"
          />
        </view>

        <!-- 操作按钮 -->
        <view class="action-buttons">
          <AppButton type="primary" size="large" @click="goToSimulation">
            <uni-icons type="compose" size="18" color="#fff" />
            <text>去模拟填报</text>
          </AppButton>
          <AppButton size="large" @click="reset">
            <uni-icons type="refresh" size="18" color="#606266" />
            <text>重新推荐</text>
          </AppButton>
        </view>
      </view>

      <view v-else class="empty-state large">
        <uni-icons type="info" size="64" color="#c0c4cc" />
        <text class="empty-text">暂无推荐结果，请先填写模考成绩</text>
      </view>
    </view>

    <!-- 操作按钮 -->
    <view class="form-actions">
      <AppButton v-if="currentStep === 1" @click="prevStep">
        上一步
      </AppButton>
      <AppButton
        v-if="currentStep === 1"
        type="success"
        :loading="loading"
        :disabled="!canGetRecommendations"
        @click="getRecommendations"
      >
        <uni-icons type="star" size="18" color="#fff" />
        <text>获取推荐</text>
      </AppButton>
      <AppButton
        v-if="currentStep === 0"
        type="primary"
        :disabled="!canNext"
        @click="nextStep"
      >
        下一步
      </AppButton>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from 'vue'
import { AppCard, AppButton } from '@/components/common'
import RecommendationPanel from '@/components/recommendation/RecommendationPanel.vue'
import {
  getDistricts,
  getMiddleSchools,
  getVolunteerRecommendations,
  ExamType,
  type District,
  type MiddleSchool,
} from '@/api/reference'

// 步骤定义
const steps = [
  { title: '基本信息' },
  { title: '模考成绩' },
  { title: '推荐结果' },
]

// 状态
const currentStep = ref(0)
const loading = ref(false)
const districts = ref<District[]>([])
const middleSchools = ref<MiddleSchool[]>([])
const middleSchoolsLoading = ref(false)
const activeResultTab = ref('firstMock')

// 表单数据
const form = reactive({
  districtId: null as number | null,
  middleSchoolId: null as number | null,
  hasQuotaSchoolEligibility: true,
  firstMock: {
    hasScore: true,
    totalScore: '' as string | number,
    districtRank: '' as string | number,
  },
  secondMock: {
    hasScore: true,
    totalScore: '' as string | number,
    districtRank: '' as string | number,
  },
})

// 推荐结果
interface RecommendationResults {
  hasData: boolean
  quotaDistrictRecommendations: any[]
  quotaSchoolRecommendations: any[]
  unifiedRecommendations: any[]
  scoreConversion: any
}

const firstMockResults = reactive<RecommendationResults>({
  hasData: false,
  quotaDistrictRecommendations: [],
  quotaSchoolRecommendations: [],
  unifiedRecommendations: [],
  scoreConversion: undefined,
})

const secondMockResults = reactive<RecommendationResults>({
  hasData: false,
  quotaDistrictRecommendations: [],
  quotaSchoolRecommendations: [],
  unifiedRecommendations: [],
  scoreConversion: undefined,
})

// 区总分配置
const districtScoreConfig: Record<number, { firstMock: number; secondMock: number; english: number }> = {
  1: { firstMock: 700, secondMock: 605, english: 140 }, // 徐汇
  2: { firstMock: 645, secondMock: 615, english: 150 }, // 杨浦
  3: { firstMock: 645, secondMock: 615, english: 150 }, // 闵行
  4: { firstMock: 645, secondMock: 615, english: 150 }, // 松江
  5: { firstMock: 645, secondMock: 605, english: 140 }, // 浦东
  6: { firstMock: 615, secondMock: 615, english: 150 }, // 黄浦
  7: { firstMock: 615, secondMock: 615, english: 150 }, // 宝山
  8: { firstMock: 615, secondMock: 615, english: 150 }, // 奉贤
  9: { firstMock: 635, secondMock: 615, english: 150 }, // 虹口
  10: { firstMock: 635, secondMock: 605, english: 140 }, // 普陀
  11: { firstMock: 635, secondMock: 605, english: 140 }, // 长宁
  12: { firstMock: 630, secondMock: 605, english: 140 }, // 静安
  13: { firstMock: 635, secondMock: 605, english: 140 }, // 嘉定
  14: { firstMock: 605, secondMock: 605, english: 140 }, // 青浦
  15: { firstMock: 605, secondMock: 605, english: 140 }, // 金山
  16: { firstMock: 605, secondMock: 605, english: 140 }, // 崇明
}

// 计算属性
const districtName = computed(() => {
  const d = districts.value.find(d => d.id === form.districtId)
  return d?.name || ''
})

const middleSchoolName = computed(() => {
  const s = middleSchools.value.find(s => s.id === form.middleSchoolId)
  return s?.name || ''
})

const currentConfig = computed(() => {
  return districtScoreConfig[form.districtId || 0] || { firstMock: 615, secondMock: 615, english: 150 }
})

const firstMockTotal = computed(() => currentConfig.value.firstMock)
const secondMockTotal = computed(() => currentConfig.value.secondMock)

const firstMockConverted = computed(() => {
  const score = Number(form.firstMock.totalScore) || 0
  if (score <= 0 || firstMockTotal.value <= 0) return 0
  return (score / firstMockTotal.value) * 750
})

const secondMockConverted = computed(() => {
  const score = Number(form.secondMock.totalScore) || 0
  if (score <= 0 || secondMockTotal.value <= 0) return 0
  return (score / secondMockTotal.value) * 750
})

const canNext = computed(() => {
  if (currentStep.value === 0) {
    return form.districtId !== null
  }
  if (currentStep.value === 1) {
    const firstScore = Number(form.firstMock.totalScore) || 0
    const secondScore = Number(form.secondMock.totalScore) || 0
    return (form.firstMock.hasScore && firstScore > 0) ||
           (form.secondMock.hasScore && secondScore > 0)
  }
  return true
})

const canGetRecommendations = computed(() => {
  return form.districtId !== null && canNext.value
})

const hasAnyRecommendations = computed(() => {
  return firstMockResults.hasData || secondMockResults.hasData
})

// 方法
async function loadDistricts() {
  try {
    const data = await getDistricts()
    districts.value = data.districts
  } catch (error) {
    uni.showToast({ title: '加载区县失败', icon: 'none' })
  }
}

function onDistrictChange(e: any) {
  const index = e.detail.value
  form.districtId = districts.value[index]?.id ?? null
  form.middleSchoolId = null
  middleSchools.value = []
  loadMiddleSchools()
}

async function loadMiddleSchools() {
  if (!form.districtId) return

  middleSchoolsLoading.value = true
  try {
    const data = await getMiddleSchools({ districtId: form.districtId })
    middleSchools.value = data.middleSchools
  } catch (error) {
    uni.showToast({ title: '加载初中学校失败', icon: 'none' })
  } finally {
    middleSchoolsLoading.value = false
  }
}

function onMiddleSchoolChange(e: any) {
  const index = e.detail.value
  form.middleSchoolId = middleSchools.value[index]?.id ?? null
}

function nextStep() {
  if (currentStep.value < 2) {
    currentStep.value++
  }
}

function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--
  }
}

async function getRecommendations() {
  if (!form.districtId) {
    uni.showToast({ title: '请选择区县', icon: 'none' })
    return
  }

  const firstScore = Number(form.firstMock.totalScore) || 0
  const secondScore = Number(form.secondMock.totalScore) || 0
  const hasFirstMock = form.firstMock.hasScore && firstScore > 0
  const hasSecondMock = form.secondMock.hasScore && secondScore > 0

  if (!hasFirstMock && !hasSecondMock) {
    uni.showToast({ title: '请至少填写一项模考成绩', icon: 'none' })
    return
  }

  loading.value = true

  try {
    const promises: Promise<void>[] = []

    if (hasFirstMock) {
      promises.push(
        getVolunteerRecommendations({
          districtId: form.districtId,
          middleSchoolId: form.middleSchoolId ?? undefined,
          examType: ExamType.FIRST_MOCK,
          totalScore: firstScore,
          hasQuotaSchoolEligibility: form.hasQuotaSchoolEligibility,
          year: 2025,
        }).then(res => {
          firstMockResults.quotaDistrictRecommendations = res.quotaDistrictRecommendations
          firstMockResults.quotaSchoolRecommendations = res.quotaSchoolRecommendations
          firstMockResults.unifiedRecommendations = res.unifiedRecommendations
          firstMockResults.scoreConversion = res.scoreConversion
          firstMockResults.hasData = true
        })
      )
    }

    if (hasSecondMock) {
      promises.push(
        getVolunteerRecommendations({
          districtId: form.districtId,
          middleSchoolId: form.middleSchoolId ?? undefined,
          examType: ExamType.SECOND_MOCK,
          totalScore: secondScore,
          hasQuotaSchoolEligibility: form.hasQuotaSchoolEligibility,
          year: 2025,
        }).then(res => {
          secondMockResults.quotaDistrictRecommendations = res.quotaDistrictRecommendations
          secondMockResults.quotaSchoolRecommendations = res.quotaSchoolRecommendations
          secondMockResults.unifiedRecommendations = res.unifiedRecommendations
          secondMockResults.scoreConversion = res.scoreConversion
          secondMockResults.hasData = true
        })
      )
    }

    await Promise.all(promises)

    if (hasSecondMock) {
      activeResultTab.value = 'secondMock'
    } else {
      activeResultTab.value = 'firstMock'
    }

    currentStep.value = 2
    uni.showToast({ title: '推荐结果已生成', icon: 'success' })
  } catch (error: any) {
    uni.showToast({ title: error.message || '获取推荐失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function goToSimulation() {
  uni.navigateTo({ url: '/pages/form/form' })
}

function reset() {
  currentStep.value = 0
  form.districtId = null
  form.middleSchoolId = null
  form.hasQuotaSchoolEligibility = true
  form.firstMock = { hasScore: true, totalScore: '', districtRank: '' }
  form.secondMock = { hasScore: true, totalScore: '', districtRank: '' }

  firstMockResults.hasData = false
  firstMockResults.quotaDistrictRecommendations = []
  firstMockResults.quotaSchoolRecommendations = []
  firstMockResults.unifiedRecommendations = []
  firstMockResults.scoreConversion = undefined

  secondMockResults.hasData = false
  secondMockResults.quotaDistrictRecommendations = []
  secondMockResults.quotaSchoolRecommendations = []
  secondMockResults.unifiedRecommendations = []
  secondMockResults.scoreConversion = undefined
}

onMounted(() => {
  loadDistricts()
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  padding: 24rpx;
  padding-bottom: 160rpx;
  background-color: #f5f7fa;
}

/* Steps */
.steps-container {
  display: flex;
  justify-content: space-between;
  padding: 24rpx 32rpx;
  margin-bottom: 24rpx;
  background-color: #fff;
  border-radius: 16rpx;
}

.step-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  flex: 1;
}

.step-circle {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #c0c4cc;
  transition: all 0.3s;
}

.step-item.active .step-circle {
  background-color: #409eff;
}

.step-item.completed .step-circle {
  background-color: #67c23a;
}

.step-number {
  font-size: 26rpx;
  color: #fff;
  font-weight: 500;
}

.step-title {
  margin-top: 12rpx;
  font-size: 24rpx;
  color: #909399;
}

.step-item.active .step-title {
  color: #303133;
  font-weight: 500;
}

.step-line {
  position: absolute;
  top: 24rpx;
  left: calc(50% + 32rpx);
  width: calc(100% - 64rpx);
  height: 4rpx;
  background-color: #e4e7ed;
}

.step-line.completed {
  background-color: #67c23a;
}

/* Card */
.card-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.card-title {
  font-size: 30rpx;
  font-weight: 500;
  color: #303133;
}

/* Form */
.form-body {
  padding: 16rpx 0;
}

.form-item {
  margin-bottom: 28rpx;
}

.form-item.half {
  flex: 1;
  margin-bottom: 0;
}

.form-label {
  display: block;
  font-size: 28rpx;
  color: #606266;
  margin-bottom: 12rpx;
}

.form-label.required::before {
  content: '*';
  color: #f56c6c;
  margin-right: 4rpx;
}

.picker-input {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 24rpx;
  background-color: #f5f7fa;
  border-radius: 12rpx;
  font-size: 28rpx;
  color: #303133;
}

.picker-input.placeholder {
  color: #c0c4cc;
}

.picker-input.disabled {
  opacity: 0.6;
}

.form-row {
  display: flex;
  gap: 24rpx;
}

.number-input {
  width: 100%;
  padding: 20rpx 24rpx;
  background-color: #f5f7fa;
  border-radius: 12rpx;
  font-size: 28rpx;
  box-sizing: border-box;
}

.checkbox-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.checkbox-label {
  font-size: 28rpx;
  color: #606266;
}

.form-tip {
  font-size: 24rpx;
  color: #909399;
  margin-top: -16rpx;
  margin-bottom: 16rpx;
}

/* Info banner */
.info-banner {
  display: flex;
  gap: 16rpx;
  padding: 20rpx 24rpx;
  margin-bottom: 24rpx;
  background-color: #ecf5ff;
  border-radius: 12rpx;
}

.info-content {
  flex: 1;
}

.info-title {
  display: block;
  font-size: 28rpx;
  font-weight: 500;
  color: #303133;
  margin-bottom: 8rpx;
}

.info-text {
  font-size: 24rpx;
  color: #606266;
  line-height: 1.5;
}

/* Score cards */
.score-cards {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.score-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.total-hint {
  font-size: 24rpx;
  color: #909399;
}

.score-form {
  padding: 16rpx 0;
}

.score-result {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 16rpx 20rpx;
  margin-top: 20rpx;
  border-radius: 12rpx;
  font-size: 26rpx;
}

.score-result.success {
  background-color: #f0f9eb;
  color: #67c23a;
}

/* Tags */
.tag {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 6rpx 16rpx;
  border-radius: 8rpx;
  font-size: 24rpx;
}

.tag-small {
  padding: 4rpx 12rpx;
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

/* Empty state */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40rpx 0;
}

.empty-state.large {
  padding: 80rpx 0;
}

.empty-text {
  margin-top: 16rpx;
  font-size: 26rpx;
  color: #909399;
}

/* Loading */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80rpx 0;
}

.loading-spinner {
  width: 80rpx;
  height: 80rpx;
}

.spinner {
  width: 100%;
  height: 100%;
  border: 6rpx solid #e4e7ed;
  border-top-color: #409eff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-text {
  margin-top: 24rpx;
  font-size: 30rpx;
  color: #409eff;
}

/* Recommendations */
.recommendations-container {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

/* Segment control */
.segment-control {
  display: flex;
  background-color: #fff;
  border-radius: 12rpx;
  overflow: hidden;
}

.segment-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  padding: 24rpx;
  font-size: 28rpx;
  color: #606266;
  transition: all 0.3s;
}

.segment-item.active {
  background-color: #ecf5ff;
  color: #409eff;
}

/* Conversion card */
.conversion-card {
  margin-bottom: 24rpx;
}

.conversion-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20rpx;
}

.conversion-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  text-align: center;
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

/* Action buttons */
.action-buttons {
  display: flex;
  justify-content: center;
  gap: 24rpx;
  margin-top: 32rpx;
}

.action-buttons .app-button {
  flex: 1;
}

/* Form actions */
.form-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  gap: 24rpx;
  padding: 24rpx 32rpx;
  padding-bottom: calc(24rpx + env(safe-area-inset-bottom));
  background-color: #fff;
  box-shadow: 0 -4rpx 16rpx rgba(0, 0, 0, 0.05);
}

.form-actions .app-button {
  flex: 1;
}

/* ========================================
   H5 桌面端优化
   ======================================== */

/* #ifdef H5 */
// 桌面端 (>= 1024px)
@media screen and (min-width: 1024px) {
  .page-container {
    max-width: 960px;
    margin: 0 auto;
    padding: 48rpx;
    padding-bottom: 180rpx;
  }

  .steps-container {
    padding: 32rpx 48rpx;
    border-radius: 20rpx;
    margin-bottom: 32rpx;
    position: sticky;
    top: 0;
    z-index: 10;
    box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.05);
  }

  .step-circle {
    width: 56rpx;
    height: 56rpx;
  }

  .step-number {
    font-size: 28rpx;
  }

  .step-title {
    font-size: 28rpx;
  }

  .step-line {
    top: 28rpx;
  }

  .card {
    border-radius: 20rpx;
    box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);
    transition: transform 0.2s ease, box-shadow 0.2s ease;

    &:hover {
      transform: translateY(-4rpx);
      box-shadow: 0 8rpx 28rpx rgba(0, 0, 0, 0.1);
    }
  }

  .card-header {
    padding: 28rpx 40rpx;
  }

  .card-title {
    font-size: 34rpx;
  }

  .card-body {
    padding: 32rpx 40rpx;
  }

  .form-body {
    padding: 24rpx 0;
  }

  .form-item {
    margin-bottom: 36rpx;
  }

  .form-label {
    font-size: 30rpx;
    margin-bottom: 16rpx;
  }

  .picker-input {
    padding: 24rpx 28rpx;
    border-radius: 12rpx;
    font-size: 30rpx;
    transition: background-color 0.2s ease;

    &:hover {
      background-color: #ebedf0;
    }
  }

  .form-row {
    gap: 32rpx;
  }

  .number-input {
    padding: 24rpx 28rpx;
    border-radius: 12rpx;
    font-size: 30rpx;
    transition: background-color 0.2s ease;

    &:hover {
      background-color: #ebedf0;
    }

    &:focus {
      background-color: #fff;
      box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
    }
  }

  .checkbox-item {
    gap: 20rpx;
  }

  .checkbox-label {
    font-size: 30rpx;
  }

  .form-tip {
    font-size: 26rpx;
  }

  .info-banner {
    padding: 24rpx 32rpx;
    border-radius: 16rpx;
    margin-bottom: 32rpx;
  }

  .info-title {
    font-size: 30rpx;
  }

  .info-text {
    font-size: 26rpx;
  }

  .score-cards {
    gap: 32rpx;
  }

  .score-card-header {
    margin-bottom: 24rpx;
  }

  .score-form {
    padding: 24rpx 0;
  }

  .score-result {
    padding: 20rpx 24rpx;
    border-radius: 12rpx;
    font-size: 28rpx;
  }

  .tag {
    padding: 8rpx 20rpx;
    font-size: 26rpx;
  }

  .tag-small {
    padding: 6rpx 16rpx;
    font-size: 24rpx;
  }

  .empty-state.large {
    padding: 100rpx 0;
  }

  .empty-text {
    font-size: 28rpx;
  }

  .loading-container {
    padding: 100rpx 0;
  }

  .loading-spinner {
    width: 100rpx;
    height: 100rpx;
  }

  .loading-text {
    font-size: 32rpx;
  }

  .recommendations-container {
    gap: 32rpx;
  }

  .segment-control {
    border-radius: 16rpx;
    overflow: hidden;
  }

  .segment-item {
    padding: 28rpx;
    font-size: 30rpx;
    cursor: pointer;
    transition: background-color 0.2s ease;

    &:hover:not(.active) {
      background-color: #f5f7fa;
    }
  }

  .conversion-card {
    margin-bottom: 32rpx;
  }

  .conversion-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 28rpx;
  }

  .conversion-item {
    padding: 20rpx;
    border-radius: 12rpx;
    background-color: #f5f7fa;
    transition: background-color 0.2s ease;

    &:hover {
      background-color: #ebedf0;
    }
  }

  .conversion-label {
    font-size: 26rpx;
  }

  .conversion-value {
    font-size: 32rpx;
  }

  .action-buttons {
    gap: 32rpx;
    margin-top: 40rpx;

    .app-button {
      min-width: 240rpx;
      max-width: 320rpx;

      &:hover {
        transform: translateY(-4rpx);
      }
    }
  }

  .form-actions {
    max-width: 960px;
    left: 50%;
    transform: translateX(-50%);
    border-radius: 20rpx 20rpx 0 0;
    padding: 28rpx 48rpx;

    .app-button {
      max-width: 280rpx;
      min-width: 200rpx;
      height: 88rpx;
      font-size: 32rpx;

      &:hover {
        transform: translateY(-4rpx);
      }
    }
  }
}

// 大桌面端 (>= 1440px)
@media screen and (min-width: 1440px) {
  .page-container {
    max-width: 1080px;
    padding: 64rpx;
  }

  .card {
    border-radius: 24rpx;
  }

  .form-actions {
    max-width: 1080px;
  }
}
/* #endif */
</style>
