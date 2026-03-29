/**
 * 格式化工具函数
 */

function formatTime(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hour = String(date.getHours()).padStart(2, '0')
  const minute = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day} ${hour}:${minute}`
}

function formatPercent(value) {
  if (typeof value !== 'number') return '0%'
  return Math.round(value) + '%'
}

function formatScoreDiff(diff) {
  if (typeof diff !== 'number') return ''
  if (diff > 0) return `+${diff}`
  return String(diff)
}

function formatScoreRange(low, high) {
  if (!low || !high) return ''
  return `${low} - ${high}`
}

module.exports = {
  formatTime,
  formatPercent,
  formatScoreDiff,
  formatScoreRange
}
