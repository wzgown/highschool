// 参考数据 API - Connect-RPC 实现
import { referenceClient } from "./connect";
import type { District, MiddleSchool, School, SchoolDetail, HistoryScore } from "@/gen/highschool/v1/district_pb";
import type { SchoolWithQuota, SchoolForUnified } from "@/gen/highschool/v1/reference_service_pb";

export type { District, MiddleSchool, School, SchoolDetail, HistoryScore, SchoolWithQuota, SchoolForUnified };

// 获取区县列表
export async function getDistricts(): Promise<{ districts: District[] }> {
  const res = await referenceClient.getDistricts({});
  return { districts: res.districts };
}

// 获取初中学校列表
export async function getMiddleSchools(params?: { districtId?: number }): Promise<{ middleSchools: MiddleSchool[] }> {
  const res = await referenceClient.getMiddleSchools({
    districtId: params?.districtId,
  });
  return { middleSchools: res.middleSchools };
}

// 获取高中学校列表
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
    total: res.meta?.total ?? 0
  };
}

// 获取学校详情
export async function getSchoolDetail(id: number): Promise<{ school: SchoolDetail }> {
  const res = await referenceClient.getSchoolDetail({ id });
  if (!res.school) {
    throw new Error("学校不存在");
  }
  return { school: res.school };
}

// 获取历年分数线
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

// 获取有名额分配到区的高中列表
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

// 获取有名额分配到校的高中列表
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

// 获取统一招生（1-15志愿）可选学校列表
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
