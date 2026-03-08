/**
 * Reference API - Connect-RPC implementation
 * Handles reference data like districts, schools, and historical scores
 */
import { referenceClient } from './connect';
import type { District } from '@/gen/highschool/v1/district_pb';
import type {
  MiddleSchool,
  School,
  SchoolDetail,
  HistoryScore,
} from '@/gen/highschool/v1/school_pb';
import {
  ExamType,
  type SchoolWithQuota,
  type SchoolForUnified,
  type RecommendedSchool,
  type ScoreConversion,
} from '@/gen/highschool/v1/reference_service_pb';

// Re-export types and enums
export type {
  District,
  MiddleSchool,
  School,
  SchoolDetail,
  HistoryScore,
  SchoolWithQuota,
  SchoolForUnified,
  RecommendedSchool,
  ScoreConversion,
};
export { ExamType };

/**
 * Get list of districts
 */
export async function getDistricts(): Promise<{ districts: District[] }> {
  const res = await referenceClient.getDistricts({});
  return { districts: res.districts };
}

/**
 * Get list of middle schools
 */
export async function getMiddleSchools(params?: {
  districtId?: number;
}): Promise<{ middleSchools: MiddleSchool[] }> {
  const res = await referenceClient.getMiddleSchools({
    districtId: params?.districtId,
  });
  return { middleSchools: res.middleSchools };
}

/**
 * Get list of high schools with pagination
 */
export async function getSchools(params?: {
  districtId?: number;
  keyword?: string;
  page?: number;
  pageSize?: number;
}): Promise<{ schools: School[]; total: number }> {
  const res = await referenceClient.getSchools({
    districtId: params?.districtId,
    keyword: params?.keyword,
    page: params?.page ?? 1,
    pageSize: params?.pageSize ?? 20,
  });

  return {
    schools: res.schools,
    total: res.meta?.total ?? 0,
  };
}

/**
 * Get school detail by ID
 */
export async function getSchoolDetail(
  id: number
): Promise<{ school: SchoolDetail }> {
  const res = await referenceClient.getSchoolDetail({ id });

  if (!res.school) {
    throw new Error('学校不存在');
  }

  return { school: res.school };
}

/**
 * Get historical scores
 */
export async function getHistoryScores(params?: {
  districtId?: number;
  schoolId?: number;
  year?: number;
}): Promise<{ scores: HistoryScore[] }> {
  const res = await referenceClient.getHistoryScores({
    districtId: params?.districtId,
    schoolId: params?.schoolId,
    year: params?.year,
  });

  return { scores: res.scores };
}

/**
 * Get schools with quota allocation to district
 */
export async function getSchoolsWithQuotaDistrict(params: {
  districtId: number;
  year?: number;
}): Promise<{ schools: SchoolWithQuota[] }> {
  const res = await referenceClient.getSchoolsWithQuotaDistrict({
    districtId: params.districtId,
    year: params.year ?? 2025,
  });

  return { schools: res.schools };
}

/**
 * Get schools with quota allocation to school
 */
export async function getSchoolsWithQuotaSchool(params: {
  middleSchoolId: number;
  year?: number;
}): Promise<{ schools: SchoolWithQuota[] }> {
  const res = await referenceClient.getSchoolsWithQuotaSchool({
    middleSchoolId: params.middleSchoolId,
    year: params.year ?? 2025,
  });

  return { schools: res.schools };
}

/**
 * Get schools available for unified admission (15 volunteers)
 */
export async function getSchoolsForUnified(params: {
  districtId: number;
  year?: number;
}): Promise<{ schools: SchoolForUnified[] }> {
  const res = await referenceClient.getSchoolsForUnified({
    districtId: params.districtId,
    year: params.year ?? 2025,
  });

  return { schools: res.schools };
}

/**
 * Get volunteer recommendations
 */
export async function getVolunteerRecommendations(params: {
  districtId: number;
  middleSchoolId?: number;
  examType: ExamType;
  totalScore: number;
  hasQuotaSchoolEligibility: boolean;
  year?: number;
}): Promise<{
  quotaDistrictRecommendations: RecommendedSchool[];
  quotaSchoolRecommendations: RecommendedSchool[];
  unifiedRecommendations: RecommendedSchool[];
  scoreConversion: ScoreConversion | undefined;
  year: number;
}> {
  const res = await referenceClient.getVolunteerRecommendations({
    districtId: params.districtId,
    middleSchoolId: params.middleSchoolId,
    examType: params.examType,
    totalScore: params.totalScore,
    hasQuotaSchoolEligibility: params.hasQuotaSchoolEligibility,
    year: params.year,
  });

  return {
    quotaDistrictRecommendations: res.quotaDistrictRecommendations,
    quotaSchoolRecommendations: res.quotaSchoolRecommendations,
    unifiedRecommendations: res.unifiedRecommendations,
    scoreConversion: res.scoreConversion,
    year: res.year,
  };
}
