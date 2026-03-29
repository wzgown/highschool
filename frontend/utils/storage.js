/**
 * 本地存储工具
 */

const STORAGE_KEYS = {
  FORM_DATA: 'form_data',
  ANALYSIS_ID: 'analysis_id'
}

function saveFormData(data) {
  wx.setStorageSync(STORAGE_KEYS.FORM_DATA, JSON.stringify(data))
}

function loadFormData() {
  const raw = wx.getStorageSync(STORAGE_KEYS.FORM_DATA)
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

module.exports = {
  STORAGE_KEYS,
  saveFormData,
  loadFormData,
  clearFormData,
  saveAnalysisId,
  loadAnalysisId
}
