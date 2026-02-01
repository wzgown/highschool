/**
 * 考生相关类型定义
 * 前后端共享
 */

/**
 * 考生成绩（满分750分）
 */
export interface CandidateScores {
  /** 总分 (0-750) */
  total: number;
  /** 语文 (150) */
  chinese: number;
  /** 数学 (150) */
  math: number;
  /** 外语 (150) */
  foreign: number;
  /** 综合测试 (150) */
  integrated: number;
  /** 道德与法治 (60) */
  ethics: number;
  /** 历史 (60) */
  history: number;
  /** 体育与健身 (30) */
  pe: number;
}

/**
 * 考生排名信息
 */
export interface CandidateRanking {
  /** 区内排名 */
  rank: number;
  /** 全区总人数 */
  totalStudents: number;
  /** 排名百分比 (0-100) */
  percentile: number;
}

/**
 * 名额分配到校志愿（最多2个）
 */
export type QuotaSchoolVolunteers = [number | null, number | null];

/**
 * 统一招生志愿（最多15个）
 */
export type UnifiedVolunteers = (number | null)[];

/**
 * 考生志愿填报
 */
export interface CandidateVolunteers {
  /** 名额分配到区志愿（1个） */
  quotaDistrict: number | null;
  /** 名额分配到校志愿（2个平行志愿） */
  quotaSchool: QuotaSchoolVolunteers;
  /** 统一招生志愿（15个平行志愿） */
  unified: UnifiedVolunteers;
}

/**
 * 考生基本信息
 */
export interface CandidateInfo {
  /** 所属区ID */
  districtId: number;
  /** 初中学校ID */
  middleSchoolId: number;
  /** 是否具备名额分配到校填报资格 */
  hasQuotaSchoolEligibility: boolean;
}

/**
 * 完整考生数据
 */
export interface Candidate {
  /** 考生ID */
  id: string;
  /** 基本信息 */
  info: CandidateInfo;
  /** 成绩 */
  scores: CandidateScores;
  /** 排名 */
  ranking: CandidateRanking;
  /** 志愿 */
  volunteers: CandidateVolunteers;
  /** 综合素质评价 (50分满分，名额分配批次使用) */
  comprehensiveQuality: number;
  /** 是否同分优待 */
  isTiePreferred?: boolean;
  /** 设备ID（用于历史记录关联） */
  deviceId?: string;
  /** 创建时间 */
  createdAt?: Date;
}

/**
 * 脱敏后的考生数据（用于历史记录）
 */
export interface AnonymizedCandidateData {
  /** 区ID */
  districtId: number;
  /** 初中学校ID */
  middleSchoolId: number;
  /** 分数区间（如"700-710"） */
  scoreRange: string;
  /** 总分 */
  totalScore: number;
  /** 志愿数量 */
  volunteerCount: number;
  /** 是否具备名额分配到校资格 */
  hasQuotaSchoolEligibility: boolean;
  /** 创建时间 */
  createdAt: Date;
}

/**
 * 考生同分比较数据（用于录取排序）
 */
export interface CandidateTieBreaker {
  /** 综合素质评价 (50分) */
  comprehensiveQuality: number;
  /** 语数外三科合计 */
  chineseMathForeignSum: number;
  /** 数学成绩 */
  mathScore: number;
  /** 语文成绩 */
  chineseScore: number;
  /** 综合测试成绩 */
  integratedTestScore: number;
  /** 是否同分优待 */
  isTiePreferred: boolean;
}

/**
 * 计算同分比较数据
 */
export function calculateTieBreakerData(scores: CandidateScores, comprehensiveQuality: number, isTiePreferred = false): CandidateTieBreaker {
  return {
    comprehensiveQuality,
    chineseMathForeignSum: scores.chinese + scores.math + scores.foreign,
    mathScore: scores.math,
    chineseScore: scores.chinese,
    integratedTestScore: scores.integrated,
    isTiePreferred,
  };
}

/**
 * 获取分数区间字符串
 */
export function getScoreRange(score: number, rangeSize = 10): string {
  const lower = Math.floor(score / rangeSize) * rangeSize;
  const upper = lower + rangeSize;
  return `${lower}-${upper}`;
}

/**
 * 验证成绩合法性
 */
export function validateScores(scores: CandidateScores): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  if (scores.total < 0 || scores.total > 750) {
    errors.push('总分必须在0-750之间');
  }

  if (scores.chinese < 0 || scores.chinese > 150) {
    errors.push('语文成绩必须在0-150之间');
  }

  if (scores.math < 0 || scores.math > 150) {
    errors.push('数学成绩必须在0-150之间');
  }

  if (scores.foreign < 0 || scores.foreign > 150) {
    errors.push('外语成绩必须在0-150之间');
  }

  if (scores.integrated < 0 || scores.integrated > 150) {
    errors.push('综合测试成绩必须在0-150之间');
  }

  if (scores.ethics < 0 || scores.ethics > 60) {
    errors.push('道德与法治成绩必须在0-60之间');
  }

  if (scores.history < 0 || scores.history > 60) {
    errors.push('历史成绩必须在0-60之间');
  }

  if (scores.pe < 0 || scores.pe > 30) {
    errors.push('体育成绩必须在0-30之间');
  }

  // 验证总分是否等于各科之和
  const calculatedTotal = scores.chinese + scores.math + scores.foreign +
    scores.integrated + scores.ethics + scores.history + scores.pe;
  if (Math.abs(scores.total - calculatedTotal) > 0.5) {
    errors.push(`总分(${scores.total})与各科成绩之和(${calculatedTotal})不一致`);
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}
