/**
 * CandidateService API
 * Connect-RPC JSON over wx.request
 */

var api = require('./api')
var device = require('./device')

var SERVICE = 'highschool.v1.CandidateService'

/**
 * 提交模拟分析
 */
function submitAnalysis(formData) {
  var deviceId = device.getDeviceId()

  var quotaSchool = (formData.volunteers.quotaSchool || [])
    .filter(function (id) { return id !== 0 })
    .slice(0, 2)

  var unified = (formData.volunteers.unified || [])
    .filter(function (id) { return id !== 0 })
    .slice(0, 15)

  var volunteers = {
    quotaDistrict: formData.volunteers.quotaDistrict || undefined,
    quotaSchool: quotaSchool,
    unified: unified
  }

  // 不具备资格时清除名额到校志愿
  if (!formData.hasQuotaSchoolEligibility) {
    volunteers.quotaSchool = []
  }

  return api.callRpc(SERVICE, 'SubmitAnalysis', {
    candidate: {
      districtId: formData.districtId,
      middleSchoolId: formData.middleSchoolId,
      hasQuotaSchoolEligibility: formData.hasQuotaSchoolEligibility
    },
    scores: {
      total: formData.scores.total,
      chinese: formData.scores.chinese || 0,
      math: formData.scores.math || 0,
      foreign: formData.scores.foreign || 0,
      integrated: formData.scores.integrated || 0,
      ethics: formData.scores.ethics || 0,
      history: formData.scores.history || 0,
      pe: formData.scores.pe || 0
    },
    ranking: {
      rank: formData.ranking.rank,
      totalStudents: formData.ranking.totalStudents
    },
    comprehensiveQuality: formData.comprehensiveQuality,
    volunteers: volunteers,
    isTiePreferred: false,
    deviceId: deviceId
  }).then(function (res) {
    var result = res.result || res
    if (!result || !result.id) {
      throw new Error('提交分析失败')
    }
    return { analysisId: result.id }
  })
}

/**
 * 获取分析结果
 */
function getAnalysisResult(id) {
  return api.callRpc(SERVICE, 'GetAnalysisResult', { id: id })
}

/**
 * 轮询获取分析结果
 */
function pollAnalysisResult(id, maxRetries, interval) {
  maxRetries = maxRetries || 10
  interval = interval || 3000

  return new Promise(function (resolve, reject) {
    var retries = 0

    function poll() {
      getAnalysisResult(id).then(function (res) {
        var result = res.result || res

        if (result && result.status === 'completed') {
          resolve(result)
        } else if (result && result.status === 'failed') {
          reject(new Error(result.errorMessage || '分析处理失败'))
        } else if (result && (result.status === 'pending' || result.status === 'processing')) {
          retries++
          if (retries >= maxRetries) {
            reject(new Error('分析超时，请稍后再试'))
          } else {
            setTimeout(poll, interval)
          }
        } else {
          // 未知状态，按完成处理
          resolve(result)
        }
      }).catch(function (err) {
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
 */
function getHistory() {
  var deviceId = device.getDeviceId()

  return api.callRpc(SERVICE, 'GetHistory', {
    page: 1,
    pageSize: 50,
    deviceId: deviceId
  }).then(function (res) {
    return {
      histories: res.histories || [],
      total: (res.meta && res.meta.total) ? res.meta.total : 0
    }
  })
}

/**
 * 删除历史记录
 */
function deleteHistory(id) {
  return api.callRpc(SERVICE, 'DeleteHistory', { id: id })
}

module.exports = {
  submitAnalysis: submitAnalysis,
  getAnalysisResult: getAnalysisResult,
  pollAnalysisResult: pollAnalysisResult,
  getHistory: getHistory,
  deleteHistory: deleteHistory
}
