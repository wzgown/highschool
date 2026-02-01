/**
 * 参考数据API
 */

import { get } from '../client';
import type {
  DistrictsResponse,
  SchoolsListParams,
  SchoolsListResponse,
  SchoolDetailResponse,
  MiddleSchoolsResponse,
  DistrictExamCountResponse,
} from '@shared/types/api';

/**
 * 获取区县列表
 */
export function getDistricts(): Promise<DistrictsResponse> {
  return get<DistrictsResponse>('/reference/districts');
}

/**
 * 获取学校列表
 */
export function getSchools(params?: SchoolsListParams): Promise<SchoolsListResponse> {
  return get<SchoolsListResponse>('/reference/schools', params);
}

/**
 * 获取学校详情
 */
export function getSchoolDetail(id: number): Promise<SchoolDetailResponse> {
  return get<SchoolDetailResponse>(`/reference/schools/${id}`);
}

/**
 * 获取初中学校列表
 */
export function getMiddleSchools(params?: {
  districtId?: number;
  isNonSelective?: boolean;
}): Promise<MiddleSchoolsResponse> {
  return get<MiddleSchoolsResponse>('/reference/middle-schools', params);
}

/**
 * 获取各区中考人数
 */
export function getDistrictExamCount(year?: number): Promise<DistrictExamCountResponse> {
  return get<DistrictExamCountResponse>('/reference/district-exam-count', { year });
}

/**
 * 获取历年分数线（占位）
 */
export function getHistoryScores(params: {
  districtId: number;
  schoolId?: number;
  year?: number;
  batch?: string;
}): Promise<any> {
  return get<any>('/reference/history-scores', params);
}
