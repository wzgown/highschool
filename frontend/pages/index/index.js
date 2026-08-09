Page({
  onShow: function () {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 0 })
    }
  },

  onStartAnalysis: function () {
    wx.navigateTo({ url: '/pages/form/form' })
  },

  onSmartRecommend: function () {
    wx.navigateTo({ url: '/pages/recommendation/recommendation' })
  },

  onViewHistory: function () {
    wx.switchTab({ url: '/pages/history/history' })
  },

  goAbout: function () {
    wx.navigateTo({ url: '/pages/about/about' })
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
