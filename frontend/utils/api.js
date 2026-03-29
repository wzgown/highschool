/**
 * Connect-RPC JSON 客户端
 * 使用 wx.request 直接调用 Connect-RPC JSON 端点
 */

var API_URLS = [
  'http://127.0.0.1:3000',
  'http://localhost:3000',
  'http://[::1]:3000'
]

var activeUrlIndex = 0

/**
 * 调用 Connect-RPC 服务方法
 * @param {string} service
 * @param {string} method
 * @param {object} data
 * @returns {Promise<object>}
 */
function callRpc(service, method, data) {
  return new Promise(function (resolve, reject) {
    var startIndex = activeUrlIndex
    var tried = 0

    function attempt(index) {
      if (tried >= API_URLS.length) {
        reject(new Error('API 连接失败，请确认后端服务已启动 (端口 3000)'))
        return
      }

      var currentUrl = API_URLS[index] + '/' + service + '/' + method

      wx.request({
        url: currentUrl,
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
            activeUrlIndex = index
            var result = (res.data && res.data.result) ? res.data.result : res.data
            resolve(result)
          } else {
            // HTTP 错误也重试下一个 URL
            tried++
            attempt((index + 1) % API_URLS.length)
          }
        },
        fail: function () {
          tried++
          attempt((index + 1) % API_URLS.length)
        }
      })
    }

    attempt(startIndex)
  })
}

function testConnection() {
  return callRpc('highschool.v1.ReferenceService', 'GetDistricts', {})
    .then(function () {
      return {
        ok: true,
        msg: 'API 连接正常',
        url: API_URLS[activeUrlIndex]
      }
    })
    .catch(function (err) {
      return {
        ok: false,
        msg: err.message || 'API 连接失败',
        url: API_URLS[activeUrlIndex]
      }
    })
}

module.exports = {
  callRpc: callRpc,
  testConnection: testConnection,
  getActiveUrl: function () { return API_URLS[activeUrlIndex] },
  API_URLS: API_URLS
}
