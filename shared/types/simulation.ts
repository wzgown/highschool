/**
 * 模拟分析相关类型定义
 * 前后端共享
 */

import type { AdmissionBatchCode } from './school';
import type { Candidate, CandidateScores } from './candidate';

/**
 * 提交模拟分析请求
 */
export interface SubmitAnalysisRequest {
  /** 考生ID（可选，用于更新已有记录） */
  candidateId?: string;
  /** 设备ID */
  deviceId: string;
  /** 考生信息 */
  candidate: {
    /** 所属区ID */
    districtId: number;
    /** 初中学校ID */
    middleSchoolId: number;
    /** 是否具备名额分配到校填报资格 */
    hasQuotaSchoolEligibility: boolean;
  };
  /** 成绩 */
  scores: {
    /** 总分 (0-750) */
    total: number;
    /** 语文 */
    chinese: number;
    /** 数学 */
    math: number;
    /** 外语 */
    foreign: number;
    /** 综合测试 */
    integrated: number;
    /** 道德与法治 */
    ethics: number;
    /** 历史 */
    history: number;
    /** 体育 */
    pe: number;
  };
  /** 排名 */
  ranking: {
    /** 区内排名 */
    rank: number;
    /** 全区总人数 */
    totalStudents: number;
  };
  /** 综合素质评价 (默认50) */
  comprehensiveQuality: number;
  /** 志愿 */
  volunteers: {
    /** 名额分配到区志愿（school_id） */
    quotaDistrict: number | null;
    /** 名额分配到校志愿（最多2个） */
    quotaSchool: [number | null, number | null];
    /** 统一招生志愿（最多15个） */
    unified: (number | null)[];
  };
  /** 是否同分优待 */
  isTiePreferred?: boolean;
}

/**
 * 模拟分析状态
 */
export enum AnalysisStatus {
  /** 等待处理 */
  PENDING = 'pending',
  /** 处理中 */
  PROCESSING = 'processing',
  /** 完成 */
  COMPLETED = 'completed',
  /** 失败 */
  FAILED = 'failed',
}

/**
 * 录取批次
 */
export type AdmissionBatch = 'QUOTA_DISTRICT' | 'QUOTA_SCHOOL' | 'UNIFIED';

/**
 * 风险等级
 */
export enum RiskLevel {
  /** 安全（保底） */
  SAFE = 'safe',
  /** 稳妥 */
  MODERATE = 'moderate',
  /** 冲刺 */
  RISKY = 'risky',
  /** 高风险 */
  HIGH_RISK = 'high_risk',
}

/**
 * 信心等级
 */
export enum ConfidenceLevel {
  /** 高信心 */
  HIGH = 'high',
  /** 中等信心 */
  MEDIUM = 'medium',
  /** 低信心 */
  LOW = 'low',
}

/**
 * 排名预测结果
 */
export interface RankPrediction {
  /** 预测的区内排名 */
  districtRank: number;
  /** 排名范围（最低-最高） */
  districtRankRange: [number, number];
  /** 信心等级 */
  confidence: ConfidenceLevel;
  /** 排名百分比 */
  percentile: number;
}

/**
 * 志愿录取概率
 */
export interface VolunteerProbability {
  /** 批次 */
  batch: AdmissionBatch;
  /** 学校ID */
  schoolId: number;
  /** 学校名称 */
  schoolName: string;
  /** 学校代码 */
  schoolCode?: string;
  /** 录取概率 (0-100) */
  probability: number;
  /** 风险等级 */
  riskLevel: RiskLevel;
  /** 与历年分数线对比（正数表示高于历年线，负数表示低于历年线） */
  scoreDiff?: number | null;
  /** 历年最低分 */
  historyMinScore?: number;
  /** 志愿序号 */
  volunteerIndex?: number;
}

/**
 * 策略梯度分析
 */
export interface StrategyGradient {
  /** 冲刺志愿数量 */
  reach: number;
  /** 稳妥志愿数量 */
  target: number;
  /** 保底志愿数量 */
  safety: number;
}

/**
 * 策略分析结果
 */
export interface StrategyAnalysis {
  /** 策略评分 (0-100) */
  score: number;
  /** 梯度分析 */
  gradient: StrategyGradient;
  /** 建议列表 */
  suggestions: string[];
  /** 警告列表 */
  warnings: string[];
  /** 志愿填报合理性分析 */
  volunteerRationality?: {
    /** 是否有合理的保底志愿 */
    hasSafetySchool: boolean;
    /** 志愿梯度是否合理 */
    isGradientReasonable: boolean;
    /** 是否有重复或无效志愿 */
    hasDuplicateOrInvalid: boolean;
  };
}

/**
 * 分数分布区间
 */
export interface ScoreDistribution {
  /** 分数区间（如"700-710"） */
  range: string;
  /** 人数 */
  count: number;
  /** 百分比 */
  percentage: number;
}

/**
 * 竞争对手分析
 */
export interface CompetitorAnalysis {
  /** 虚拟竞争对手总数 */
  count: number;
  /** 分数分布 */
  scoreDistribution: ScoreDistribution[];
  /** 志愿重叠度 */
  volunteerOverlap?: {
    /** 志愿相同的竞争对手数量 */
    sameVolunteerCount: number;
    /** 志愿高度相似的竞争对手数量 */
    similarVolunteerCount: number;
  };
}

/**
 * 模拟分析结果
 */
export interface SimulationResult {
  /** 排名预测 */
  predictions: RankPrediction;
  /** 各志愿录取概率 */
  probabilities: VolunteerProbability[];
  /** 策略分析 */
  strategy: StrategyAnalysis;
  /** 竞争对手分析 */
  competitors: CompetitorAnalysis;
  /** 模拟次数 */
  simulationCount: number;
  /** 预估录取批次 */
  predictedBatch?: AdmissionBatch;
  /** 预估录取学校 */
  predictedSchool?: {
    id: number;
    name: string;
    batch: AdmissionBatch;
  };
}

/**
 * 模拟历史摘要
 */
export interface SimulationHistorySummary {
  /** 记录ID */
  id: string;
  /** 创建时间 */
  createdAt: Date;
  /** 总志愿数 */
  totalVolunteers: number;
  /** 安全志愿数 */
  safeCount: number;
  /** 稳妥志愿数 */
  moderateCount: number;
  /** 冲刺志愿数 */
  riskyCount: number;
  /** 高风险志愿数 */
  highRiskCount: number;
  /** 策略评分 */
  strategyScore: number;
  /** 是否已录取（基于模拟结果） */
  isAdmitted?: boolean;
}

/**
 * 模拟历史记录
 */
export interface SimulationHistory {
  /** 记录ID */
  id: string;
  /** 设备ID */
  deviceId: string;
  /** 设备信息 */
  deviceInfo?: {
    platform: string;
    userAgent?: string;
    screenResolution?: string;
  };
  /** 考生数据（脱敏） */
  candidateData: {
    districtId: number;
    middleSchoolId: number;
    scoreRange: string;
    totalScore: number;
    volunteerCount: number;
    hasQuotaSchoolEligibility: boolean;
  };
  /** 模拟结果 */
  simulationResult: SimulationResult;
  /** 创建时间 */
  createdAt: Date;
}

/**
 * 模拟历史列表响应
 */
export interface SimulationHistoryListResponse {
  /** 历史记录列表 */
  histories: SimulationHistorySummary[];
  /** 总数 */
  total: number;
  /** 当前页 */
  page?: number;
  /** 每页数量 */
  pageSize?: number;
}

/**
 * 模拟分析响应
 */
export interface AnalysisResultResponse {
  /** 分析ID */
  id: string;
  /** 状态 */
  status: AnalysisStatus;
  /** 结果 */
  results?: SimulationResult;
  /** 错误信息 */
  error?: string;
  /** 创建时间 */
  createdAt: Date;
  /** 完成时间 */
  completedAt?: Date;
  /** 处理时长（秒） */
  processingDuration?: number;
}

/**
 * 模拟配置
 */
export interface SimulationConfig {
  /** 模拟次数（默认1000） */
  simulationCount: number;
  /** 虚拟竞争对手数量（默认基于区人数） */
  competitorCount?: number;
  /** 是否启用历史数据优化 */
  useHistoricalData: boolean;
  /** 是否缓存结果 */
  enableCache: boolean;
  /** 缓存过期时间（秒） */
  cacheExpiration?: number;
}

/**
 * 虚拟竞争对手
 */
export interface VirtualCompetitor {
  /** 竞争对手ID */
  id: string;
  /** 总分 */
  totalScore: number;
  /** 区内排名 */
  districtRank: number;
  /** 是否同分优待 */
  isTiePreferred: boolean;
  /** 综合素质评价 */
  comprehensiveQuality: number;
  /** 语数外三科合计 */
  chineseMathForeignSum: number;
  /** 数学成绩 */
  mathScore: number;
  /** 语文成绩 */
  chineseScore: number;
  /** 综合测试成绩 */
  integratedTestScore: number;
  /** 志愿列表 */
  volunteers: {
    quotaDistrict?: number;
    quotaSchool?: number[];
    unified?: number[];
  };
  /** 初中学校ID（用于名额分配到校） */
  middleSchoolId?: number;
}

/**
 * 模拟运行结果（单次模拟）
 */
export interface SimulationRunResult {
  /** 是否被录取 */
  admitted: boolean;
  /** 录取批次 */
  admittedBatch?: AdmissionBatch;
  /** 录取学校ID */
  admittedSchoolId?: number;
  /** 录取学校名称 */
  admittedSchoolName?: string;
  /** 录取志愿序号 */
  admittedVolunteerIndex?: number;
}

/**
 * 根据概率获取风险等级
 */
export function getRiskLevelByProbability(probability: number): RiskLevel {
  if (probability >= 80) return RiskLevel.SAFE;
  if (probability >= 50) return RiskLevel.MODERATE;
  if (probability >= 20) return RiskLevel.RISKY;
  return RiskLevel.HIGH_RISK;
}

/**
 * 获取风险等级的中文名称
 */
export function getRiskLevelLabel(riskLevel: RiskLevel): string {
  const labels: Record<RiskLevel, string> = {
    [RiskLevel.SAFE]: '保底',
    [RiskLevel.MODERATE]: '稳妥',
    [RiskLevel.RISKY]: '冲刺',
    [RiskLevel.HIGH_RISK]: '高风险',
  };
  return labels[riskLevel] || '未知';
}

/**
 * 获取风险等级的颜色
 */
export function getRiskLevelColor(riskLevel: RiskLevel): string {
  const colors: Record<RiskLevel, string> = {
    [RiskLevel.SAFE]: '#52c41a',      // 绿色
    [RiskLevel.MODERATE]: '#1890ff',  // 蓝色
    [RiskLevel.RISKY]: '#faad14',     // 橙色
    [RiskLevel.HIGH_RISK]: '#f5222d', // 红色
  };
  return colors[riskLevel] || '#d9d9d9';
}

/**
 * 获取信心等级的中文名称
 */
export function getConfidenceLevelLabel(confidence: ConfidenceLevel): string {
  const labels: Record<ConfidenceLevel, string> = {
    [ConfidenceLevel.HIGH]: '高',
    [ConfidenceLevel.MEDIUM]: '中',
    [ConfidenceLevel.LOW]: '低',
  };
  return labels[confidence] || '未知';
}

/**
 * 计算策略评分
 */
export function calculateStrategyScore(
  probabilities: VolunteerProbability[],
  gradient: StrategyGradient
): number {
  let score = 100;

  // 检查是否有足够的保底志愿（至少2个安全或稳妥）
  const safeCount = probabilities.filter(
    p => p.riskLevel === RiskLevel.SAFE || p.riskLevel === RiskLevel.MODERATE
  ).length;
  if (safeCount < 2) {
    score -= 20;
  }

  // 检查梯度是否合理（有冲刺、稳妥、保底）
  if (gradient.reach === 0) {
    score -= 10; // 没有冲刺志愿
  }
  if (gradient.safety === 0) {
    score -= 30; // 没有保底志愿，严重扣分
  }

  // 检查高风险志愿数量
  const highRiskCount = probabilities.filter(
    p => p.riskLevel === RiskLevel.HIGH_RISK
  ).length;
  score -= highRiskCount * 5;

  return Math.max(0, Math.min(100, score));
}
