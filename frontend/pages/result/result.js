var candidate = require('../../utils/candidate')
var format = require('../../utils/format')

Page({
  data: {
    loading: true,
    error: null,
    id: '',
    result: null,
    // 展示数据（已从 proto 字段映射）
    predictions: null,
    probabilities: [],
    strategy: null,
    competitors: null
  },

  onLoad: function (options) {
    if (options.id) {
      this.setData({ id: options.id })
      this.loadResult()
    }
  },

  loadResult: function () {
    var self = this
    self.setData({ loading: true, error: null })

    candidate.pollAnalysisResult(self.data.id, 10, 3000)
      .then(function (result) {
        var results = result.results || {}
        var rawPredictions = results.predictions || null
        var rawProbabilities = results.probabilities || []
        var rawStrategy = results.strategy || null
        var rawCompetitors = results.competitors || null

        // 映射排名预测（proto 字段 -> 模板字段）
        var predictions = null
        if (rawPredictions) {
          predictions = {
            districtRank: rawPredictions.districtRank,
            rankLow: rawPredictions.districtRankRangeLow,
            rankHigh: rawPredictions.districtRankRangeHigh,
            confidence: rawPredictions.confidence,
            percentile: rawPredictions.percentile
          }
        }

        // 映射录取概率
        var probabilities = rawProbabilities.map(function (p) {
          var prob = (p.probability !== undefined && p.probability !== null)
            ? Math.round(p.probability) : 0
          return {
            batch: p.batch,
            schoolId: p.schoolId,
            schoolName: p.schoolName,
            schoolCode: p.schoolCode || '',
            probability: prob,
            riskLevel: p.riskLevel || 'unknown',
            scoreDiff: (p.scoreDiff !== undefined && p.scoreDiff !== null) ? p.scoreDiff : null,
            volunteerIndex: p.volunteerIndex || 0,
            batchName: self._getBatchName(p.batch),
            batchType: self._getBatchType(p.batch),
            riskText: self._getRiskText(p.riskLevel),
            riskType: self._getRiskType(p.riskLevel)
          }
        })

        // 映射策略分析
        var strategy = null
        if (rawStrategy) {
          var gradient = rawStrategy.gradient || {}
          strategy = {
            score: rawStrategy.score,
            reach: gradient.reach || 0,
            target: gradient.target || 0,
            safety: gradient.safety || 0,
            suggestions: rawStrategy.suggestions || [],
            warnings: rawStrategy.warnings || []
          }
        }

        // 映射竞争分析
        var competitors = null
        if (rawCompetitors) {
          var rawDist = rawCompetitors.scoreDistribution || []
          var maxCount = 1
          rawDist.forEach(function (d) {
            var c = d.count || 0
            if (c > maxCount) maxCount = c
          })
          competitors = {
            count: rawCompetitors.count || 0,
            distributions: rawDist.map(function (d) {
              var c = d.count || 0
              return {
                range: d.range,
                count: c,
                percent: Math.round((c / maxCount) * 100)
              }
            })
          }
        }

        self.setData({
          loading: false,
          result: result,
          predictions: predictions,
          probabilities: probabilities,
          strategy: strategy,
          competitors: competitors
        })
      })
      .catch(function (err) {
        self.setData({
          loading: false,
          error: (err && err.message) || '分析失败'
        })
      })
  },

  _getBatchName: function (batch) {
    if (batch && batch.indexOf('UNIFIED') === 0) return '统一招生'
    var map = { QUOTA_DISTRICT: '名额分配到区', QUOTA_SCHOOL: '名额分配到校' }
    return map[batch] || batch
  },

  _getBatchType: function (batch) {
    if (batch && batch.indexOf('UNIFIED') === 0) return 'warning'
    var map = { QUOTA_DISTRICT: 'primary', QUOTA_SCHOOL: 'success' }
    return map[batch] || 'info'
  },

  _getRiskText: function (risk) {
    var map = { safe: '安全', moderate: '稳妥', risky: '冲刺', high_risk: '高风险', unknown: '待评估' }
    return map[risk] || '待评估'
  },

  _getRiskType: function (risk) {
    var map = { safe: 'success', moderate: 'warning', risky: 'danger', high_risk: 'info', unknown: 'info' }
    return map[risk] || 'info'
  },

  goBack: function () {
    wx.switchTab({ url: '/pages/form/form' })
  },

  viewHistory: function () {
    wx.switchTab({ url: '/pages/history/history' })
  },

  onRetry: function () {
    this.loadResult()
  }
})
