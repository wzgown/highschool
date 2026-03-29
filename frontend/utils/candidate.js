/**
 * CandidateService API
 * Connect-RPC JSON over wx.request
 */

const { callRpc } = require('./api')
const { getDeviceId } = require('./device')

const SERVICE = 'highschool.v1.CandidateService'

/**
 * 提交模拟分析
 * @param {object} formData - 表单数据
 * @returns {Promise<{analysisId: string}>}
 */
async function submitAnalysis(formData) {
  const deviceId = getDeviceId()
  const volunteers = {
    quotaDistrict: formData.volunteers.quotaDistrict || undefined,
    quotaSchool: formData.volunteers.quotaSchool.filter(id => id !== 0).slice(0, 2),
    unified: formData.volunteers.unified.filter(id => id !== 0).slice(0, 15)
  }

  const res = await callRpc(SERVICE, 'SubmitAnalysis', {
    candidate: {
      districtId: formData.districtId,
      middleSchoolId: formData.middleSchoolId,
      hasQuotaSchoolEligibility: formData.hasQuotaSchoolEligibility
    },
    scores: { ...formData.scores },
    ranking: { ...formData.ranking },
    comprehensiveQuality: formData.comprehensiveQuality,
    volunteers,
    isTiePreferred: false,
    deviceId
  })

  const result = res.result || res
  if (!result || !result.id) {
    throw new Error('提交分析失败')
  }
  return { analysisId: result.id }
}

/**
 * 获取分析结果（支持轮询）
 * @param {string} id - 分析 ID
 * @param {number} maxRetries - 最大轮询次数
 * @param {number} interval - 轮询间隔(ms)
 * @returns {Promise<object>} 分析结果
 */
function getAnalysisResult(id) {
  return callRpc(SERVICE, 'GetAnalysisResult', { id })
}

/**
 * 轮询获取分析结果
 */
function pollAnalysisResult(id, maxRetries = 10, interval = 3000) {
  return new Promise((resolve, reject) => {
    let retries = 0

    function poll() {
      getAnalysisResult(id).then(res => {
        const result = res.result || res
        if (result && result.status === 'completed') {
          resolve(result)
        } else if (result && (result.status === 'pending' || result.status === 'processing')) {
          retries++
          if (retries >= maxRetries) {
            reject(new Error('分析超时，请稍后再试'))
          } else {
            setTimeout(poll, interval)
          }
        } else {
          resolve(result)
        }
      }).catch(err => {
        retries++
        if (retries >= maxRetries) {
          reject(err)
        } else {
          setTimeout(poll, interval)
        }
      })
    }

    poll()
  })
}

/**
 * 获取历史记录
 * @returns {Promise<{histories: Array, total: number}>}
 */
async function getHistory() {
  const deviceId = getDeviceId()
  const res = await callRpc(SERVICE, 'GetHistory', {
    page: 1,
    pageSize: 50,
    deviceId
  })
  return {
    histories: res.histories || [],
    total: res.meta ? res.meta.total : 0
  }
}

/**
 * 删除历史记录
 * @param {string} id - 历史 ID
 */
function deleteHistory(id) {
  return callRpc(SERVICE, 'DeleteHistory', { id })
}

module.exports = {
  submitAnalysis,
  getAnalysisResult,
  pollAnalysisResult,
  getHistory,
  deleteHistory
}
