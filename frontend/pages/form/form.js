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
var districtUtil = require('../../utils/district')
var pickerUtil = require('../../utils/picker')

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
    filteredDistricts: [],
    middleSchools: [],
    filteredMiddleSchools: [],
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
    showDistrictPicker: false,
    districtSearch: '',
    showMiddleSchoolPicker: false,
    middleSchoolSearch: '',
    showSchoolPicker: false,
    pickerType: '',
    pickerSchools: [],
    pickerSearch: '',

    // 统一招生志愿拖拽排序
    dragging: false,
    dragIdx: -1,
    dragOffsets: new Array(15).fill(0),
    dragAnim: false
  },

  // ======== 生命周期 ========

  onLoad: function () {
    this._loadDistricts()
    this._restoreForm()
  },

  onUnload: function () {
    this._saveForm()
  },

  noop: function () {},

  // ======== 数据加载 ========

  _loadDistricts: function () {
    var self = this
    reference.getDistricts().then(function (res) {
      var districts = districtUtil.filterDistricts(res.districts || [])
      var updates = {
        districts: districts,
        filteredDistricts: districtUtil.searchDistricts(districts, self.data.districtSearch)
      }

      if (self.data.districtId && !districtUtil.findDistrictById(districts, self.data.districtId)) {
        updates.districtId = null
        updates.districtName = ''
        updates.middleSchoolId = null
        updates.middleSchoolName = ''
        updates.middleSchools = []
        updates.filteredMiddleSchools = []
      }

      self.setData(updates)
      self._validateCurrentStep()
    }).catch(function () {
      wx.showToast({ title: '加载区县失败', icon: 'none' })
    })
  },

  _restoreForm: function () {
    var saved = storage.loadFormData()
    if (!saved) return
    var savedIsCityLevel = districtUtil.isCityLevel({
      id: saved.districtId,
      name: saved.districtName
    })

    this.setData({
      districtId: savedIsCityLevel ? null : (saved.districtId || null),
      districtName: savedIsCityLevel ? '' : (saved.districtName || ''),
      middleSchoolId: savedIsCityLevel ? null : (saved.middleSchoolId || null),
      middleSchoolName: savedIsCityLevel ? '' : (saved.middleSchoolName || ''),
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

    if (saved.districtId && !savedIsCityLevel) {
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
    this._selectDistrict(district)
  },

  onDistrictPickerOpen: function () {
    this.setData({
      showDistrictPicker: true,
      districtSearch: '',
      filteredDistricts: this.data.districts
    })
  },

  onDistrictPickerClose: function () {
    this.setData({
      showDistrictPicker: false,
      districtSearch: ''
    })
  },

  onDistrictSearch: function (e) {
    var query = e.detail.value || ''
    this.setData({
      districtSearch: query,
      filteredDistricts: districtUtil.searchDistricts(this.data.districts, query)
    })
  },

  onDistrictSelect: function (e) {
    var district = districtUtil.findDistrictById(this.data.districts, e.currentTarget.dataset.id)
    if (!district) return
    this._selectDistrict(district)
  },

  _selectDistrict: function (district) {
    // 切换区县时清除所有关联数据
    this.setData({
      districtId: district.id,
      districtName: district.name,
      showDistrictPicker: false,
      districtSearch: '',
      filteredDistricts: this.data.districts,
      middleSchoolId: null,
      middleSchoolName: '',
      middleSchools: [],
      filteredMiddleSchools: [],
      showMiddleSchoolPicker: false,
      middleSchoolSearch: '',
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
      var middleSchools = pickerUtil.mapOptions(res.middleSchools || [])
      self.setData({
        middleSchools: middleSchools,
        filteredMiddleSchools: pickerUtil.searchOptions(middleSchools, self.data.middleSchoolSearch)
      })
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

  onMiddleSchoolPickerOpen: function () {
    if (!this.data.districtId) {
      wx.showToast({ title: '请先选择区县', icon: 'none' })
      return
    }

    this.setData({
      showMiddleSchoolPicker: true,
      middleSchoolSearch: '',
      filteredMiddleSchools: this.data.middleSchools
    })
  },

  onMiddleSchoolPickerClose: function () {
    this.setData({
      showMiddleSchoolPicker: false,
      middleSchoolSearch: ''
    })
  },

  onMiddleSchoolSearch: function (e) {
    var query = e.detail.value || ''
    this.setData({
      middleSchoolSearch: query,
      filteredMiddleSchools: pickerUtil.searchOptions(this.data.middleSchools, query)
    })
  },

  onMiddleSchoolSelect: function (e) {
    var school = pickerUtil.findById(this.data.middleSchools, e.currentTarget.dataset.id)
    if (!school) return

    this.setData({
      middleSchoolId: school.id,
      middleSchoolName: school.name,
      showMiddleSchoolPicker: false,
      middleSchoolSearch: ''
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

      var quotaDistrictSchools = pickerUtil.mapOptions(results[0].schools || [])
      var quotaSchoolSchools = pickerUtil.mapOptions(results[1].schools || [])
      var unifiedSchools = pickerUtil.mapOptions(results[2].schools || [])

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

  // 同批次已选学校（当前正在编辑的志愿位除外）：同批次不可重复填报
  _getSelectedIds: function (type) {
    var v = this.data.volunteers
    if (type === 'quotaDistrict') {
      return []
    }
    if (type === 'quotaSchool0' || type === 'quotaSchool1') {
      var other = type === 'quotaSchool0' ? v.quotaSchool[1] : v.quotaSchool[0]
      return other ? [other] : []
    }
    // unifiedN：排除其他志愿位已选学校
    var index = parseInt(type.replace('unified', ''), 10)
    return v.unified.filter(function (id, i) { return id && i !== index })
  },

  // 批次可选学校列表（剔除同批次已选）
  _getBatchSchools: function (type) {
    var schools
    if (type === 'quotaDistrict') {
      schools = this.data.quotaDistrictSchools
    } else if (type === 'quotaSchool0' || type === 'quotaSchool1') {
      schools = this.data.quotaSchoolSchools
    } else {
      schools = this.data.unifiedSchools
    }
    var selected = this._getSelectedIds(type)
    if (!selected.length) return schools
    return (schools || []).filter(function (s) { return selected.indexOf(s.id) === -1 })
  },

  onSchoolPickerOpen: function (e) {
    var type = e.currentTarget.dataset.type

    this.setData({
      showSchoolPicker: true,
      pickerType: type,
      pickerSchools: this._getBatchSchools(type),
      pickerSearch: ''
    })
  },

  onPickerSearch: function (e) {
    var query = e.detail.value.trim()
    this.setData({ pickerSearch: query })

    var allSchools = this._getBatchSchools(this.data.pickerType)

    if (!query) {
      this.setData({ pickerSchools: allSchools })
      return
    }

    this.setData({ pickerSchools: pickerUtil.searchOptions(allSchools, query) })
  },

  onSchoolSelect: function (e) {
    var schoolId = Number(e.currentTarget.dataset.id)
    var schoolName = e.currentTarget.dataset.name || ''
    var type = this.data.pickerType

    // 兜底：同批次重复选择直接拒绝（正常流程下选择器已过滤）
    if (this._getSelectedIds(type).indexOf(schoolId) !== -1) {
      wx.showToast({ title: '同批次不能重复选择该学校', icon: 'none' })
      return
    }

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

  // ======== 统一招生志愿拖拽排序（长按整行拖动） ========

  onPageScroll: function (e) {
    this._scrollTop = e.scrollTop || 0
  },

  onDragStart: function (e) {
    var index = Number(e.currentTarget.dataset.index)
    if (!this.data.volunteers.unified[index]) return
    var self = this
    wx.createSelectorQuery().in(this).selectAll('.volunteer-item-unified').boundingClientRect(function (rects) {
      if (!rects || rects.length < 2) return
      // 先只记录基准，不改动任何 data；等手指真的移动再进入拖拽态，
      // 避免长按瞬间的 setData 重渲染造成画面闪缩
      self._dragMetrics = {
        baseTop: rects[0].top,
        rowH: rects[0].height,
        stride: rects[1].top - rects[0].top
      }
      self._dragScroll0 = self._scrollTop || 0
      self._dragPending = index
    }).exec()
  },

  onDragMove: function (e) {
    if (!this._dragMetrics) return
    if (!this.data.dragging) {
      if (this._dragPending === -1 || this._dragPending === undefined) return
      this.setData({ dragging: true, dragIdx: this._dragPending })
      this._dragPending = -1
      return
    }
    var touch = e.touches[0]
    var m = this._dragMetrics
    // 拖动过程中页面可能同时滚动，用滚动量修正行位置基准
    var baseTop = m.baseTop - ((this._scrollTop || 0) - (this._dragScroll0 || 0))

    // 已填志愿为数组前缀，空位（0）在后；拖拽范围限制在前缀内
    var u = this.data.volunteers.unified
    var filled = 0
    for (var i = 0; i < u.length; i++) { if (u[i]) filled++ }

    var target = Math.round((touch.clientY - baseTop - m.rowH / 2) / m.stride)
    target = Math.max(0, Math.min(filled - 1, target))

    var from = this.data.dragIdx
    if (target === from) return

    var newU = u.slice()
    var newNames = this.data.volunteerNames.unified.slice()
    newU.splice(target, 0, newU.splice(from, 1)[0])
    newNames.splice(target, 0, newNames.splice(from, 1)[0])

    // 换位动画：给被挤开的行一个反向初始位移（瞬间、无过渡），
    // 下一帧归位（带过渡），视觉上它们平滑滑到新位置
    var offsets = new Array(15).fill(0)
    var i2
    if (target > from) {
      for (i2 = from; i2 < target; i2++) offsets[i2] = m.stride
    } else {
      for (i2 = target + 1; i2 <= from; i2++) offsets[i2] = -m.stride
    }

    this.setData({
      'volunteers.unified': newU,
      'volunteerNames.unified': newNames,
      dragIdx: target,
      dragOffsets: offsets,
      dragAnim: false
    })
    var self = this
    clearTimeout(this._dragAnimTimer)
    this._dragAnimTimer = setTimeout(function () {
      self.setData({ dragOffsets: new Array(15).fill(0), dragAnim: true })
    }, 40)
  },

  onDragEnd: function () {
    this._dragMetrics = null
    this._dragPending = -1
    clearTimeout(this._dragAnimTimer)
    if (!this.data.dragging) return
    this.setData({
      dragging: false,
      dragIdx: -1,
      dragOffsets: new Array(15).fill(0),
      dragAnim: false
    })
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
  },

  onShareAppMessage: function () {
    return {
      title: '折桂登高 - 中考志愿模拟分析',
      path: '/pages/index/index'
    }
  },

  onShareTimeline: function () {
    return {
      title: '折桂登高 - 智能分析录取概率，优化志愿填报策略'
    }
  }
})
