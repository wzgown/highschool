<template>
  <div class="form-view">
    <el-steps :active="currentStep" finish-status="success" class="steps" simple>
      <el-step title="基本信息" />
      <el-step title="成绩信息" />
      <el-step title="志愿填报" />
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

          <el-form-item label="初中学校" required>
            <el-select
              v-model="form.middleSchoolId"
              placeholder="请先选择区县"
              class="full-width"
              :disabled="!form.districtId || middleSchoolsLoading"
              :loading="middleSchoolsLoading"
            >
              <el-option
                v-for="school in middleSchools"
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

    <!-- 步骤 2: 成绩信息 -->
    <div v-show="currentStep === 1" class="step-content">
      <el-card class="form-card">
        <template #header>
          <div class="card-header">
            <el-icon><Document /></el-icon>
            <span>中考成绩</span>
          </div>
        </template>

        <el-form :model="form" label-position="top" class="form-body">
          <el-row :gutter="20">
            <el-col :xs="24" :sm="12">
              <el-form-item label="中考总分" required>
                <el-input-number
                  v-model="form.scores.total"
                  :min="0"
                  :max="750"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="12">
              <el-form-item label="综合素质评价" required>
                <el-input-number
                  v-model="form.comprehensiveQuality"
                  :min="0"
                  :max="50"
                  :disabled="true"
                  class="full-width"
                  controls-position="right"
                />
                <div class="form-tip">默认50分（合格）</div>
              </el-form-item>
            </el-col>
          </el-row>

          <el-divider>各科成绩</el-divider>

          <el-row :gutter="20">
            <el-col :xs="24" :sm="8">
              <el-form-item label="语文">
                <el-input-number
                  v-model="form.scores.chinese"
                  :min="0"
                  :max="150"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="8">
              <el-form-item label="数学">
                <el-input-number
                  v-model="form.scores.math"
                  :min="0"
                  :max="150"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="8">
              <el-form-item label="外语">
                <el-input-number
                  v-model="form.scores.foreign"
                  :min="0"
                  :max="150"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
          </el-row>

          <el-row :gutter="20">
            <el-col :xs="24" :sm="8">
              <el-form-item label="综合测试">
                <el-input-number
                  v-model="form.scores.integrated"
                  :min="0"
                  :max="150"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="8">
              <el-form-item label="道德与法治">
                <el-input-number
                  v-model="form.scores.ethics"
                  :min="0"
                  :max="60"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="8">
              <el-form-item label="历史">
                <el-input-number
                  v-model="form.scores.history"
                  :min="0"
                  :max="60"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
          </el-row>

          <el-row :gutter="20">
            <el-col :xs="24" :sm="8">
              <el-form-item label="体育">
                <el-input-number
                  v-model="form.scores.pe"
                  :min="0"
                  :max="30"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
          </el-row>

          <el-alert
            v-if="!isScoreValid && calculatedTotal > 0"
            title="成绩校验提醒"
            type="warning"
            :closable="false"
            show-icon
          >
            <p>
              各科成绩合计为 {{ calculatedTotal }} 分，与填写的总分 {{ form.scores.total }} 分不符。
              请检查各科成绩是否填写正确。
            </p>
          </el-alert>

          <el-divider>校内排名</el-divider>

          <el-row :gutter="20">
            <el-col :xs="24" :sm="12">
              <el-form-item label="校内排名" required>
                <el-input-number
                  v-model="form.ranking.rank"
                  :min="1"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="12">
              <el-form-item label="校内总人数" required>
                <el-input-number
                  v-model="form.ranking.totalStudents"
                  :min="1"
                  class="full-width"
                  controls-position="right"
                />
              </el-form-item>
            </el-col>
          </el-row>

          <el-alert
            v-if="form.ranking.rank > form.ranking.totalStudents && form.ranking.totalStudents > 0"
            title="排名校验提醒"
            type="error"
            :closable="false"
            show-icon
          >
            校内排名不能大于总人数
          </el-alert>
        </el-form>
      </el-card>
    </div>

    <!-- 步骤 3: 志愿填报 -->
    <div v-show="currentStep === 2" class="step-content">
      <el-card class="form-card">
        <template #header>
          <div class="card-header">
            <el-icon><List /></el-icon>
            <span>志愿填报</span>
          </div>
        </template>

        <div class="form-body">
          <!-- 名额分配到区 -->
          <div class="volunteer-section">
            <h3 class="section-subtitle">
              <el-tag type="primary">名额分配到区</el-tag>
              <span class="subtitle-hint">1个志愿 | 总分800分 | 全区竞争</span>
            </h3>
            <el-select
              v-model="form.volunteers.quotaDistrict"
              placeholder="请选择学校"
              class="full-width"
              clearable
              filterable
            >
              <el-option
                v-for="school in highSchools"
                :key="school.id"
                :label="`${school.fullName} (${school.code})`"
                :value="school.id"
              />
            </el-select>
          </div>

          <!-- 名额分配到校 -->
          <div class="volunteer-section" v-if="form.hasQuotaSchoolEligibility">
            <h3 class="section-subtitle">
              <el-tag type="success">名额分配到校</el-tag>
              <span class="subtitle-hint">2个志愿 | 总分800分 | 校内竞争</span>
            </h3>
            <div
              v-for="(schoolId, index) in form.volunteers.quotaSchool"
              :key="index"
              class="volunteer-item"
            >
              <span class="volunteer-index">{{ index + 1 }}</span>
              <el-select
                v-model="form.volunteers.quotaSchool[index]"
                placeholder="请选择学校"
                class="volunteer-select"
                filterable
              >
                <el-option
                  v-for="school in highSchools"
                  :key="school.id"
                  :label="`${school.fullName} (${school.code})`"
                  :value="school.id"
                />
              </el-select>
              <el-button
                type="danger"
                :icon="Delete"
                circle
                @click="removeVolunteer('quotaSchool', index)"
              />
            </div>
            <el-button
              v-if="form.volunteers.quotaSchool.length < 2"
              type="primary"
              plain
              :icon="Plus"
              @click="addVolunteer('quotaSchool')"
            >
              添加志愿
            </el-button>
          </div>

          <!-- 统一招生1-15志愿 -->
          <div class="volunteer-section">
            <h3 class="section-subtitle">
              <el-tag type="warning">统一招生</el-tag>
              <span class="subtitle-hint">1-15志愿 | 总分750分 | 平行志愿</span>
            </h3>
            <div
              v-for="(schoolId, index) in form.volunteers.unified"
              :key="index"
              class="volunteer-item"
            >
              <span class="volunteer-index">{{ index + 1 }}</span>
              <el-select
                v-model="form.volunteers.unified[index]"
                placeholder="请选择学校"
                class="volunteer-select"
                filterable
              >
                <el-option
                  v-for="school in highSchools"
                  :key="school.id"
                  :label="`${school.fullName} (${school.code})`"
                  :value="school.id"
                />
              </el-select>
              <el-button
                type="danger"
                :icon="Delete"
                circle
                @click="removeVolunteer('unified', index)"
              />
            </div>
            <el-button
              v-if="form.volunteers.unified.length < 15"
              type="primary"
              plain
              :icon="Plus"
              @click="addVolunteer('unified')"
            >
              添加志愿 ({{ form.volunteers.unified.length }}/15)
            </el-button>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 操作按钮 -->
    <div class="form-actions">
      <el-button v-if="currentStep > 0" @click="prevStep">
        上一步
      </el-button>
      <el-button
        v-if="currentStep < 2"
        type="primary"
        @click="nextStep"
        :disabled="!canNext"
      >
        下一步
      </el-button>
      <el-button
        v-if="currentStep === 2"
        type="primary"
        :loading="submitting"
        @click="submit"
        :disabled="!canSubmit"
      >
        开始分析
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import { User, Document, List, Plus, Delete } from '@element-plus/icons-vue';
import { ElMessage } from 'element-plus';
import { useCandidateStore } from '@/stores/candidate';
import { getDistricts, getMiddleSchools, getSchools } from '@/api/reference';
import { submitAnalysis, formatFormToRequest } from '@/api/candidate';
import type { District, MiddleSchool, School } from '@/api/reference';

const router = useRouter();
const store = useCandidateStore();

// 状态
const currentStep = ref(0);
const submitting = ref(false);
const districts = ref<District[]>([]);
const middleSchools = ref<MiddleSchool[]>([]);
const highSchools = ref<School[]>([]);
const middleSchoolsLoading = ref(false);

// 表单数据
const form = computed(() => store.form);
const calculatedTotal = computed(() => store.calculatedTotal);
const isScoreValid = computed(() => store.isScoreValid);

// 步骤验证
const canNext = computed(() => {
  if (currentStep.value === 0) {
    return form.value.districtId !== null && form.value.middleSchoolId !== null;
  }
  if (currentStep.value === 1) {
    return (
      form.value.scores.total > 0 &&
      isScoreValid.value &&
      form.value.ranking.rank > 0 &&
      form.value.ranking.totalStudents > 0 &&
      form.value.ranking.rank <= form.value.ranking.totalStudents
    );
  }
  return true;
});

const canSubmit = computed(() => {
  const hasVolunteers =
    form.value.volunteers.quotaDistrict !== null ||
    form.value.volunteers.quotaSchool.length > 0 ||
    form.value.volunteers.unified.length > 0;
  return hasVolunteers;
});

// 方法
async function loadDistricts() {
  try {
    const data = await getDistricts();
    districts.value = data.districts;
  } catch (error) {
    ElMessage.error('加载区县失败');
  }
}

async function onDistrictChange() {
  form.value.middleSchoolId = null;
  middleSchools.value = [];
  
  if (!form.value.districtId) return;
  
  middleSchoolsLoading.value = true;
  try {
    const data = await getMiddleSchools({ districtId: form.value.districtId });
    middleSchools.value = data.middleSchools;
  } catch (error) {
    ElMessage.error('加载初中学校失败');
  } finally {
    middleSchoolsLoading.value = false;
  }
}

async function loadHighSchools() {
  try {
    const data = await getSchools({ pageSize: 1000 });
    highSchools.value = data.schools;
  } catch (error) {
    ElMessage.error('加载高中学校失败');
  }
}

function nextStep() {
  if (currentStep.value < 2) {
    currentStep.value++;
  }
}

function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--;
  }
}

function addVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified') {
  store.addVolunteer(batch, 0);
}

function removeVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified', index?: number) {
  store.removeVolunteer(batch, index);
}

async function submit() {
  if (submitting.value) return;
  
  submitting.value = true;
  try {
    const request = formatFormToRequest(form.value);
    const { analysisId } = await submitAnalysis(request);
    ElMessage.success('分析请求已提交');
    router.push(`/result/${analysisId}`);
  } catch (error: any) {
    ElMessage.error(error.message || '提交失败');
  } finally {
    submitting.value = false;
  }
}

// 监听区县变化
watch(() => form.value.districtId, () => {
  if (form.value.districtId) {
    onDistrictChange();
  }
});

// 初始化
onMounted(() => {
  loadDistricts();
  loadHighSchools();
});
</script>

<style lang="scss" scoped>
.form-view {
  max-width: 800px;
  margin: 0 auto;
}

.steps {
  margin-bottom: 30px;
}

.step-content {
  margin-bottom: 20px;
}

.form-card {
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

.section-subtitle {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
  font-size: 15px;
}

.subtitle-hint {
  font-size: 13px;
  color: #909399;
  font-weight: normal;
}

.volunteer-section {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #e4e7ed;

  &:last-child {
    border-bottom: none;
    margin-bottom: 0;
  }
}

.volunteer-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.volunteer-index {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #409EFF;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  flex-shrink: 0;
}

.volunteer-select {
  flex: 1;
}

.form-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 30px;
  padding: 20px;
}

@media (max-width: 768px) {
  .form-actions {
    flex-direction: column;
    
    .el-button {
      width: 100%;
    }
  }
}
</style>
