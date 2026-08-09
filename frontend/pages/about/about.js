var appConfig = require('../../utils/config')

Page({
  data: {
    agentEnabled: false,
    aiCardTitle: '',
    aiLines: []
  },

  onLoad: function () {
    var self = this
    appConfig.fetchAppConfig().then(function (cfg) {
      var ui = cfg.agentUi || {}
      self.setData({
        agentEnabled: cfg.agentEnabled,
        aiCardTitle: ui.about_title || '',
        aiLines: [
          { label: ui.about_1_label || '', value: ui.about_1_value || '' },
          { label: ui.about_2_label || '', value: ui.about_2_value || '' },
          { label: ui.about_3_label || '', value: ui.about_3_value || '' }
        ]
      })
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
      title: '折桂登高 - 录取概率分析，优化志愿填报策略'
    }
  }
})
