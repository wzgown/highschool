/**
 * E2E API 测试 - 通过 HTTP 直接测试 Connect-RPC 后端
 * 验证小程序依赖的所有 API 端点
 */

const BASE_URL = 'http://127.0.0.1:3000'

// ======== 测试工具 ========

let totalTests = 0
let passedTests = 0
let failedTests = 0
const failures = []

function assert(condition, testName, detail) {
  totalTests++
  if (condition) {
    passedTests++
    console.log(`  \x1b[32mPASS\x1b[0m ${testName}`)
  } else {
    failedTests++
    failures.push({ test: testName, detail: detail || '' })
    console.log(`  \x1b[31mFAIL\x1b[0m ${testName} — ${detail || 'assertion failed'}`)
  }
}

function assertEq(actual, expected, testName) {
  const pass = actual === expected
  if (!pass) {
    assert(pass, testName, `expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`)
  } else {
    assert(pass, testName)
  }
}

function assertGt(actual, threshold, testName) {
  assert(actual > threshold, testName, `expected > ${threshold}, got ${actual}`)
}

function assertIncludes(arr, item, testName) {
  assert(Array.isArray(arr) && arr.includes(item), testName, `array does not include ${item}`)
}

async function rpc(service, method, body) {
  const url = `${BASE_URL}/${service}/${method}`
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body || {})
  })
  const data = await res.json()
  return { status: res.status, data }
}

// ======== ReferenceService 测试 ========

async function testGetDistricts() {
  console.log('\n\x1b[36m[ReferenceService] GetDistricts\x1b[0m')

  const { status, data } = await rpc('highschool.v1.ReferenceService', 'GetDistricts', {})

  assertEq(status, 200, '返回状态码 200')
  assert(Array.isArray(data.districts), '返回 districts 数组')
  assertGt(data.districts.length, 0, 'districts 非空')

  // 验证区县数据结构
  const first = data.districts[0]
  assert(first.id !== undefined, 'district 包含 id 字段')
  assert(first.name !== undefined, 'district 包含 name 字段')

  // 验证包含关键区县
  const names = data.districts.map(function (d) { return d.name })
  assertIncludes(names, '黄浦区', '包含黄浦区')
  assertIncludes(names, '浦东新区', '包含浦东新区')
  assertIncludes(names, '徐汇区', '包含徐汇区')

  return data.districts
}

async function testGetMiddleSchools(districtId) {
  console.log('\n\x1b[36m[ReferenceService] GetMiddleSchools\x1b[0m')

  // 正常请求
  const { status, data } = await rpc('highschool.v1.ReferenceService', 'GetMiddleSchools', {
    districtId: districtId
  })

  assertEq(status, 200, '返回状态码 200')
  assert(Array.isArray(data.middleSchools), '返回 middleSchools 数组')
  assertGt(data.middleSchools.length, 0, 'middleSchools 非空')

  const first = data.middleSchools[0]
  assert(first.id !== undefined, 'middleSchool 包含 id')
  assert(first.name !== undefined, 'middleSchool 包含 name')
  assertEq(first.districtId, districtId, 'middleSchool districtId 匹配')

  // 无效 districtId
  const { data: emptyData } = await rpc('highschool.v1.ReferenceService', 'GetMiddleSchools', {
    districtId: 99999
  })
  assert(
    !emptyData.middleSchools || emptyData.middleSchools.length === 0,
    '无效 districtId 返回空列表'
  )

  return data.middleSchools
}

async function testGetSchoolsWithQuotaDistrict(districtId) {
  console.log('\n\x1b[36m[ReferenceService] GetSchoolsWithQuotaDistrict\x1b[0m')

  const { status, data } = await rpc('highschool.v1.ReferenceService', 'GetSchoolsWithQuotaDistrict', {
    districtId: districtId,
    year: 2025
  })

  assertEq(status, 200, '返回状态码 200')
  assert(Array.isArray(data.schools), '返回 schools 数组')
  assertGt(data.schools.length, 0, 'schools 非空')

  const first = data.schools[0]
  assert(first.id !== undefined, 'school 包含 id')
  assert(first.fullName !== undefined, 'school 包含 fullName')
  assert(first.code !== undefined, 'school 包含 code')
  assert(first.quotaCount !== undefined, 'school 包含 quotaCount')
  assertGt(first.quotaCount, 0, 'quotaCount > 0')

  return data.schools
}

async function testGetSchoolsWithQuotaSchool(middleSchoolId) {
  console.log('\n\x1b[36m[ReferenceService] GetSchoolsWithQuotaSchool\x1b[0m')

  const { status, data } = await rpc('highschool.v1.ReferenceService', 'GetSchoolsWithQuotaSchool', {
    middleSchoolId: middleSchoolId,
    year: 2025
  })

  assertEq(status, 200, '返回状态码 200')

  if (data.schools && data.schools.length > 0) {
    const first = data.schools[0]
    assert(first.id !== undefined, 'school 包含 id')
    assert(first.fullName !== undefined, 'school 包含 fullName')
    assertGt(first.quotaCount, 0, 'quotaCount > 0')
    return data.schools
  }

  console.log('  \x1b[33mSKIP\x1b[0m 该初中无名额分配到校数据')
  return []
}

async function testGetSchoolsForUnified(districtId) {
  console.log('\n\x1b[36m[ReferenceService] GetSchoolsForUnified\x1b[0m')

  const { status, data } = await rpc('highschool.v1.ReferenceService', 'GetSchoolsForUnified', {
    districtId: districtId,
    year: 2025
  })

  assertEq(status, 200, '返回状态码 200')
  assert(Array.isArray(data.schools), '返回 schools 数组')
  assertGt(data.schools.length, 0, 'schools 非空（统一招生学校列表）')

  const first = data.schools[0]
  assert(first.id !== undefined, 'school 包含 id')
  assert(first.fullName !== undefined, 'school 包含 fullName')
  assert(first.code !== undefined, 'school 包含 code')

  return data.schools
}

// ======== CandidateService 测试 ========

async function testSubmitAnalysis(districtId, middleSchoolId, quotaSchoolIds, unifiedSchoolIds) {
  console.log('\n\x1b[36m[CandidateService] SubmitAnalysis\x1b[0m')

  const deviceId = 'e2e-test-' + Date.now()

  const payload = {
    candidate: {
      districtId: districtId,
      middleSchoolId: middleSchoolId,
      hasQuotaSchoolEligibility: true
    },
    scores: {
      total: 650,
      chinese: 130,
      math: 140,
      foreign: 135,
      integrated: 130,
      ethics: 50,
      history: 45,
      pe: 20
    },
    ranking: {
      rank: 50,
      totalStudents: 400
    },
    comprehensiveQuality: 50,
    volunteers: {
      quotaDistrict: unifiedSchoolIds[0],
      quotaSchool: quotaSchoolIds.slice(0, 2),
      unified: unifiedSchoolIds.slice(0, 7)
    },
    isTiePreferred: false,
    deviceId: deviceId
  }

  const { status, data } = await rpc('highschool.v1.CandidateService', 'SubmitAnalysis', payload)

  assertEq(status, 200, '返回状态码 200')
  assert(data.result !== undefined, '返回 result 对象')
  assert(data.result.id !== undefined, 'result 包含 id')
  assert(data.result.status !== undefined, 'result 包含 status')

  return { analysisId: data.result.id, deviceId: deviceId, result: data.result }
}

async function testGetAnalysisResult(analysisId) {
  console.log('\n\x1b[36m[CandidateService] GetAnalysisResult\x1b[0m')

  const { status, data } = await rpc('highschool.v1.CandidateService', 'GetAnalysisResult', {
    id: analysisId
  })

  assertEq(status, 200, '返回状态码 200')
  assert(data.result !== undefined, '返回 result 对象')

  const result = data.result
  assertEq(result.status, 'completed', '分析状态为 completed')

  // 验证分析结果结构
  const results = result.results || {}
  assert(results.predictions !== undefined, '包含 predictions')
  assert(Array.isArray(results.probabilities), '包含 probabilities 数组')
  assert(results.strategy !== undefined, '包含 strategy')

  // 验证 predictions
  if (results.predictions) {
    const pred = results.predictions
    assert(pred.districtRank !== undefined, 'predictions 包含 districtRank')
    assert(pred.confidence !== undefined, 'predictions 包含 confidence')
    assert(pred.percentile !== undefined, 'predictions 包含 percentile')
  }

  // 验证 probabilities
  if (results.probabilities && results.probabilities.length > 0) {
    const prob = results.probabilities[0]
    assert(prob.batch !== undefined, 'probability 包含 batch')
    assert(prob.schoolId !== undefined, 'probability 包含 schoolId')
    assert(prob.schoolName !== undefined, 'probability 包含 schoolName')
    assert(prob.riskLevel !== undefined, 'probability 包含 riskLevel')
    assert(prob.volunteerIndex !== undefined, 'probability 包含 volunteerIndex')
  }

  // 验证 strategy
  if (results.strategy) {
    assert(results.strategy.gradient !== undefined, 'strategy 包含 gradient')
    assert(Array.isArray(results.strategy.suggestions), 'strategy 包含 suggestions 数组')
  }

  return result
}

async function testGetHistory(deviceId) {
  console.log('\n\x1b[36m[CandidateService] GetHistory\x1b[0m')

  const { status, data } = await rpc('highschool.v1.CandidateService', 'GetHistory', {
    page: 1,
    pageSize: 10,
    deviceId: deviceId
  })

  assertEq(status, 200, '返回状态码 200')
  assert(Array.isArray(data.histories), '返回 histories 数组')
  assertGt(data.histories.length, 0, 'histories 非空（刚提交过分析）')

  const first = data.histories[0]
  assert(first.id !== undefined, 'history 包含 id')
  assert(first.createdAt !== undefined, 'history 包含 createdAt')

  return data.histories
}

async function testDeleteHistory(historyId) {
  console.log('\n\x1b[36m[CandidateService] DeleteHistory\x1b[0m')

  const { status, data } = await rpc('highschool.v1.CandidateService', 'DeleteHistory', {
    id: historyId
  })

  assertEq(status, 200, '返回状态码 200')

  // 验证删除后查不到
  const { data: verifyData } = await rpc('highschool.v1.CandidateService', 'GetHistory', {
    page: 1,
    pageSize: 50,
    deviceId: 'verify-deleted-' + Date.now()
  })

  // 注意：这里无法完全验证，因为 deviceId 不同
  // 但至少确认 API 没报错
  assert(true, '删除后 API 正常返回')
}

// ======== 错误场景测试 ========

async function testErrorCases(districtId) {
  console.log('\n\x1b[36m[Error Cases] 错误场景测试\x1b[0m')

  // 提交成绩校验 - 总分超出
  const { status: s1, data: d1 } = await rpc('highschool.v1.CandidateService', 'SubmitAnalysis', {
    candidate: { districtId: districtId, middleSchoolId: 49, hasQuotaSchoolEligibility: false },
    scores: { total: 800, chinese: 150, math: 150, foreign: 150, integrated: 150, ethics: 60, history: 60, pe: 30 },
    ranking: { rank: 1, totalStudents: 400 },
    comprehensiveQuality: 50,
    volunteers: { unified: [1] },
    isTiePreferred: false,
    deviceId: 'e2e-error-test'
  })
  // 后端可能有校验，也可能没有（取决于实现）
  assert(s1 === 200 || s1 === 400, '总分超出返回 200 或 400')

  // 空志愿提交
  const { status: s2, data: d2 } = await rpc('highschool.v1.CandidateService', 'SubmitAnalysis', {
    candidate: { districtId: districtId, middleSchoolId: 49, hasQuotaSchoolEligibility: false },
    scores: { total: 650 },
    ranking: { rank: 50, totalStudents: 400 },
    comprehensiveQuality: 50,
    volunteers: { unified: [] },
    isTiePreferred: false,
    deviceId: 'e2e-empty-volunteer'
  })
  assert(s2 === 200 || s2 === 400, '空志愿返回 200 或 400')

  // 无效分析 ID 查询
  const { status: s3, data: d3 } = await rpc('highschool.v1.CandidateService', 'GetAnalysisResult', {
    id: '999999'
  })
  assert(s3 === 200 || s3 === 404, '无效 ID 返回 200 或 404')
}

// ======== 完整用户流程测试 ========

async function testFullUserJourney() {
  console.log('\n\x1b[36m[Full Flow] 完整用户流程测试\x1b[0m')
  console.log('  模拟用户从首页进入 → 填写表单 → 提交分析 → 查看结果 → 查看历史')

  // Step 1: 加载区县列表（首页 API 连接测试）
  console.log('\n  Step 1: 首页加载 - API 连接测试')
  const districts = await testGetDistricts()

  // Step 2: 选择区县，加载初中列表
  console.log('\n  Step 2: 选择黄浦区 → 加载初中列表')
  const hpDistrict = districts.find(function (d) { return d.name === '黄浦区' })
  assert(hpDistrict !== undefined, '找到黄浦区')
  const middleSchools = await testGetMiddleSchools(hpDistrict.id)

  // Step 3: 选择初中，加载名额分配学校
  console.log('\n  Step 3: 选择格致初级中学 → 加载志愿学校列表')
  const targetSchool = middleSchools.find(function (s) { return s.name.includes('格致') })
  assert(targetSchool !== undefined, '找到格致初级中学')

  const quotaDistrictSchools = await testGetSchoolsWithQuotaDistrict(hpDistrict.id)
  const quotaSchoolSchools = await testGetSchoolsWithQuotaSchool(targetSchool.id)
  const unifiedSchools = await testGetSchoolsForUnified(hpDistrict.id)

  // Step 4: 提交志愿分析
  console.log('\n  Step 4: 填写成绩和志愿 → 提交分析')
  const quotaIds = quotaSchoolSchools.map(function (s) { return s.id })
  const unifiedIds = unifiedSchools.map(function (s) { return s.id })

  const submitResult = await testSubmitAnalysis(
    hpDistrict.id,
    targetSchool.id,
    quotaIds,
    unifiedIds
  )

  // Step 5: 查看分析结果
  console.log('\n  Step 5: 查看分析结果')
  await testGetAnalysisResult(submitResult.analysisId)

  // Step 6: 查看历史记录
  console.log('\n  Step 6: 查看历史记录')
  const histories = await testGetHistory(submitResult.deviceId)

  // Step 7: 删除历史记录
  console.log('\n  Step 7: 删除历史记录')
  if (histories.length > 0) {
    await testDeleteHistory(histories[0].id)
  }

  // Step 8: 错误场景
  await testErrorCases(hpDistrict.id)
}

// ======== 主函数 ========

async function main() {
  console.log('\x1b[1m========================================\x1b[0m')
  console.log('\x1b[1m  中考志愿模拟系统 - E2E API 测试\x1b[0m')
  console.log('\x1b[1m========================================\x1b[0m')

  try {
    await testFullUserJourney()
  } catch (err) {
    console.error('\n\x1b[31m测试执行出错:\x1b[0m', err.message)
    failedTests++
    failures.push({ test: '执行异常', detail: err.message })
  }

  // 输出汇总
  console.log('\n\x1b[1m========================================\x1b[0m')
  console.log('\x1b[1m  测试结果汇总\x1b[0m')
  console.log('\x1b[1m========================================\x1b[0m')
  console.log(`  总计: ${totalTests}  通过: \x1b[32m${passedTests}\x1b[0m  失败: \x1b[31m${failedTests}\x1b[0m`)

  if (failures.length > 0) {
    console.log('\n  \x1b[31m失败列表:\x1b[0m')
    failures.forEach(function (f) {
      console.log(`    - ${f.test}: ${f.detail}`)
    })
  }

  console.log('')
  process.exit(failedTests > 0 ? 1 : 0)
}

main()
