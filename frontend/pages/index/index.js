Page({
  data: {},

  onStartAnalysis() {
    wx.switchTab({ url: '/pages/form/form' })
  },

  onViewHistory() {
    wx.switchTab({ url: '/pages/history/history' })
  }
})
