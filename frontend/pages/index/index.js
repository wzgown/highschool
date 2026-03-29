var api = require('../../utils/api')

Page({
  data: {
    connectionStatus: '',
    connectionTesting: false,
    connectionUrl: ''
  },

  onLoad: function () {
    this._testApiConnection()
  },

  onShow: function () {
    // tabBar 页面每次显示时检测
    if (!this.data.connectionStatus || this.data.connectionStatus === 'fail') {
      this._testApiConnection()
    }
  },

  _testApiConnection: function () {
    var that = this
    that.setData({ connectionTesting: true, connectionStatus: 'testing' })

    api.testConnection().then(function (result) {
      that.setData({
        connectionTesting: false,
        connectionStatus: result.ok ? 'ok' : 'fail',
        connectionUrl: result.url || ''
      })
    })
  },

  onStartAnalysis: function () {
    wx.switchTab({ url: '/pages/form/form' })
  },

  onSmartRecommend: function () {
    wx.navigateTo({ url: '/pages/recommendation/recommendation' })
  },

  onViewHistory: function () {
    wx.switchTab({ url: '/pages/history/history' })
  },

  onRetryConnection: function () {
    this._testApiConnection()
  }
})
