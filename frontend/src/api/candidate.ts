// 考生 API - Connect-RPC 实现
import { candidateClient } from "./connect";
import type { 
  AnalysisResult, 
  HistorySummary,
  CandidateInfo,
  CandidateScores,
  RankingInfo,
  Volunteers,
} from "@/gen/highschool/v1/candidate_pb";

export type { 
  AnalysisResult, 
  HistorySummary,
  CandidateInfo,
  CandidateScores,
  RankingInfo,
  Volunteers,
};

// 提交分析请求类型
export interface SubmitAnalysisRequest {
  candidate: CandidateInfo;
  scores: CandidateScores;
  ranking: RankingInfo;
  comprehensiveQuality: number;
  volunteers: Volunteers;
  isTiePreferred?: boolean;
  deviceId?: string;
}

// 将表单数据转换为请求格式
import { useCandidateStore } from "@/stores/candidate";

export function formatFormToRequest(form: ReturnType<typeof useCandidateStore>['form']): SubmitAnalysisRequest {
  return {
    candidate: {
      districtId: form.districtId!,
      middleSchoolId: form.middleSchoolId!,
      hasQuotaSchoolEligibility: form.hasQuotaSchoolEligibility,
    },
    scores: { ...form.scores },
    ranking: { ...form.ranking },
    comprehensiveQuality: form.comprehensiveQuality,
    volunteers: {
      quotaDistrict: form.volunteers.quotaDistrict ?? undefined,
      quotaSchool: form.volunteers.quotaSchool.slice(0, 2),
      unified: form.volunteers.unified.slice(0, 15),
    },
  };
}

// 提交模拟分析
export async function submitAnalysis(data: SubmitAnalysisRequest): Promise<{ analysisId: string }> {
  const res = await candidateClient.submitAnalysis({
    candidate: data.candidate,
    scores: data.scores,
    ranking: data.ranking,
    comprehensiveQuality: data.comprehensiveQuality,
    volunteers: data.volunteers,
    isTiePreferred: data.isTiePreferred ?? false,
    deviceId: data.deviceId,
  });
  if (!res.result?.id) {
    throw new Error("提交分析失败");
  }
  return { analysisId: res.result.id };
}

// 获取分析结果
export async function getAnalysisResult(id: string): Promise<AnalysisResult> {
  const res = await candidateClient.getAnalysisResult({ id });
  if (!res.result) {
    throw new Error("分析结果不存在");
  }
  return res.result;
}

// 获取历史记录
export async function getHistory(): Promise<{ histories: HistorySummary[]; total: number }> {
  const res = await candidateClient.getHistory({});
  return { 
    histories: res.histories, 
    total: res.meta?.total ?? 0 
  };
}

// 删除历史记录
export async function deleteHistory(id: string): Promise<void> {
  await candidateClient.deleteHistory({ id });
}
