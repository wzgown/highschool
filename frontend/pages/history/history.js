const { getHistory, deleteHistory } = require('../../utils/candidate')
const { formatTime } = require('../../utils/format')

Page({
  data: {
    loading: true,
    histories: [],
    total: 0,
    isEmpty: false
  },

  onShow() {
    this.loadHistory()
  },

  async loadHistory() {
    this.setData({ loading: true })
    try {
      const { histories, total } = await getHistory()
      this.setData({
        loading: false,
        histories: histories.map(h => ({
          ...h,
          createdTime: formatTime(h.createdAt),
          summary: h.summary || { totalVolunteers: 0, safeCount: 0, moderateCount: 0, riskyCount: 0 }
        })),
        total,
        isEmpty: histories.length === 0
      })
    } catch (err) {
      this.setData({ loading: false, isEmpty: true })
      wx.showToast({ title: '加载失败', icon: 'none' })
    }
  },

  onViewDetail(e) {
    const id = e.currentTarget.dataset.id
    wx.navigateTo({ url: `/pages/result/result?id=${id}` })
  },

  onDelete(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '确认删除',
      content: '确定要删除这条记录吗？',
      success: async (res) => {
        if (res.confirm) {
          try {
            await deleteHistory(id)
            wx.showToast({ title: '已删除', icon: 'success' })
            this.loadHistory()
          } catch (err) {
            wx.showToast({ title: '删除失败', icon: 'none' })
          }
        }
      }
    })
  },

  onStartAnalysis() {
    wx.switchTab({ url: '/pages/form/form' })
  },

  onRefresh() {
    this.loadHistory()
  }
})
