/**
 * Candidate API - Connect-RPC implementation
 * Handles candidate analysis, history, and related operations
 */
import { candidateClient } from './connect';
import type {
  AnalysisResult,
  HistorySummary,
  CandidateInfo,
  CandidateScores,
  RankingInfo,
  Volunteers,
} from '@/gen/highschool/v1/candidate_pb';

// Re-export types
export type {
  AnalysisResult,
  HistorySummary,
  CandidateInfo,
  CandidateScores,
  RankingInfo,
  Volunteers,
};

/**
 * Submit analysis request type
 */
export interface SubmitAnalysisRequest {
  candidate: CandidateInfo;
  scores: CandidateScores;
  ranking: RankingInfo;
  comprehensiveQuality: number;
  volunteers: Volunteers;
  isTiePreferred?: boolean;
  deviceId?: string;
}

/**
 * Submit analysis for simulation
 */
export async function submitAnalysis(
  data: SubmitAnalysisRequest
): Promise<{ analysisId: string }> {
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
    throw new Error('提交分析失败');
  }

  return { analysisId: res.result.id };
}

/**
 * Get analysis result by ID
 */
export async function getAnalysisResult(id: string): Promise<AnalysisResult> {
  const res = await candidateClient.getAnalysisResult({ id });

  if (!res.result) {
    throw new Error('分析结果不存在');
  }

  return res.result;
}

/**
 * Get history records for current device
 */
export async function getHistory(): Promise<{
  histories: HistorySummary[];
  total: number;
}> {
  // Import device utility dynamically to avoid circular dependencies
  const { getDeviceId } = await import('@/utils/device');
  const deviceId = await getDeviceId();

  const res = await candidateClient.getHistory({ deviceId });

  return {
    histories: res.histories,
    total: res.meta?.total ?? 0,
  };
}

/**
 * Delete a single history record
 */
export async function deleteHistory(id: string): Promise<void> {
  await candidateClient.deleteHistory({ id });
}

/**
 * Delete all history records for current device
 */
export async function deleteAllHistory(): Promise<void> {
  await candidateClient.deleteHistory({});
}
