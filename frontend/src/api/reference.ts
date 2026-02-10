// 参考数据 API - Connect-RPC 实现
import { referenceClient } from "./connect";
import type { District, MiddleSchool, School, SchoolDetail, HistoryScore } from "@/gen/highschool/v1/district_pb";

export type { District, MiddleSchool, School, SchoolDetail, HistoryScore };

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
