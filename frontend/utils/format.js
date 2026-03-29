/**
 * 格式化工具函数
 */

function padZero(n) {
  return n < 10 ? '0' + n : '' + n
}

function formatTime(dateStr) {
  if (!dateStr) return ''
  var date = new Date(dateStr)
  var year = date.getFullYear()
  var month = padZero(date.getMonth() + 1)
  var day = padZero(date.getDate())
  var hour = padZero(date.getHours())
  var minute = padZero(date.getMinutes())
  return year + '-' + month + '-' + day + ' ' + hour + ':' + minute
}

function formatPercent(value) {
  if (typeof value !== 'number') return '0%'
  return Math.round(value) + '%'
}

function formatScoreDiff(diff) {
  if (typeof diff !== 'number') return ''
  if (diff > 0) return '+' + diff
  return '' + diff
}

function formatScoreRange(low, high) {
  if (!low || !high) return ''
  return low + ' - ' + high
}

module.exports = {
  formatTime: formatTime,
  formatPercent: formatPercent,
  formatScoreDiff: formatScoreDiff,
  formatScoreRange: formatScoreRange
}
