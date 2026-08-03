var appConfig = require('../utils/config')

// 基础 tab（任何时候都显示）；AI 顾问 tab 仅在远程配置开启时追加
var BASE_TABS = [
  {
    pagePath: 'pages/index/index',
    text: '首页',
    iconPath: '/images/home.png',
    selectedIconPath: '/images/home-active.png'
  },
  {
    pagePath: 'pages/history/history',
    text: '历史',
    iconPath: '/images/history.png',
    selectedIconPath: '/images/history-active.png'
  }
]

var AGENT_TAB = {
  pagePath: 'pages/chat/chat',
  text: '顾问',
  iconPath: '/images/chat.png',
  selectedIconPath: '/images/chat-active.png'
}

Component({
  data: {
    selected: 0,
    list: BASE_TABS.slice()
  },

  lifetimes: {
    attached: function () {
      var self = this
      appConfig.fetchAppConfig().then(function (cfg) {
        if (cfg.agentEnabled && self.data.list.length === BASE_TABS.length) {
          self.setData({ list: BASE_TABS.concat([AGENT_TAB]) })
        }
      })
    }
  },

  methods: {
    switchTab: function (e) {
      var path = e.currentTarget.dataset.path
      wx.switchTab({ url: '/' + path })
    }
  }
})
