App({
  globalData: {
    apiBaseUrl: 'https://zg.mkfriend.top',
    version: '1.7',
    formData: null,
    analysisId: null,
    pendingAnalysisId: null
  },

  onLaunch() {
    var envVersion = 'develop'
    try {
      if (typeof __wxConfig !== 'undefined' && __wxConfig) {
        envVersion = __wxConfig.envVersion || 'develop'
      }
    } catch (e) {}

    this.globalData.apiBaseUrl = 'https://zg.mkfriend.top'
  }
})
