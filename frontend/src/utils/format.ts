/**
 * 格式化工具函数
 */

/**
 * 格式化分数
 */
export function formatScore(score: number | string, decimals = 1): string {
  const num = typeof score === 'string' ? parseFloat(score) : score;
  if (isNaN(num)) return '-';
  return num.toFixed(decimals);
}

/**
 * 格式化百分比
 */
export function formatPercent(value: number, decimals = 1): string {
  if (isNaN(value)) return '-';
  return `${value.toFixed(decimals)}%`;
}

/**
 * 格式化排名
 */
export function formatRank(rank: number | string, total?: number): string {
  const r = typeof rank === 'string' ? parseInt(rank) : rank;
  if (isNaN(r)) return '-';

  if (total) {
    return `${r} / ${total}`;
  }

  return `${r}`;
}

/**
 * 格式化日期
 */
export function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  if (isNaN(d.getTime())) return '-';

  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  const hours = String(d.getHours()).padStart(2, '0');
  const minutes = String(d.getMinutes()).padStart(2, '0');

  return `${year}-${month}-${day} ${hours}:${minutes}`;
}

/**
 * 格式化相对时间
 */
export function formatRelativeTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  if (isNaN(d.getTime())) return '-';

  const now = new Date();
  const diff = now.getTime() - d.getTime();
  const seconds = Math.floor(diff / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (seconds < 60) {
    return '刚刚';
  }

  if (minutes < 60) {
    return `${minutes}分钟前`;
  }

  if (hours < 24) {
    return `${hours}小时前`;
  }

  if (days < 7) {
    return `${days}天前`;
  }

  return formatDate(d);
}

/**
 * 格式化分数区间
 */
export function formatScoreRange(min: number, max: number): string {
  return `${min.toFixed(0)}-${max.toFixed(0)}`;
}

/**
 * 格式化学校类型
 */
export function formatSchoolType(code: string): string {
  const typeMap: Record<string, string> = {
    'CITY_MODEL': '市实验性示范性高中',
    'CITY_FEATURED': '市特色普通高中',
    'CITY_POLICY': '享受市实验性示范性高中招生政策高中',
    'DISTRICT_MODEL': '区实验性示范性高中',
    'DISTRICT_FEATURED': '区特色普通高中',
    'GENERAL': '一般高中',
    'MUNICIPAL': '委属市实验性示范性高中',
  };

  return typeMap[code] || code;
}

/**
 * 格式化批次名称
 */
export function formatBatchName(code: string): string {
  const batchMap: Record<string, string> = {
    'QUOTA_DISTRICT': '名额分配到区',
    'QUOTA_SCHOOL': '名额分配到校',
    'UNIFIED_1_15': '统一招生1-15志愿',
    'AUTONOMOUS': '自主招生',
    'UNIFIED_CONSULT': '征求志愿',
  };

  return batchMap[code] || code;
}

/**
 * 格式化风险等级名称
 */
export function formatRiskLevel(level: string): string {
  const riskMap: Record<string, string> = {
    'safe': '保底',
    'moderate': '稳妥',
    'risky': '冲刺',
    'high_risk': '高风险',
  };

  return riskMap[level] || level;
}

/**
 * 格式化策略评分等级
 */
export function formatStrategyGrade(score: number): {
  label: string;
  class: string;
} {
  if (score >= 90) {
    return { label: '优秀', class: 'excellent' };
  }
  if (score >= 75) {
    return { label: '良好', class: 'good' };
  }
  if (score >= 60) {
    return { label: '一般', class: 'fair' };
  }
  return { label: '较差', class: 'poor' };
}

/**
 * 截断文本
 */
export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
}

/**
 * 高亮关键词
 */
export function highlightKeyword(text: string, keyword: string): string {
  if (!keyword) return text;
  const regex = new RegExp(`(${keyword})`, 'gi');
  return text.replace(regex, '<span class="highlight">$1</span>');
}
