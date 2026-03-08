<template>
  <view class="page-container">
    <!-- 步骤指示器 -->
    <view class="steps">
      <view
        v-for="(step, index) in stepNames"
        :key="index"
        class="step-item"
        :class="{ active: currentStep === index, completed: currentStep > index }"
      >
        <view class="step-circle">
          <text v-if="currentStep <= index">{{ index + 1 }}</text>
          <uni-icons v-else type="checkmarkempty" size="14" color="#fff" />
        </view>
        <text class="step-name">{{ step }}</text>
      </view>
    </view>

    <!-- 步骤 1: 基本信息 -->
    <view v-show="currentStep === 0" class="step-content">
      <view class="form-card">
        <view class="card-header">
          <uni-icons type="person" size="20" color="#409EFF" />
          <text class="card-title">考生基本信息</text>
        </view>

        <view class="form-body">
          <!-- 所属区县 -->
          <view class="form-item">
            <text class="form-label required">所属区县</text>
            <picker
              mode="selector"
              :range="districtOptions"
              range-key="label"
              @change="onDistrictPickerChange"
            >
              <view class="picker-input" :class="{ placeholder: !selectedDistrictName }">
                {{ selectedDistrictName || '请选择所属区县' }}
                <uni-icons type="arrowdown" size="14" color="#c0c4cc" />
              </view>
            </picker>
          </view>

          <!-- 初中学校 -->
          <view class="form-item">
            <text class="form-label required">初中学校</text>
            <picker
              mode="selector"
              :range="filteredMiddleSchoolOptions"
              range-key="label"
              :disabled="!form.districtId || middleSchoolsLoading"
              @change="onMiddleSchoolPickerChange"
            >
              <view
                class="picker-input"
                :class="{ placeholder: !selectedMiddleSchoolName, disabled: !form.districtId }"
              >
                {{
                  middleSchoolsLoading
                    ? '加载中...'
                    : selectedMiddleSchoolName || '请先选择区县'
                }}
                <uni-icons type="arrowdown" size="14" color="#c0c4cc" />
              </view>
            </picker>
          </view>

          <!-- 名额分配到校资格 -->
          <view class="form-item checkbox-item">
            <view class="checkbox-wrapper" @click="toggleQuotaEligibility">
              <view class="checkbox" :class="{ checked: form.hasQuotaSchoolEligibility }">
                <uni-icons
                  v-if="form.hasQuotaSchoolEligibility"
                  type="checkmarkempty"
                  size="14"
                  color="#fff"
                />
              </view>
              <text class="checkbox-label">具备名额分配到校填报资格</text>
            </view>
            <text class="form-tip">
              仅限"不选择生源初中在籍在读满3年的应届初三学生"
            </text>
          </view>
        </view>
      </view>
    </view>

    <!-- 步骤 2: 成绩信息 -->
    <view v-show="currentStep === 1" class="step-content">
      <view class="form-card">
        <view class="card-header">
          <uni-icons type="paperclip" size="20" color="#409EFF" />
          <text class="card-title">中考成绩</text>
        </view>

        <view class="form-body">
          <!-- 总分和综合素质 -->
          <view class="form-row">
            <view class="form-item half">
              <text class="form-label required">中考总分</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.total"
                  type="number"
                  class="number-input"
                  placeholder="0"
                  :maxlength="3"
                />
                <text class="input-suffix">分</text>
              </view>
            </view>
            <view class="form-item half">
              <text class="form-label required">综合素质评价</text>
              <view class="number-input-wrapper disabled">
                <input
                  :value="form.comprehensiveQuality"
                  type="number"
                  class="number-input"
                  disabled
                />
                <text class="input-suffix">分</text>
              </view>
              <text class="form-tip">默认50分（合格）</text>
            </view>
          </view>

          <!-- 分隔线 -->
          <view class="divider">
            <text>各科成绩（选填）</text>
          </view>

          <!-- 语文/数学/外语 -->
          <view class="form-row">
            <view class="form-item third">
              <text class="form-label">语文</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.chinese"
                  type="number"
                  class="number-input"
                  placeholder="0"
                />
              </view>
            </view>
            <view class="form-item third">
              <text class="form-label">数学</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.math"
                  type="number"
                  class="number-input"
                  placeholder="0"
                />
              </view>
            </view>
            <view class="form-item third">
              <text class="form-label">外语</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.foreign"
                  type="number"
                  class="number-input"
                  placeholder="0"
                />
              </view>
            </view>
          </view>

          <!-- 综合/道法/历史 -->
          <view class="form-row">
            <view class="form-item third">
              <text class="form-label">综合测试</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.integrated"
                  type="number"
                  class="number-input"
                  placeholder="0"
                />
              </view>
            </view>
            <view class="form-item third">
              <text class="form-label">道德与法治</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.ethics"
                  type="number"
                  class="number-input"
                  placeholder="0"
                />
              </view>
            </view>
            <view class="form-item third">
              <text class="form-label">历史</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.history"
                  type="number"
                  class="number-input"
                  placeholder="0"
                />
              </view>
            </view>
          </view>

          <!-- 体育 -->
          <view class="form-row">
            <view class="form-item third">
              <text class="form-label">体育</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.scores.pe"
                  type="number"
                  class="number-input"
                  placeholder="0"
                />
              </view>
            </view>
          </view>

          <!-- 成绩校验提示 -->
          <view v-if="!isScoreValid" class="alert warning">
            <uni-icons type="info" size="16" color="#e6a23c" />
            <text>{{ scoreValidation.message }}</text>
          </view>
          <view
            v-else-if="hasAnySubjectScore && !hasAllSubjectScores"
            class="alert info"
          >
            <uni-icons type="info" size="16" color="#409EFF" />
            <text>
              已填科目合计 {{ calculatedTotal }} 分，总分 {{ form.scores.total }} 分。
            </text>
          </view>

          <!-- 分隔线 -->
          <view class="divider">
            <text>校内排名</text>
          </view>

          <!-- 排名 -->
          <view class="form-row">
            <view class="form-item half">
              <text class="form-label required">校内排名</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.ranking.rank"
                  type="number"
                  class="number-input"
                  placeholder="1"
                />
              </view>
            </view>
            <view class="form-item half">
              <text class="form-label required">校内总人数</text>
              <view class="number-input-wrapper">
                <input
                  v-model="form.ranking.totalStudents"
                  type="number"
                  class="number-input"
                  placeholder="1"
                />
              </view>
            </view>
          </view>

          <!-- 排名校验提示 -->
          <view
            v-if="form.ranking.rank > form.ranking.totalStudents && form.ranking.totalStudents > 0"
            class="alert error"
          >
            <uni-icons type="closeempty" size="16" color="#f56c6c" />
            <text>校内排名不能大于总人数</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 步骤 3: 志愿填报 -->
    <view v-show="currentStep === 2" class="step-content">
      <view class="form-card">
        <view class="card-header">
          <uni-icons type="list" size="20" color="#409EFF" />
          <text class="card-title">志愿填报</text>
        </view>

        <view class="form-body">
          <!-- 名额分配到区 -->
          <view class="volunteer-section">
            <view class="section-header">
              <view class="tag primary">名额分配到区</view>
              <text class="section-hint">1个志愿 | 总分800分 | 全区竞争</text>
            </view>
            <picker
              mode="selector"
              :range="quotaDistrictOptions"
              range-key="label"
              @change="onQuotaDistrictChange"
            >
              <view class="picker-input volunteer-picker">
                <text v-if="selectedQuotaDistrictName" class="selected-text">
                  {{ selectedQuotaDistrictName }}
                </text>
                <text v-else class="placeholder-text">请选择学校</text>
                <uni-icons type="arrowdown" size="14" color="#c0c4cc" />
              </view>
            </picker>
            <view
              v-if="quotaDistrictSchools.length === 0 && !highSchoolsLoading"
              class="form-tip"
            >
              暂无名额分配到区的学校数据
            </view>
          </view>

          <!-- 名额分配到校 -->
          <view v-if="form.hasQuotaSchoolEligibility" class="volunteer-section">
            <view class="section-header">
              <view class="tag success">名额分配到校</view>
              <text class="section-hint">2个志愿 | 总分800分 | 校内竞争</text>
            </view>
            <view
              v-for="(schoolId, index) in form.volunteers.quotaSchool"
              :key="'quota-' + index"
              class="volunteer-item"
            >
              <view class="volunteer-index">{{ index + 1 }}</view>
              <picker
                mode="selector"
                :range="getFilteredQuotaSchoolOptions(index)"
                range-key="label"
                class="volunteer-picker-flex"
                @change="(e: any) => onQuotaSchoolChange(e, index)"
              >
                <view class="picker-input volunteer-picker">
                  <text
                    v-if="getQuotaSchoolName(index)"
                    class="selected-text"
                  >
                    {{ getQuotaSchoolName(index) }}
                  </text>
                  <text v-else class="placeholder-text">请选择学校</text>
                  <uni-icons type="arrowdown" size="14" color="#c0c4cc" />
                </view>
              </picker>
              <view
                v-if="form.volunteers.quotaSchool[index]"
                class="clear-btn"
                @click="clearVolunteer('quotaSchool', index)"
              >
                <uni-icons type="closeempty" size="16" color="#909399" />
              </view>
            </view>
            <view
              v-if="quotaSchoolSchools.length === 0 && !highSchoolsLoading"
              class="alert warning quota-warning"
            >
              <uni-icons type="info" size="16" color="#e6a23c" />
              <text>您所在初中暂无名额分配到校数据，仍可填报统一招生志愿。</text>
            </view>
          </view>

          <!-- 统一招生 -->
          <view class="volunteer-section">
            <view class="section-header">
              <view class="tag warning">统一招生</view>
              <text class="section-hint">1-15志愿 | 总分750分 | 平行志愿</text>
            </view>
            <view
              v-for="(schoolId, index) in form.volunteers.unified"
              :key="'unified-' + index"
              class="volunteer-item"
            >
              <view class="volunteer-index">{{ index + 1 }}</view>
              <picker
                mode="selector"
                :range="getFilteredUnifiedOptions(index)"
                range-key="label"
                class="volunteer-picker-flex"
                @change="(e: any) => onUnifiedChange(e, index)"
              >
                <view class="picker-input volunteer-picker">
                  <text v-if="getUnifiedName(index)" class="selected-text">
                    {{ getUnifiedName(index) }}
                  </text>
                  <text v-else class="placeholder-text">请选择学校</text>
                  <uni-icons type="arrowdown" size="14" color="#c0c4cc" />
                </view>
              </picker>
              <view
                v-if="form.volunteers.unified[index]"
                class="clear-btn"
                @click="clearVolunteer('unified', index)"
              >
                <uni-icons type="closeempty" size="16" color="#909399" />
              </view>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 操作按钮 -->
    <view class="form-actions">
      <AppButton
        v-if="currentStep > 0"
        type="default"
        class="action-btn"
        @click="prevStep"
      >
        上一步
      </AppButton>
      <AppButton
        v-if="currentStep < 2"
        type="primary"
        class="action-btn"
        :disabled="!canNext"
        @click="nextStep"
      >
        下一步
      </AppButton>
      <AppButton
        v-if="currentStep === 2"
        type="primary"
        class="action-btn"
        :loading="submitting"
        :disabled="!canSubmit"
        @click="submit"
      >
        开始分析
      </AppButton>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { AppButton } from '@/components/common';
import { useCandidateStore } from '@/stores/candidate';
import {
  getDistricts,
  getMiddleSchools,
  getSchoolsWithQuotaDistrict,
  getSchoolsWithQuotaSchool,
  getSchoolsForUnified,
  type District,
  type MiddleSchool,
  type SchoolWithQuota,
  type SchoolForUnified,
} from '@/api/reference';
import { submitAnalysis, formatFormToRequest } from '@/api/candidate';

// Types
interface PickerOption {
  label: string;
  value: number;
}

// Store
const store = useCandidateStore();
const form = computed(() => store.form);
const calculatedTotal = computed(() => store.calculatedTotal);
const hasAnySubjectScore = computed(() => store.hasAnySubjectScore);
const hasAllSubjectScores = computed(() => store.hasAllSubjectScores);
const scoreValidation = computed(() => store.scoreValidation);
const isScoreValid = computed(() => store.isScoreValid);

// State
const stepNames = ['基本信息', '成绩信息', '志愿填报'];
const currentStep = ref(0);
const submitting = ref(false);

// District data
const districts = ref<District[]>([]);
const districtOptions = computed<PickerOption[]>(() =>
  districts.value.map((d) => ({ label: d.name, value: d.id }))
);
const selectedDistrictName = computed(() =>
  districts.value.find((d) => d.id === form.value.districtId)?.name
);

// Middle school data
const middleSchools = ref<MiddleSchool[]>([]);
const middleSchoolsLoading = ref(false);
const middleSchoolOptions = computed<PickerOption[]>(() =>
  middleSchools.value.map((m) => ({ label: m.name, value: m.id }))
);
const filteredMiddleSchoolOptions = computed(() => middleSchoolOptions.value);
const selectedMiddleSchoolName = computed(() =>
  middleSchools.value.find((m) => m.id === form.value.middleSchoolId)?.name
);

// High school data for volunteers
const quotaDistrictSchools = ref<SchoolWithQuota[]>([]);
const quotaSchoolSchools = ref<SchoolWithQuota[]>([]);
const unifiedSchools = ref<SchoolForUnified[]>([]);
const highSchoolsLoading = ref(false);

// Computed options for volunteer pickers
const quotaDistrictOptions = computed<PickerOption[]>(() =>
  quotaDistrictSchools.value.map((s) => ({
    label: `${s.fullName} (${s.code}) - 名额${s.quotaCount}人`,
    value: s.id,
  }))
);
const selectedQuotaDistrictName = computed(() => {
  const school = quotaDistrictSchools.value.find(
    (s) => s.id === form.value.volunteers.quotaDistrict
  );
  return school ? `${school.fullName} (${school.code})` : '';
});

const quotaSchoolOptions = computed<PickerOption[]>(() =>
  quotaSchoolSchools.value.map((s) => ({
    label: `${s.fullName} (${s.code}) - 名额${s.quotaCount}人`,
    value: s.id,
  }))
);

const unifiedOptions = computed<PickerOption[]>(() =>
  unifiedSchools.value.map((s) => ({
    label: `${s.fullName} (${s.code})`,
    value: s.id,
  }))
);

// Get selected school names
function getQuotaSchoolName(index: number): string {
  const schoolId = form.value.volunteers.quotaSchool[index];
  if (!schoolId) return '';
  const school = quotaSchoolSchools.value.find((s) => s.id === schoolId);
  return school ? `${school.fullName} (${school.code})` : '';
}

function getUnifiedName(index: number): string {
  const schoolId = form.value.volunteers.unified[index];
  if (!schoolId) return '';
  const school = unifiedSchools.value.find((s) => s.id === schoolId);
  return school ? `${school.fullName} (${school.code})` : '';
}

// Filter options to exclude already selected schools
const selectedQuotaSchoolIds = computed(() => {
  const ids = new Set<number>();
  for (const id of form.value.volunteers.quotaSchool) {
    if (id) ids.add(id);
  }
  return ids;
});

const selectedUnifiedIds = computed(() => {
  const ids = new Set<number>();
  for (const id of form.value.volunteers.unified) {
    if (id) ids.add(id);
  }
  return ids;
});

function getFilteredQuotaSchoolOptions(currentIndex: number): PickerOption[] {
  const currentValue = form.value.volunteers.quotaSchool[currentIndex];
  return quotaSchoolOptions.value.filter((opt) => {
    if (opt.value === currentValue) return true;
    return !selectedQuotaSchoolIds.value.has(opt.value);
  });
}

function getFilteredUnifiedOptions(currentIndex: number): PickerOption[] {
  const currentValue = form.value.volunteers.unified[currentIndex];
  return unifiedOptions.value.filter((opt) => {
    if (opt.value === currentValue) return true;
    return !selectedUnifiedIds.value.has(opt.value);
  });
}

// Step validation
const canNext = computed(() => {
  if (currentStep.value === 0) {
    return form.value.districtId !== null && form.value.middleSchoolId !== null;
  }
  if (currentStep.value === 1) {
    return (
      form.value.scores.total > 0 &&
      form.value.ranking.rank > 0 &&
      form.value.ranking.totalStudents > 0 &&
      form.value.ranking.rank <= form.value.ranking.totalStudents &&
      isScoreValid.value
    );
  }
  return true;
});

const canSubmit = computed(() => {
  const hasQuotaDistrict = form.value.volunteers.quotaDistrict !== null;
  const hasQuotaSchool = form.value.volunteers.quotaSchool.some((id) => id !== 0);
  const hasUnified = form.value.volunteers.unified.some((id) => id !== 0);
  return hasQuotaDistrict || hasQuotaSchool || hasUnified;
});

// Methods
async function loadDistricts() {
  try {
    const data = await getDistricts();
    districts.value = data.districts;
  } catch (error) {
    uni.showToast({ title: '加载区县失败', icon: 'none' });
  }
}

async function onDistrictChange() {
  store.form.middleSchoolId = null;
  middleSchools.value = [];

  if (!form.value.districtId) return;

  middleSchoolsLoading.value = true;
  try {
    const data = await getMiddleSchools({ districtId: form.value.districtId });
    middleSchools.value = data.middleSchools;
  } catch (error) {
    uni.showToast({ title: '加载初中学校失败', icon: 'none' });
  } finally {
    middleSchoolsLoading.value = false;
  }
}

async function loadQuotaSchools() {
  if (!form.value.districtId) return;

  highSchoolsLoading.value = true;
  try {
    const [quotaDistrictRes, quotaSchoolRes, unifiedRes] = await Promise.all([
      getSchoolsWithQuotaDistrict({ districtId: form.value.districtId, year: 2025 }),
      form.value.middleSchoolId
        ? getSchoolsWithQuotaSchool({
            middleSchoolId: form.value.middleSchoolId,
            year: 2025,
          })
        : Promise.resolve({ schools: [] }),
      getSchoolsForUnified({ districtId: form.value.districtId, year: 2025 }),
    ]);

    quotaDistrictSchools.value = quotaDistrictRes.schools;
    quotaSchoolSchools.value = quotaSchoolRes.schools;
    unifiedSchools.value = unifiedRes.schools;
  } catch (error) {
    uni.showToast({ title: '加载高中学校失败', icon: 'none' });
  } finally {
    highSchoolsLoading.value = false;
  }
}

// Picker change handlers
function onDistrictPickerChange(e: any) {
  const index = e.detail.value;
  const option = districtOptions.value[index];
  if (option) {
    store.form.districtId = option.value;
    onDistrictChange();
  }
}

function onMiddleSchoolPickerChange(e: any) {
  const index = e.detail.value;
  const option = filteredMiddleSchoolOptions.value[index];
  if (option) {
    store.form.middleSchoolId = option.value;
  }
}

function toggleQuotaEligibility() {
  store.form.hasQuotaSchoolEligibility = !store.form.hasQuotaSchoolEligibility;
}

function onQuotaDistrictChange(e: any) {
  const index = e.detail.value;
  const option = quotaDistrictOptions.value[index];
  store.form.volunteers.quotaDistrict = option ? option.value : null;
}

function onQuotaSchoolChange(e: any, idx: number) {
  const index = e.detail.value;
  const options = getFilteredQuotaSchoolOptions(idx);
  const option = options[index];
  store.form.volunteers.quotaSchool[idx] = option ? option.value : 0;
}

function onUnifiedChange(e: any, idx: number) {
  const index = e.detail.value;
  const options = getFilteredUnifiedOptions(idx);
  const option = options[index];
  store.form.volunteers.unified[idx] = option ? option.value : 0;
}

function clearVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified', index?: number) {
  if (batch === 'quotaDistrict') {
    store.form.volunteers.quotaDistrict = null;
  } else if (batch === 'quotaSchool' && index !== undefined) {
    store.form.volunteers.quotaSchool[index] = 0;
  } else if (batch === 'unified' && index !== undefined) {
    store.form.volunteers.unified[index] = 0;
  }
}

function nextStep() {
  if (currentStep.value < 2) {
    currentStep.value++;
    if (currentStep.value === 2) {
      loadQuotaSchools();
    }
  }
}

function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--;
  }
}

async function submit() {
  if (submitting.value) return;

  submitting.value = true;
  try {
    const request = await formatFormToRequest(form.value);
    const { analysisId } = await submitAnalysis(request);
    uni.showToast({ title: '分析请求已提交', icon: 'success' });
    uni.navigateTo({ url: `/pages/result/result?id=${analysisId}` });
  } catch (error: any) {
    uni.showToast({ title: error.message || '提交失败', icon: 'none' });
  } finally {
    submitting.value = false;
  }
}

// Watch for district changes
watch(
  () => form.value.districtId,
  () => {
    if (form.value.districtId) {
      onDistrictChange();
    }
  }
);

// Initialize
onMounted(() => {
  loadDistricts();
});
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background-color: #f5f7fa;
  padding-bottom: 140rpx;
}

// Steps
.steps {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 32rpx 40rpx;
  background-color: #fff;
  border-bottom: 1rpx solid #ebeef5;
}

.step-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;

  &.active .step-circle {
    background-color: #409eff;
    color: #fff;
  }

  &.completed .step-circle {
    background-color: #67c23a;
  }
}

.step-circle {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background-color: #c0c4cc;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  margin-bottom: 8rpx;
}

.step-name {
  font-size: 24rpx;
  color: #606266;

  .active & {
    color: #409eff;
    font-weight: 500;
  }
}

// Form Card
.step-content {
  padding: 24rpx;
}

.form-card {
  background-color: #fff;
  border-radius: 16rpx;
  overflow: hidden;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 24rpx 32rpx;
  border-bottom: 1rpx solid #ebeef5;
}

.card-title {
  font-size: 32rpx;
  font-weight: 500;
  color: #303133;
}

.form-body {
  padding: 24rpx 32rpx;
}

// Form Items
.form-item {
  margin-bottom: 32rpx;

  &.checkbox-item {
    margin-bottom: 0;
  }
}

.form-label {
  display: block;
  font-size: 28rpx;
  color: #606266;
  margin-bottom: 16rpx;

  &.required::before {
    content: '*';
    color: #f56c6c;
    margin-right: 4rpx;
  }
}

.form-tip {
  font-size: 24rpx;
  color: #909399;
  margin-top: 8rpx;
}

// Picker Input
.picker-input {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 80rpx;
  padding: 0 24rpx;
  background-color: #f5f7fa;
  border-radius: 8rpx;
  font-size: 28rpx;
  color: #303133;

  &.placeholder {
    color: #c0c4cc;
  }

  &.disabled {
    background-color: #f5f5f5;
    color: #c0c4cc;
  }
}

// Number Input
.number-input-wrapper {
  display: flex;
  align-items: center;
  height: 80rpx;
  padding: 0 24rpx;
  background-color: #f5f7fa;
  border-radius: 8rpx;

  &.disabled {
    background-color: #f5f5f5;
  }
}

.number-input {
  flex: 1;
  font-size: 28rpx;
  color: #303133;
}

.input-suffix {
  font-size: 28rpx;
  color: #909399;
  margin-left: 8rpx;
}

// Form Row
.form-row {
  display: flex;
  gap: 24rpx;
  margin-bottom: 32rpx;
}

.form-item.half {
  flex: 1;
  margin-bottom: 0;
}

.form-item.third {
  flex: 1;
  margin-bottom: 0;
}

// Divider
.divider {
  display: flex;
  align-items: center;
  margin: 32rpx 0;

  &::before,
  &::after {
    content: '';
    flex: 1;
    height: 1rpx;
    background-color: #ebeef5;
  }

  text {
    padding: 0 24rpx;
    font-size: 26rpx;
    color: #909399;
  }
}

// Checkbox
.checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.checkbox {
  width: 40rpx;
  height: 40rpx;
  border-radius: 8rpx;
  border: 2rpx solid #dcdfe6;
  display: flex;
  align-items: center;
  justify-content: center;

  &.checked {
    background-color: #409eff;
    border-color: #409eff;
  }
}

.checkbox-label {
  font-size: 28rpx;
  color: #303133;
}

// Alert
.alert {
  display: flex;
  align-items: flex-start;
  gap: 12rpx;
  padding: 20rpx 24rpx;
  border-radius: 8rpx;
  margin-top: 24rpx;
  font-size: 26rpx;
  line-height: 1.5;

  &.warning {
    background-color: #fdf6ec;
    color: #e6a23c;
  }

  &.info {
    background-color: #ecf5ff;
    color: #409eff;
  }

  &.error {
    background-color: #fef0f0;
    color: #f56c6c;
  }
}

// Volunteer Section
.volunteer-section {
  margin-bottom: 40rpx;
  padding-bottom: 32rpx;
  border-bottom: 1rpx solid #ebeef5;

  &:last-child {
    border-bottom: none;
    margin-bottom: 0;
  }
}

.section-header {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 24rpx;
}

.tag {
  padding: 8rpx 16rpx;
  border-radius: 6rpx;
  font-size: 24rpx;
  font-weight: 500;

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
}

.section-hint {
  font-size: 24rpx;
  color: #909399;
}

.volunteer-picker {
  margin-top: 16rpx;

  .selected-text {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .placeholder-text {
    flex: 1;
    color: #c0c4cc;
  }
}

.volunteer-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 16rpx;
  margin-top: 16rpx;
}

.volunteer-index {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background-color: #409eff;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  flex-shrink: 0;
}

.volunteer-picker-flex {
  flex: 1;
}

.clear-btn {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f5f7fa;
  border-radius: 50%;
}

.quota-warning {
  margin-top: 24rpx;
}

// Form Actions
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
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.05);
}

.action-btn {
  flex: 1;
  max-width: 320rpx;
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
    padding-bottom: 160rpx;
  }

  .steps {
    padding: 40rpx 80rpx;
    position: sticky;
    top: 0;
    background-color: #fff;
    z-index: 10;
    box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
  }

  .step-circle {
    width: 56rpx;
    height: 56rpx;
    font-size: 28rpx;
  }

  .step-name {
    font-size: 28rpx;
  }

  .step-content {
    padding: 32rpx 48rpx;
  }

  .form-card {
    border-radius: 20rpx;
    box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);
  }

  .card-header {
    padding: 28rpx 40rpx;
  }

  .card-title {
    font-size: 36rpx;
  }

  .form-body {
    padding: 32rpx 40rpx;
  }

  .form-label {
    font-size: 30rpx;
    margin-bottom: 20rpx;
  }

  .form-tip {
    font-size: 26rpx;
  }

  .picker-input,
  .number-input-wrapper {
    height: 88rpx;
    padding: 0 28rpx;
    border-radius: 12rpx;
    font-size: 30rpx;
    transition: border-color 0.2s ease, box-shadow 0.2s ease;

    &:hover {
      background-color: #f0f2f5;
    }

    &:focus-within {
      background-color: #fff;
      box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
    }
  }

  .number-input {
    font-size: 30rpx;
  }

  .form-row {
    gap: 32rpx;
    margin-bottom: 40rpx;
  }

  .divider text {
    font-size: 28rpx;
  }

  .checkbox {
    width: 44rpx;
    height: 44rpx;
  }

  .checkbox-label {
    font-size: 30rpx;
  }

  .alert {
    padding: 24rpx 28rpx;
    font-size: 28rpx;
  }

  .volunteer-section {
    margin-bottom: 48rpx;
    padding-bottom: 40rpx;
  }

  .tag {
    padding: 10rpx 20rpx;
    font-size: 26rpx;
  }

  .section-hint {
    font-size: 26rpx;
  }

  .volunteer-index {
    width: 56rpx;
    height: 56rpx;
    font-size: 28rpx;
  }

  .clear-btn {
    width: 64rpx;
    height: 64rpx;
    transition: background-color 0.2s ease;

    &:hover {
      background-color: #ebedf0;
    }
  }

  .form-actions {
    max-width: 960px;
    left: 50%;
    transform: translateX(-50%);
    border-radius: 20rpx 20rpx 0 0;
  }

  .action-btn {
    max-width: 280rpx;
    min-width: 200rpx;
    height: 88rpx;
    font-size: 32rpx;

    &:hover {
      transform: translateY(-2rpx);
    }
  }
}

// 大桌面端 (>= 1440px)
@media screen and (min-width: 1440px) {
  .page-container {
    max-width: 1080px;
  }

  .form-card {
    border-radius: 24rpx;
  }

  .form-actions {
    max-width: 1080px;
  }
}
/* #endif */
</style>
