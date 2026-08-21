var agent = require('../../utils/agent')
var markdown = require('../../utils/markdown')
var appConfig = require('../../utils/config')
var storage = require('../../utils/storage')

// 通用快捷问题（可直接回答，不含占位模板）
var BASE_QUICK_QUESTIONS = [
  '今年最低控制线多少',
  '名额分配到校规则是什么',
  '我们学校到校录取线多少'
]

// 追加上下文 chip：用户最近浏览的分析结果里的第一所志愿学校
// （result 页写入 storage）。无上下文时退回通用趋势问题——
// 后端 Planner 检测到缺校名会走 Clarify 追问「哪所高中」，而不是死胡同。
function buildQuickQuestions() {
  var list = BASE_QUICK_QUESTIONS.slice()
  var schools = storage.loadFocusSchools()
  if (schools && schools.length) {
    list.push(schools[0] + '三年分数线走势')
  } else {
    list.push('查一所高中的三年分数线走势')
  }
  return list
}

var msgSeq = 0
function nextMsgId() {
  msgSeq += 1
  return 'msg-' + Date.now() + '-' + msgSeq
}

// 免责声明固定脚注（Synthesizer 硬规则：每条数据类回复结尾附带）。
// 从正文拆出单独渲染，避免与正文同字号同样式。
var FOOTNOTE_RE = /\n+\s*(数据仅供参考[^\n]*官方公布为准[。.]?)\s*$/

function splitFootnote(content) {
  var m = String(content || '').match(FOOTNOTE_RE)
  if (!m) return { body: content || '', footnote: '' }
  return { body: String(content).slice(0, m.index).replace(/\s+$/, ''), footnote: m[1] }
}

/**
 * 拼接 toolCalls 的节点状态条文案
 */
function buildStatusLine(toolCalls) {
  if (!toolCalls || !toolCalls.length) return ''
  var summaries = toolCalls
    .filter(function (t) { return t && t.summary })
    .map(function (t) { return t.summary })
  if (!summaries.length) return ''
  return '已查询：' + summaries.join('、')
}

/**
 * 从 score_trend payload 中提取多年分数行
 */
function extractTrendRows(payload) {
  var arr = null
  if (Array.isArray(payload)) arr = payload
  else if (Array.isArray(payload.scores)) arr = payload.scores
  else if (Array.isArray(payload.trend)) arr = payload.trend
  else if (Array.isArray(payload.items)) arr = payload.items
  if (!arr) return []
  return arr.map(function (item) {
    if (!item || typeof item !== 'object') return null
    var year = item.year || item.examYear || ''
    var score = ''
    if (item.score !== undefined && item.score !== null) score = item.score
    else if (item.minScore !== undefined && item.minScore !== null) score = item.minScore
    else if (item.admissionScore !== undefined && item.admissionScore !== null) score = item.admissionScore
    if (year === '' && score === '') return null
    return { year: String(year), score: String(score) }
  }).filter(function (row) { return row !== null })
}

// 卡片数据明细的展示规则：技术字段隐藏，常用字段中文化。
// 原始 payload（school_id/boardiing_type_id 等）直接展示对普通用户毫无意义。
var KV_HIDDEN_KEYS = {
  school_id: true, code: true, data_nature: true, is_active: true,
  created_at: true, updated_at: true, district_filter: true, keyword: true, count: true
}

var KV_LABELS = {
  full_name: '学校',
  short_name: '简称',
  district_name: '所在区',
  school_type_id: '学校类型',
  school_nature_id: '办学性质',
  boarding_type_id: '寄宿',
  has_international_course: '国际课程',
  unified_score_latest: '最新平行志愿线',
  quota_district_score_latest: '最新名额到区线',
  quota_school_score_latest: '最新名额到校线',
  batch: '批次',
  year: '年份',
  min_score: '最低分',
  avg_score: '平均分',
  plan: '计划人数',
  score_scale: '分制'
}

var KV_VALUE_MAPS = {
  school_nature_id: { PUBLIC: '公办', PRIVATE: '民办' },
  school_type_id: {
    MUNICIPAL: '市属高中',
    CITY_MODEL: '市实验性示范性高中',
    CITY_FEATURED: '市特色普通高中',
    CITY_POLICY: '市实验性示范性高中（校区/分校）',
    DISTRICT_EXPERIMENTAL: '区实验性示范性高中',
    DISTRICT_FEATURED: '区特色普通高中',
    DISTRICT_MODEL: '区示范性高中',
    GENERAL: '普通高中'
  },
  boarding_type_id: { FULL: '全寄宿', PARTIAL: '部分寄宿', DAY: '走读', NONE: '不寄宿' },
  batch: {
    QUOTA_DISTRICT: '名额分配到区',
    QUOTA_SCHOOL: '名额分配到校',
    UNIFIED_1_15: '统一招生1-15志愿'
  }
}

// 单个值的用户可读化：枚举映射 → 布尔 → 分数条目（{year,min_score,score_scale}）
function formatKvValue(key, value) {
  if (value === null || value === undefined) return ''
  var map = KV_VALUE_MAPS[key]
  if (map && typeof value === 'string' && map[value]) return map[value]
  if (typeof value === 'boolean') return value ? '有' : '无'
  if (typeof value === 'object') {
    var parts = []
    if (value.min_score !== undefined && value.min_score !== null) parts.push(value.min_score + '分')
    if (value.avg_score !== undefined && value.avg_score !== null) parts.push('平均' + value.avg_score + '分')
    if (parts.length) {
      if (value.year) parts.push(value.year + '年')
      if (value.score_scale) parts.push(value.score_scale + '分制')
      return parts.join(' · ')
    }
    try { return JSON.stringify(value) } catch (e) { return String(value) }
  }
  return String(value)
}

/**
 * 通用 payload 转 key-value 列表（隐藏技术字段 + 中文标签）
 */
function toKvList(payload) {
  return Object.keys(payload)
    .filter(function (k) { return !KV_HIDDEN_KEYS[k] })
    .map(function (key) {
      return { key: KV_LABELS[key] || key, value: formatKvValue(key, payload[key]) }
    })
    .filter(function (row) { return row.value !== '' })
}

/**
 * 解析 schoolCards，payloadJson 为字符串需 JSON.parse 并容错
 */
function parseSchoolCards(cards) {
  if (!cards || !cards.length) return []
  return cards.map(function (card) {
    var payload = null
    if (card && card.payloadJson) {
      try {
        payload = JSON.parse(card.payloadJson)
      } catch (e) {
        payload = null
      }
    }
    var view = {
      cardType: (card && card.cardType) || '',
      schoolName: (card && card.schoolName) || '',
      districtName: (card && card.districtName) || '',
      displayType: 'kv',
      trendRows: [],
      kv: [],
      // 数据明细默认折叠：内容偏技术性，普通用户不需要展开
      kvCollapsed: true
    }
    if (payload && typeof payload === 'object') {
      if (view.cardType === 'score_trend') {
        var rows = extractTrendRows(payload)
        if (rows.length) {
          view.displayType = 'score_trend'
          view.trendRows = rows
          return view
        }
      }
      view.kv = toKvList(payload)
    }
    return view
  })
}

Page({
  data: {
    sessionId: '',
    messages: [],
    inputValue: '',
    sending: false,
    pendingQuestion: null,
    quickQuestions: [],
    scrollToId: '',
    configReady: false,
    featureOff: false,
    // 频道文案（功能开启时由后端 /app-config 下发；包体不含相关静态字样）
    ui: {
      title: '',
      subtitle: '',
      welcomeTitle: '',
      welcomeDesc: '',
      welcomeDisclaimer: ''
    }
  },

  onLoad: function () {
    var self = this
    this.setData({ quickQuestions: buildQuickQuestions() })
    // 功能开关：审核期间远程关闭顾问频道（个人开发者类目限制）。
    // 关闭时不渲染任何内容，直接展示中性内容——页面完全不可见。
    this.sessionReady = appConfig.fetchAppConfig().then(function (cfg) {
      if (!cfg.agentEnabled) {
        // 功能关闭（审核期）：停留本页展示中性诗意内容，不跳走、无任何频道痕迹
        self.setData({ featureOff: true })
        return null
      }
      // 功能开启时由后端文案恢复真实标题（app.json/chat.json 中为审核安全的中性标题「更多」）
      var ui = cfg.agentUi || {}
      self.setData({
        configReady: true,
        ui: {
          title: ui.title || '',
          subtitle: ui.subtitle || '',
          welcomeTitle: ui.welcome_title || '',
          welcomeDesc: ui.welcome_desc || '',
          welcomeDisclaimer: ui.welcome_disclaimer || ''
        }
      })
      if (ui.title) {
        wx.setNavigationBarTitle({ title: ui.title })
      }
      return self.initSession()
    })
  },

  onShow: function () {
    // 每次进入/回到本页都刷新上下文 chip（用户可能刚看完分析结果回来）
    this.setData({ quickQuestions: buildQuickQuestions() })
    if (!this.data.configReady) return
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 2 })
    }
    var app = getApp()
    var analysisId = app && app.globalData && app.globalData.pendingAnalysisId
    if (analysisId) {
      app.globalData.pendingAnalysisId = null
      var self = this
      Promise.resolve(this.sessionReady).then(function () {
        self.sendMessage('帮我解读这份模拟结果', { context: { analysisId: analysisId } })
      })
    }
  },

  initSession: function () {
    var self = this
    var stored = ''
    try {
      stored = wx.getStorageSync('agentSessionId') || ''
    } catch (e) {}

    if (stored) {
      this.setData({ sessionId: stored })
      return agent.getAgentHistory(stored, 50).then(function (res) {
        var history = (res && res.messages) || []
        if (!history.length) return
        var messages = history.map(function (m) {
          var role = (m && m.role === 'user') ? 'user' : 'assistant'
          var split = role === 'assistant' ? splitFootnote((m && m.content) || '') : { body: (m && m.content) || '', footnote: '' }
          return {
            id: nextMsgId(),
            role: role,
            content: split.body,
            footnote: split.footnote,
            nodes: role === 'assistant' ? markdown.toNodes(split.body) : null,
            statusLine: '',
            cards: []
          }
        })
        self.setData({ messages: messages })
        self.scrollToBottom()
      }).catch(function () {
        // 历史加载失败不阻塞会话
      })
    }

    return this.createSession()
  },

  createSession: function () {
    var self = this
    return agent.newAgentSession().then(function (res) {
      var sessionId = (res && res.sessionId) || ''
      if (!sessionId) {
        throw new Error('会话创建失败')
      }
      try {
        wx.setStorageSync('agentSessionId', sessionId)
      } catch (e) {}
      self.setData({ sessionId: sessionId })
      return sessionId
    }).catch(function (err) {
      wx.showToast({ title: '会话初始化失败，请稍后重试', icon: 'none' })
      throw err
    })
  },

  onNewChat: function () {
    try {
      wx.removeStorageSync('agentSessionId')
    } catch (e) {}
    this.setData({
      sessionId: '',
      messages: [],
      inputValue: '',
      sending: false,
      pendingQuestion: null
    })
    this.sessionReady = this.createSession()
  },

  onInput: function (e) {
    this.setData({ inputValue: e.detail.value })
  },

  onSend: function () {
    var text = (this.data.inputValue || '').trim()
    if (!text || this.data.sending) return
    this.setData({ inputValue: '' })
    this.sendMessage(text, {})
  },

  onQuickQuestion: function (e) {
    if (this.data.sending) return
    var text = e.currentTarget.dataset.text
    if (!text) return
    this.sendMessage(text, {})
  },

  onPendingOption: function (e) {
    if (this.data.sending) return
    var text = e.currentTarget.dataset.text
    if (!text) return
    this.setData({ pendingQuestion: null })
    this.sendMessage(text, { pendingAnswer: text })
  },

  // 展开/收起卡片数据明细
  onToggleKvCard: function (e) {
    var mi = e.currentTarget.dataset.mi
    var ci = e.currentTarget.dataset.ci
    var msg = this.data.messages[mi]
    var card = msg && msg.cards && msg.cards[ci]
    if (!card) return
    var upd = {}
    upd['messages[' + mi + '].cards[' + ci + '].kvCollapsed'] = !card.kvCollapsed
    this.setData(upd)
  },

  sendMessage: function (text, extra) {
    extra = extra || {}
    var self = this
    if (!text || this.data.sending || !this.data.configReady) return

    var userMsg = {
      id: nextMsgId(),
      role: 'user',
      content: text,
      statusLine: '',
      cards: []
    }
    this.setData({
      messages: this.data.messages.concat([userMsg]),
      sending: true
    })
    this.scrollToBottom()

    Promise.resolve(this.sessionReady).then(function () {
      var params = {
        sessionId: self.data.sessionId,
        message: text
      }
      if (extra.context) params.context = extra.context
      if (extra.pendingAnswer) params.pendingAnswer = extra.pendingAnswer
      return agent.agentChat(params)
    }).then(function (res) {
      res = res || {}
      if (res.sessionId && res.sessionId !== self.data.sessionId) {
        try {
          wx.setStorageSync('agentSessionId', res.sessionId)
        } catch (e) {}
        self.setData({ sessionId: res.sessionId })
      }
      var split = splitFootnote(res.reply || '')
      var assistantMsg = {
        id: nextMsgId(),
        role: 'assistant',
        content: split.body,
        footnote: split.footnote,
        nodes: markdown.toNodes(split.body),
        statusLine: buildStatusLine(res.toolCalls),
        cards: parseSchoolCards(res.schoolCards)
      }
      self.setData({
        messages: self.data.messages.concat([assistantMsg]),
        sending: false,
        pendingQuestion: (res.pendingQuestion && res.pendingQuestion.question)
          ? res.pendingQuestion
          : null
      })
      self.scrollToBottom()
    }).catch(function (err) {
      var errorMsg = {
        id: nextMsgId(),
        role: 'assistant',
        content: (err && err.message)
          ? ('出错了：' + err.message + '，请稍后重试')
          : '出错了，请稍后重试',
        statusLine: '',
        cards: []
      }
      self.setData({
        messages: self.data.messages.concat([errorMsg]),
        sending: false
      })
      self.scrollToBottom()
    })
  },

  scrollToBottom: function () {
    var self = this
    setTimeout(function () {
      var last = self.data.messages[self.data.messages.length - 1]
      var anchor = self.data.sending
        ? 'chat-typing'
        : (last ? last.id : 'chat-bottom')
      self.setData({ scrollToId: anchor })
    }, 100)
  }
})
