/**
 * ReferenceService API
 * Connect-RPC JSON over wx.request
 */

var api = require('./api')

var SERVICE = 'highschool.v1.ReferenceService'

function getDistricts() {
  return api.callRpc(SERVICE, 'GetDistricts', {})
}

function getMiddleSchools(districtId) {
  return api.callRpc(SERVICE, 'GetMiddleSchools', {
    districtId: districtId || undefined
  })
}

function getSchools(params) {
  return api.callRpc(SERVICE, 'GetSchools', {
    districtId: (params && params.districtId) || undefined,
    keyword: (params && params.keyword) || undefined,
    page: (params && params.page) || 1,
    pageSize: (params && params.pageSize) || 20
  })
}

function getSchoolDetail(id) {
  return api.callRpc(SERVICE, 'GetSchoolDetail', { id: id })
}

function getHistoryScores(params) {
  return api.callRpc(SERVICE, 'GetHistoryScores', {
    districtId: (params && params.districtId) || undefined,
    schoolId: (params && params.schoolId) || undefined,
    year: (params && params.year) || undefined
  })
}

function getSchoolsWithQuotaDistrict(districtId, year) {
  return api.callRpc(SERVICE, 'GetSchoolsWithQuotaDistrict', {
    districtId: districtId,
    year: year || 2025
  })
}

function getSchoolsWithQuotaSchool(middleSchoolId, year) {
  return api.callRpc(SERVICE, 'GetSchoolsWithQuotaSchool', {
    middleSchoolId: middleSchoolId,
    year: year || 2025
  })
}

function getSchoolsForUnified(districtId, year) {
  return api.callRpc(SERVICE, 'GetSchoolsForUnified', {
    districtId: districtId,
    year: year || 2025
  })
}

function getVolunteerRecommendations(params) {
  return api.callRpc(SERVICE, 'GetVolunteerRecommendations', {
    districtId: params.districtId,
    middleSchoolId: params.middleSchoolId || undefined,
    examType: params.examType,
    totalScore: params.totalScore,
    hasQuotaSchoolEligibility: params.hasQuotaSchoolEligibility,
    year: params.year || 2025
  })
}

module.exports = {
  getDistricts: getDistricts,
  getMiddleSchools: getMiddleSchools,
  getSchools: getSchools,
  getSchoolDetail: getSchoolDetail,
  getHistoryScores: getHistoryScores,
  getSchoolsWithQuotaDistrict: getSchoolsWithQuotaDistrict,
  getSchoolsWithQuotaSchool: getSchoolsWithQuotaSchool,
  getSchoolsForUnified: getSchoolsForUnified,
  getVolunteerRecommendations: getVolunteerRecommendations
}
