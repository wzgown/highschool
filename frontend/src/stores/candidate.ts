import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export interface CandidateForm {
  // 基本信息
  districtId: number | null;
  middleSchoolId: number | null;
  hasQuotaSchoolEligibility: boolean;

  // 成绩信息
  scores: {
    total: number;
    chinese: number;
    math: number;
    foreign: number;
    integrated: number;
    ethics: number;
    history: number;
    pe: number;
  };

  // 排名信息
  ranking: {
    rank: number;
    totalStudents: number;
  };

  // 综合素质评价
  comprehensiveQuality: number;

  // 志愿信息
  volunteers: {
    quotaDistrict: number | null;
    quotaSchool: number[];
    unified: number[];
  };
}

// 各科目满分上限
export const SCORE_LIMITS = {
  chinese: 150,
  math: 150,
  foreign: 150,
  integrated: 150,
  ethics: 60,
  history: 60,
  pe: 30,
  total: 750,
} as const;

const defaultScores = {
  total: 0,
  chinese: 0,
  math: 0,
  foreign: 0,
  integrated: 0,
  ethics: 0,
  history: 0,
  pe: 0,
};

const defaultState = (): CandidateForm => ({
  districtId: null,
  middleSchoolId: null,
  hasQuotaSchoolEligibility: false,
  scores: { ...defaultScores },
  ranking: { rank: 0, totalStudents: 0 },
  comprehensiveQuality: 50,
  volunteers: {
    quotaDistrict: null,
    quotaSchool: [],
    unified: [],
  },
});

export const useCandidateStore = defineStore('candidate', () => {
  // State
  const form = ref<CandidateForm>(defaultState());

  // Getters
  // 计算已填科目的总分（非0科目才计入）
  const calculatedTotal = computed(() => {
    const { chinese, math, foreign, integrated, ethics, history, pe } = form.value.scores;
    return chinese + math + foreign + integrated + ethics + history + pe;
  });

  // 判断是否填了任何科目（有非0科目）
  const hasAnySubjectScore = computed(() => {
    const { chinese, math, foreign, integrated, ethics, history, pe } = form.value.scores;
    return chinese > 0 || math > 0 || foreign > 0 || integrated > 0 ||
           ethics > 0 || history > 0 || pe > 0;
  });

  // 判断是否填了所有科目
  const hasAllSubjectScores = computed(() => {
    const { chinese, math, foreign, integrated, ethics, history, pe } = form.value.scores;
    return chinese > 0 && math > 0 && foreign > 0 && integrated > 0 &&
           ethics > 0 && history > 0 && pe > 0;
  });

  // 成绩校验状态：返回具体的状态信息
  const scoreValidation = computed(() => {
    const scores = form.value.scores;
    const total = scores.total;

    // 检查单科成绩是否超过上限
    const exceedsMax: string[] = [];
    if (scores.chinese > SCORE_LIMITS.chinese) exceedsMax.push('语文');
    if (scores.math > SCORE_LIMITS.math) exceedsMax.push('数学');
    if (scores.foreign > SCORE_LIMITS.foreign) exceedsMax.push('外语');
    if (scores.integrated > SCORE_LIMITS.integrated) exceedsMax.push('综合测试');
    if (scores.ethics > SCORE_LIMITS.ethics) exceedsMax.push('道德与法治');
    if (scores.history > SCORE_LIMITS.history) exceedsMax.push('历史');
    if (scores.pe > SCORE_LIMITS.pe) exceedsMax.push('体育');
    if (exceedsMax.length > 0) {
      return { valid: false, type: 'exceeds_max', message: `${exceedsMax.join('、')} 超过满分上限` };
    }

    // 没填任何科目，允许通过
    if (!hasAnySubjectScore.value) {
      return { valid: true, type: 'no_subjects', message: '' };
    }

    // 填了所有科目，总和必须等于总分
    if (hasAllSubjectScores.value) {
      if (calculatedTotal.value !== total) {
        return {
          valid: false,
          type: 'all_subjects_mismatch',
          message: `各科成绩合计 ${calculatedTotal.value} 分，与总分 ${total} 分不一致`
        };
      }
      return { valid: true, type: 'all_match', message: '' };
    }

    // 填了部分科目，总和不能大于总分
    if (calculatedTotal.value > total) {
      return {
        valid: false,
        type: 'partial_exceeds',
        message: `已填科目合计 ${calculatedTotal.value} 分，超过总分 ${total} 分`
      };
    }

    return { valid: true, type: 'partial_ok', message: '' };
  });

  // 成绩是否有效
  const isScoreValid = computed(() => scoreValidation.value.valid);
  
  const canSubmit = computed(() => {
    const f = form.value;
    return (
      f.districtId !== null &&
      f.middleSchoolId !== null &&
      f.scores.total > 0 &&
      f.ranking.rank > 0 &&
      f.ranking.totalStudents > 0 &&
      isScoreValid.value &&
      (f.volunteers.quotaDistrict !== null || f.volunteers.quotaSchool.length > 0 || f.volunteers.unified.length > 0)
    );
  });
  
  // Actions
  function reset() {
    form.value = defaultState();
  }
  
  function updateScores(scores: Partial<CandidateForm['scores']>) {
    form.value.scores = { ...form.value.scores, ...scores };
  }
  
  function updateRanking(ranking: Partial<CandidateForm['ranking']>) {
    form.value.ranking = { ...form.value.ranking, ...ranking };
  }
  
  function updateVolunteers(volunteers: Partial<CandidateForm['volunteers']>) {
    form.value.volunteers = { ...form.value.volunteers, ...volunteers };
  }
  
  function addVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified', schoolId: number) {
    const v = form.value.volunteers;
    switch (batch) {
      case 'quotaDistrict':
        v.quotaDistrict = schoolId;
        break;
      case 'quotaSchool':
        if (v.quotaSchool.length < 2) {
          v.quotaSchool.push(schoolId);
        }
        break;
      case 'unified':
        if (v.unified.length < 15) {
          v.unified.push(schoolId);
        }
        break;
    }
  }
  
  function removeVolunteer(batch: 'quotaDistrict' | 'quotaSchool' | 'unified', index?: number) {
    const v = form.value.volunteers;
    switch (batch) {
      case 'quotaDistrict':
        v.quotaDistrict = null;
        break;
      case 'quotaSchool':
        if (index !== undefined && index >= 0 && index < v.quotaSchool.length) {
          v.quotaSchool.splice(index, 1);
        }
        break;
      case 'unified':
        if (index !== undefined && index >= 0 && index < v.unified.length) {
          v.unified.splice(index, 1);
        }
        break;
    }
  }
  
  return {
    form,
    calculatedTotal,
    hasAnySubjectScore,
    hasAllSubjectScores,
    scoreValidation,
    isScoreValid,
    canSubmit,
    reset,
    updateScores,
    updateRanking,
    updateVolunteers,
    addVolunteer,
    removeVolunteer,
  };
});
