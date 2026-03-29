/**
 * Connect-RPC JSON 客户端
 * 使用 wx.request 直接调用 Connect-RPC JSON 端点
 */

const API_BASE_URL = 'http://127.0.0.1:3000'

/**
 * 调用 Connect-RPC 服务方法
 * @param {string} service - 服务名，如 'highschool.v1.ReferenceService'
 * @param {string} method - 方法名，如 'GetDistricts'
 * @param {object} data - 请求体（JSON 对象）
 * @returns {Promise<object>} 响应结果
 */
function callRpc(service, method, data = {}) {
  const url = `${API_BASE_URL}/${service}/${method}`

  return new Promise((resolve, reject) => {
    wx.request({
      url,
      method: 'POST',
      data,
      timeout: 10000,
      header: {
        'Content-Type': 'application/json',
        'Connect-Protocol-Version': '1'
      },
      success(res) {
        if (res.statusCode === 200) {
          // Connect 协议返回 {"result": {...}}
          resolve(res.data.result || res.data)
        } else {
          var errMsg = (res.data && res.data.message) || '请求失败 (' + res.statusCode + ')'
          reject(new Error(errMsg))
        }
      },
      fail(err) {
        reject(new Error(err.errMsg || '网络请求失败'))
      }
    })
  })
}

module.exports = { callRpc }
