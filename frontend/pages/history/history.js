/**
 * 历史记录页面
 */

var candidate = require('../../utils/candidate')
var format = require('../../utils/format')

Page({
  data: {
    loading: true,
    histories: [],
    total: 0,
    isEmpty: false
  },

  onShow: function () {
    this.loadHistory()
  },

  loadHistory: function () {
    var self = this
    self.setData({ loading: true })

    candidate.getHistory().then(function (result) {
      var histories = (result.histories || []).map(function (h) {
        return {
          id: h.id,
          createdAt: h.createdAt,
          createdTime: format.formatTime(h.createdAt),
          totalScore: h.totalScore || 0,
          districtName: h.districtName || '',
          summary: h.summary || { totalVolunteers: 0, safeCount: 0, moderateCount: 0, riskyCount: 0 }
        }
      })

      self.setData({
        loading: false,
        histories: histories,
        total: result.total,
        isEmpty: histories.length === 0
      })
    }).catch(function () {
      self.setData({ loading: false, isEmpty: true })
      wx.showToast({ title: '加载失败', icon: 'none' })
    })
  },

  onViewDetail: function (e) {
    var id = e.currentTarget.dataset.id
    wx.navigateTo({ url: '/pages/result/result?id=' + id })
  },

  onDelete: function (e) {
    var self = this
    var id = e.currentTarget.dataset.id

    wx.showModal({
      title: '确认删除',
      content: '确定要删除这条记录吗？',
      success: function (res) {
        if (res.confirm) {
          candidate.deleteHistory(id).then(function () {
            wx.showToast({ title: '已删除', icon: 'success' })
            self.loadHistory()
          }).catch(function () {
            wx.showToast({ title: '删除失败', icon: 'none' })
          })
        }
      }
    })
  },

  onStartAnalysis: function () {
    wx.switchTab({ url: '/pages/form/form' })
  },

  onRefresh: function () {
    this.loadHistory()
  }
})
