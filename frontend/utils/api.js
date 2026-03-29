/**
 * Connect-RPC JSON 客户端
 * 使用 wx.request 直接调用 Connect-RPC JSON 端点
 *
 * 支持多个备选 URL，自动重试
 */

var API_URLS = [
  'http://127.0.0.1:3000',
  'http://localhost:3000',
  'http://[::1]:3000'
]

var activeUrlIndex = 0

function getActiveUrl() {
  return API_URLS[activeUrlIndex]
}

/**
 * 尝试依次请求多个 URL
 */
function tryRequest(url, requestData, resolve, reject, urlIndex) {
  if (urlIndex >= API_URLS.length) {
    reject(new Error('所有 API 地址均连接失败，请确认后端服务已启动'))
    return
  }

  var currentUrl = API_URLS[urlIndex] + '/' + requestData.service + '/' + requestData.method

  wx.request({
    url: currentUrl,
    method: 'POST',
    data: requestData.body || {},
    timeout: 8000,
    dataType: 'json',
    responseType: 'text',
    header: {
      'Content-Type': 'application/json'
    },
    success: function (res) {
      if (res.statusCode === 200) {
        activeUrlIndex = urlIndex
        var result = (res.data && res.data.result) ? res.data.result : res.data
        resolve(result)
      } else {
        var errMsg = '请求失败 (' + res.statusCode + ')'
        if (res.data && res.data.message) {
          errMsg = res.data.message
        }
        reject(new Error(errMsg))
      }
    },
    fail: function (err) {
      // 当前 URL 失败，尝试下一个
      tryRequest(url, requestData, resolve, reject, urlIndex + 1)
    }
  })
}

/**
 * 调用 Connect-RPC 服务方法
 * @param {string} service - 服务名
 * @param {string} method - 方法名
 * @param {object} data - 请求体
 * @returns {Promise<object>}
 */
function callRpc(service, method, data) {
  var requestData = {
    service: service,
    method: method,
    body: data || {}
  }

  return new Promise(function (resolve, reject) {
    // 优先使用上次成功的 URL
    var startIndex = activeUrlIndex
    // 先尝试活跃 URL
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
            var errMsg = '请求失败 (' + res.statusCode + ')'
            if (res.data && res.data.message) {
              errMsg = res.data.message
            }
            reject(new Error(errMsg))
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

/**
 * 测试 API 连通性
 * @returns {Promise<{ok: boolean, msg: string, url: string}>}
 */
function testConnection() {
  return callRpc('highschool.v1.ReferenceService', 'GetDistricts', {})
    .then(function (result) {
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
  getActiveUrl: getActiveUrl,
  API_URLS: API_URLS
}
