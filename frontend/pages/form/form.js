/**
 * 志愿填报页面 - 3步向导表单
 * Step 0: 基本信息（区县、初中、名额分配到校资格）
 * Step 1: 成绩信息（总分、各科成绩、校内排名）
 * Step 2: 志愿填报（名额到区、名额到校、统一招生）
 */

var reference = require('../../utils/reference')
var candidate = require('../../utils/candidate')
var storage = require('../../utils/storage')
var constants = require('../../utils/constants')

var SCORE_LIMITS = constants.SCORE_LIMITS

var EMPTY_SCORES = {
  total: 0,
  chinese: 0,
  math: 0,
  foreign: 0,
  integrated: 0,
  ethics: 0,
  history: 0,
  pe: 0
}

function cloneScores(s) {
  return {
    total: s.total || 0,
    chinese: s.chinese || 0,
    math: s.math || 0,
    foreign: s.foreign || 0,
    integrated: s.integrated || 0,
    ethics: s.ethics || 0,
    history: s.history || 0,
    pe: s.pe || 0
  }
}

function cloneRanking(r) {
  return { rank: r.rank || 0, totalStudents: r.totalStudents || 0 }
}

Page({
  data: {
    currentStep: 0,
    submitting: false,

    // 下拉选项
    districts: [],
    middleSchools: [],
    quotaDistrictSchools: [],
    quotaSchoolSchools: [],
    unifiedSchools: [],

    // 表单数据
    districtId: null,
    districtName: '',
    middleSchoolId: null,
    middleSchoolName: '',
    hasQuotaSchoolEligibility: false,

    scores: cloneScores(EMPTY_SCORES),
    comprehensiveQuality: 50,
    ranking: { rank: 0, totalStudents: 0 },

    volunteers: {
      quotaDistrict: null,
      quotaSchool: [0, 0],
      unified: new Array(15).fill(0)
    },

    // 学校名称（用于模板展示）
    volunteerNames: {
      quotaDistrict: '',
      quotaSchool0: '',
      quotaSchool1: '',
      unified: new Array(15).fill('')
    },

    // 校验状态
    canNext: false,
    canSubmit: false,
    scoreValidation: { valid: true, message: '' },
    rankValidation: { valid: true, message: '' },

    // 学校选择器
    showSchoolPicker: false,
    pickerType: '',
    pickerSchools: [],
    pickerSearch: ''
  },

  // ======== 生命周期 ========

  onLoad: function () {
    this._loadDistricts()
    this._restoreForm()
  },

  onUnload: function () {
    this._saveForm()
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

  _restoreForm: function () {
    var saved = storage.loadFormData()
    if (!saved) return

    this.setData({
      districtId: saved.districtId || null,
      districtName: saved.districtName || '',
      middleSchoolId: saved.middleSchoolId || null,
      middleSchoolName: saved.middleSchoolName || '',
      hasQuotaSchoolEligibility: saved.hasQuotaSchoolEligibility || false,
      scores: saved.scores ? cloneScores(saved.scores) : cloneScores(EMPTY_SCORES),
      comprehensiveQuality: saved.comprehensiveQuality || 50,
      ranking: saved.ranking ? cloneRanking(saved.ranking) : { rank: 0, totalStudents: 0 },
      volunteers: {
        quotaDistrict: (saved.volunteers && saved.volunteers.quotaDistrict) || null,
        quotaSchool: (saved.volunteers && saved.volunteers.quotaSchool) || [0, 0],
        unified: (saved.volunteers && saved.volunteers.unified) || new Array(15).fill(0)
      }
    })

    if (saved.districtId) {
      this._loadMiddleSchools(saved.districtId)
    }

    this._validateCurrentStep()
  },

  _saveForm: function () {
    var formData = {
      districtId: this.data.districtId,
      districtName: this.data.districtName,
      middleSchoolId: this.data.middleSchoolId,
      middleSchoolName: this.data.middleSchoolName,
      hasQuotaSchoolEligibility: this.data.hasQuotaSchoolEligibility,
      scores: cloneScores(this.data.scores),
      comprehensiveQuality: this.data.comprehensiveQuality,
      ranking: cloneRanking(this.data.ranking),
      volunteers: {
        quotaDistrict: this.data.volunteers.quotaDistrict,
        quotaSchool: this.data.volunteers.quotaSchool.slice(),
        unified: this.data.volunteers.unified.slice()
      }
    }
    storage.saveFormData(formData)
  },

  // ======== 区县/学校选择 ========

  onDistrictChange: function (e) {
    var index = Number(e.detail.value)
    var district = this.data.districts[index]
    if (!district) return

    // 切换区县时清除所有关联数据
    this.setData({
      districtId: district.id,
      districtName: district.name,
      middleSchoolId: null,
      middleSchoolName: '',
      middleSchools: [],
      // 清除志愿数据（区县变更后志愿失效）
      volunteers: {
        quotaDistrict: null,
        quotaSchool: [0, 0],
        unified: new Array(15).fill(0)
      },
      volunteerNames: {
        quotaDistrict: '',
        quotaSchool0: '',
        quotaSchool1: '',
        unified: new Array(15).fill('')
      },
      quotaDistrictSchools: [],
      quotaSchoolSchools: [],
      unifiedSchools: []
    })

    this._loadMiddleSchools(district.id)
    this._validateCurrentStep()
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

  onMiddleSchoolChange: function (e) {
    var index = Number(e.detail.value)
    var school = this.data.middleSchools[index]
    if (!school) return

    this.setData({
      middleSchoolId: school.id,
      middleSchoolName: school.name
    })
    this._validateCurrentStep()
  },

  onQuotaEligibilityChange: function (e) {
    this.setData({
      hasQuotaSchoolEligibility: e.detail.value
    })
  },

  // ======== 成绩输入 ========

  onScoreInput: function (e) {
    var field = e.currentTarget.dataset.field
    var raw = e.detail.value

    // 允许输入中的状态（如 "669." "669.5"）
    if (field === 'total') {
      if (raw && !/^\d*\.?\d*$/.test(raw)) {
        return
      }
      var updates = {}
      updates['scores.' + field] = raw
      this.setData(updates)
    } else {
      var value = Math.max(0, Number(raw) || 0)
      var updates = {}
      updates['scores.' + field] = value
      this.setData(updates)
    }

    this._validateScore()
    this._validateCurrentStep()
  },

  onRankInput: function (e) {
    var field = e.currentTarget.dataset.field
    var value = Math.max(0, Number(e.detail.value) || 0)

    var updates = {}
    updates['ranking.' + field] = value
    this.setData(updates)

    this._validateRank()
    this._validateCurrentStep()
  },

  // ======== 校验逻辑 ========

  _validateCurrentStep: function () {
    if (this.data.currentStep === 0) {
      this._validateStep0()
    } else if (this.data.currentStep === 1) {
      this._validateStep1()
    } else if (this.data.currentStep === 2) {
      this._validateStep2()
    }
  },

  _validateStep0: function () {
    var canNext = !!(this.data.districtId && this.data.middleSchoolId)
    this.setData({ canNext: canNext })
  },

  _validateStep1: function () {
    var scores = this.data.scores
    var ranking = this.data.ranking

    this._validateScore()
    this._validateRank()

    var scoreValid = scores.total > 0 && scores.total <= SCORE_LIMITS.total
    var rankValid = ranking.rank > 0 && ranking.totalStudents > 0 && ranking.rank <= ranking.totalStudents
    var canNext = scoreValid && rankValid && this.data.scoreValidation.valid

    this.setData({ canNext: canNext })
  },

  _validateStep2: function () {
    var volunteers = this.data.volunteers
    var hasUnified = volunteers.unified.some(function (id) { return id !== 0 })
    this.setData({ canSubmit: hasUnified })
  },

  _validateScore: function () {
    var scores = this.data.scores
    var subjects = ['chinese', 'math', 'foreign', 'integrated', 'ethics', 'history', 'pe']

    for (var i = 0; i < subjects.length; i++) {
      var subject = subjects[i]
      var limit = SCORE_LIMITS[subject]
      if (scores[subject] > limit) {
        this.setData({
          scoreValidation: {
            valid: false,
            message: this._subjectLabel(subject) + '不能超过' + limit + '分'
          }
        })
        return
      }
    }

    var partialSum =
      scores.chinese +
      scores.math +
      scores.foreign +
      scores.integrated +
      scores.ethics +
      scores.history +
      scores.pe

    var totalNum = Number(scores.total) || 0
    var hasPartial = partialSum > 0
    var hasTotal = totalNum > 0

    if (hasPartial && hasTotal && Math.abs(partialSum - totalNum) > 0.01) {
      this.setData({
        scoreValidation: {
          valid: false,
          message: '各科成绩之和(' + partialSum + ')与总分(' + scores.total + ')不一致'
        }
      })
      return
    }

    this.setData({
      scoreValidation: { valid: true, message: '' }
    })
  },

  _validateRank: function () {
    var ranking = this.data.ranking

    if (ranking.rank > 0 && ranking.totalStudents > 0 && ranking.rank > ranking.totalStudents) {
      this.setData({
        rankValidation: {
          valid: false,
          message: '排名不能超过总人数'
        }
      })
      return
    }

    this.setData({
      rankValidation: { valid: true, message: '' }
    })
  },

  _subjectLabel: function (field) {
    var labels = {
      chinese: '语文',
      math: '数学',
      foreign: '外语',
      integrated: '综合测试',
      ethics: '道德与法治',
      history: '历史',
      pe: '体育'
    }
    return labels[field] || field
  },

  // ======== 步骤导航 ========

  nextStep: function () {
    if (!this.data.canNext) return

    var nextStep = this.data.currentStep + 1
    this.setData({ currentStep: nextStep })

    if (nextStep === 1) {
      this._validateStep1()
    } else if (nextStep === 2) {
      this._loadQuotaSchools()
    }
  },

  prevStep: function () {
    if (this.data.currentStep <= 0) return
    this.setData({
      currentStep: this.data.currentStep - 1
    })
    this._validateCurrentStep()
  },

  _loadQuotaSchools: function () {
    var self = this
    var districtId = self.data.districtId
    var middleSchoolId = self.data.middleSchoolId

    if (!districtId || !middleSchoolId) {
      wx.showToast({ title: '请先完成基本信息', icon: 'none' })
      return
    }

    wx.showLoading({ title: '加载学校数据...' })

    Promise.all([
      reference.getSchoolsWithQuotaDistrict(districtId),
      reference.getSchoolsWithQuotaSchool(middleSchoolId),
      reference.getSchoolsForUnified(districtId)
    ]).then(function (results) {
      wx.hideLoading()

      var quotaDistrictSchools = (results[0].schools || []).map(function (s) {
        return { id: s.id, fullName: s.fullName || s.name, code: s.code || '', quotaCount: s.quotaCount || 0 }
      })

      var quotaSchoolSchools = (results[1].schools || []).map(function (s) {
        return { id: s.id, fullName: s.fullName || s.name, code: s.code || '', quotaCount: s.quotaCount || 0 }
      })

      var unifiedSchools = (results[2].schools || []).map(function (s) {
        return { id: s.id, fullName: s.fullName || s.name, code: s.code || '' }
      })

      self.setData({
        quotaDistrictSchools: quotaDistrictSchools,
        quotaSchoolSchools: quotaSchoolSchools,
        unifiedSchools: unifiedSchools
      })

      self._resolveVolunteerNames(quotaDistrictSchools, quotaSchoolSchools, unifiedSchools)
      self._validateStep2()
    }).catch(function () {
      wx.hideLoading()
      wx.showToast({ title: '加载学校数据失败', icon: 'none' })
    })
  },

  // ======== 学校选择器 ========

  onSchoolPickerOpen: function (e) {
    var type = e.currentTarget.dataset.type
    var schools = []

    if (type === 'quotaDistrict') {
      schools = this.data.quotaDistrictSchools
    } else if (type === 'quotaSchool0' || type === 'quotaSchool1') {
      schools = this.data.quotaSchoolSchools
    } else if (type.indexOf('unified') === 0) {
      schools = this.data.unifiedSchools
    }

    this.setData({
      showSchoolPicker: true,
      pickerType: type,
      pickerSchools: schools,
      pickerSearch: ''
    })
  },

  onPickerSearch: function (e) {
    var query = e.detail.value.trim()
    this.setData({ pickerSearch: query })

    var allSchools = []
    var type = this.data.pickerType

    if (type === 'quotaDistrict') {
      allSchools = this.data.quotaDistrictSchools
    } else if (type === 'quotaSchool0' || type === 'quotaSchool1') {
      allSchools = this.data.quotaSchoolSchools
    } else {
      allSchools = this.data.unifiedSchools
    }

    if (!query) {
      this.setData({ pickerSchools: allSchools })
      return
    }

    var filtered = allSchools.filter(function (s) {
      return s.fullName.indexOf(query) !== -1 || (s.code && s.code.indexOf(query) !== -1)
    })
    this.setData({ pickerSchools: filtered })
  },

  onSchoolSelect: function (e) {
    var schoolId = Number(e.currentTarget.dataset.id)
    var schoolName = e.currentTarget.dataset.name || ''
    var type = this.data.pickerType

    var updates = {
      showSchoolPicker: false,
      pickerSearch: ''
    }

    if (type === 'quotaDistrict') {
      updates['volunteers.quotaDistrict'] = schoolId
      updates['volunteerNames.quotaDistrict'] = schoolName
    } else if (type === 'quotaSchool0') {
      updates['volunteers.quotaSchool[0]'] = schoolId
      updates['volunteerNames.quotaSchool0'] = schoolName
    } else if (type === 'quotaSchool1') {
      updates['volunteers.quotaSchool[1]'] = schoolId
      updates['volunteerNames.quotaSchool1'] = schoolName
    } else if (type.indexOf('unified') === 0) {
      var index = parseInt(type.replace('unified', ''), 10)
      updates['volunteers.unified[' + index + ']'] = schoolId
      updates['volunteerNames.unified[' + index + ']'] = schoolName
    }

    this.setData(updates)
    this._validateStep2()
  },

  onPickerClose: function () {
    this.setData({
      showSchoolPicker: false,
      pickerSearch: ''
    })
  },

  onClearVolunteer: function (e) {
    var type = e.currentTarget.dataset.type
    var updates = {}

    if (type === 'quotaDistrict') {
      updates['volunteers.quotaDistrict'] = null
      updates['volunteerNames.quotaDistrict'] = ''
    } else if (type === 'quotaSchool0') {
      updates['volunteers.quotaSchool[0]'] = 0
      updates['volunteerNames.quotaSchool0'] = ''
    } else if (type === 'quotaSchool1') {
      updates['volunteers.quotaSchool[1]'] = 0
      updates['volunteerNames.quotaSchool1'] = ''
    } else if (type.indexOf('unified') === 0) {
      var index = parseInt(type.replace('unified', ''), 10)
      updates['volunteers.unified[' + index + ']'] = 0
      updates['volunteerNames.unified[' + index + ']'] = ''
    }

    this.setData(updates)
    this._validateStep2()
  },

  // ======== 查找学校名称 ========

  _resolveVolunteerNames: function (quotaDistrictSchools, quotaSchoolSchools, unifiedSchools) {
    var volunteers = this.data.volunteers
    var names = {
      quotaDistrict: '',
      quotaSchool0: '',
      quotaSchool1: '',
      unified: new Array(15).fill('')
    }

    if (volunteers.quotaDistrict) {
      var found = quotaDistrictSchools.filter(function (s) { return s.id === volunteers.quotaDistrict })[0]
      names.quotaDistrict = found ? found.fullName : ''
    }

    if (volunteers.quotaSchool[0]) {
      var found2 = quotaSchoolSchools.filter(function (s) { return s.id === volunteers.quotaSchool[0] })[0]
      names.quotaSchool0 = found2 ? found2.fullName : ''
    }

    if (volunteers.quotaSchool[1]) {
      var found3 = quotaSchoolSchools.filter(function (s) { return s.id === volunteers.quotaSchool[1] })[0]
      names.quotaSchool1 = found3 ? found3.fullName : ''
    }

    for (var idx = 0; idx < volunteers.unified.length; idx++) {
      var uid = volunteers.unified[idx]
      if (uid) {
        var found4 = unifiedSchools.filter(function (s) { return s.id === uid })[0]
        names.unified[idx] = found4 ? found4.fullName : ''
      }
    }

    this.setData({ volunteerNames: names })
  },

  // ======== 提交分析 ========

  onSubmit: function () {
    if (!this.data.canSubmit || this.data.submitting) return

    var self = this
    self.setData({ submitting: true })
    wx.showLoading({ title: '提交分析中...' })

    var formData = {
      districtId: self.data.districtId,
      middleSchoolId: self.data.middleSchoolId,
      hasQuotaSchoolEligibility: self.data.hasQuotaSchoolEligibility,
      scores: cloneScores(self.data.scores),
      comprehensiveQuality: self.data.comprehensiveQuality,
      ranking: cloneRanking(self.data.ranking),
      volunteers: {
        quotaDistrict: self.data.volunteers.quotaDistrict,
        quotaSchool: self.data.volunteers.quotaSchool.slice(),
        unified: self.data.volunteers.unified.slice()
      }
    }

    candidate.submitAnalysis(formData)
      .then(function (result) {
        wx.hideLoading()
        storage.clearFormData()
        storage.saveAnalysisId(result.analysisId)
        wx.redirectTo({
          url: '/pages/result/result?id=' + result.analysisId
        })
      })
      .catch(function (err) {
        wx.hideLoading()
        self.setData({ submitting: false })
        wx.showToast({
          title: (err && err.message) || '提交失败，请重试',
          icon: 'none',
          duration: 3000
        })
      })
  }
})
