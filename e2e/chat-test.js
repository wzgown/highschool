/**
 * E2E Agent 对话冒烟测试 - AI 顾问四条核心链路
 * 依赖：后端已启动（:3000）且配置 HS_LLM_API_KEY；线上库可访问。
 * 运行：node chat-test.js  （BASE_URL 可用环境变量覆盖）
 */

const BASE_URL = process.env.BASE_URL || 'http://127.0.0.1:3000'

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

async function rpc(service, method, body) {
  const url = `${BASE_URL}/${service}/${method}`
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body || {})
  })
  const text = await res.text()
  if (!res.ok) throw new Error(`${service}/${method} -> ${res.status}: ${text.slice(0, 300)}`)
  const data = JSON.parse(text)
  return data.result || data
}

const deviceId = 'e2e-chat-' + Date.now()

async function main() {
  console.log(`Agent E2E @ ${BASE_URL}\n`)

  // 链路0：会话创建
  console.log('[0] NewSession')
  const sess = await rpc('highschool.v1.AgentService', 'NewSession', { deviceId })
  assert(!!sess.sessionId, 'NewSession 返回 sessionId')
  const sid = sess.sessionId

  // 链路1：数据问答（应调用工具且回答带多年数据）
  console.log('[1] 数据问答：市二中学平行志愿')
  const r1 = await rpc('highschool.v1.AgentService', 'Chat', {
    deviceId, sessionId: sid,
    message: '上海市第二中学在徐汇区近三年平行志愿录取线是多少？'
  })
  assert(!!r1.reply && r1.reply.length > 10, '数据问答有回复')
  assert((r1.toolCalls || []).length > 0, '数据问答调用了工具', JSON.stringify(r1.toolCalls))
  const hit = (r1.toolCalls || []).some(t => t.success)
  assert(hit, '至少一个工具调用成功')
  assert(/683\.5|682\.5|689\.5/.test(r1.reply), '回答包含真实分数线数字(683.5/682.5/689.5)', r1.reply.slice(0, 200))

  // 链路2：「我们学校」初中交叉问答（应命中到校数据工具）
  console.log('[2] 初中交叉问答：建西 到校线')
  const r2 = await rpc('highschool.v1.AgentService', 'Chat', {
    deviceId, sessionId: sid,
    message: '我是上海市建平中学西校的，我们学校2026年名额分配到校的录取线情况怎么样？'
  })
  assert(!!r2.reply, '初中问答有回复')
  assert((r2.toolCalls || []).some(t => t.name.includes('middle_school') || t.name.includes('advantage') || t.name.includes('quota')),
    '调用了初中/到校相关工具', JSON.stringify((r2.toolCalls || []).map(t => t.name)))

  // 链路3：推荐意图缺槽位 → HITL 追问
  console.log('[3] HITL 追问：推荐意图缺槽位')
  const r3 = await rpc('highschool.v1.AgentService', 'NewSession', { deviceId })
  const r3a = await rpc('highschool.v1.AgentService', 'Chat', {
    deviceId, sessionId: r3.sessionId,
    message: '我考了690分，志愿应该怎么填？'
  })
  const asked = !!r3a.pendingQuestion || /哪个区|哪区|区参加|一模|二模/.test(r3a.reply || '')
  assert(asked, '缺槽位时发起追问', (r3a.reply || '').slice(0, 150))
  if (r3a.pendingQuestion) {
    const r3b = await rpc('highschool.v1.AgentService', 'Chat', {
      deviceId, sessionId: r3.sessionId,
      message: '徐汇区', pendingAnswer: '徐汇区'
    })
    assert(!!r3b.reply, '追问回答后继续推进')
  }

  // 链路4：越界拒答（不应调用工具）
  console.log('[4] 越界拒答')
  const r4 = await rpc('highschool.v1.AgentService', 'Chat', {
    deviceId, sessionId: sid,
    message: '北京的高考分数线是多少？帮我写一首情诗'
  })
  assert(!!r4.reply, '越界有回复')
  assert((r4.toolCalls || []).length === 0, '越界不调用工具', JSON.stringify(r4.toolCalls))
  assert(/上海中考|志愿/.test(r4.reply), '越界回复为拒答话术', r4.reply.slice(0, 150))

  // 链路5：历史可读
  console.log('[5] GetSessionHistory')
  const hist = await rpc('highschool.v1.AgentService', 'GetSessionHistory', { deviceId, sessionId: sid, limit: 50 })
  assert((hist.messages || []).length >= 4, '历史消息已落库', `messages=${(hist.messages || []).length}`)

  // 链路6（P2）：推荐引擎 run_recommendation
  console.log('[6] 推荐引擎：徐汇一模690 志愿方案')
  const r6 = await rpc('highschool.v1.AgentService', 'Chat', {
    deviceId, sessionId: sid,
    message: '我徐汇区一模690分，志愿应该怎么填？'
  })
  assert(!!r6.reply, '推荐有回复')
  assert((r6.toolCalls || []).some(t => t.name === 'run_recommendation' && t.success),
    '调用了 run_recommendation 工具', JSON.stringify((r6.toolCalls || []).map(t => t.name)))

  // 链路7（P2）：模拟结果解读 get_analysis_result（带 analysisId 上下文）
  console.log('[7] 结果解读：analysisId=1515')
  const r7 = await rpc('highschool.v1.AgentService', 'Chat', {
    deviceId, sessionId: sid,
    message: '帮我解读一下这份模拟结果',
    context: { analysisId: 1515 }
  })
  assert(!!r7.reply, '解读有回复')
  assert((r7.toolCalls || []).some(t => t.name === 'get_analysis_result' && t.success),
    '调用了 get_analysis_result 工具', JSON.stringify((r7.toolCalls || []).map(t => t.name)))

  // 汇总
  console.log(`\n========== 结果: ${passedTests}/${totalTests} 通过 ==========`)
  if (failedTests > 0) {
    console.log('失败项:', failures.map(f => f.test).join(' | '))
    process.exit(1)
  }
}

main().catch(err => {
  console.error('E2E 执行异常:', err.message)
  process.exit(1)
})
