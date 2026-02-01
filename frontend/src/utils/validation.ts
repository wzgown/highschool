/**
 * 验证工具函数
 */

/**
 * 验证成绩
 */
export function validateScore(score: number, min: number, max: number): {
  valid: boolean;
  message?: string;
} {
  if (isNaN(score)) {
    return { valid: false, message: '请输入有效数字' };
  }

  if (score < min || score > max) {
    return { valid: false, message: `成绩必须在${min}-${max}之间` };
  }

  return { valid: true };
}

/**
 * 验证排名
 */
export function validateRank(rank: number, totalStudents: number): {
  valid: boolean;
  message?: string;
} {
  if (isNaN(rank) || rank <= 0) {
    return { valid: false, message: '请输入有效的排名' };
  }

  if (isNaN(totalStudents) || totalStudents <= 0) {
    return { valid: false, message: '请输入有效的总人数' };
  }

  if (rank > totalStudents) {
    return { valid: false, message: '排名不能超过总人数' };
  }

  return { valid: true };
}

/**
 * 验证志愿
 */
export function validateVolunteer(
  volunteers: (number | null)[],
  maxCount: number,
  batchName: string
): {
  valid: boolean;
  message?: string;
} {
  const filledCount = volunteers.filter((v) => v !== null).length;

  if (filledCount > maxCount) {
    return { valid: false, message: `${batchName}批次最多只能填报${maxCount}个志愿` };
  }

  // 检查重复
  const filled = volunteers.filter((v) => v !== null) as number[];
  const unique = new Set(filled);
  if (filled.length !== unique.size) {
    return { valid: false, message: '不能填报重复的学校' };
  }

  return { valid: true };
}

/**
 * 验证综合素质评价
 */
export function validateComprehensiveQuality(score: number): {
  valid: boolean;
  message?: string;
} {
  if (isNaN(score)) {
    return { valid: false, message: '请输入有效数字' };
  }

  if (score < 0 || score > 50) {
    return { valid: false, message: '综合素质评价必须在0-50之间' };
  }

  return { valid: true };
}

/**
 * 验证必填字段
 */
export function validateRequired(value: any, fieldName: string): {
  valid: boolean;
  message?: string;
} {
  if (value === null || value === undefined || value === '') {
    return { valid: false, message: `请选择${fieldName}` };
  }

  return { valid: true };
}
