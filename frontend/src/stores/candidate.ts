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
  
  // 成绩校验：如果没填任何科目，返回true；如果填了，则校验总和是否等于总分
  const isScoreValid = computed(() => {
    if (!hasAnySubjectScore.value) {
      return true; // 没填任何科目，允许通过
    }
    return form.value.scores.total === calculatedTotal.value;
  });
  
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
