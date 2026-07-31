/**
 * Mock LLM（OpenAI 兼容）— 供 Agent 集成测试用
 * 按 system prompt 关键字路由：意图识别器/任务规划器/折桂登高(synthesizer)
 * 用法: node mock-llm.js [port]   (默认 3999)
 */
const http = require('http')
const port = Number(process.argv[2] || 3999)

function reply(content) {
  return {
    id: 'chatcmpl-mock',
    object: 'chat.completion',
    choices: [{ index: 0, message: { role: 'assistant', content }, finish_reason: 'stop' }],
    usage: { prompt_tokens: 100, completion_tokens: 50 }
  }
}

function lastUserText(messages) {
  for (let i = messages.length - 1; i >= 0; i--) {
    if (messages[i].role === 'user') return String(messages[i].content || '')
  }
  return ''
}

function route(messages) {
  const sys = String((messages[0] || {}).content || '')
  const user = lastUserText(messages)

  if (sys.includes('意图识别器')) {
    if (/北京|情诗|高考/.test(user)) {
      return JSON.stringify({ intent: 'off_topic', confidence: 0.99, slots: {} })
    }
    if (/解读|模拟结果|我的结果/.test(user)) {
      return JSON.stringify({ intent: 'result_interpretation', confidence: 0.95, slots: { analysis_id: 1515 } })
    }
    if (/一模|二模/.test(user) && /怎么填|如何填|志愿/.test(user)) {
      return JSON.stringify({ intent: 'recommendation', confidence: 0.95, slots: { district_name: '徐汇区', total_score: 690, exam_type: 'MOCK1' } })
    }
    if (/怎么填|如何填|志愿.*建议/.test(user) && /690/.test(user)) {
      return JSON.stringify({ intent: 'recommendation', confidence: 0.95, slots: { total_score: 690 } })
    }
    if (/徐汇区/.test(user) && /690|怎么填/.test(user)) {
      return JSON.stringify({ intent: 'recommendation', confidence: 0.95, slots: { total_score: 690, district_name: '徐汇区' } })
    }
    if (/建平中学西校/.test(user)) {
      return JSON.stringify({ intent: 'data_query', confidence: 0.95, slots: { middle_school_name: '上海市建平中学西校', district_name: '浦东新区' } })
    }
    return JSON.stringify({ intent: 'data_query', confidence: 0.95, slots: { school_names: ['上海市第二中学'], district_name: '徐汇区', batch: 'UNIFIED_1_15' } })
  }

  if (sys.includes('任务规划器')) {
    if (/解读|模拟结果|我的结果|result_interpretation/.test(user)) {
      return JSON.stringify({ steps: [{ tool_name: 'get_analysis_result', args: { analysis_id: 1515 } }] })
    }
    if (/一模|MOCK1|怎么填|recommendation/.test(user) && /690/.test(user)) {
      return JSON.stringify({ steps: [{ tool_name: 'run_recommendation', args: { district_name: '徐汇区', total_score: 690, exam_type: 'MOCK1' } }] })
    }
    if (/690/.test(user)) {
      return JSON.stringify({ steps: [{ tool_name: 'locate_score', args: { district_name: '徐汇区', score: 690, batch: 'UNIFIED_1_15' } }] })
    }
    if (/建平中学西校/.test(user)) {
      return JSON.stringify({ steps: [{ tool_name: 'get_middle_school_advantage', args: { middle_school_name: '上海市建平中学西校' } }] })
    }
    return JSON.stringify({ steps: [{ tool_name: 'get_admission_scores', args: { school_name: '上海市第二中学', district_name: '徐汇区', batch: 'UNIFIED_1_15' } }] })
  }

  // synthesizer：从注入的工具结果中提取 year/min_score 组织回答（数字全部可溯源）
  const pairs = [...user.matchAll(/"year"\s*:\s*(\d+)[^}]*?"min_score"\s*:\s*([\d.]+)/g)].map(m => `${m[1]}年${m[2]}分`)
  if (pairs.length > 0) {
    return `根据官方数据：${pairs.slice(0, 6).join('、')}（平行志愿为750分制）。数据仅供参考，以上海市教育考试院官方公布为准。`
  }
  // locate_score / advantage 等其他工具结果：引用其中出现的数字
  const nums = [...user.matchAll(/"min_score"\s*:\s*([\d.]+)/g)].map(m => m[1])
  if (nums.length > 0) {
    return `查询结果如下：相关录取线为 ${nums.slice(0, 5).join('、')} 分。数据仅供参考，以上海市教育考试院官方公布为准。`
  }
  // 推荐引擎结果：引用预估线
  const est = [...user.matchAll(/"estimated_score"\s*:\s*([\d.]+)/g)].map(m => m[1])
  if (est.length > 0) {
    return `根据您的成绩，为您推荐冲稳保方案，相关学校预估参考线为 ${est.slice(0, 5).join('、')} 分（750分制）。数据仅供参考，以上海市教育考试院官方公布为准。`
  }
  // 模拟结果：引用概率
  const prob = [...user.matchAll(/"probability"\s*:\s*([\d.]+)/g)].map(m => m[1])
  if (prob.length > 0) {
    return `您的模拟结果中，各志愿录取概率为 ${prob.slice(0, 5).join('%、')}%。数据仅供参考，以上海市教育考试院官方公布为准。`
  }
  return '已为您查询。数据仅供参考，以上海市教育考试院官方公布为准。'
}

http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/chat/completions') {
    let body = ''
    req.on('data', c => (body += c))
    req.on('end', () => {
      try {
        const { messages } = JSON.parse(body)
        const content = route(messages || [])
        res.writeHead(200, { 'Content-Type': 'application/json' })
        res.end(JSON.stringify(reply(content)))
      } catch (e) {
        res.writeHead(400).end(e.message)
      }
    })
  } else {
    res.writeHead(404).end()
  }
}).listen(port, () => console.log(`mock-llm listening on :${port}`))
