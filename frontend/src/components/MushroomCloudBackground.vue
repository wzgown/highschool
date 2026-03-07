<template>
  <div class="mushroom-cloud-container" ref="containerRef">
    <canvas
      ref="canvasRef"
      class="mushroom-cloud-canvas"
      @mousemove="handleMouseMove"
      @mouseleave="handleMouseLeave"
      @click="handleClick"
    ></canvas>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import { useRouter } from 'vue-router'
import {
  scoreSegments,
  COLOR_SCHEME,
  maxCount,
  totalStudents,
  type ScoreSegment,
} from '@/data/mushroomCloudData'

interface Particle {
  x: number
  y: number
  baseY: number
  radius: number
  color: string
  alpha: number
  speed: number
  phase: number
  scoreSegment: ScoreSegment
  velocityY: number
}

const props = withDefaults(
  defineProps<{
    particleDensity?: number
    showLabels?: boolean
    animationSpeed?: number
  }>(),
  {
    particleDensity: 15,
    showLabels: true,
    animationSpeed: 1,
  }
)

const router = useRouter()

const containerRef = ref<HTMLDivElement | null>(null)
const canvasRef = ref<HTMLCanvasElement | null>(null)
let animationId: number | null = null
let particles: Particle[] = []
let prefersReducedMotion = false

// 悬停状态
const hoveredSegment = ref<ScoreSegment | null>(null)
const mousePosition = ref({ x: 0, y: 0 })

// 根据分数计算颜色 (使用配置文件中的方案)
const getColorForScore = (score: number): string => {
  if (score >= 650) {
    return COLOR_SCHEME.highScore
  } else if (score >= 550) {
    const ratio = (score - 550) / 100
    return interpolateColor(COLOR_SCHEME.midScore, COLOR_SCHEME.highScore, ratio)
  } else {
    const ratio = score / 550
    return interpolateColor(COLOR_SCHEME.lowScore, COLOR_SCHEME.midScore, ratio)
  }
}

// 颜色插值
const interpolateColor = (color1: string, color2: string, ratio: number): string => {
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

// 初始化粒子 - 蘑菇云效果
const initParticles = () => {
  if (!canvasRef.value) return

  const canvas = canvasRef.value
  const dpr = window.devicePixelRatio || 1
  const width = canvas.width / dpr
  const height = canvas.height / dpr

  particles = []

  const minScore = Math.min(...scoreSegments.map((s) => s.scoreValue))
  const maxScore = Math.max(...scoreSegments.map((s) => s.scoreValue))

  // 为每个分数段创建粒子群
  scoreSegments.forEach((segment) => {
    // 根据人数确定粒子数量
    const particleCount = Math.max(3, Math.floor((segment.count / maxCount) * props.particleDensity * 10))

    // Y轴位置: 高分在上，低分在下
    const normalizedY = (segment.scoreValue - minScore) / (maxScore - minScore)
    const baseY = height * (0.9 - normalizedY * 0.75)

    // 气泡大小基于人数
    const bubbleRadius = 5 + (segment.count / maxCount) * 25

    for (let i = 0; i < particleCount; i++) {
      // 高斯分布生成蘑菇云形状
      const u1 = Math.random()
      const u2 = Math.random()
      const gaussian = Math.sqrt(-2 * Math.log(Math.max(0.0001, u1))) * Math.cos(2 * Math.PI * u2)

      // 水平扩散: 低分区域扩散更宽（蘑菇云底部）
      const spreadFactor = 0.06 + (1 - normalizedY) * 0.3
      const x = width * 0.5 + gaussian * width * spreadFactor

      // 垂直偏移
      const verticalSpread = bubbleRadius * 0.8
      const y = baseY + (Math.random() - 0.5) * verticalSpread

      // 粒子大小: 中心粒子更大
      const distFromCenter = Math.abs(gaussian)
      const sizeFactor = 1 - distFromCenter * 0.3
      const radius = Math.max(1.5, (2 + Math.random() * 3) * sizeFactor)

      // 上升速度: 低分区域上升更慢
      const speed = (0.2 + normalizedY * 0.4 + Math.random() * 0.3) * props.animationSpeed

      particles.push({
        x,
        y,
        baseY,
        radius,
        color: segment.color,
        alpha: segment.opacity * (0.6 + Math.random() * 0.4),
        speed,
        phase: Math.random() * Math.PI * 2,
        scoreSegment: segment,
        velocityY: -speed,
      })
    }
  })
}

// 调整Canvas大小
const resizeCanvas = () => {
  if (!canvasRef.value || !containerRef.value) return

  const canvas = canvasRef.value
  const parent = containerRef.value
  const dpr = window.devicePixelRatio || 1
  const rect = parent.getBoundingClientRect()

  canvas.width = rect.width * dpr
  canvas.height = rect.height * dpr
  canvas.style.width = `${rect.width}px`
  canvas.style.height = `${rect.height}px`

  const ctx = canvas.getContext('2d')
  if (ctx) {
    ctx.scale(dpr, dpr)
  }

  initParticles()
}

// 检查reduced motion偏好
const checkReducedMotion = () => {
  const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
  prefersReducedMotion = mediaQuery.matches

  mediaQuery.addEventListener('change', (e) => {
    prefersReducedMotion = e.matches
  })
}

// 鼠标移动处理
const handleMouseMove = (event: MouseEvent) => {
  if (!canvasRef.value) return

  const rect = canvasRef.value.getBoundingClientRect()
  const x = event.clientX - rect.left
  const y = event.clientY - rect.top

  mousePosition.value = { x, y }

  // 查找最近的粒子对应的分数段
  let closestParticle: Particle | null = null
  let closestDistance = Infinity

  for (const particle of particles) {
    const distance = Math.sqrt((particle.x - x) ** 2 + (particle.y - y) ** 2)
    if (distance < particle.radius + 15 && distance < closestDistance) {
      closestDistance = distance
      closestParticle = particle
    }
  }

  hoveredSegment.value = closestParticle?.scoreSegment || null
}

// 鼠标离开处理
const handleMouseLeave = () => {
  hoveredSegment.value = null
}

// 点击处理
const handleClick = () => {
  if (hoveredSegment.value) {
    console.log('Clicked segment:', hoveredSegment.value.label)
    // 后续F004会实现路由跳转
  }
}

// 绘制背景渐变
const drawBackground = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
  const gradient = ctx.createLinearGradient(0, 0, 0, height)
  gradient.addColorStop(0, COLOR_SCHEME.gradientStart)
  gradient.addColorStop(1, COLOR_SCHEME.gradientEnd)
  ctx.fillStyle = gradient
  ctx.fillRect(0, 0, width, height)
}

// 绘制粒子
const drawParticle = (
  ctx: CanvasRenderingContext2D,
  particle: Particle,
  isHovered: boolean
) => {
  const drawRadius = isHovered ? particle.radius * 1.8 : particle.radius
  const alpha = isHovered ? 1 : particle.alpha

  ctx.beginPath()
  ctx.arc(particle.x, particle.y, drawRadius, 0, Math.PI * 2)

  // 高亮或高分粒子添加发光效果
  if (isHovered || particle.scoreSegment.scoreValue > 620) {
    ctx.shadowBlur = isHovered ? 20 : 10
    ctx.shadowColor = particle.color
  } else {
    ctx.shadowBlur = 0
  }

  ctx.fillStyle = particle.color + Math.round(alpha * 255).toString(16).padStart(2, '0')
  ctx.fill()

  ctx.shadowBlur = 0
}

// 动画循环
let lastTime = 0
const animate = (time: number) => {
  if (!canvasRef.value) return

  const canvas = canvasRef.value
  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const dpr = window.devicePixelRatio || 1
  const width = canvas.width / dpr
  const height = canvas.height / dpr

  ctx.clearRect(0, 0, width, height)

  // 绘制背景渐变
  drawBackground(ctx, width, height)

  const deltaTime = (time - lastTime) / 1000
  lastTime = time

  particles.forEach((particle) => {
    if (!prefersReducedMotion) {
      // 更新相位
      particle.phase += particle.speed * deltaTime * 2

      // 垂直浮动
      const yOffset = Math.sin(particle.phase) * 10
      const xOffset = Math.cos(particle.phase * 0.7) * 5

      particle.y = particle.baseY + yOffset
      particle.x += xOffset * deltaTime * 0.1

      // 边界检查
      if (particle.x < 0) particle.x = width
      if (particle.x > width) particle.x = 0
    }

    // 检查是否悬停
    const isHovered =
      hoveredSegment.value &&
      particle.scoreSegment.id === hoveredSegment.value.id

    drawParticle(ctx, particle, isHovered || false)
  })

  animationId = requestAnimationFrame(animate)
}

onMounted(() => {
  checkReducedMotion()
  resizeCanvas()

  window.addEventListener('resize', resizeCanvas)
  lastTime = performance.now()
  animationId = requestAnimationFrame(animate)
})

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
  window.removeEventListener('resize', resizeCanvas)
})

watch(
  () => props.particleDensity,
  () => {
    initParticles()
  }
)

watch(
  () => props.animationSpeed,
  () => {
    initParticles()
  }
)

// 暴露方法供父组件使用
defineExpose({
  getHoveredSegment: () => hoveredSegment.value,
  getTotalStudents: () => totalStudents,
})
</script>

<style lang="scss" scoped>
.mushroom-cloud-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  background-color: v-bind('COLOR_SCHEME.background');
}

.mushroom-cloud-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  cursor: crosshair;
  z-index: 0;
}
</style>
