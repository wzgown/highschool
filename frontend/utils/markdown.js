/**
 * markdown.js — 轻量 Markdown → 微信小程序 rich-text nodes 转换器
 * 支持：表格、标题(#~####)、加粗、斜体、行内代码、无序/有序列表、段落。
 * 只处理助手回复中常见的安全子集，不解析图片/链接/HTML。
 */

var P_STYLE = 'margin:0 0 10rpx 0;line-height:1.7;font-size:28rpx;color:#2b333d;'
var TABLE_STYLE = 'border-collapse:collapse;margin:8rpx 0 14rpx 0;font-size:26rpx;max-width:100%;'
var CELL_STYLE = 'border:1rpx solid #d8dee6;padding:8rpx 14rpx;text-align:left;line-height:1.5;'
var HEAD_CELL_STYLE = CELL_STYLE + 'background:#f2f6f5;font-weight:600;color:#1f7a68;'
var CODE_STYLE = 'background:#f1f3f5;border-radius:6rpx;padding:2rpx 8rpx;font-size:24rpx;'
var LIST_STYLE = 'margin:0 0 10rpx 0;padding-left:36rpx;line-height:1.7;font-size:28rpx;'
var H_STYLE = 'margin:12rpx 0 8rpx 0;line-height:1.5;color:#1f7a68;'

function text(t) { return { type: 'text', text: t } }

// 行内解析：**bold**、*em*、`code`
function parseInline(str) {
  var children = []
  var re = /(\*\*[^*\n]+\*\*|\*[^*\n]+\*|`[^`\n]+`)/g
  var parts = String(str).split(re)
  for (var i = 0; i < parts.length; i++) {
    var p = parts[i]
    if (!p) continue
    if (/^\*\*[^*\n]+\*\*$/.test(p)) {
      children.push({ name: 'strong', children: [text(p.slice(2, -2))] })
    } else if (/^\*[^*\n]+\*$/.test(p)) {
      children.push({ name: 'em', children: [text(p.slice(1, -1))] })
    } else if (/^`[^`\n]+`$/.test(p)) {
      children.push({ name: 'code', attrs: { style: CODE_STYLE }, children: [text(p.slice(1, -1))] })
    } else {
      children.push(text(p))
    }
  }
  return children
}

function splitRow(line) {
  // 去掉首尾的 | 再切分
  var cells = String(line).trim().replace(/^\|/, '').replace(/\|$/, '').split('|')
  return cells.map(function (c) { return c.trim() })
}

function isTableLine(line) { return /^\s*\|.*\|\s*$/.test(line) }
function isTableSep(line) { return /^\s*\|[\s:|-]+\|\s*$/.test(line) }

function buildTable(headerLine, bodyLines) {
  var headers = splitRow(headerLine)
  var headRow = {
    name: 'tr',
    children: headers.map(function (h) {
      return { name: 'th', attrs: { style: HEAD_CELL_STYLE }, children: parseInline(h) }
    })
  }
  var rows = [headRow]
  for (var i = 0; i < bodyLines.length; i++) {
    var cells = splitRow(bodyLines[i])
    rows.push({
      name: 'tr',
      children: cells.map(function (c) {
        return { name: 'td', attrs: { style: CELL_STYLE }, children: parseInline(c) }
      })
    })
  }
  return { name: 'table', attrs: { style: TABLE_STYLE }, children: rows }
}

/**
 * toNodes(markdown) -> rich-text nodes 数组
 */
function toNodes(md) {
  var lines = String(md || '').replace(/\r\n/g, '\n').split('\n')
  var nodes = []
  var i = 0
  while (i < lines.length) {
    var line = lines[i]

    // 表格块
    if (isTableLine(line) && i + 1 < lines.length && isTableSep(lines[i + 1])) {
      var body = []
      i += 2
      while (i < lines.length && isTableLine(lines[i])) {
        body.push(lines[i])
        i++
      }
      nodes.push(buildTable(line, body))
      continue
    }

    // 标题
    var h = line.match(/^\s*(#{1,6})\s+(.*)$/)
    if (h) {
      var level = Math.min(h[1].length + 2, 6) // # → h3，避免过大
      var size = level === 3 ? '30rpx' : '28rpx'
      nodes.push({
        name: 'h' + level,
        attrs: { style: H_STYLE + 'font-size:' + size + ';' },
        children: parseInline(h[2])
      })
      i++
      continue
    }

    // 无序列表
    if (/^\s*[-*•]\s+/.test(line)) {
      var ulItems = []
      while (i < lines.length && /^\s*[-*•]\s+/.test(lines[i])) {
        ulItems.push({
          name: 'li',
          children: parseInline(lines[i].replace(/^\s*[-*•]\s+/, ''))
        })
        i++
      }
      nodes.push({ name: 'ul', attrs: { style: LIST_STYLE }, children: ulItems })
      continue
    }

    // 有序列表
    if (/^\s*\d+\.\s+/.test(line)) {
      var olItems = []
      while (i < lines.length && /^\s*\d+\.\s+/.test(lines[i])) {
        olItems.push({
          name: 'li',
          children: parseInline(lines[i].replace(/^\s*\d+\.\s+/, ''))
        })
        i++
      }
      nodes.push({ name: 'ol', attrs: { style: LIST_STYLE }, children: olItems })
      continue
    }

    // 空行
    if (!line.trim()) { i++; continue }

    // 段落
    nodes.push({ name: 'p', attrs: { style: P_STYLE }, children: parseInline(line) })
    i++
  }
  return nodes
}

module.exports = {
  toNodes: toNodes
}
