/**
 * AgentService API
 * Connect-RPC JSON over wx.request
 * 注意：顾问频道推理耗时较长，单独使用 60s 超时，
 * 不复用 api.js 的 8s 契约，仅共享其 baseUrl 解析逻辑
 */

var api = require('./api')
var device = require('./device')

var SERVICE = 'highschool.v1.AgentService'
var AGENT_TIMEOUT = 60000

/**
 * 调用 AgentService 方法（60s 超时）
 */
function callAgentRpc(method, data) {
  return new Promise(function (resolve, reject) {
    wx.request({
      url: api.getActiveUrl() + '/' + SERVICE + '/' + method,
      method: 'POST',
      data: data || {},
      timeout: AGENT_TIMEOUT,
      dataType: 'json',
      responseType: 'text',
      header: {
        'Content-Type': 'application/json'
      },
      success: function (res) {
        if (res.statusCode === 200) {
          var result = (res.data && res.data.result) ? res.data.result : res.data
          resolve(result)
        } else {
          reject(new Error('顾问服务请求失败 (' + res.statusCode + ')'))
        }
      },
      fail: function (err) {
        reject(new Error('网络请求失败，请检查网络连接'))
      }
    })
  })
}

/**
 * 发送对话消息
 * @param {object} params {sessionId, message, context?, pendingAnswer?}
 */
function agentChat(params) {
  var data = {
    deviceId: device.getDeviceId(),
    sessionId: params.sessionId,
    message: params.message
  }
  if (params.context) {
    data.context = params.context
  }
  if (params.pendingAnswer) {
    data.pendingAnswer = params.pendingAnswer
  }
  return callAgentRpc('Chat', data)
}

/**
 * 创建新会话
 */
function newAgentSession() {
  return callAgentRpc('NewSession', {
    deviceId: device.getDeviceId()
  })
}

/**
 * 获取会话历史
 */
function getAgentHistory(sessionId, limit) {
  return callAgentRpc('GetSessionHistory', {
    deviceId: device.getDeviceId(),
    sessionId: sessionId,
    limit: limit || 50
  })
}

module.exports = {
  agentChat: agentChat,
  newAgentSession: newAgentSession,
  getAgentHistory: getAgentHistory
}
