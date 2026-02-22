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
              filterable
              :filter-method="filterMiddleSchool"
              @visible-change="resetMiddleSchoolFilter"
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

          <el-divider content-position="center">各科成绩（选填）</el-divider>

          <el-row :gutter="20">
            <el-col :xs="24" :sm="8">
              <el-form-item label="语文（选填）">
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
              <el-form-item label="数学（选填）">
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
              <el-form-item label="外语（选填）">
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
              <el-form-item label="综合测试（选填）">
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
              <el-form-item label="道德与法治（选填）">
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
              <el-form-item label="历史（选填）">
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
              <el-form-item label="体育（选填）">
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
            v-if="!isScoreValid"
            title="成绩校验提醒"
            type="warning"
            :closable="false"
            show-icon
          >
            <p>{{ scoreValidation.message }}</p>
          </el-alert>

          <el-alert
            v-if="isScoreValid && hasAnySubjectScore && !hasAllSubjectScores"
            title="成绩提示"
            type="info"
            :closable="false"
            show-icon
          >
            <p>
              已填科目合计 {{ calculatedTotal }} 分，总分 {{ form.scores.total }} 分。
              如需更精确分析，可继续填写其他科目成绩。
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
              <span class="subtitle-hint">1个志愿 | 总分800分 | 全区竞争 | 仅显示有名额学校</span>
            </h3>
            <el-select
              v-model="form.volunteers.quotaDistrict"
              placeholder="请选择学校"
              class="full-width"
              clearable
              filterable
              :loading="highSchoolsLoading"
            >
              <el-option
                v-for="school in filteredQuotaDistrictSchools"
                :key="school.id"
                :label="`${school.fullName} (${school.code}) - 名额${school.quotaCount}人`"
                :value="school.id"
              />
            </el-select>
            <div v-if="quotaDistrictSchools.length === 0 && !highSchoolsLoading" class="form-tip">
              暂无名额分配到区的学校数据
            </div>
          </div>

          <!-- 名额分配到校 -->
          <div class="volunteer-section" v-if="form.hasQuotaSchoolEligibility">
            <h3 class="section-subtitle">
              <el-tag type="success">名额分配到校</el-tag>
              <span class="subtitle-hint">2个志愿 | 总分800分 | 校内竞争 | 可拖拽排序 | 仅显示有名额学校</span>
            </h3>
            <div
              v-for="(schoolId, index) in form.volunteers.quotaSchool"
              :key="index"
              class="volunteer-item"
              draggable="true"
              @dragstart="onDragStart($event, 'quotaSchool', index)"
              @dragover.prevent="onDragOver($event, index)"
              @drop="onDrop($event, 'quotaSchool', index)"
              @dragend="onDragEnd"
              :class="{ 'drag-over': dragOverIndex === index && dragType === 'quotaSchool' }"
            >
              <el-icon class="drag-handle"><Rank /></el-icon>
              <span class="volunteer-index">{{ index + 1 }}</span>
              <el-select
                v-model="form.volunteers.quotaSchool[index]"
                placeholder="请选择学校"
                class="volunteer-select"
                filterable
                :loading="highSchoolsLoading"
              >
                <el-option
                  v-for="school in getFilteredQuotaSchoolSchools(index)"
                  :key="school.id"
                  :label="`${school.fullName} (${school.code}) - 名额${school.quotaCount}人`"
                  :value="school.id"
                />
              </el-select>
              <el-button
                v-if="form.volunteers.quotaSchool[index]"
                type="info"
                :icon="CircleClose"
                circle
                @click="clearVolunteer('quotaSchool', index)"
              />
            </div>
            <div v-if="quotaSchoolSchools.length === 0 && !highSchoolsLoading && form.hasQuotaSchoolEligibility" class="form-tip quota-warning">
              <el-icon><Warning /></el-icon>
              <span>您所在初中暂无名额分配到校数据，可能数据尚未录入或该校今年无名额分配到校计划。您仍可填报统一招生志愿。</span>
            </div>
          </div>

          <!-- 统一招生1-15志愿 -->
          <div class="volunteer-section">
            <h3 class="section-subtitle">
              <el-tag type="warning">统一招生</el-tag>
              <span class="subtitle-hint">1-15志愿 | 总分750分 | 平行志愿 | 仅显示本区学校 | 可拖拽排序</span>
            </h3>
            <div
              v-for="(schoolId, index) in form.volunteers.unified"
              :key="index"
              class="volunteer-item"
              draggable="true"
              @dragstart="onDragStart($event, 'unified', index)"
              @dragover.prevent="onDragOver($event, index)"
              @drop="onDrop($event, 'unified', index)"
              @dragend="onDragEnd"
              :class="{ 'drag-over': dragOverIndex === index && dragType === 'unified' }"
            >
              <el-icon class="drag-handle"><Rank /></el-icon>
              <span class="volunteer-index">{{ index + 1 }}</span>
              <el-select
                v-model="form.volunteers.unified[index]"
                placeholder="请选择学校"
                class="volunteer-select"
                filterable
                :loading="highSchoolsLoading"
              >
                <el-option
                  v-for="school in getFilteredUnifiedSchools(index)"
                  :key="school.id"
                  :label="`${school.fullName} (${school.code})`"
                  :value="school.id"
                />
              </el-select>
              <el-button
                v-if="form.volunteers.unified[index]"
                type="info"
                :icon="CircleClose"
                circle
                @click="clearVolunteer('unified', index)"
              />
            </div>
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
import { User, Document, List, CircleClose, Rank, Warning } from '@element-plus/icons-vue';
import { ElMessage } from 'element-plus';
import { pinyin } from 'pinyin-pro';
import { useCandidateStore } from '@/stores/candidate';
import { getDistricts, getMiddleSchools, getSchoolsWithQuotaDistrict, getSchoolsWithQuotaSchool, getSchoolsForUnified, type SchoolWithQuota, type SchoolForUnified } from '@/api/reference';
import { submitAnalysis, formatFormToRequest } from '@/api/candidate';
import type { District, MiddleSchool } from '@/api/reference';

const router = useRouter();
const store = useCandidateStore();

// 状态
const currentStep = ref(0);
const submitting = ref(false);
const districts = ref<District[]>([]);
const middleSchools = ref<MiddleSchool[]>([]);
const filteredMiddleSchools = ref<MiddleSchool[]>([]);
const unifiedSchools = ref<SchoolForUnified[]>([]); // 统一招生学校列表
const middleSchoolsLoading = ref(false);

// 名额分配学校列表（按批次分离）
const quotaDistrictSchools = ref<SchoolWithQuota[]>([]); // 名额分配到区
const quotaSchoolSchools = ref<SchoolWithQuota[]>([]);   // 名额分配到校
const highSchoolsLoading = ref(false);

// 拖拽排序状态
const dragIndex = ref<number | null>(null);
const dragOverIndex = ref<number | null>(null);
const dragType = ref<'quotaSchool' | 'unified' | null>(null);

// 表单数据
const form = computed(() => store.form);
const calculatedTotal = computed(() => store.calculatedTotal);
const hasAnySubjectScore = computed(() => store.hasAnySubjectScore);
const hasAllSubjectScores = computed(() => store.hasAllSubjectScores);
const scoreValidation = computed(() => store.scoreValidation);
const isScoreValid = computed(() => store.isScoreValid);

// 名额分配到校批次已选择的学校ID集合（仅用于本批次内过滤）
const selectedQuotaSchoolIds = computed(() => {
  const ids = new Set<number>();
  for (const id of form.value.volunteers.quotaSchool) {
    if (id) ids.add(id);
  }
  return ids;
});

// 统一招生批次已选择的学校ID集合（仅用于本批次内过滤）
const selectedUnifiedIds = computed(() => {
  const ids = new Set<number>();
  for (const id of form.value.volunteers.unified) {
    if (id) ids.add(id);
  }
  return ids;
});

// 过滤后的名额分配到区学校列表（本批次只有1个志愿，无需过滤）
const filteredQuotaDistrictSchools = computed(() => {
  return quotaDistrictSchools.value;
});

// 过滤后的名额分配到校学校列表（排除本批次内已选择的，但保留当前志愿的选择）
function getFilteredQuotaSchoolSchools(currentIndex: number) {
  const currentValue = form.value.volunteers.quotaSchool[currentIndex];
  return quotaSchoolSchools.value.filter(school => {
    // 保留当前选择
    if (school.id === currentValue) return true;
    // 排除本批次内已在其他志愿中选择的
    return !selectedQuotaSchoolIds.value.has(school.id);
  });
}

// 过滤后的统一招生学校列表（排除本批次内已选择的，但保留当前志愿的选择）
function getFilteredUnifiedSchools(currentIndex: number) {
  const currentValue = form.value.volunteers.unified[currentIndex];
  return unifiedSchools.value.filter(school => {
    // 保留当前选择
    if (school.id === currentValue) return true;
    // 排除本批次内已在其他志愿中选择的
    return !selectedUnifiedIds.value.has(school.id);
  });
}

// 步骤验证
const canNext = computed(() => {
  if (currentStep.value === 0) {
    return form.value.districtId !== null && form.value.middleSchoolId !== null;
  }
  if (currentStep.value === 1) {
    // 成绩步骤：总分必填，排名必填，成绩校验可选（没填科目也能过）
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
  // 检查是否有有效志愿（非0值）
  const hasQuotaDistrict = form.value.volunteers.quotaDistrict !== null;
  const hasQuotaSchool = form.value.volunteers.quotaSchool.some(id => id !== 0);
  const hasUnified = form.value.volunteers.unified.some(id => id !== 0);
  return hasQuotaDistrict || hasQuotaSchool || hasUnified;
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
  filteredMiddleSchools.value = [];

  if (!form.value.districtId) return;

  middleSchoolsLoading.value = true;
  try {
    const data = await getMiddleSchools({ districtId: form.value.districtId });
    middleSchools.value = data.middleSchools;
    filteredMiddleSchools.value = data.middleSchools;
  } catch (error) {
    ElMessage.error('加载初中学校失败');
  } finally {
    middleSchoolsLoading.value = false;
  }
}

// 加载名额分配学校（当进入志愿填报步骤时）
async function loadQuotaSchools() {
  if (!form.value.districtId) return;

  highSchoolsLoading.value = true;
  try {
    // 并行加载三个批次的学校
    const [quotaDistrictRes, quotaSchoolRes, unifiedRes] = await Promise.all([
      getSchoolsWithQuotaDistrict({ districtId: form.value.districtId, year: 2025 }),
      form.value.middleSchoolId
        ? getSchoolsWithQuotaSchool({ middleSchoolId: form.value.middleSchoolId, year: 2025 })
        : Promise.resolve({ schools: [] }),
      // 统一招生（1-15志愿）：本区学校 + 面向全市招生的学校
      getSchoolsForUnified({ districtId: form.value.districtId, year: 2025 })
    ]);

    quotaDistrictSchools.value = quotaDistrictRes.schools;
    quotaSchoolSchools.value = quotaSchoolRes.schools;
    unifiedSchools.value = unifiedRes.schools;
  } catch (error) {
    ElMessage.error('加载高中学校失败');
  } finally {
    highSchoolsLoading.value = false;
  }
}

// 初中学校筛选：支持中文、拼音、代码
function filterMiddleSchool(query: string) {
  if (!query) {
    filteredMiddleSchools.value = middleSchools.value;
    return;
  }

  const queryLower = query.toLowerCase();
  filteredMiddleSchools.value = middleSchools.value.filter(school => {
    // 中文匹配
    if (school.name.includes(query)) return true;

    // 代码匹配
    if (school.code.toLowerCase().includes(queryLower)) return true;

    // 拼音匹配（全拼和首字母）
    const fullPinyin = pinyin(school.name, { toneType: 'none' }).replace(/\s/g, '').toLowerCase();
    const initialPinyin = pinyin(school.name, { pattern: 'first', toneType: 'none' }).replace(/\s/g, '').toLowerCase();

    return fullPinyin.includes(queryLower) || initialPinyin.includes(queryLower);
  });
}

function resetMiddleSchoolFilter(visible: boolean) {
  if (visible) {
    filteredMiddleSchools.value = middleSchools.value;
  }
}

function nextStep() {
  if (currentStep.value < 2) {
    currentStep.value++;
    // 进入志愿填报步骤时加载名额分配学校
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

function addVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified') {
  store.addVolunteer(batch, 0);
}

function removeVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified', index?: number) {
  store.removeVolunteer(batch, index);
}

// 清空指定位置的志愿（不移除输入框）
function clearVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified', index?: number) {
  if (batch === 'quotaDistrict') {
    form.value.volunteers.quotaDistrict = null;
  } else if (batch === 'quotaSchool' && index !== undefined) {
    form.value.volunteers.quotaSchool[index] = 0;
  } else if (batch === 'unified' && index !== undefined) {
    form.value.volunteers.unified[index] = 0;
  }
}

// 拖拽排序方法
function onDragStart(event: DragEvent, type: 'quotaSchool' | 'unified', index: number) {
  dragIndex.value = index;
  dragType.value = type;
  if (event.dataTransfer) {
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', String(index));
  }
}

function onDragOver(event: DragEvent, index: number) {
  event.preventDefault();
  if (dragIndex.value !== null && dragIndex.value !== index) {
    dragOverIndex.value = index;
  }
}

function onDrop(event: DragEvent, type: 'quotaSchool' | 'unified', index: number) {
  event.preventDefault();
  if (dragIndex.value === null || dragIndex.value === index || dragType.value !== type) {
    return;
  }

  const list = form.value.volunteers[type];
  const draggedItem = list[dragIndex.value];
  if (draggedItem !== undefined) {
    // 创建新数组并交换位置
    const newList = [...list];
    newList.splice(dragIndex.value, 1);
    newList.splice(index, 0, draggedItem);

    // 更新 store
    store.updateVolunteers({ [type]: newList });
  }

  // 重置状态
  dragIndex.value = null;
  dragOverIndex.value = null;
  dragType.value = null;
}

function onDragEnd() {
  dragIndex.value = null;
  dragOverIndex.value = null;
  dragType.value = null;
}

async function submit() {
  if (submitting.value) return;

  submitting.value = true;
  try {
    const request = await formatFormToRequest(form.value);
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
  cursor: grab;
  transition: all 0.2s ease;
  padding: 8px;
  border-radius: 8px;
  background: transparent;

  &:active {
    cursor: grabbing;
  }

  &.drag-over {
    background: #ecf5ff;
    border: 2px dashed #409EFF;
  }

  &:hover .drag-handle {
    color: #409EFF;
  }
}

.drag-handle {
  color: #c0c4cc;
  cursor: grab;
  font-size: 18px;
  transition: color 0.2s;

  &:active {
    cursor: grabbing;
  }
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

.quota-warning {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 12px 16px;
  margin-top: 12px;
  background: #fdf6ec;
  border: 1px solid #f5dab1;
  border-radius: 4px;
  color: #e6a23c;
  font-size: 14px;
  line-height: 1.5;

  .el-icon {
    flex-shrink: 0;
    margin-top: 2px;
    font-size: 16px;
  }

  span {
    flex: 1;
  }
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
