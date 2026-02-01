/**
 * 录取相关常量
 * 前后端共享
 */

import { AdmissionBatchCode } from '../types/school';

/**
 * 科目满分值
 */
export const SUBJECT_MAX_SCORES = {
  chinese: 150,
  math: 150,
  foreign: 150,
  integrated: 150,
  ethics: 60,
  history: 60,
  pe: 30,
  comprehensive_quality: 50, // 综合素质评价（名额分配批次）
} as const;

/**
 * 学业考试总分满分
 */
export const EXAM_TOTAL_SCORE = 750;

/**
 * 名额分配批次总分满分（学业考 + 综合素质评价）
 */
export const QUOTA_TOTAL_SCORE = 800;

/**
 * 各科目满分值类型
 */
export type SubjectCode = keyof typeof SUBJECT_MAX_SCORES;

/**
 * 招生批次信息
 */
export const ADMISSION_BATCHES = [
  {
    code: AdmissionBatchCode.AUTONOMOUS,
    name: '自主招生录取',
    description: '含委属市实验性示范性高中、市特色普通高中自招、体艺自招、国际课程班',
    totalScore: EXAM_TOTAL_SCORE,
    displayOrder: 1,
    supported: false, // 本系统不支持
  },
  {
    code: AdmissionBatchCode.QUOTA_DISTRICT,
    name: '名额分配到区',
    description: '1个志愿，总分800分（含综合素质评价50分）',
    totalScore: QUOTA_TOTAL_SCORE,
    displayOrder: 2,
    supported: true,
  },
  {
    code: AdmissionBatchCode.QUOTA_SCHOOL,
    name: '名额分配到校',
    description: '2个平行志愿，总分800分（含综合素质评价50分），仅限不选择生源初中学生',
    totalScore: QUOTA_TOTAL_SCORE,
    displayOrder: 3,
    supported: true,
  },
  {
    code: AdmissionBatchCode.UNIFIED_1_15,
    name: '统一招生1-15志愿',
    description: '15个平行志愿，总分750分',
    totalScore: EXAM_TOTAL_SCORE,
    displayOrder: 4,
    supported: true,
  },
  {
    code: AdmissionBatchCode.UNIFIED_CONSULT,
    name: '统一招生征求志愿',
    description: '征求志愿，总分750分',
    totalScore: EXAM_TOTAL_SCORE,
    displayOrder: 5,
    supported: false,
  },
] as const;

/**
 * 招生批次执行顺序
 */
export const ADMISSION_BATCH_ORDER: AdmissionBatchCode[] = [
  AdmissionBatchCode.AUTONOMOUS,
  AdmissionBatchCode.QUOTA_DISTRICT,
  AdmissionBatchCode.QUOTA_SCHOOL,
  AdmissionBatchCode.UNIFIED_1_15,
  AdmissionBatchCode.UNIFIED_CONSULT,
];

/**
 * 各批次志愿数量限制
 */
export const VOLUNTEER_LIMITS = {
  [AdmissionBatchCode.QUOTA_DISTRICT]: 1,
  [AdmissionBatchCode.QUOTA_SCHOOL]: 2,
  [AdmissionBatchCode.UNIFIED_1_15]: 15,
} as const;

/**
 * 同分比较位序
 */
export const TIE_BREAKER_ORDER = [
  'isTiePreferred',           // 1. 同分优待
  'comprehensiveQuality',     // 2. 综合素质评价成绩
  'chineseMathForeignSum',    // 3. 语数外三科合计
  'mathScore',                // 4. 数学成绩
  'chineseScore',             // 5. 语文成绩
  'integratedTestScore',      // 6. 综合测试成绩
] as const;

/**
 * 同分比较位序名称
 */
export const TIE_BREAKER_NAMES: Record<string, string> = {
  isTiePreferred: '同分优待',
  comprehensiveQuality: '综合素质评价成绩',
  chineseMathForeignSum: '语数外三科合计成绩',
  mathScore: '数学成绩',
  chineseScore: '语文成绩',
  integratedTestScore: '综合测试成绩',
};

/**
 * 最低投档控制分数线（2025年）
 */
export const CONTROL_SCORES_2025 = {
  autonomous: 605,       // 普通高中自主招生录取
  quota: 605,            // 名额分配综合评价录取
  unified: 513,          // 普通高中统一招生录取
  zhongben: 513,         // 中本贯通录取
  five_year: 400,        // 五年一贯制和中高职贯通录取
  technical: 350,        // 普通中专录取
} as const;

/**
 * 模拟配置默认值
 */
export const DEFAULT_SIMULATION_CONFIG = {
  simulationCount: 1000,           // 模拟次数
  competitorMultiplier: 2,         // 竞争对手数量倍数（基于区人数）
  useHistoricalData: true,         // 使用历史数据优化
  enableCache: true,               // 启用缓存
  cacheExpiration: 3600,           // 缓存过期时间（秒）
  workerTimeout: 300000,           // Worker超时时间（毫秒）
} as const;

/**
 * 概率阈值（用于判断风险等级）
 */
export const PROBABILITY_THRESHOLDS = {
  SAFE: 80,           // >= 80% 为保底
  MODERATE: 50,       // >= 50% 为稳妥
  RISKY: 20,          // >= 20% 为冲刺
  HIGH_RISK: 0,       // < 20% 为高风险
} as const;

/**
 * 志愿梯度评估标准
 */
export const GRADIENT_STANDARDS = {
  minReach: 1,            // 最少冲刺志愿数
  minTarget: 2,           // 最少稳妥志愿数
  minSafety: 1,           // 最少保底志愿数
  maxHighRisk: 2,         // 最多高风险志愿数
} as const;

/**
 * 策略评分标准
 */
export const STRATEGY_SCORE_STANDARDS = {
  noSafetyPenalty: 30,        // 无保底志愿扣分
  noTargetPenalty: 10,        // 无稳妥志愿扣分
  noReachPenalty: 5,          // 无冲刺志愿扣分
  highRiskPenalty: 5,         // 每个高风险志愿扣分
  minScore: 0,                // 最低分数
  maxScore: 100,              // 最高分数
} as const;

/**
 * 区内排名估算系数
 */
export const RANK_ESTIMATION_COEFFICIENTS = {
  scoreWeight: 0.85,          // 分数权重
  districtWeight: 0.15,       // 区因素权重
  baseVariance: 50,           // 基础方差（排名浮动范围）
} as const;

/**
 * 数据年份范围
 */
export const DATA_YEAR_RANGE = {
  min: 2022,
  max: 2025,
} as const;

/**
 * 获取批次总分
 */
export function getBatchTotalScore(batchCode: AdmissionBatchCode): number {
  const batch = ADMISSION_BATCHES.find(b => b.code === batchCode);
  return batch?.totalScore ?? EXAM_TOTAL_SCORE;
}

/**
 * 获取批次志愿数量限制
 */
export function getVolunteerLimit(batchCode: AdmissionBatchCode): number {
  return VOLUNTEER_LIMITS[batchCode] ?? 0;
}

/**
 * 是否支持该批次
 */
export function isBatchSupported(batchCode: AdmissionBatchCode): boolean {
  const batch = ADMISSION_BATCHES.find(b => b.code === batchCode);
  return batch?.supported ?? false;
}

/**
 * 获取批次名称
 */
export function getBatchName(batchCode: AdmissionBatchCode): string {
  const batch = ADMISSION_BATCHES.find(b => b.code === batchCode);
  return batch?.name ?? '未知批次';
}

/**
 * 获取批次描述
 */
export function getBatchDescription(batchCode: AdmissionBatchCode): string {
  const batch = ADMISSION_BATCHES.find(b => b.code === batchCode);
  return batch?.description ?? '';
}
