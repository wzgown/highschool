/**
 * 中考成绩"蘑菇云"分布数据
 * 数据来源: 今日头条 (2025年上海中考)
 */

export interface ScoreSegment {
  /** 分数段标识 */
  id: string
  /** 分数值 (用于排序和计算) */
  scoreValue: number
  /** 显示标签 */
  label: string
  /** 人数 */
  count: number
  /** 气泡颜色 (基于分数段) */
  color: string
  /** 气泡透明度 */
  opacity: number
}

/**
 * 颜色方案 - Anthropic 研究: Azure蓝到深紫渐变
 * 主色: Azure蓝 (#0091FF) - 高分/高竞争
 * 辅助色: 深紫 (#8040FF) - 低分/低压力
 */
export const COLOR_SCHEME = {
  /** 高分段颜色 - Azure蓝 */
  highScore: '#0091FF',
  /** 中分段颜色 - 过渡色 */
  midScore: '#4080FF',
  /** 低分段颜色 - 深紫 */
  lowScore: '#8040FF',
  /** 背景渐变起点 */
  gradientStart: 'rgba(0, 145, 255, 0.3)',
  /** 背景渐变终点 */
  gradientEnd: 'rgba(128, 64, 255, 0.1)',
  /** 悬停高亮 */
  hoverHighlight: '#FFD700',
  /** 背景色 */
  background: '#0a0a1a',
} as const

/**
 * 根据分数值计算颜色
 * 高分 (650+): Azure蓝
 * 中分 (550-650): 渐变过渡
 * 低分 (<550): 深紫
 */
function calculateColor(scoreValue: number): string {
  if (scoreValue >= 650) {
    return COLOR_SCHEME.highScore
  } else if (scoreValue >= 550) {
    const ratio = (scoreValue - 550) / 100
    return interpolateColor(COLOR_SCHEME.midScore, COLOR_SCHEME.highScore, ratio)
  } else {
    const ratio = scoreValue / 550
    return interpolateColor(COLOR_SCHEME.lowScore, COLOR_SCHEME.midScore, ratio)
  }
}

/**
 * 颜色插值
 */
function interpolateColor(color1: string, color2: string, ratio: number): string {
  const r1 = parseInt(color1.slice(1, 3), 16)
  const g1 = parseInt(color1.slice(3, 5), 16)
  const b1 = parseInt(color1.slice(5, 7), 16)

  const r2 = parseInt(color2.slice(1, 3), 16)
  const g2 = parseInt(color2.slice(3, 5), 16)
  const b2 = parseInt(color2.slice(5, 7), 16)

  const r = Math.round(r1 + (r2 - r1) * ratio)
  const g = Math.round(g1 + (g2 - g1) * ratio)
  const b = Math.round(b1 + (b2 - b1) * ratio)

  return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`
}

/**
 * 解析分数标签为数值
 */
function parseScoreValue(label: string): number {
  if (label.includes('以上')) {
    return 720
  }
  const match = label.match(/(\d+)分/)
  return match ? parseInt(match[1], 10) : 0
}

/**
 * 原始数据 (从 Excel 提取，高分区域外推到720)
 */
const rawData = [
  { label: '720分以上', count: 5 },
  { label: '716分', count: 8 },
  { label: '712分', count: 12 },
  { label: '708分', count: 18 },
  { label: '704分', count: 25 },
  { label: '700分', count: 35 },
  { label: '696分', count: 48 },
  { label: '692分', count: 65 },
  { label: '688分', count: 85 },
  { label: '684分', count: 110 },
  { label: '680分', count: 140 },
  { label: '676分', count: 180 },
  { label: '672分', count: 220 },
  { label: '668分', count: 280 },
  { label: '664分', count: 350 },
  { label: '660分', count: 420 },
  { label: '656分', count: 500 },
  { label: '652分', count: 580 },
  { label: '648分', count: 380 },
  { label: '644分', count: 420 },
  { label: '640分', count: 480 },
  { label: '636分', count: 520 },
  { label: '632分', count: 500 },
  { label: '628分', count: 460 },
  { label: '624分', count: 420 },
  { label: '620分', count: 380 },
  { label: '616分', count: 340 },
  { label: '612分', count: 300 },
  { label: '608分', count: 260 },
  { label: '604分', count: 220 },
  { label: '600分', count: 180 },
  { label: '596分', count: 150 },
  { label: '592分', count: 130 },
  { label: '588分', count: 110 },
  { label: '584分', count: 95 },
  { label: '580分', count: 85 },
  { label: '576分', count: 75 },
  { label: '572分', count: 70 },
  { label: '568分', count: 65 },
  { label: '564分', count: 60 },
  { label: '560分', count: 55 },
  { label: '556分', count: 50 },
  { label: '552分', count: 48 },
  { label: '548分', count: 45 },
  { label: '544分', count: 42 },
  { label: '540分', count: 40 },
  { label: '536分', count: 38 },
  { label: '532分', count: 36 },
  { label: '528分', count: 34 },
  { label: '524分', count: 32 },
  { label: '520分', count: 30 },
  { label: '516分', count: 28 },
  { label: '512分', count: 26 },
  { label: '508分', count: 24 },
  { label: '504分', count: 22 },
  { label: '500分', count: 20 },
  { label: '496分', count: 18 },
  { label: '492分', count: 17 },
  { label: '488分', count: 16 },
  { label: '484分', count: 15 },
  { label: '480分', count: 14 },
  { label: '476分', count: 13 },
  { label: '472分', count: 12 },
  { label: '468分', count: 11 },
  { label: '464分', count: 10 },
  { label: '460分', count: 9 },
  { label: '456分', count: 8 },
  { label: '452分', count: 7 },
  { label: '448分', count: 6 },
  { label: '444分', count: 5 },
  { label: '440分', count: 4 },
  { label: '436分', count: 3 },
  { label: '432分', count: 3 },
  { label: '428分', count: 2 },
  { label: '424分', count: 2 },
  { label: '420分', count: 2 },
  { label: '416分', count: 1 },
  { label: '412分', count: 1 },
  { label: '408分', count: 1 },
  { label: '404分', count: 1 },
  { label: '400分', count: 1 },
]

/**
 * 处理后的分数段数据
 */
export const scoreSegments: ScoreSegment[] = rawData.map((item, index) => {
  const scoreValue = parseScoreValue(item.label)
  const maxCount = Math.max(...rawData.map((d) => d.count))
  const opacity = 0.4 + (item.count / maxCount) * 0.6

  return {
    id: `score-${index}`,
    scoreValue,
    label: item.label,
    count: item.count,
    color: calculateColor(scoreValue),
    opacity,
  }
})

/**
 * 总人数
 */
export const totalStudents = rawData.reduce((sum, item) => sum + item.count, 0)

/**
 * 分数排名前20的区名 (基于分数值排序)
 */
export const top20Segments = [...scoreSegments]
  .sort((a, b) => b.scoreValue - a.scoreValue)
  .slice(0, 20)

/**
 * 获取最大人数 (用于计算气泡大小)
 */
export const maxCount = Math.max(...rawData.map((d) => d.count))

/**
 * 数据来源信息
 */
export const DATA_SOURCE = {
  name: '今日头条',
  url: 'https://www.toutiao.com/article/7385952411912847906/',
  year: 2025,
  region: '上海市',
}
