var agent = require('../../utils/agent')

var QUICK_QUESTIONS = [
  '今年最低控制线多少',
  '名额分配到校规则是什么',
  '我们学校到校录取线多少',
  'XX 中学三年分数线走势'
]

var msgSeq = 0
function nextMsgId() {
  msgSeq += 1
  return 'msg-' + Date.now() + '-' + msgSeq
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

/**
 * 通用 payload 转 key-value 列表
 */
function toKvList(payload) {
  return Object.keys(payload).map(function (key) {
    var value = payload[key]
    if (value === null || value === undefined) {
      value = ''
    } else if (typeof value === 'object') {
      try {
        value = JSON.stringify(value)
      } catch (e) {
        value = String(value)
      }
    }
    return { key: key, value: String(value) }
  })
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
      kv: []
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
    quickQuestions: QUICK_QUESTIONS,
    scrollToId: ''
  },

  onLoad: function () {
    this.sessionReady = this.initSession()
  },

  onShow: function () {
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
          return {
            id: nextMsgId(),
            role: (m && m.role === 'user') ? 'user' : 'assistant',
            content: (m && m.content) || '',
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

  sendMessage: function (text, extra) {
    extra = extra || {}
    var self = this
    if (!text || this.data.sending) return

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
      var assistantMsg = {
        id: nextMsgId(),
        role: 'assistant',
        content: res.reply || '',
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
