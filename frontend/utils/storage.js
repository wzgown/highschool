/**
 * 本地存储工具
 */

var STORAGE_KEYS = {
  FORM_DATA: 'form_data',
  ANALYSIS_ID: 'analysis_id',
  FOCUS_SCHOOLS: 'agent_focus_schools'
}

function saveFormData(data) {
  wx.setStorageSync(STORAGE_KEYS.FORM_DATA, JSON.stringify(data))
}

function loadFormData() {
  var raw = wx.getStorageSync(STORAGE_KEYS.FORM_DATA)
  if (!raw) return null
  try {
    return JSON.parse(raw)
  } catch (e) {
    return null
  }
}

function clearFormData() {
  wx.removeStorageSync(STORAGE_KEYS.FORM_DATA)
}

function saveAnalysisId(id) {
  wx.setStorageSync(STORAGE_KEYS.ANALYSIS_ID, id)
}

function loadAnalysisId() {
  return wx.getStorageSync(STORAGE_KEYS.ANALYSIS_ID) || ''
}

// 最近浏览的分析结果中的志愿学校名（result 页写入；顾问页据此生成
// 「XX三年分数线走势」上下文快捷提问，无则退回通用问题，勿写死示例校）
function saveFocusSchools(names) {
  wx.setStorageSync(STORAGE_KEYS.FOCUS_SCHOOLS, JSON.stringify(names || []))
}

function loadFocusSchools() {
  var raw = wx.getStorageSync(STORAGE_KEYS.FOCUS_SCHOOLS)
  if (!raw) return []
  try {
    var arr = JSON.parse(raw)
    return Array.isArray(arr) ? arr : []
  } catch (e) {
    return []
  }
}

module.exports = {
  STORAGE_KEYS: STORAGE_KEYS,
  saveFormData: saveFormData,
  loadFormData: loadFormData,
  clearFormData: clearFormData,
  saveAnalysisId: saveAnalysisId,
  loadAnalysisId: loadAnalysisId,
  saveFocusSchools: saveFocusSchools,
  loadFocusSchools: loadFocusSchools
}
