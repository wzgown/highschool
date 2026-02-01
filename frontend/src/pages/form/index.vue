<template>
  <view class="page">
    <view class="container">
      <!-- 进度指示 -->
      <view class="progress">
        <view
          v-for="(step, index) in steps"
          :key="index"
          class="progress-step"
          :class="{ active: currentStep === index, completed: currentStep > index }"
        >
          <view class="progress-number">{{ index + 1 }}</view>
          <text class="progress-label">{{ step.label }}</text>
        </view>
      </view>

      <!-- 基本信息表单 -->
      <view v-if="currentStep === 0" class="form-section">
        <view class="section-title">基本信息</view>

        <view class="form-item">
          <text class="form-item-label form-item-required">所属区县</text>
          <picker mode="selector" :range="districts" range-key="name" @change="onDistrictChange">
            <view class="form-input">
              {{ selectedDistrict?.name || '请选择区县' }}
            </view>
          </picker>
        </view>

        <view class="form-item">
          <text class="form-item-label form-item-required">初中学校</text>
          <picker mode="selector" :range="middleSchools" range-key="name" @change="onMiddleSchoolChange">
            <view class="form-input">
              {{ selectedMiddleSchool?.name || '请选择初中学校' }}
            </view>
          </picker>
        </view>

        <view class="form-item">
          <view class="checkbox-item">
            <checkbox :checked="candidate.hasQuotaSchoolEligibility" @click="toggleQuotaEligibility" />
            <text class="checkbox-label">具备名额分配到校填报资格</text>
          </view>
          <text class="form-item-hint">仅限不选择生源初中在籍在读满3年的应届生</text>
        </view>
      </view>

      <!-- 成绩表单 -->
      <view v-if="currentStep === 1" class="form-section">
        <view class="section-title">中考成绩</view>

        <view class="form-item">
          <text class="form-item-label form-item-required">总分 (750)</text>
          <input
            class="form-input"
            type="digit"
            v-model.number="candidate.scores.total"
            placeholder="请输入总分"
            @blur="validateScores"
          />
        </view>

        <view class="score-grid">
          <view class="form-item" v-for="subject in subjects" :key="subject.key">
            <text class="form-item-label">{{ subject.name }} ({{ subject.max }})</text>
            <input
              class="form-input"
              type="digit"
              v-model.number="candidate.scores[subject.key]"
              placeholder="0"
              @blur="validateScores"
            />
          </view>
        </view>

        <view class="form-item">
          <text class="form-item-label">综合素质评价 (50)</text>
          <slider
            :value="candidate.comprehensiveQuality"
            :min="0"
            :max="50"
            :step="1"
            activeColor="#1890ff"
            @change="onQualityChange"
            show-value
          />
        </view>
      </view>

      <!-- 排名表单 -->
      <view v-if="currentStep === 2" class="form-section">
        <view class="section-title">区内排名</view>

        <view class="form-item">
          <text class="form-item-label form-item-required">区内排名</text>
          <input
            class="form-input"
            type="number"
            v-model.number="candidate.rank"
            placeholder="请输入排名"
          />
        </view>

        <view class="form-item">
          <text class="form-item-label form-item-required">全区总人数</text>
          <input
            class="form-input"
            type="number"
            v-model.number="candidate.totalStudents"
            placeholder="请输入总人数"
          />
        </view>

        <view class="info-card">
          <text class="info-card-title">💡 提示</text>
          <text class="info-card-text">如果您不确定确切排名，可以根据估分区间进行估算。系统将基于您提供的数据进行模拟分析。</text>
        </view>
      </view>

      <!-- 志愿表单 -->
      <view v-if="currentStep === 3" class="form-section">
        <view class="section-title">志愿填报</view>

        <!-- 名额分配到区 -->
        <view class="volunteer-section">
          <text class="volunteer-section-title">名额分配到区 (1个志愿)</text>
          <view class="form-item">
            <school-selector
              v-model="candidate.volunteers.quotaDistrict"
              :district-id="candidate.districtId"
              :quota-type="'district'"
              placeholder="选择学校（可选）"
            />
          </view>
        </view>

        <!-- 名额分配到校 -->
        <view v-if="candidate.hasQuotaSchoolEligibility" class="volunteer-section">
          <text class="volunteer-section-title">名额分配到校 (2个志愿)</text>
          <view class="form-item">
            <school-selector
              v-model="candidate.volunteers.quotaSchool[0]"
              :district-id="candidate.districtId"
              :quota-type="'school'"
              placeholder="第一志愿"
            />
          </view>
          <view class="form-item">
            <school-selector
              v-model="candidate.volunteers.quotaSchool[1]"
              :district-id="candidate.districtId"
              :quota-type="'school'"
              placeholder="第二志愿"
            />
          </view>
        </view>

        <!-- 统一招生 -->
        <view class="volunteer-section">
          <text class="volunteer-section-title">统一招生1-15志愿</text>
          <view class="form-item" v-for="i in 15" :key="i">
            <school-selector
              v-model="candidate.volunteers.unified[i - 1]"
              :district-id="candidate.districtId"
              placeholder="第{{ i }}志愿（可选）"
            />
          </view>
        </view>
      </view>

      <!-- 操作按钮 -->
      <view class="actions">
        <button v-if="currentStep > 0" class="btn btn-default" @tap="prevStep">上一步</button>
        <button v-if="currentStep < 3" class="btn btn-primary" @tap="nextStep">下一步</button>
        <button v-if="currentStep === 3" class="btn btn-primary" @tap="submit" :loading="submitting">
          提交分析
        </button>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useCandidateStore } from '@/stores/candidate';
import { useReferenceStore } from '@/stores/reference';
import type { District, MiddleSchool } from '@shared/types/api';

const candidateStore = useCandidateStore();
const referenceStore = useReferenceStore();

const currentStep = ref(0);
const submitting = ref(false);

const steps = [
  { label: '基本信息' },
  { label: '成绩' },
  { label: '排名' },
  { label: '志愿' },
];

const subjects = [
  { key: 'chinese', name: '语文', max: 150 },
  { key: 'math', name: '数学', max: 150 },
  { key: 'foreign', name: '外语', max: 150 },
  { key: 'integrated', name: '综合', max: 150 },
  { key: 'ethics', name: '道德', max: 60 },
  { key: 'history', name: '历史', max: 60 },
  { key: 'pe', name: '体育', max: 30 },
];

const candidate = computed(() => candidateStore);
const districts = computed(() => referenceStore.districts);
const middleSchools = computed(() => referenceStore.getMiddleSchoolsByDistrict(candidateStore.districtId || 0));

const selectedDistrict = computed(() => {
  if (!candidateStore.districtId) return null;
  return referenceStore.getDistrictById(candidateStore.districtId);
});

const selectedMiddleSchool = computed(() => {
  if (!candidateStore.middleSchoolId) return null;
  return referenceStore.getMiddleSchoolById(candidateStore.middleSchoolId);
});

onMounted(async () => {
  // 加载区县数据
  const { getDistricts } = await import('@/api');
  const data = await getDistricts();
  referenceStore.setDistricts(data.districts);
});

function onDistrictChange(e: any) {
  const index = e.detail.value;
  const district = districts.value[index];
  candidateStore.setDistrictId(district.id);
  candidateStore.setMiddleSchoolId(null);

  // 加载初中学校数据
  loadMiddleSchools(district.id);
}

async function loadMiddleSchools(districtId: number) {
  const { getMiddleSchools } = await import('@/api');
  const data = await getMiddleSchools({ districtId });
  referenceStore.setMiddleSchools(data.middleSchools);
}

function onMiddleSchoolChange(e: any) {
  const index = e.detail.value;
  const school = middleSchools.value[index];
  candidateStore.setMiddleSchoolId(school.id);
}

function toggleQuotaEligibility() {
  candidateStore.setQuotaSchoolEligibility(!candidateStore.hasQuotaSchoolEligibility);
}

function onQualityChange(e: any) {
  candidateStore.setComprehensiveQuality(e.detail.value);
}

function validateScores() {
  candidateStore.validateScores();
}

function nextStep() {
  if (!validateCurrentStep()) return;
  currentStep.value++;
}

function prevStep() {
  currentStep.value--;
}

function validateCurrentStep(): boolean {
  switch (currentStep.value) {
    case 0:
      if (!candidateStore.hasBasicInfo) {
        uni.showToast({ title: '请填写完整信息', icon: 'none' });
        return false;
      }
      break;
    case 1:
      if (!candidateStore.hasScores) {
        uni.showToast({ title: '请填写完整成绩', icon: 'none' });
        return false;
      }
      break;
    case 2:
      if (!candidateStore.hasRanking) {
        uni.showToast({ title: '请填写完整排名', icon: 'none' });
        return false;
      }
      break;
  }
  return true;
}

async function submit() {
  if (!validateCurrentStep()) return;

  submitting.value = true;

  try {
    const data = candidateStore.getSubmitData();

    // 跳转到加载页面
    uni.redirectTo({
      url: `/pages/loading/index?data=${encodeURIComponent(JSON.stringify(data))}`
    });
  } catch (error: any) {
    uni.showToast({
      title: error.message || '提交失败',
      icon: 'none'
    });
  } finally {
    submitting.value = false;
  }
}
</script>

<style lang="scss" scoped>
@import '@/styles/index.scss';

.progress {
  display: flex;
  justify-content: space-between;
  margin-bottom: 48rpx;
}

.progress-step {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;

  &:not(:last-child)::after {
    content: '';
    position: absolute;
    top: 28rpx;
    left: 50%;
    width: 100%;
    height: 2rpx;
    background-color: #d9d9d9;
    z-index: 0;
  }

  &.active,
  &.completed {
    .progress-number {
      background-color: #1890ff;
      color: #fff;
    }

    .progress-label {
      color: #1890ff;
    }
  }

  &.completed::after {
    background-color: #1890ff;
  }
}

.progress-number {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  background-color: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  font-weight: 600;
  color: #8c8c8c;
  margin-bottom: 8rpx;
  position: relative;
  z-index: 1;
}

.progress-label {
  font-size: 24rpx;
  color: #8c8c8c;
}

.form-section {
  background-color: #fff;
  border-radius: 16rpx;
  padding: 32rpx 24rpx;
  margin-bottom: 24rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #1a1a1a;
  margin-bottom: 24rpx;
}

.score-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24rpx;
}

.checkbox-item {
  display: flex;
  align-items: center;
  margin-bottom: 8rpx;
}

.checkbox-label {
  margin-left: 16rpx;
  font-size: 28rpx;
  color: #333;
}

.form-item-hint {
  font-size: 24rpx;
  color: #8c8c8c;
  display: block;
  margin-top: 8rpx;
}

.info-card {
  background-color: #f6ffed;
  border: 1rpx solid #b7eb8f;
  border-radius: 8rpx;
  padding: 16rpx;
  margin-top: 24rpx;
}

.info-card-title {
  font-size: 26rpx;
  font-weight: 600;
  color: #52c41a;
  display: block;
  margin-bottom: 8rpx;
}

.info-card-text {
  font-size: 24rpx;
  color: #595959;
  line-height: 1.6;
}

.volunteer-section {
  margin-bottom: 32rpx;
}

.volunteer-section-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #1a1a1a;
  display: block;
  margin-bottom: 16rpx;
}

.actions {
  display: flex;
  gap: 16rpx;
  margin-top: 24rpx;
}

.actions .btn {
  flex: 1;
}
</style>
