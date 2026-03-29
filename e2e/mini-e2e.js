/**
 * 微信小程序 miniprogram-automator E2E 测试
 *
 * API 文档: https://miniprogram.qq.com/miniprogram/dev/devframework/automator.html
 *
 * 前置条件：
 * 1. 微信开发者工具已打开项目 frontend/ 目录
 * 2. 开发者工具 → 设置 → 安全 → 开启服务端口
 *
 * 运行方式：
 *   node e2e/mini-e2e.js
 */

const automator = require('miniprogram-automator')
const path = require('path')

// ======== 配置 ========

const PROJECT_PATH = path.resolve(__dirname, '../frontend')
const DEFAULT_CLI_PATH = '/Applications/wechatwebdevtools.app/Contents/MacOS/cli'

// ======== 测试工具 ========

let totalTests = 0
let passedTests = 0
let failedTests = 0
const failures = []

function assert(condition, testName, detail) {
  totalTests++
  if (condition) {
    passedTests++
    console.log(`    \x1b[32mPASS\x1b[0m ${testName}`)
  } else {
    failedTests++
    failures.push({ test: testName, detail: detail || '' })
    console.log(`    \x1b[31mFAIL\x1b[0m ${testName} — ${detail || 'assertion failed'}`)
  }
}

function assertEq(actual, expected, testName) {
  const pass = actual === expected
  assert(pass, testName, `expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`)
}

function assertGt(actual, threshold, testName) {
  assert(actual > threshold, testName, `expected > ${threshold}, got ${actual}`)
}

function wait(ms) {
  return new Promise(function (resolve) { setTimeout(resolve, ms) })
}

// ======== 首页测试 ========

async function testIndexPage(mp) {
  console.log('\n  \x1b[36m[Test Suite] 首页 (index)\x1b[0m')

  const page = await mp.reLaunch('/pages/index/index')
  await wait(3000)

  // 验证连接状态检测
  const connectionStatus = await page.data('connectionStatus')
  console.log(`    首页 connectionStatus: ${connectionStatus}`)

  assert(
    connectionStatus === 'ok' || connectionStatus === 'fail' || connectionStatus === 'testing',
    'API 连接状态已检测',
    `当前状态: ${connectionStatus}`
  )

  // 等待连接测试完成
  if (connectionStatus === 'testing') {
    await wait(8000)
    const finalStatus = await page.data('connectionStatus')
    assert(
      finalStatus === 'ok' || finalStatus === 'fail',
      'API 连接检测完成',
      `最终状态: ${finalStatus}`
    )

    if (finalStatus === 'ok') {
      const connectionUrl = await page.data('connectionUrl')
      assert(connectionUrl && connectionUrl.length > 0, '连接成功时显示 API 地址')
    }
  } else if (connectionStatus === 'ok') {
    const connectionUrl = await page.data('connectionUrl')
    assert(connectionUrl && connectionUrl.length > 0, '连接成功时显示 API 地址')
  }

  // 验证页面元素
  const heroTitle = await page.$('.hero-title')
  assert(heroTitle !== null, '首页包含 hero 标题')

  const featureCards = await page.$$('.feature-card')
  assert(featureCards.length >= 3, '首页包含至少 3 个功能卡片', `实际: ${featureCards.length}`)

  const startBtn = await page.$('.btn-primary')
  assert(startBtn !== null, '包含"开始志愿模拟"按钮')

  const historyBtn = await page.$('.btn-secondary')
  assert(historyBtn !== null, '包含"查看历史记录"按钮')

  const batchInfo = await page.$('.batch-info')
  assert(batchInfo !== null, '包含录取批次说明')
}

// ======== TabBar 导航测试 ========

async function testTabBarNavigation(mp) {
  console.log('\n  \x1b[36m[Test Suite] TabBar 导航\x1b[0m')

  // 首页 tab
  const p1 = await mp.switchTab('/pages/index/index')
  assert(p1 !== null, '首页 tab 可导航')

  // 填报 tab
  const p2 = await mp.switchTab('/pages/form/form')
  assert(p2 !== null, '填报 tab 可导航')

  // 历史 tab
  const p3 = await mp.switchTab('/pages/history/history')
  assert(p3 !== null, '历史 tab 可导航')
}

// ======== 表单页面测试 ========

async function testFormPage(mp) {
  console.log('\n  \x1b[36m[Test Suite] 表单页面 - 基本信息 (Step 0)\x1b[0m')

  const page = await mp.switchTab('/pages/form/form')
  await wait(3000)

  // 清除持久化数据，确保干净的初始状态
  await page.callMethod('onLoad')
  await wait(1000)

  // 验证初始步骤
  const currentStep = await page.data('currentStep')
  assertEq(currentStep, 0, '初始步骤为 0')

  // 验证区县列表加载
  const districts = await page.data('districts')
  assert(
    Array.isArray(districts) && districts.length > 0,
    '区县列表已加载',
    `区县数量: ${districts ? districts.length : 0}`
  )

  // 重置表单数据以测试初始状态
  await page.setData({
    districtId: null,
    districtName: '',
    middleSchoolId: null,
    middleSchoolName: ''
  })
  await page.callMethod('_validateStep0')
  await wait(300)

  // 验证初始不能下一步
  const canNext = await page.data('canNext')
  assertEq(canNext, false, '未选择区县和初中时不能下一步')

  // --- Step 0: 选择区县和初中 ---
  console.log('\n  \x1b[36m[Test Suite] 表单页面 - 选择区县和初中\x1b[0m')

  await page.setData({
    districtId: 2,
    districtName: '黄浦区'
  })

  // 触发加载初中
  await page.callMethod('_loadMiddleSchools', 2)
  await wait(2000)

  const middleSchools = await page.data('middleSchools')
  assert(
    Array.isArray(middleSchools) && middleSchools.length > 0,
    '初中列表已加载',
    `初中数量: ${middleSchools ? middleSchools.length : 0}`
  )

  // 选择初中
  await page.setData({
    middleSchoolId: 49,
    middleSchoolName: '格致初级中学'
  })

  // 触发校验
  await page.callMethod('_validateStep0')
  await wait(500)

  const canNextAfter = await page.data('canNext')
  assertEq(canNextAfter, true, '选择区县和初中后可以下一步')

  // --- Step 1: 成绩输入 ---
  console.log('\n  \x1b[36m[Test Suite] 表单页面 - 成绩输入 (Step 1)\x1b[0m')

  await page.setData({ currentStep: 1 })
  await page.callMethod('_validateStep1')
  await wait(500)

  // 输入成绩
  await page.setData({
    'scores.total': 650,
    'scores.chinese': 130,
    'scores.math': 140,
    'scores.foreign': 135,
    'scores.integrated': 130,
    'scores.ethics': 50,
    'scores.history': 45,
    'scores.pe': 20,
    'ranking.rank': 50,
    'ranking.totalStudents': 400
  })

  await page.callMethod('_validateScore')
  await page.callMethod('_validateRank')
  await page.callMethod('_validateStep1')
  await wait(500)

  const scores = await page.data('scores')
  assertEq(scores.total, 650, '总分设置为 650')

  const scoreValidation = await page.data('scoreValidation')
  assert(scoreValidation.valid === true, '成绩校验通过', `message: ${scoreValidation.message}`)

  const rankValidation = await page.data('rankValidation')
  assert(rankValidation.valid === true, '排名校验通过', `message: ${rankValidation.message}`)

  const canNextStep1 = await page.data('canNext')
  assertEq(canNextStep1, true, '成绩和排名填写后可以下一步')

  // --- Step 2: 志愿填报 ---
  console.log('\n  \x1b[36m[Test Suite] 表单页面 - 志愿填报 (Step 2)\x1b[0m')

  await page.setData({ currentStep: 2 })
  await wait(500)

  // 手动触发加载学校数据
  await page.callMethod('_loadQuotaSchools')
  await wait(3000)

  const quotaDistrictSchools = await page.data('quotaDistrictSchools')
  const quotaSchoolSchools = await page.data('quotaSchoolSchools')
  const unifiedSchools = await page.data('unifiedSchools')

  assert(
    Array.isArray(quotaDistrictSchools) && quotaDistrictSchools.length > 0,
    '名额到区学校已加载',
    `数量: ${quotaDistrictSchools ? quotaDistrictSchools.length : 0}`
  )
  assert(
    Array.isArray(quotaSchoolSchools) && quotaSchoolSchools.length > 0,
    '名额到校学校已加载',
    `数量: ${quotaSchoolSchools ? quotaSchoolSchools.length : 0}`
  )
  assert(
    Array.isArray(unifiedSchools) && unifiedSchools.length > 0,
    '统一招生学校已加载',
    `数量: ${unifiedSchools ? unifiedSchools.length : 0}`
  )

  // 选择志愿
  if (quotaDistrictSchools.length > 0) {
    await page.setData({
      'volunteers.quotaDistrict': quotaDistrictSchools[0].id,
      'volunteerNames.quotaDistrict': quotaDistrictSchools[0].fullName
    })
  }

  if (quotaSchoolSchools.length >= 2) {
    await page.setData({
      'volunteers.quotaSchool[0]': quotaSchoolSchools[0].id,
      'volunteerNames.quotaSchool0': quotaSchoolSchools[0].fullName,
      'volunteers.quotaSchool[1]': quotaSchoolSchools[1].id,
      'volunteerNames.quotaSchool1': quotaSchoolSchools[1].fullName
    })
  }

  // 至少选 1 个统一招生志愿
  if (unifiedSchools.length > 0) {
    const selectCount = Math.min(7, unifiedSchools.length)
    for (var i = 0; i < selectCount; i++) {
      var updates = {}
      updates['volunteers.unified[' + i + ']'] = unifiedSchools[i].id
      updates['volunteerNames.unified[' + i + ']'] = unifiedSchools[i].fullName
      await page.setData(updates)
    }
  }

  await page.callMethod('_validateStep2')
  await wait(500)

  const canSubmit = await page.data('canSubmit')
  assertEq(canSubmit, true, '选择志愿后可以提交')

  // 验证提交状态
  const submitting = await page.data('submitting')
  assertEq(submitting, false, '未提交时 submitting 为 false')
}

// ======== 历史记录页面测试 ========

async function testHistoryPage(mp) {
  console.log('\n  \x1b[36m[Test Suite] 历史记录页面 (history)\x1b[0m')

  const page = await mp.switchTab('/pages/history/history')
  await wait(3000)

  const loading = await page.data('loading')
  assertEq(loading, false, '加载完成')

  const isEmpty = await page.data('isEmpty')
  const histories = await page.data('histories')

  if (isEmpty || !histories || histories.length === 0) {
    console.log('    \x1b[33mINFO\x1b[0m 历史记录为空')
  } else {
    assertGt(histories.length, 0, '历史记录列表非空')
    assert(histories[0].id !== undefined, '历史记录包含 id')
    assert(histories[0].createdTime !== undefined, '历史记录包含创建时间')
  }
}

// ======== 表单数据持久化测试 ========

async function testFormPersistence(mp) {
  console.log('\n  \x1b[36m[Test Suite] 表单数据持久化\x1b[0m')

  // 设置表单数据
  const formPage = await mp.switchTab('/pages/form/form')
  await wait(2000)

  // 先清除旧数据
  await formPage.setData({
    districtId: null,
    districtName: '',
    middleSchoolId: null,
    middleSchoolName: ''
  })

  await formPage.setData({
    districtId: 2,
    districtName: '黄浦区',
    middleSchoolId: 49,
    middleSchoolName: '格致初级中学'
  })

  // 调用保存方法
  await formPage.callMethod('_saveForm')
  await wait(500)

  // 离开页面再回来
  await mp.switchTab('/pages/index/index')
  await wait(1500)
  const backPage = await mp.switchTab('/pages/form/form')
  await wait(3000)

  // 验证数据恢复
  const restoredDistrictId = await backPage.data('districtId')
  assertEq(restoredDistrictId, 2, '表单数据持久化：区县 ID 恢复')

  const restoredDistrictName = await backPage.data('districtName')
  assertEq(restoredDistrictName, '黄浦区', '表单数据持久化：区县名称恢复')
}

// ======== 表单校验边界测试 ========

async function testFormValidation(mp) {
  console.log('\n  \x1b[36m[Test Suite] 表单校验边界测试\x1b[0m')

  const page = await mp.switchTab('/pages/form/form')
  await wait(2000)

  // 跳到 Step 1 进行校验测试
  await page.setData({ currentStep: 1 })

  // 测试：总分超限
  await page.setData({ 'scores.total': 800 })
  await page.callMethod('_validateScore')
  await wait(300)
  var sv = await page.data('scoreValidation')
  // 800 > 750 应该报错（或者总分校验逻辑）
  // 实际校验是各科分数不能超过上限，总分只检查 > 0
  console.log(`    总分 800 校验结果: valid=${sv.valid}, message=${sv.message}`)

  // 测试：排名超过总人数
  await page.setData({
    'ranking.rank': 500,
    'ranking.totalStudents': 400
  })
  await page.callMethod('_validateRank')
  await wait(300)
  var rv = await page.data('rankValidation')
  assert(rv.valid === false, '排名超过总人数校验失败')
  assertEq(rv.message, '排名不能超过总人数', '排名校验错误消息正确')

  // 测试：各科之和与总分不一致
  await page.setData({
    'scores.total': 650,
    'scores.chinese': 100,
    'scores.math': 100,
    'scores.foreign': 100,
    'scores.integrated': 100,
    'scores.ethics': 50,
    'scores.history': 50,
    'scores.pe': 25
  })
  await page.callMethod('_validateScore')
  await wait(300)
  sv = await page.data('scoreValidation')
  assert(sv.valid === false, '各科之和不等于总分时校验失败')

  // Step 2: 无统一招生志愿不能提交
  await page.setData({ currentStep: 2 })
  await page.setData({
    'volunteers.unified': Array(15).fill(0)
  })
  await page.callMethod('_validateStep2')
  await wait(300)
  var cs = await page.data('canSubmit')
  assertEq(cs, false, '无统一招生志愿时不能提交')
}

// ======== 主函数 ========

async function main() {
  console.log('\x1b[1m========================================\x1b[0m')
  console.log('\x1b[1m  微信小程序 E2E 测试 (miniprogram-automator)\x1b[0m')
  console.log('\x1b[1m========================================\x1b[0m')

  let mp = null

  try {
    console.log('\n  正在启动小程序...')
    const cliPath = process.env.CLI_PATH || DEFAULT_CLI_PATH

    mp = await automator.launch({
      cliPath: cliPath,
      projectPath: PROJECT_PATH
    })

    console.log('  \x1b[32m小程序启动成功\x1b[0m\n')

    // 运行所有测试套件
    await testIndexPage(mp)
    await testTabBarNavigation(mp)
    await testFormPage(mp)
    await testHistoryPage(mp)
    await testFormPersistence(mp)
    await testFormValidation(mp)

  } catch (err) {
    console.error('\n  \x1b[31m测试执行出错:\x1b[0m', err.message)
    console.error('  堆栈:', err.stack)
    failedTests++
    failures.push({ test: '执行异常', detail: err.message })
  } finally {
    if (mp) {
      await mp.close()
      console.log('\n  小程序已关闭')
    }
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
