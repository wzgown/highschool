<template>
  <div class="recommendation-view">
    <el-steps :active="currentStep" finish-status="success" class="steps" simple>
      <el-step title="基本信息" />
      <el-step title="模考成绩" />
      <el-step title="推荐结果" />
    </el-steps>

    <!-- 步骤 1: 基本信息 -->
    <div v-show="currentStep === 0" class="step-content">
      <el-card class="form-card">
        <template #header>
          <div class="card-header">
            <el-icon><User /></el-icon>
            <span>考生基本信息</span>
          </div>
        </template>

        <el-form :model="form" label-position="top" class="form-body">
          <el-form-item label="所属区县" required>
            <el-select
              v-model="form.districtId"
              placeholder="请选择所属区县"
              class="full-width"
              @change="onDistrictChange"
            >
              <el-option
                v-for="district in districts"
                :key="district.id"
                :label="district.name"
                :value="district.id"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="初中学校">
            <el-select
              v-model="form.middleSchoolId"
              placeholder="请先选择区县（选填，用于名额到校推荐）"
              class="full-width"
              :disabled="!form.districtId || middleSchoolsLoading"
              :loading="middleSchoolsLoading"
              filterable
              :filter-method="filterMiddleSchool"
              @visible-change="resetMiddleSchoolFilter"
              clearable
            >
              <el-option
                v-for="school in filteredMiddleSchools"
                :key="school.id"
                :label="school.name"
                :value="school.id"
              />
            </el-select>
          </el-form-item>

          <el-form-item>
            <el-checkbox v-model="form.hasQuotaSchoolEligibility">
              具备名额分配到校填报资格
            </el-checkbox>
            <div class="form-tip">
              仅限"不选择生源初中在籍在读满3年的应届初三学生"
            </div>
          </el-form-item>
        </el-form>
      </el-card>
    </div>

    <!-- 步骤 2: 模考成绩 -->
    <div v-show="currentStep === 1" class="step-content">
      <el-alert type="info" :closable="false" show-icon class="score-info-header">
        <template #title>成绩录入说明</template>
        请填写一模、二模成绩（至少填写一项）。各区总分不同（一模605-700分，二模605-615分），系统将自动转换为中考等效分数。
      </el-alert>

      <div class="score-cards">
        <!-- 一模成绩卡片 -->
        <el-card class="score-card">
          <template #header>
            <div class="score-card-header">
              <div class="title-row">
                <el-tag type="primary" size="large">一模成绩</el-tag>
                <span class="total-hint">{{ districtName }}一模总分：{{ firstMockTotal }}分</span>
              </div>
              <el-checkbox v-model="form.firstMock.hasScore">已参加</el-checkbox>
            </div>
          </template>

          <div v-if="form.firstMock.hasScore" class="score-form">
            <el-row :gutter="20">
              <el-col :xs="24" :sm="12">
                <el-form-item label="一模总分">
                  <el-input-number
                    v-model="form.firstMock.totalScore"
                    :min="0"
                    :max="firstMockTotal"
                    class="full-width"
                    controls-position="right"
                    placeholder="请输入总分"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12">
                <el-form-item label="区排名（选填）">
                  <el-input-number
                    v-model="form.firstMock.districtRank"
                    :min="1"
                    class="full-width"
                    controls-position="right"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-alert
              v-if="form.firstMock.totalScore > 0"
              type="success"
              :closable="false"
              show-icon
            >
              预估中考等效：约 {{ firstMockConverted.toFixed(1) }} 分（750分制）
            </el-alert>
          </div>
          <el-empty v-else description="未参加一模或成绩暂未公布" :image-size="60" />
        </el-card>

        <!-- 二模成绩卡片 -->
        <el-card class="score-card">
          <template #header>
            <div class="score-card-header">
              <div class="title-row">
                <el-tag type="success" size="large">二模成绩</el-tag>
                <span class="total-hint">{{ districtName }}二模总分：{{ secondMockTotal }}分</span>
              </div>
              <el-checkbox v-model="form.secondMock.hasScore">已参加</el-checkbox>
            </div>
          </template>

          <div v-if="form.secondMock.hasScore" class="score-form">
            <el-row :gutter="20">
              <el-col :xs="24" :sm="12">
                <el-form-item label="二模总分">
                  <el-input-number
                    v-model="form.secondMock.totalScore"
                    :min="0"
                    :max="secondMockTotal"
                    class="full-width"
                    controls-position="right"
                    placeholder="请输入总分"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12">
                <el-form-item label="区排名（选填）">
                  <el-input-number
                    v-model="form.secondMock.districtRank"
                    :min="1"
                    class="full-width"
                    controls-position="right"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-alert
              v-if="form.secondMock.totalScore > 0"
              type="success"
              :closable="false"
              show-icon
            >
              预估中考等效：约 {{ secondMockConverted.toFixed(1) }} 分（750分制）
            </el-alert>
          </div>
          <el-empty v-else description="未参加二模或成绩暂未公布" :image-size="60" />
        </el-card>
      </div>
    </div>

    <!-- 步骤 3: 推荐结果 -->
    <div v-show="currentStep === 2" class="step-content">
      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading" :size="48"><Loading /></el-icon>
        <p>正在生成智能推荐...</p>
      </div>

      <div v-else-if="hasAnyRecommendations" class="recommendations-container">
        <!-- Tab 切换一模/二模推荐结果 -->
        <el-tabs v-model="activeResultTab" type="border-card">
          <!-- 一模推荐结果 -->
          <el-tab-pane v-if="firstMockResults.hasData" name="firstMock">
            <template #label>
              <span class="tab-label">
                <el-tag type="primary" size="small">一模</el-tag>
                推荐结果
              </span>
            </template>

            <el-card v-if="firstMockResults.scoreConversion" class="conversion-card" shadow="never">
              <template #header>
                <div class="card-header">
                  <el-icon><TrendCharts /></el-icon>
                  <span>一模分数转换</span>
                </div>
              </template>
              <el-descriptions :column="3" border size="small">
                <el-descriptions-item label="原始分数">
                  {{ firstMockResults.scoreConversion.originalScore?.toFixed(1) }} 分
                </el-descriptions-item>
                <el-descriptions-item label="转换后750分制">
                  <el-tag type="primary">{{ firstMockResults.scoreConversion.convertedScore_750?.toFixed(1) }} 分</el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="转换后800分制">
                  <el-tag type="success">{{ firstMockResults.scoreConversion.convertedScore_800?.toFixed(1) }} 分</el-tag>
                </el-descriptions-item>
              </el-descriptions>
            </el-card>

            <RecommendationPanel
              :quota-district-recommendations="firstMockResults.quotaDistrictRecommendations"
              :quota-school-recommendations="firstMockResults.quotaSchoolRecommendations"
              :unified-recommendations="firstMockResults.unifiedRecommendations"
              :score-conversion="firstMockResults.scoreConversion"
            />
          </el-tab-pane>

          <!-- 二模推荐结果 -->
          <el-tab-pane v-if="secondMockResults.hasData" name="secondMock">
            <template #label>
              <span class="tab-label">
                <el-tag type="success" size="small">二模</el-tag>
                推荐结果
              </span>
            </template>

            <el-card v-if="secondMockResults.scoreConversion" class="conversion-card" shadow="never">
              <template #header>
                <div class="card-header">
                  <el-icon><TrendCharts /></el-icon>
                  <span>二模分数转换</span>
                </div>
              </template>
              <el-descriptions :column="3" border size="small">
                <el-descriptions-item label="原始分数">
                  {{ secondMockResults.scoreConversion.originalScore?.toFixed(1) }} 分
                </el-descriptions-item>
                <el-descriptions-item label="转换后750分制">
                  <el-tag type="primary">{{ secondMockResults.scoreConversion.convertedScore_750?.toFixed(1) }} 分</el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="转换后800分制">
                  <el-tag type="success">{{ secondMockResults.scoreConversion.convertedScore_800?.toFixed(1) }} 分</el-tag>
                </el-descriptions-item>
              </el-descriptions>
            </el-card>

            <RecommendationPanel
              :quota-district-recommendations="secondMockResults.quotaDistrictRecommendations"
              :quota-school-recommendations="secondMockResults.quotaSchoolRecommendations"
              :unified-recommendations="secondMockResults.unifiedRecommendations"
              :score-conversion="secondMockResults.scoreConversion"
            />
          </el-tab-pane>
        </el-tabs>

        <!-- 操作按钮 -->
        <div class="action-buttons">
          <el-button type="primary" size="large" @click="goToSimulation">
            <el-icon><EditPen /></el-icon>
            去模拟填报
          </el-button>
          <el-button size="large" @click="reset">
            <el-icon><RefreshRight /></el-icon>
            重新推荐
          </el-button>
        </div>
      </div>

      <el-empty v-else description="暂无推荐结果，请先填写模考成绩" />
    </div>

    <!-- 操作按钮 -->
    <div class="form-actions">
      <el-button v-if="currentStep === 1" @click="prevStep">
        上一步
      </el-button>
      <el-button
        v-if="currentStep === 1"
        type="success"
        :loading="loading"
        @click="getRecommendations"
        :disabled="!canGetRecommendations"
      >
        <el-icon><MagicStick /></el-icon>
        获取推荐
      </el-button>
      <el-button
        v-if="currentStep === 0"
        type="primary"
        @click="nextStep"
        :disabled="!canNext"
      >
        下一步
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { User, Document, TrendCharts, Loading, EditPen, RefreshRight, MagicStick } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { pinyin } from 'pinyin-pro'
import {
  getDistricts,
  getMiddleSchools,
  getVolunteerRecommendations,
  type District,
  type MiddleSchool,
  type RecommendedSchool,
  type ScoreConversion,
  ExamType,
} from '@/api/reference'
import RecommendationPanel from '@/components/recommendation/RecommendationPanel.vue'

const router = useRouter()

// 状态
const currentStep = ref(0)
const loading = ref(false)
const districts = ref<District[]>([])
const middleSchools = ref<MiddleSchool[]>([])
const filteredMiddleSchools = ref<MiddleSchool[]>([])
const middleSchoolsLoading = ref(false)
const activeResultTab = ref('firstMock')

// 表单数据
const form = reactive({
  districtId: null as number | null,
  middleSchoolId: null as number | null,
  hasQuotaSchoolEligibility: true,
  firstMock: {
    hasScore: true,
    totalScore: 0,
    districtRank: null as number | null,
  },
  secondMock: {
    hasScore: true,
    totalScore: 0,
    districtRank: null as number | null,
  },
})

// 推荐结果
interface RecommendationResults {
  hasData: boolean
  quotaDistrictRecommendations: RecommendedSchool[]
  quotaSchoolRecommendations: RecommendedSchool[]
  unifiedRecommendations: RecommendedSchool[]
  scoreConversion: ScoreConversion | undefined
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
  return d?.name || '未知区'
})

const currentConfig = computed(() => {
  return districtScoreConfig[form.districtId || 0] || { firstMock: 615, secondMock: 615, english: 150 }
})

const firstMockTotal = computed(() => currentConfig.value.firstMock)
const secondMockTotal = computed(() => currentConfig.value.secondMock)
const englishScore = computed(() => currentConfig.value.english)

const firstMockConverted = computed(() => {
  if (form.firstMock.totalScore <= 0 || firstMockTotal.value <= 0) return 0
  return (form.firstMock.totalScore / firstMockTotal.value) * 750
})

const secondMockConverted = computed(() => {
  if (form.secondMock.totalScore <= 0 || secondMockTotal.value <= 0) return 0
  return (form.secondMock.totalScore / secondMockTotal.value) * 750
})

const canNext = computed(() => {
  if (currentStep.value === 0) {
    return form.districtId !== null
  }
  if (currentStep.value === 1) {
    // 至少填写一项成绩
    return (form.firstMock.hasScore && form.firstMock.totalScore > 0) ||
           (form.secondMock.hasScore && form.secondMock.totalScore > 0)
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
    ElMessage.error('加载区县失败')
  }
}

async function onDistrictChange() {
  form.middleSchoolId = null
  middleSchools.value = []
  filteredMiddleSchools.value = []

  if (!form.districtId) return

  middleSchoolsLoading.value = true
  try {
    const data = await getMiddleSchools({ districtId: form.districtId })
    middleSchools.value = data.middleSchools
    filteredMiddleSchools.value = data.middleSchools
  } catch (error) {
    ElMessage.error('加载初中学校失败')
  } finally {
    middleSchoolsLoading.value = false
  }
}

function filterMiddleSchool(query: string) {
  if (!query) {
    filteredMiddleSchools.value = middleSchools.value
    return
  }

  const queryLower = query.toLowerCase()
  filteredMiddleSchools.value = middleSchools.value.filter(school => {
    if (school.name.includes(query)) return true
    if (school.code?.toLowerCase().includes(queryLower)) return true
    const fullPinyin = pinyin(school.name, { toneType: 'none' }).replace(/\s/g, '').toLowerCase()
    const initialPinyin = pinyin(school.name, { pattern: 'first', toneType: 'none' }).replace(/\s/g, '').toLowerCase()
    return fullPinyin.includes(queryLower) || initialPinyin.includes(queryLower)
  })
}

function resetMiddleSchoolFilter(visible: boolean) {
  if (visible) {
    filteredMiddleSchools.value = middleSchools.value
  }
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
    ElMessage.warning('请选择区县')
    return
  }

  const hasFirstMock = form.firstMock.hasScore && form.firstMock.totalScore > 0
  const hasSecondMock = form.secondMock.hasScore && form.secondMock.totalScore > 0

  if (!hasFirstMock && !hasSecondMock) {
    ElMessage.warning('请至少填写一项模考成绩')
    return
  }

  loading.value = true

  try {
    // 并行请求一模和二模的推荐
    const promises: Promise<void>[] = []

    if (hasFirstMock) {
      promises.push(
        getVolunteerRecommendations({
          districtId: form.districtId,
          middleSchoolId: form.middleSchoolId ?? undefined,
          examType: ExamType.FIRST_MOCK,
          totalScore: form.firstMock.totalScore,
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
          totalScore: form.secondMock.totalScore,
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

    // 设置默认显示的 tab
    if (hasSecondMock) {
      activeResultTab.value = 'secondMock'
    } else {
      activeResultTab.value = 'firstMock'
    }

    currentStep.value = 2
    ElMessage.success('推荐结果已生成')
  } catch (error: any) {
    ElMessage.error(error.message || '获取推荐失败')
  } finally {
    loading.value = false
  }
}

function goToSimulation() {
  router.push('/form')
}

function reset() {
  currentStep.value = 0
  form.districtId = null
  form.middleSchoolId = null
  form.hasQuotaSchoolEligibility = true
  form.firstMock = { hasScore: true, totalScore: 0, districtRank: null }
  form.secondMock = { hasScore: true, totalScore: 0, districtRank: null }

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
.recommendation-view {
  max-width: 900px;
  margin: 0 auto;
}

.steps {
  margin-bottom: 30px;
}

.step-content {
  margin-bottom: 20px;
  padding: 0 4px;
}

.form-card,
.conversion-card {
  :deep(.el-card__header) {
    padding: 16px 20px;
  }
}

.card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 500;
}

.form-body {
  padding: 10px 0;
}

.full-width {
  width: 100%;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.score-info-header {
  margin-bottom: 20px;
}

.score-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.score-card {
  :deep(.el-card__header) {
    padding: 12px 16px;
    background: #f5f7fa;
  }
}

.score-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .title-row {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .total-hint {
    font-size: 13px;
    color: #909399;
  }
}

.score-form {
  padding: 10px 0;
}

.score-breakdown {
  margin-top: 20px;

  .breakdown-content {
    font-size: 14px;
    color: #606266;

    ul {
      margin: 10px 0;
      padding-left: 20px;
    }

    li {
      margin-bottom: 4px;
    }
  }
}

.tab-label {
  display: flex;
  align-items: center;
  gap: 6px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: #409eff;

  p {
    margin-top: 16px;
    font-size: 16px;
  }
}

.recommendations-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 20px;
}

.form-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 30px;
  padding: 20px;
}

@media (max-width: 768px) {
  .score-cards {
    grid-template-columns: 1fr;
  }

  .form-actions,
  .action-buttons {
    flex-direction: column;

    .el-button {
      width: 100%;
    }
  }
}
</style>
