/**
 * 常量定义
 */

// 各科目满分上限
const SCORE_LIMITS = {
  chinese: 150,
  math: 150,
  foreign: 150,
  integrated: 150,
  ethics: 60,
  history: 60,
  pe: 30,
  total: 750
}

// 综合素质默认值
const COMPREHENSIVE_QUALITY_DEFAULT = 50

// 志愿数量
const VOLUNTEER_COUNTS = {
  quotaDistrict: 1,
  quotaSchool: 2,
  unified: 15
}

// 录取批次
const BATCH_TYPES = {
  QUOTA_DISTRICT: 'QUOTA_DISTRICT',
  QUOTA_SCHOOL: 'QUOTA_SCHOOL',
  UNIFIED: 'UNIFIED'
}

// 批次显示名
const BATCH_NAMES = {
  QUOTA_DISTRICT: '名额分配到区',
  QUOTA_SCHOOL: '名额分配到校',
  UNIFIED: '统一招生'
}

// 风险等级
const RISK_LEVELS = {
  safe: { text: '安全', type: 'success' },
  moderate: { text: '稳妥', type: 'warning' },
  risky: { text: '冲刺', type: 'danger' },
  high_risk: { text: '高风险', type: 'info' }
}

// 置信度
const CONFIDENCE_MAP = {
  high: { text: '准确度高', type: 'success' },
  medium: { text: '准确度中', type: 'warning' },
  low: { text: '准确度低', type: 'info' }
}

module.exports = {
  SCORE_LIMITS,
  COMPREHENSIVE_QUALITY_DEFAULT,
  VOLUNTEER_COUNTS,
  BATCH_TYPES,
  BATCH_NAMES,
  RISK_LEVELS,
  CONFIDENCE_MAP
}
