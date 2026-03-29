/**
 * ReferenceService API
 * Connect-RPC JSON over wx.request
 */

const { callRpc } = require('./api')

const SERVICE = 'highschool.v1.ReferenceService'

function getDistricts() {
  return callRpc(SERVICE, 'GetDistricts', {})
}

function getMiddleSchools(districtId) {
  return callRpc(SERVICE, 'GetMiddleSchools', {
    districtId: districtId || undefined
  })
}

function getSchools(params = {}) {
  return callRpc(SERVICE, 'GetSchools', {
    districtId: params.districtId || undefined,
    keyword: params.keyword || undefined,
    page: params.page || 1,
    pageSize: params.pageSize || 20
  })
}

function getSchoolDetail(id) {
  return callRpc(SERVICE, 'GetSchoolDetail', { id })
}

function getHistoryScores(params = {}) {
  return callRpc(SERVICE, 'GetHistoryScores', {
    districtId: params.districtId || undefined,
    schoolId: params.schoolId || undefined,
    year: params.year || undefined
  })
}

function getSchoolsWithQuotaDistrict(districtId, year = 2025) {
  return callRpc(SERVICE, 'GetSchoolsWithQuotaDistrict', {
    districtId,
    year
  })
}

function getSchoolsWithQuotaSchool(middleSchoolId, year = 2025) {
  return callRpc(SERVICE, 'GetSchoolsWithQuotaSchool', {
    middleSchoolId,
    year
  })
}

function getSchoolsForUnified(districtId, year = 2025) {
  return callRpc(SERVICE, 'GetSchoolsForUnified', {
    districtId,
    year
  })
}

function getVolunteerRecommendations(params) {
  return callRpc(SERVICE, 'GetVolunteerRecommendations', {
    districtId: params.districtId,
    middleSchoolId: params.middleSchoolId || undefined,
    examType: params.examType,
    totalScore: params.totalScore,
    hasQuotaSchoolEligibility: params.hasQuotaSchoolEligibility,
    year: params.year || 2025
  })
}

module.exports = {
  getDistricts,
  getMiddleSchools,
  getSchools,
  getSchoolDetail,
  getHistoryScores,
  getSchoolsWithQuotaDistrict,
  getSchoolsWithQuotaSchool,
  getSchoolsForUnified,
  getVolunteerRecommendations
}
