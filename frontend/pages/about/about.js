var appConfig = require('../../utils/config')

Page({
  data: {
    agentEnabled: false
  },

  onLoad: function () {
    var self = this
    appConfig.fetchAppConfig().then(function (cfg) {
      self.setData({ agentEnabled: cfg.agentEnabled })
    })
  },

  onShareAppMessage: function () {
    return {
      title: '折桂登高 - 中考志愿模拟分析',
      path: '/pages/index/index'
    }
  },

  onShareTimeline: function () {
    return {
      title: '折桂登高 - 智能分析录取概率，优化志愿填报策略'
    }
  }
})
