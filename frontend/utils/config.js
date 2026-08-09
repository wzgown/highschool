/**
 * config.js — 远程应用配置（功能开关）
 * GET {base}/app-config?version=x.y.z → { agent_enabled, tip_url }
 * 缓存：globalData 内存 + storage（5 分钟 TTL）。
 * 拉取失败时默认 agentEnabled=false（审核安全：宁可暂时隐藏）。
 */

var api = require('./api.js')

var CACHE_KEY = 'appConfigCache'
var CACHE_TTL = 5 * 60 * 1000

var DEFAULT_CONFIG = {
  agentEnabled: false,
  tipUrl: '',
  agentUi: null
}

function readCache() {
  var app = getApp()
  if (app && app.globalData && app.globalData.appConfig) {
    var c = app.globalData.appConfig
    if (Date.now() - c.fetchedAt < CACHE_TTL) return c
  }
  try {
    var stored = wx.getStorageSync(CACHE_KEY)
    if (stored && stored.fetchedAt && Date.now() - stored.fetchedAt < CACHE_TTL) {
      return stored
    }
  } catch (e) {}
  return null
}

function writeCache(cfg) {
  var app = getApp()
  if (app && app.globalData) {
    app.globalData.appConfig = cfg
  }
  try {
    wx.setStorageSync(CACHE_KEY, cfg)
  } catch (e) {}
}

/**
 * 获取应用配置（优先缓存）。返回 Promise<{agentEnabled, tipUrl}>
 */
function fetchAppConfig(force) {
  if (!force) {
    var cached = readCache()
    if (cached) return Promise.resolve(cached)
  }
  var app = getApp()
  var version = (app && app.globalData && app.globalData.version) || ''
  var url = api.getActiveUrl() + '/app-config'
  if (version) {
    url += '?version=' + encodeURIComponent(version)
  }
  return new Promise(function (resolve) {
    wx.request({
      url: url,
      method: 'GET',
      dataType: 'json',
      timeout: 3000,
      success: function (res) {
        if (res.statusCode === 200 && res.data) {
          var cfg = {
            agentEnabled: !!res.data.agent_enabled,
            tipUrl: res.data.tip_url || '',
            agentUi: res.data.agent_ui || null,
            fetchedAt: Date.now()
          }
          writeCache(cfg)
          resolve(cfg)
        } else {
          resolve(Object.assign({ fetchedAt: Date.now() }, DEFAULT_CONFIG))
        }
      },
      fail: function () {
        resolve(Object.assign({ fetchedAt: Date.now() }, DEFAULT_CONFIG))
      }
    })
  })
}

module.exports = {
  fetchAppConfig: fetchAppConfig
}
