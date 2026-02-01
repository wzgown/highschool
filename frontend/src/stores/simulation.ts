/**
 * 模拟分析数据存储
 */

import { defineStore } from 'pinia';
import type {
  SimulationResult,
  AnalysisStatus,
  SimulationHistorySummary,
} from '@shared/types/simulation';

interface SimulationState {
  // 当前分析状态
  currentAnalysis: {
    id: string | null;
    status: AnalysisStatus;
    result: SimulationResult | null;
    error: string | null;
    createdAt: Date | null;
    completedAt: Date | null;
  };

  // 历史记录
  histories: SimulationHistorySummary[];

  // 历史记录分页
  historiesPagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };

  // WebSocket连接状态
  wsConnected: boolean;
}

export const useSimulationStore = defineStore('simulation', {
  state: (): SimulationState => ({
    currentAnalysis: {
      id: null,
      status: 'pending' as AnalysisStatus,
      result: null,
      error: null,
      createdAt: null,
      completedAt: null,
    },
    histories: [],
    historiesPagination: {
      page: 1,
      pageSize: 20,
      total: 0,
      hasMore: true,
    },
    wsConnected: false,
  }),

  getters: {
    // 是否正在分析
    isAnalyzing: (state) => {
      return state.currentAnalysis.status === 'processing' || state.currentAnalysis.status === 'pending';
    },

    // 分析是否完成
    isAnalysisCompleted: (state) => {
      return state.currentAnalysis.status === 'completed';
    },

    // 分析是否失败
    isAnalysisFailed: (state) => {
      return state.currentAnalysis.status === 'failed';
    },

    // 获取策略评分
    strategyScore: (state) => {
      return state.currentAnalysis.result?.strategy.score || 0;
    },

    // 获取策略等级
    strategyGrade: (state) => {
      const score = state.currentAnalysis.result?.strategy.score || 0;
      if (score >= 90) return 'excellent';
      if (score >= 75) return 'good';
      if (score >= 60) return 'fair';
      return 'poor';
    },
  },

  actions: {
    // 开始新的分析
    startAnalysis(analysisId: string) {
      this.currentAnalysis = {
        id: analysisId,
        status: 'pending',
        result: null,
        error: null,
        createdAt: new Date(),
        completedAt: null,
      };
    },

    // 更新分析状态
    updateStatus(status: AnalysisStatus) {
      this.currentAnalysis.status = status;
      if (status === 'completed' || status === 'failed') {
        this.currentAnalysis.completedAt = new Date();
      }
    },

    // 设置分析结果
    setResult(result: SimulationResult) {
      this.currentAnalysis.result = result;
      this.currentAnalysis.status = 'completed';
      this.currentAnalysis.completedAt = new Date();
    },

    // 设置分析错误
    setError(error: string) {
      this.currentAnalysis.error = error;
      this.currentAnalysis.status = 'failed';
      this.currentAnalysis.completedAt = new Date();
    },

    // 重置当前分析
    resetAnalysis() {
      this.currentAnalysis = {
        id: null,
        status: 'pending',
        result: null,
        error: null,
        createdAt: null,
        completedAt: null,
      };
    },

    // 设置历史记录
    setHistories(histories: SimulationHistorySummary[], total: number) {
      this.histories = histories;
      this.historiesPagination.total = total;
      this.historiesPagination.hasMore =
        this.historiesPagination.page * this.historiesPagination.pageSize < total;
    },

    // 追加历史记录
    appendHistories(histories: SimulationHistorySummary[]) {
      this.histories.push(...histories);
      this.historiesPagination.hasMore = histories.length === this.historiesPagination.pageSize;
    },

    // 设置历史记录页码
    setHistoriesPage(page: number) {
      this.historiesPagination.page = page;
    },

    // 删除历史记录
    removeHistory(historyId: string) {
      const index = this.histories.findIndex((h) => h.id === historyId);
      if (index !== -1) {
        this.histories.splice(index, 1);
        this.historiesPagination.total--;
      }
    },

    // 清空历史记录
    clearHistories() {
      this.histories = [];
      this.historiesPagination = {
        page: 1,
        pageSize: 20,
        total: 0,
        hasMore: false,
      };
    },

    // 设置WebSocket连接状态
    setWsConnected(connected: boolean) {
      this.wsConnected = connected;
    },
  },
});
