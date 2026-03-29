/**
 * 志愿填报页面 - 3步向导表单
 * Step 0: 基本信息（区县、初中、名额分配到校资格）
 * Step 1: 成绩信息（总分、各科成绩、校内排名）
 * Step 2: 志愿填报（名额到区、名额到校、统一招生）
 */

const {
  getDistricts,
  getMiddleSchools,
  getSchoolsWithQuotaDistrict,
  getSchoolsWithQuotaSchool,
  getSchoolsForUnified
} = require('../../utils/reference')
const { submitAnalysis } = require('../../utils/candidate')
const { saveFormData, loadFormData, clearFormData, saveAnalysisId } = require('../../utils/storage')
const { SCORE_LIMITS } = require('../../utils/constants')

const EMPTY_SCORES = {
  total: 0,
  chinese: 0,
  math: 0,
  foreign: 0,
  integrated: 0,
  ethics: 0,
  history: 0,
  pe: 0
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

    scores: { ...EMPTY_SCORES },
    comprehensiveQuality: 50,
    ranking: { rank: 0, totalStudents: 0 },

    volunteers: {
      quotaDistrict: null,
      quotaSchool: [0, 0],
      unified: Array(15).fill(0)
    },

    // 学校名称（用于模板展示，WXML 无法调用方法）
    volunteerNames: {
      quotaDistrict: '',
      quotaSchool0: '',
      quotaSchool1: '',
      unified: Array(15).fill('')
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

  onLoad() {
    this._loadDistricts()
    this._restoreForm()
  },

  onUnload() {
    this._saveForm()
  },

  // ======== 数据加载 ========

  _loadDistricts() {
    getDistricts().then(res => {
      const districts = (res.districts || []).map(d => ({
        id: d.id,
        name: d.name,
        code: d.code || ''
      }))
      this.setData({ districts })
    }).catch(err => {
      wx.showToast({ title: '加载区县失败', icon: 'none' })
    })
  },

  _restoreForm() {
    const saved = loadFormData()
    if (!saved) return

    this.setData({
      districtId: saved.districtId || null,
      districtName: saved.districtName || '',
      middleSchoolId: saved.middleSchoolId || null,
      middleSchoolName: saved.middleSchoolName || '',
      hasQuotaSchoolEligibility: saved.hasQuotaSchoolEligibility || false,
      scores: saved.scores || { ...EMPTY_SCORES },
      comprehensiveQuality: saved.comprehensiveQuality || 50,
      ranking: saved.ranking || { rank: 0, totalStudents: 0 },
      volunteers: saved.volunteers || {
        quotaDistrict: null,
        quotaSchool: [0, 0],
        unified: Array(15).fill(0)
      }
    })

    if (saved.districtId) {
      this._loadMiddleSchools(saved.districtId)
    }

    this._validateCurrentStep()
  },

  _saveForm() {
    const formData = {
      districtId: this.data.districtId,
      districtName: this.data.districtName,
      middleSchoolId: this.data.middleSchoolId,
      middleSchoolName: this.data.middleSchoolName,
      hasQuotaSchoolEligibility: this.data.hasQuotaSchoolEligibility,
      scores: { ...this.data.scores },
      comprehensiveQuality: this.data.comprehensiveQuality,
      ranking: { ...this.data.ranking },
      volunteers: {
        quotaDistrict: this.data.volunteers.quotaDistrict,
        quotaSchool: [...this.data.volunteers.quotaSchool],
        unified: [...this.data.volunteers.unified]
      }
    }
    saveFormData(formData)
  },

  // ======== 区县/学校选择 ========

  onDistrictChange(e) {
    const index = Number(e.detail.value)
    const district = this.data.districts[index]
    if (!district) return

    this.setData({
      districtId: district.id,
      districtName: district.name,
      middleSchoolId: null,
      middleSchoolName: '',
      middleSchools: []
    })

    this._loadMiddleSchools(district.id)
    this._validateCurrentStep()
  },

  _loadMiddleSchools(districtId) {
    getMiddleSchools(districtId).then(res => {
      const middleSchools = (res.middleSchools || []).map(s => ({
        id: s.id,
        name: s.name,
        code: s.code || ''
      }))
      this.setData({ middleSchools })
    }).catch(() => {
      wx.showToast({ title: '加载初中列表失败', icon: 'none' })
    })
  },

  onMiddleSchoolChange(e) {
    const index = Number(e.detail.value)
    const school = this.data.middleSchools[index]
    if (!school) return

    this.setData({
      middleSchoolId: school.id,
      middleSchoolName: school.name
    })
    this._validateCurrentStep()
  },

  onQuotaEligibilityChange(e) {
    this.setData({
      hasQuotaSchoolEligibility: e.detail.value
    })
  },

  // ======== 成绩输入 ========

  onScoreInput(e) {
    const field = e.currentTarget.dataset.field
    const value = Math.max(0, Number(e.detail.value) || 0)

    this.setData({
      [`scores.${field}`]: value
    })

    this._validateScore()
    this._validateCurrentStep()
  },

  onRankInput(e) {
    const field = e.currentTarget.dataset.field
    const value = Math.max(0, Number(e.detail.value) || 0)

    this.setData({
      [`ranking.${field}`]: value
    })

    this._validateRank()
    this._validateCurrentStep()
  },

  // ======== 校验逻辑 ========

  _validateCurrentStep() {
    if (this.data.currentStep === 0) {
      this._validateStep0()
    } else if (this.data.currentStep === 1) {
      this._validateStep1()
    } else if (this.data.currentStep === 2) {
      this._validateStep2()
    }
  },

  _validateStep0() {
    const canNext = !!(this.data.districtId && this.data.middleSchoolId)
    this.setData({ canNext })
  },

  _validateStep1() {
    const { scores, ranking } = this.data

    this._validateScore()
    this._validateRank()

    const scoreValid = scores.total > 0 && scores.total <= SCORE_LIMITS.total
    const rankValid = ranking.rank > 0 && ranking.totalStudents > 0 && ranking.rank <= ranking.totalStudents
    const canNext = scoreValid && rankValid && this.data.scoreValidation.valid

    this.setData({ canNext })
  },

  _validateStep2() {
    const { volunteers } = this.data
    const hasUnified = volunteers.unified.some(id => id !== 0)
    this.setData({ canSubmit: hasUnified })
  },

  _validateScore() {
    const { scores } = this.data
    const subjects = ['chinese', 'math', 'foreign', 'integrated', 'ethics', 'history', 'pe']

    for (const subject of subjects) {
      const limit = SCORE_LIMITS[subject]
      if (scores[subject] > limit) {
        this.setData({
          scoreValidation: {
            valid: false,
            message: `${this._subjectLabel(subject)}不能超过${limit}分`
          }
        })
        return
      }
    }

    const partialSum =
      scores.chinese +
      scores.math +
      scores.foreign +
      scores.integrated +
      scores.ethics +
      scores.history +
      scores.pe

    const hasPartial = partialSum > 0
    const hasTotal = scores.total > 0

    if (hasPartial && hasTotal && partialSum !== scores.total) {
      this.setData({
        scoreValidation: {
          valid: false,
          message: `各科成绩之和(${partialSum})与总分(${scores.total})不一致`
        }
      })
      return
    }

    this.setData({
      scoreValidation: { valid: true, message: '' }
    })
  },

  _validateRank() {
    const { ranking } = this.data

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

  _subjectLabel(field) {
    const labels = {
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

  nextStep() {
    if (!this.data.canNext) return

    const nextStep = this.data.currentStep + 1
    this.setData({ currentStep: nextStep })

    if (nextStep === 1) {
      this._validateStep1()
    } else if (nextStep === 2) {
      this._loadQuotaSchools()
    }
  },

  prevStep() {
    if (this.data.currentStep <= 0) return
    this.setData({
      currentStep: this.data.currentStep - 1
    })
    this._validateCurrentStep()
  },

  _loadQuotaSchools() {
    const { districtId, middleSchoolId } = this.data

    wx.showLoading({ title: '加载学校数据...' })

    Promise.all([
      getSchoolsWithQuotaDistrict(districtId),
      getSchoolsWithQuotaSchool(middleSchoolId),
      getSchoolsForUnified(districtId)
    ]).then(([quotaDistrictRes, quotaSchoolRes, unifiedRes]) => {
      wx.hideLoading()

      const quotaDistrictSchools = (quotaDistrictRes.schools || []).map(s => ({
        id: s.id,
        fullName: s.fullName || s.name,
        code: s.code || '',
        quotaCount: s.quotaCount || 0
      }))

      const quotaSchoolSchools = (quotaSchoolRes.schools || []).map(s => ({
        id: s.id,
        fullName: s.fullName || s.name,
        code: s.code || '',
        quotaCount: s.quotaCount || 0
      }))

      const unifiedSchools = (unifiedRes.schools || []).map(s => ({
        id: s.id,
        fullName: s.fullName || s.name,
        code: s.code || ''
      }))

      this.setData({
        quotaDistrictSchools,
        quotaSchoolSchools,
        unifiedSchools
      })

      // 解析已保存志愿的学校名称
      this._resolveVolunteerNames(
        quotaDistrictSchools,
        quotaSchoolSchools,
        unifiedSchools
      )

      this._validateStep2()
    }).catch(() => {
      wx.hideLoading()
      wx.showToast({ title: '加载学校数据失败', icon: 'none' })
    })
  },

  // ======== 学校选择器 ========

  onSchoolPickerOpen(e) {
    const type = e.currentTarget.dataset.type
    let schools = []

    if (type === 'quotaDistrict') {
      schools = this.data.quotaDistrictSchools
    } else if (type === 'quotaSchool0' || type === 'quotaSchool1') {
      schools = this.data.quotaSchoolSchools
    } else if (type.startsWith('unified')) {
      schools = this.data.unifiedSchools
    }

    this.setData({
      showSchoolPicker: true,
      pickerType: type,
      pickerSchools: schools,
      pickerSearch: ''
    })
  },

  onPickerSearch(e) {
    const query = e.detail.value.trim()
    this.setData({ pickerSearch: query })

    let allSchools = []
    const type = this.data.pickerType

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

    const filtered = allSchools.filter(s =>
      s.fullName.includes(query) || (s.code && s.code.includes(query))
    )
    this.setData({ pickerSchools: filtered })
  },

  onSchoolSelect(e) {
    const schoolId = Number(e.currentTarget.dataset.id)
    const schoolName = e.currentTarget.dataset.name || ''
    const type = this.data.pickerType

    const updates = {
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
    } else if (type.startsWith('unified')) {
      const index = parseInt(type.replace('unified', ''), 10)
      updates[`volunteers.unified[${index}]`] = schoolId
      updates[`volunteerNames.unified[${index}]`] = schoolName
    }

    this.setData(updates)
    this._validateStep2()
  },

  onPickerClose() {
    this.setData({
      showSchoolPicker: false,
      pickerSearch: ''
    })
  },

  onClearVolunteer(e) {
    const type = e.currentTarget.dataset.type

    const updates = {}

    if (type === 'quotaDistrict') {
      updates['volunteers.quotaDistrict'] = null
      updates['volunteerNames.quotaDistrict'] = ''
    } else if (type === 'quotaSchool0') {
      updates['volunteers.quotaSchool[0]'] = 0
      updates['volunteerNames.quotaSchool0'] = ''
    } else if (type === 'quotaSchool1') {
      updates['volunteers.quotaSchool[1]'] = 0
      updates['volunteerNames.quotaSchool1'] = ''
    } else if (type.startsWith('unified')) {
      const index = parseInt(type.replace('unified', ''), 10)
      updates[`volunteers.unified[${index}]`] = 0
      updates[`volunteerNames.unified[${index}]`] = ''
    }

    this.setData(updates)
    this._validateStep2()
  },

  // ======== 查找学校名称 ========

  _findSchoolName(type, schoolId) {
    if (!schoolId) return ''

    let schools = []
    if (type === 'quotaDistrict') {
      schools = this.data.quotaDistrictSchools
    } else if (type === 'quotaSchool0' || type === 'quotaSchool1') {
      schools = this.data.quotaSchoolSchools
    } else {
      schools = this.data.unifiedSchools
    }

    const school = schools.find(s => s.id === schoolId)
    return school ? school.fullName : ''
  },

  /**
   * 加载学校数据后，解析已保存志愿对应的学校名称
   */
  _resolveVolunteerNames(quotaDistrictSchools, quotaSchoolSchools, unifiedSchools) {
    const { volunteers } = this.data
    const names = {
      quotaDistrict: '',
      quotaSchool0: '',
      quotaSchool1: '',
      unified: Array(15).fill('')
    }

    if (volunteers.quotaDistrict) {
      const s = quotaDistrictSchools.find(s => s.id === volunteers.quotaDistrict)
      names.quotaDistrict = s ? s.fullName : ''
    }

    if (volunteers.quotaSchool[0]) {
      const s = quotaSchoolSchools.find(s => s.id === volunteers.quotaSchool[0])
      names.quotaSchool0 = s ? s.fullName : ''
    }

    if (volunteers.quotaSchool[1]) {
      const s = quotaSchoolSchools.find(s => s.id === volunteers.quotaSchool[1])
      names.quotaSchool1 = s ? s.fullName : ''
    }

    volunteers.unified.forEach((id, idx) => {
      if (id) {
        const s = unifiedSchools.find(s => s.id === id)
        names.unified[idx] = s ? s.fullName : ''
      }
    })

    this.setData({ volunteerNames: names })
  },

  // ======== 提交分析 ========

  onSubmit() {
    if (!this.data.canSubmit || this.data.submitting) return

    this.setData({ submitting: true })
    wx.showLoading({ title: '提交分析中...' })

    const formData = {
      districtId: this.data.districtId,
      middleSchoolId: this.data.middleSchoolId,
      hasQuotaSchoolEligibility: this.data.hasQuotaSchoolEligibility,
      scores: { ...this.data.scores },
      comprehensiveQuality: this.data.comprehensiveQuality,
      ranking: { ...this.data.ranking },
      volunteers: {
        quotaDistrict: this.data.volunteers.quotaDistrict,
        quotaSchool: [...this.data.volunteers.quotaSchool],
        unified: [...this.data.volunteers.unified]
      }
    }

    submitAnalysis(formData)
      .then(({ analysisId }) => {
        wx.hideLoading()
        clearFormData()
        saveAnalysisId(analysisId)
        wx.redirectTo({
          url: `/pages/result/result?id=${analysisId}`
        })
      })
      .catch(err => {
        wx.hideLoading()
        this.setData({ submitting: false })
        wx.showToast({
          title: err.message || '提交失败，请重试',
          icon: 'none',
          duration: 3000
        })
      })
  }
})
