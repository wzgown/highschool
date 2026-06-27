var api = require('../../utils/api.js')

Component({
  options: {
    addGlobalClass: true
  },

  data: {
    expanded: false,
    tipQrUrl: ''
  },

  lifetimes: {
    attached: function () {
      this.fetchTipQr()
    }
  },

  methods: {
    fetchTipQr: function () {
      var app = getApp()
      var version = (app && app.globalData && app.globalData.version) || ''
      var url = api.getActiveUrl() + '/tip-config'
      if (version) {
        url += '?version=' + encodeURIComponent(version)
      }

      var that = this
      wx.request({
        url: url,
        method: 'GET',
        dataType: 'json',
        timeout: 3000,
        success: function (res) {
          if (res.statusCode === 200 && res.data && res.data.url) {
            that.setData({ tipQrUrl: res.data.url })
          }
        },
        fail: function () {}
      })
    },

    onToggle: function () {
      this.setData({ expanded: !this.data.expanded })
    }
  }
})
