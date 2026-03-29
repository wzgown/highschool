App({
  globalData: {
    apiBaseUrl: 'http://localhost:3000',
    formData: null,
    analysisId: null
  },

  onLaunch() {
    const envVersion = __wxConfig ? __wxConfig.envVersion : 'develop'
    if (envVersion === 'release') {
      this.globalData.apiBaseUrl = 'https://api.shhighschool.example.com'
    }
  }
})
