var appConfig = require('../utils/config')

// 基础 tab（任何时候都显示）；顾问 tab 仅在远程配置开启时追加，文案由后端下发
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
  text: '',
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
          var tab = Object.assign({}, AGENT_TAB, {
            text: (cfg.agentUi && cfg.agentUi.tab) || '顾问'
          })
          self.setData({ list: BASE_TABS.concat([tab]) })
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
