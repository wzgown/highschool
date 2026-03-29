App({
  globalData: {
    apiBaseUrl: 'http://127.0.0.1:3000',
    formData: null,
    analysisId: null
  },

  onLaunch() {
    // __wxConfig 在真机环境可能不存在
    var envVersion = 'develop'
    try {
      if (typeof __wxConfig !== 'undefined' && __wxConfig) {
        envVersion = __wxConfig.envVersion || 'develop'
      }
    } catch (e) {
      // 开发工具环境，使用默认值
    }

    if (envVersion === 'release') {
      this.globalData.apiBaseUrl = 'https://api.shhighschool.example.com'
    }
  }
})
