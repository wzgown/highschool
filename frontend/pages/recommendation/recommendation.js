/**
 * 智能志愿推荐页面 - 3步向导
 * Step 0: 基本信息（区县、初中、名额分配到校资格）
 * Step 1: 模考成绩（一模、二模）
 * Step 2: 推荐结果
 */

var reference = require('../../utils/reference')

// 区总分配置：{ firstMock: 一模总分, secondMock: 二模总分 }
var DISTRICT_SCORE_CONFIG = {
  1: { firstMock: 700, secondMock: 605 }, // 徐汇
  2: { firstMock: 645, secondMock: 615 }, // 杨浦
  3: { firstMock: 645, secondMock: 615 }, // 闵行
  4: { firstMock: 645, secondMock: 615 }, // 松江
  5: { firstMock: 645, secondMock: 605 }, // 浦东
  6: { firstMock: 615, secondMock: 615 }, // 黄浦
  7: { firstMock: 615, secondMock: 615 }, // 宝山
  8: { firstMock: 615, secondMock: 615 }, // 奉贤
  9: { firstMock: 635, secondMock: 615 }, // 虹口
  10: { firstMock: 635, secondMock: 605 }, // 普陀
  11: { firstMock: 635, secondMock: 605 }, // 长宁
  12: { firstMock: 630, secondMock: 605 }, // 静安
  13: { firstMock: 635, secondMock: 605 }, // 嘉定
  14: { firstMock: 605, secondMock: 605 }, // 青浦
  15: { firstMock: 605, secondMock: 605 }, // 金山
  16: { firstMock: 605, secondMock: 605 }  // 崇明
}

var DEFAULT_SCORE_CONFIG = { firstMock: 615, secondMock: 615 }

function getScoreConfig(districtId) {
  return DISTRICT_SCORE_CONFIG[districtId] || DEFAULT_SCORE_CONFIG
}

function toFixed1(n) {
  if (typeof n !== 'number' || isNaN(n)) return '0.0'
  var s = Math.round(n * 10) / 10
  var parts = s.toString().split('.')
  return parts[0] + '.' + (parts[1] || '0').charAt(0)
}

Page({
  data: {
    currentStep: 0,
    loading: false,

    // 下拉选项
    districts: [],
    middleSchools: [],

    // 表单数据
    districtId: null,
    districtName: '',
    middleSchoolId: null,
    middleSchoolName: '',
    hasQuotaSchoolEligibility: true,

    // 模考成绩
    firstMockHasScore: true,
    firstMockTotalScore: 0,
    firstMockDistrictRank: 0,
    secondMockHasScore: true,
    secondMockTotalScore: 0,
    secondMockDistrictRank: 0,

    // 分数转换（用于显示）
    firstMockMax: 615,
    secondMockMax: 615,
    firstMockConverted: '',
    secondMockConverted: '',

    // 校验状态
    canNext: false,
    canSubmit: false,

    // 推荐结果
    activeResultTab: 'firstMock',
    firstMockResults: null,
    secondMockResults: null
  },

  onLoad: function () {
    this._loadDistricts()
  },

  // ======== 数据加载 ========

  _loadDistricts: function () {
    var self = this
    reference.getDistricts().then(function (res) {
      var districts = (res.districts || []).map(function (d) {
        return { id: d.id, name: d.name, code: d.code || '' }
      })
      self.setData({ districts: districts })
    }).catch(function () {
      wx.showToast({ title: '加载区县失败', icon: 'none' })
    })
  },

  _loadMiddleSchools: function (districtId) {
    var self = this
    reference.getMiddleSchools(districtId).then(function (res) {
      var middleSchools = (res.middleSchools || []).map(function (s) {
        return { id: s.id, name: s.name, code: s.code || '' }
      })
      self.setData({ middleSchools: middleSchools })
    }).catch(function () {
      wx.showToast({ title: '加载初中列表失败', icon: 'none' })
    })
  },

  // ======== 区县/学校选择 ========

  onDistrictChange: function (e) {
    var index = Number(e.detail.value)
    var district = this.data.districts[index]
    if (!district) return

    var config = getScoreConfig(district.id)

    this.setData({
      districtId: district.id,
      districtName: district.name,
      middleSchoolId: null,
      middleSchoolName: '',
      middleSchools: [],
      firstMockMax: config.firstMock,
      secondMockMax: config.secondMock,
      firstMockTotalScore: 0,
      secondMockTotalScore: 0,
      firstMockConverted: '',
      secondMockConverted: ''
    })

    this._loadMiddleSchools(district.id)
    this._validateCurrentStep()
  },

  onMiddleSchoolChange: function (e) {
    var index = Number(e.detail.value)
    var school = this.data.middleSchools[index]
    if (!school) return

    this.setData({
      middleSchoolId: school.id,
      middleSchoolName: school.name
    })
  },

  onQuotaEligibilityChange: function (e) {
    this.setData({
      hasQuotaSchoolEligibility: e.detail.value
    })
  },

  // ======== 模考成绩输入 ========

  onFirstMockToggle: function (e) {
    this.setData({ firstMockHasScore: e.detail.value })
    this._updateConversion('first')
    this._validateCurrentStep()
  },

  onSecondMockToggle: function (e) {
    this.setData({ secondMockHasScore: e.detail.value })
    this._updateConversion('second')
    this._validateCurrentStep()
  },

  onFirstMockScoreInput: function (e) {
    var value = Math.max(0, Number(e.detail.value) || 0)
    this.setData({ firstMockTotalScore: value })
    this._updateConversion('first')
    this._validateCurrentStep()
  },

  onSecondMockScoreInput: function (e) {
    var value = Math.max(0, Number(e.detail.value) || 0)
    this.setData({ secondMockTotalScore: value })
    this._updateConversion('second')
    this._validateCurrentStep()
  },

  onFirstMockRankInput: function (e) {
    this.setData({ firstMockDistrictRank: Math.max(0, Number(e.detail.value) || 0) })
  },

  onSecondMockRankInput: function (e) {
    this.setData({ secondMockDistrictRank: Math.max(0, Number(e.detail.value) || 0) })
  },

  _updateConversion: function (type) {
    if (type === 'first') {
      var score = this.data.firstMockTotalScore
      var max = this.data.firstMockMax
      if (this.data.firstMockHasScore && score > 0 && max > 0) {
        var converted = (score / max) * 750
        this.setData({ firstMockConverted: toFixed1(converted) })
      } else {
        this.setData({ firstMockConverted: '' })
      }
    } else {
      var score2 = this.data.secondMockTotalScore
      var max2 = this.data.secondMockMax
      if (this.data.secondMockHasScore && score2 > 0 && max2 > 0) {
        var converted2 = (score2 / max2) * 750
        this.setData({ secondMockConverted: toFixed1(converted2) })
      } else {
        this.setData({ secondMockConverted: '' })
      }
    }
  },

  // ======== 校验逻辑 ========

  _validateCurrentStep: function () {
    if (this.data.currentStep === 0) {
      this._validateStep0()
    } else if (this.data.currentStep === 1) {
      this._validateStep1()
    }
  },

  _validateStep0: function () {
    var canNext = !!this.data.districtId
    this.setData({ canNext: canNext })
  },

  _validateStep1: function () {
    var d = this.data
    var hasFirst = d.firstMockHasScore && d.firstMockTotalScore > 0
    var hasSecond = d.secondMockHasScore && d.secondMockTotalScore > 0
    this.setData({ canSubmit: hasFirst || hasSecond })
  },

  // ======== 步骤导航 ========

  nextStep: function () {
    if (!this.data.canNext) return
    var nextStep = this.data.currentStep + 1
    this.setData({ currentStep: nextStep })

    if (nextStep === 1) {
      this._validateStep1()
    }
  },

  prevStep: function () {
    if (this.data.currentStep <= 0) return
    this.setData({ currentStep: this.data.currentStep - 1 })
    this._validateCurrentStep()
  },

  // ======== 获取推荐 ========

  onSubmit: function () {
    var self = this
    var d = self.data

    var hasFirst = d.firstMockHasScore && d.firstMockTotalScore > 0
    var hasSecond = d.secondMockHasScore && d.secondMockTotalScore > 0

    if (!hasFirst && !hasSecond) {
      wx.showToast({ title: '请至少填写一项模考成绩', icon: 'none' })
      return
    }

    self.setData({ loading: true })
    wx.showLoading({ title: '生成推荐中...' })

    var promises = []

    if (hasFirst) {
      promises.push(
        reference.getVolunteerRecommendations({
          districtId: d.districtId,
          middleSchoolId: d.middleSchoolId || undefined,
          examType: 1,
          totalScore: d.firstMockTotalScore,
          hasQuotaSchoolEligibility: d.hasQuotaSchoolEligibility,
          year: 2025
        }).then(function (res) {
          return { type: 'firstMock', data: res }
        })
      )
    }

    if (hasSecond) {
      promises.push(
        reference.getVolunteerRecommendations({
          districtId: d.districtId,
          middleSchoolId: d.middleSchoolId || undefined,
          examType: 2,
          totalScore: d.secondMockTotalScore,
          hasQuotaSchoolEligibility: d.hasQuotaSchoolEligibility,
          year: 2025
        }).then(function (res) {
          return { type: 'secondMock', data: res }
        })
      )
    }

    Promise.all(promises).then(function (results) {
      wx.hideLoading()

      var firstMockResults = null
      var secondMockResults = null
      var activeTab = 'firstMock'

      for (var i = 0; i < results.length; i++) {
        var r = results[i]
        var mapped = self._mapRecommendations(r.data)
        if (r.type === 'firstMock') {
          firstMockResults = mapped
        } else {
          secondMockResults = mapped
          activeTab = 'secondMock'
        }
      }

      self.setData({
        loading: false,
        currentStep: 2,
        firstMockResults: firstMockResults,
        secondMockResults: secondMockResults,
        activeResultTab: activeTab
      })
    }).catch(function (err) {
      wx.hideLoading()
      self.setData({ loading: false })
      wx.showToast({
        title: (err && err.message) || '获取推荐失败',
        icon: 'none',
        duration: 3000
      })
    })
  },

  _mapRecommendations: function (raw) {
    var conversion = raw.scoreConversion || null
    var conversionDisplay = null
    if (conversion) {
      conversionDisplay = {
        originalScore: toFixed1(conversion.originalScore || 0),
        convertedScore750: toFixed1(conversion.convertedScore_750 || 0),
        convertedScore800: toFixed1(conversion.convertedScore_800 || 0)
      }
    }

    return {
      scoreConversion: conversionDisplay,
      quotaDistrictRecommendations: this._mapSchools(raw.quotaDistrictRecommendations || []),
      quotaSchoolRecommendations: this._mapSchools(raw.quotaSchoolRecommendations || []),
      unifiedRecommendations: this._mapSchools(raw.unifiedRecommendations || [])
    }
  },

  _mapSchools: function (list) {
    return list.map(function (s) {
      return {
        schoolId: s.schoolId,
        schoolName: s.schoolName || '',
        schoolCode: s.schoolCode || '',
        estimatedScore: s.estimatedScore || 0,
        scoreGap: s.scoreGap || 0,
        confidence: s.confidence || '',
        recommendationType: s.recommendationType || 'TARGET',
        recommendationReason: s.recommendationReason || '',
        typeTag: s.recommendationType === 'REACH' ? 'danger'
          : s.recommendationType === 'SAFETY' ? 'success'
          : 'warning',
        typeText: s.recommendationType === 'REACH' ? '冲刺'
          : s.recommendationType === 'SAFETY' ? '保底'
          : '稳妥'
      }
    })
  },

  // ======== 结果 Tab 切换 ========

  onTabChange: function (e) {
    var tab = e.currentTarget.dataset.tab
    this.setData({ activeResultTab: tab })
  },

  // ======== 操作 ========

  goToSimulation: function () {
    wx.switchTab({ url: '/pages/form/form' })
  },

  onReset: function () {
    this.setData({
      currentStep: 0,
      districtId: null,
      districtName: '',
      middleSchoolId: null,
      middleSchoolName: '',
      hasQuotaSchoolEligibility: true,
      firstMockHasScore: true,
      firstMockTotalScore: 0,
      firstMockDistrictRank: 0,
      secondMockHasScore: true,
      secondMockTotalScore: 0,
      secondMockDistrictRank: 0,
      firstMockConverted: '',
      secondMockConverted: '',
      canNext: false,
      canSubmit: false,
      loading: false,
      firstMockResults: null,
      secondMockResults: null,
      activeResultTab: 'firstMock'
    })
  }
})
