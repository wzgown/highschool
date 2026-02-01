/**
 * 考生数据存储
 */

import { defineStore } from 'pinia';
import type { Candidate, CandidateScores, CandidateVolunteers } from '@shared/types/candidate';

interface CandidateState {
  // 考生信息
  districtId: number | null;
  middleSchoolId: number | null;
  hasQuotaSchoolEligibility: boolean;

  // 成绩
  scores: Partial<CandidateScores>;

  // 排名
  rank: number | null;
  totalStudents: number | null;

  // 综合素质评价
  comprehensiveQuality: number;

  // 志愿
  volunteers: CandidateVolunteers;

  // 表单验证错误
  errors: Record<string, string[]>;
}

export const useCandidateStore = defineStore('candidate', {
  state: (): CandidateState => ({
    districtId: null,
    middleSchoolId: null,
    hasQuotaSchoolEligibility: false,
    scores: {
      total: 750,
      chinese: 120,
      math: 120,
      foreign: 120,
      integrated: 120,
      ethics: 48,
      history: 48,
      pe: 24,
    },
    rank: null,
    totalStudents: null,
    comprehensiveQuality: 50,
    volunteers: {
      quotaDistrict: null,
      quotaSchool: [null, null],
      unified: Array(15).fill(null),
    },
    errors: {},
  }),

  getters: {
    // 是否完成基本信息填写
    hasBasicInfo: (state) => {
      return !!state.districtId && !!state.middleSchoolId;
    },

    // 是否完成成绩填写
    hasScores: (state) => {
      const s = state.scores;
      return (
        s.total !== undefined &&
        s.chinese !== undefined &&
        s.math !== undefined &&
        s.foreign !== undefined &&
        s.integrated !== undefined &&
        s.ethics !== undefined &&
        s.history !== undefined &&
        s.pe !== undefined
      );
    },

    // 是否完成排名填写
    hasRanking: (state) => {
      return state.rank !== null && state.totalStudents !== null;
    },

    // 是否完成志愿填写
    hasVolunteers: (state) => {
      return (
        state.volunteers.quotaDistrict !== null ||
        state.volunteers.quotaSchool.some((v) => v !== null) ||
        state.volunteers.unified.some((v) => v !== null)
      );
    },

    // 是否可以提交分析
    canSubmit: (state) => {
      return (
        state.hasBasicInfo &&
        state.hasScores &&
        state.hasRanking &&
        Object.keys(state.errors).length === 0
      );
    },

    // 已填报志愿数量
    volunteerCount: (state) => {
      let count = 0;
      if (state.volunteers.quotaDistrict) count++;
      count += state.volunteers.quotaSchool.filter((v) => v !== null).length;
      count += state.volunteers.unified.filter((v) => v !== null).length;
      return count;
    },
  },

  actions: {
    // 更新区县
    setDistrictId(districtId: number | null) {
      this.districtId = districtId;
      this.validateField('districtId');
    },

    // 更新初中学校
    setMiddleSchoolId(middleSchoolId: number | null) {
      this.middleSchoolId = middleSchoolId;
      this.validateField('middleSchoolId');
    },

    // 更新名额分配到校资格
    setQuotaSchoolEligibility(eligible: boolean) {
      this.hasQuotaSchoolEligibility = eligible;
      if (!eligible) {
        this.volunteers.quotaSchool = [null, null];
      }
    },

    // 更新成绩
    setScores(scores: Partial<CandidateScores>) {
      this.scores = { ...this.scores, ...scores };
      this.validateScores();
    },

    // 更新单科成绩
    setSubjectScore(subject: keyof CandidateScores, value: number) {
      this.scores[subject] = value;
      this.validateScores();
    },

    // 更新排名
    setRanking(rank: number | null, totalStudents: number | null) {
      this.rank = rank;
      this.totalStudents = totalStudents;
      this.validateField('rank');
      this.validateField('totalStudents');
    },

    // 更新综合素质评价
    setComprehensiveQuality(value: number) {
      this.comprehensiveQuality = Math.max(0, Math.min(50, value));
    },

    // 更新名额分配到区志愿
    setQuotaDistrict(schoolId: number | null) {
      this.volunteers.quotaDistrict = schoolId;
    },

    // 更新名额分配到校志愿
    setQuotaSchool(index: number, schoolId: number | null) {
      if (index >= 0 && index < 2) {
        this.volunteers.quotaSchool[index] = schoolId;
      }
    },

    // 更新统一招生志愿
    setUnifiedVolunteer(index: number, schoolId: number | null) {
      if (index >= 0 && index < 15) {
        this.volunteers.unified[index] = schoolId;
      }
    },

    // 清空志愿
    clearVolunteers() {
      this.volunteers = {
        quotaDistrict: null,
        quotaSchool: [null, null],
        unified: Array(15).fill(null),
      };
    },

    // 清空所有数据
    clearAll() {
      this.$reset();
    },

    // 验证单个字段
    validateField(field: string) {
      const errors: string[] = [];

      switch (field) {
        case 'districtId':
          if (!this.districtId) {
            errors.push('请选择区县');
          }
          break;
        case 'middleSchoolId':
          if (!this.middleSchoolId) {
            errors.push('请选择初中学校');
          }
          break;
        case 'rank':
          if (!this.rank || this.rank <= 0) {
            errors.push('请输入有效的排名');
          }
          break;
        case 'totalStudents':
          if (!this.totalStudents || this.totalStudents <= 0) {
            errors.push('请输入有效的总人数');
          }
          if (this.rank && this.totalStudents && this.rank > this.totalStudents) {
            errors.push('排名不能超过总人数');
          }
          break;
      }

      if (errors.length > 0) {
        this.errors[field] = errors;
      } else {
        delete this.errors[field];
      }
    },

    // 验证成绩
    validateScores() {
      const errors: string[] = [];
      const s = this.scores;

      if (s.total === undefined || s.total < 0 || s.total > 750) {
        errors.push('总分必须在0-750之间');
      }
      if (s.chinese === undefined || s.chinese < 0 || s.chinese > 150) {
        errors.push('语文成绩必须在0-150之间');
      }
      if (s.math === undefined || s.math < 0 || s.math > 150) {
        errors.push('数学成绩必须在0-150之间');
      }
      if (s.foreign === undefined || s.foreign < 0 || s.foreign > 150) {
        errors.push('外语成绩必须在0-150之间');
      }
      if (s.integrated === undefined || s.integrated < 0 || s.integrated > 150) {
        errors.push('综合测试成绩必须在0-150之间');
      }
      if (s.ethics === undefined || s.ethics < 0 || s.ethics > 60) {
        errors.push('道德与法治成绩必须在0-60之间');
      }
      if (s.history === undefined || s.history < 0 || s.history > 60) {
        errors.push('历史成绩必须在0-60之间');
      }
      if (s.pe === undefined || s.pe < 0 || s.pe > 30) {
        errors.push('体育成绩必须在0-30之间');
      }

      if (errors.length > 0) {
        this.errors.scores = errors;
      } else {
        delete this.errors.scores;
      }
    },

    // 验证所有字段
    validateAll() {
      this.validateField('districtId');
      this.validateField('middleSchoolId');
      this.validateScores();
      this.validateField('rank');
      this.validateField('totalStudents');
      return Object.keys(this.errors).length === 0;
    },

    // 获取用于提交的数据
    getSubmitData() {
      if (!this.hasBasicInfo || !this.hasScores || !this.hasRanking) {
        throw new Error('请填写完整信息');
      }

      return {
        candidate: {
          districtId: this.districtId!,
          middleSchoolId: this.middleSchoolId!,
          hasQuotaSchoolEligibility: this.hasQuotaSchoolEligibility,
        },
        scores: this.scores as CandidateScores,
        ranking: {
          rank: this.rank!,
          totalStudents: this.totalStudents!,
        },
        comprehensiveQuality: this.comprehensiveQuality,
        volunteers: this.volunteers,
      };
    },
  },
});
