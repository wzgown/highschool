/**
 * 验证工具函数
 */

import type { CandidateScores } from '@shared/types/candidate';

/**
 * 验证考生成绩
 */
export function validateCandidateScores(scores: CandidateScores): {
  valid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  // 总分验证
  if (scores.total < 0 || scores.total > 750) {
    errors.push('总分必须在0-750之间');
  }

  // 各科成绩验证
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
  const calculatedTotal =
    scores.chinese +
    scores.math +
    scores.foreign +
    scores.integrated +
    scores.ethics +
    scores.history +
    scores.pe;

  if (Math.abs(scores.total - calculatedTotal) > 0.5) {
    errors.push(
      `总分(${scores.total})与各科成绩之和(${calculatedTotal})不一致`
    );
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

/**
 * 验证志愿数量
 */
export function validateVolunteerCount(
  batch: string,
  count: number
): { valid: boolean; error?: string } {
  const limits: Record<string, number> = {
    QUOTA_DISTRICT: 1,
    QUOTA_SCHOOL: 2,
    UNIFIED_1_15: 15,
  };

  const max = limits[batch];
  if (max === undefined) {
    return { valid: false, error: `未知批次: ${batch}` };
  }

  if (count > max) {
    return {
      valid: false,
      error: `${batch}批次最多只能填报${max}个志愿`,
    };
  }

  return { valid: true };
}

/**
 * 验证区内排名
 */
export function validateRanking(
  rank: number,
  totalStudents: number
): { valid: boolean; error?: string } {
  if (rank <= 0) {
    return { valid: false, error: '排名必须大于0' };
  }

  if (totalStudents <= 0) {
    return { valid: false, error: '总人数必须大于0' };
  }

  if (rank > totalStudents) {
    return { valid: false, error: '排名不能超过总人数' };
  }

  return { valid: true };
}

/**
 * 验证综合素质评价
 */
export function validateComprehensiveQuality(score: number): {
  valid: boolean;
  error?: string;
} {
  if (score < 0 || score > 50) {
    return { valid: false, error: '综合素质评价必须在0-50之间' };
  }
  return { valid: true };
}

/**
 * 验证设备ID
 */
export function validateDeviceId(deviceId: string): {
  valid: boolean;
  error?: string;
} {
  if (!deviceId || deviceId.length < 10) {
    return { valid: false, error: '设备ID无效' };
  }
  return { valid: true };
}

/**
 * 清理和验证设备ID（防止XSS等）
 */
export function sanitizeDeviceId(deviceId: string): string {
  // 只保留字母、数字、横线和下划线
  return deviceId.replace(/[^a-zA-Z0-9-_]/g, '').substring(0, 255);
}
