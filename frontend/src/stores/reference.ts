/**
 * 参考数据存储
 */

import { defineStore } from 'pinia';
import type {
  District,
  School,
  MiddleSchool,
  DistrictExamCountResponse,
} from '@shared/types/api';

interface ReferenceState {
  // 区县列表
  districts: District[];

  // 学校列表
  schools: School[];

  // 初中学校列表
  middleSchools: MiddleSchool[];

  // 各区中考人数
  examCounts: DistrictExamCountResponse | null;

  // 数据加载状态
  loading: boolean;

  // 错误信息
  error: string | null;
}

export const useReferenceStore = defineStore('reference', {
  state: (): ReferenceState => ({
    districts: [],
    schools: [],
    middleSchools: [],
    examCounts: null,
    loading: false,
    error: null,
  }),

  getters: {
    // 根据ID获取区县
    getDistrictById: (state) => (id: number) => {
      return state.districts.find((d) => d.id === id);
    },

    // 根据区ID获取学校列表
    getSchoolsByDistrict: (state) => (districtId: number) => {
      return state.schools.filter((s) => s.districtId === districtId);
    },

    // 根据区ID获取初中学校列表
    getMiddleSchoolsByDistrict: (state) => (districtId: number) => {
      return state.middleSchools.filter((ms) => ms.districtId === districtId);
    },

    // 获取不选择生源的初中学校
    getNonSelectiveMiddleSchools: (state) => (districtId?: number) => {
      return state.middleSchools.filter(
        (ms) => ms.isNonSelective && (districtId === undefined || ms.districtId === districtId)
      );
    },

    // 根据ID获取学校
    getSchoolById: (state) => (id: number) => {
      return state.schools.find((s) => s.id === id);
    },

    // 根据ID获取初中学校
    getMiddleSchoolById: (state) => (id: number) => {
      return state.middleSchools.find((ms) => ms.id === id);
    },

    // 获取区县考试人数
    getExamCountByDistrict:
      (state) =>
      (districtId: number): number | undefined => {
        return state.examCounts?.districts.find((d) => d.districtId === districtId)?.examCount;
      },
  },

  actions: {
    // 设置区县列表
    setDistricts(districts: District[]) {
      this.districts = districts;
    },

    // 设置学校列表
    setSchools(schools: School[]) {
      this.schools = schools;
    },

    // 设置初中学校列表
    setMiddleSchools(middleSchools: MiddleSchool[]) {
      this.middleSchools = middleSchools;
    },

    // 设置考试人数
    setExamCounts(examCounts: DistrictExamCountResponse) {
      this.examCounts = examCounts;
    },

    // 设置加载状态
    setLoading(loading: boolean) {
      this.loading = loading;
    },

    // 设置错误
    setError(error: string | null) {
      this.error = error;
    },

    // 清空所有数据
    clearAll() {
      this.districts = [];
      this.schools = [];
      this.middleSchools = [];
      this.examCounts = null;
      this.error = null;
    },
  },
});
