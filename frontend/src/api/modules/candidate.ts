/**
 * 考生相关API
 */

import { post, get, del } from '../client';
import type {
  SubmitAnalysisRequest,
  AnalysisResultResponse,
  SimulationHistoryListResponse,
} from '@shared/types/simulation';

/**
 * 提交模拟分析请求
 */
export function submitAnalysis(request: SubmitAnalysisRequest): Promise<AnalysisResultResponse> {
  return post<AnalysisResultResponse>('/candidates/analysis', request);
}

/**
 * 获取分析结果
 */
export function getAnalysisResult(id: string): Promise<AnalysisResultResponse> {
  return get<AnalysisResultResponse>(`/candidates/analysis/${id}`);
}

/**
 * 导出PDF报告
 */
export function exportPDF(id: string): Promise<Blob> {
  return uni.request({
    url: `/candidates/analysis/${id}/pdf`,
    method: 'GET',
    responseType: 'arraybuffer',
  }).then((response) => {
    return response.data;
  });
}

/**
 * 获取历史记录列表
 */
export function getHistoryList(params?: {
  page?: number;
  pageSize?: number;
}): Promise<SimulationHistoryListResponse> {
  return get<SimulationHistoryListResponse>('/candidates/history', params);
}

/**
 * 删除单条历史记录
 */
export function deleteHistory(id: string): Promise<void> {
  return del<void>(`/candidates/history/${id}`);
}

/**
 * 删除所有历史记录
 */
export function deleteAllHistory(): Promise<{ deletedCount: number }> {
  return del<{ deletedCount: number }>('/candidates/history');
}
