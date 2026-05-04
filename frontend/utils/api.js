/**
 * Connect-RPC JSON 客户端
 * 使用 wx.request 直接调用 Connect-RPC JSON 端点
 */

var API_URL = 'https://zg.mkfriend.top'

/**
 * 调用 Connect-RPC 服务方法
 * @param {string} service
 * @param {string} method
 * @param {object} data
 * @returns {Promise<object>}
 */
function callRpc(service, method, data) {
  return new Promise(function (resolve, reject) {
    wx.request({
      url: API_URL + '/' + service + '/' + method,
      method: 'POST',
      data: data || {},
      timeout: 8000,
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
          reject(new Error('API 请求失败 (' + res.statusCode + ')'))
        }
      },
      fail: function (err) {
        reject(new Error('网络请求失败，请检查网络连接'))
      }
    })
  })
}

function testConnection() {
  return callRpc('highschool.v1.ReferenceService', 'GetDistricts', {})
    .then(function () {
      return { ok: true, msg: 'API 连接正常', url: API_URL }
    })
    .catch(function (err) {
      return { ok: false, msg: err.message || 'API 连接失败', url: API_URL }
    })
}

module.exports = {
  callRpc: callRpc,
  testConnection: testConnection,
  getActiveUrl: function () { return API_URL },
  API_URL: API_URL
}
