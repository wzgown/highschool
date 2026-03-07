<template>
  <Transition name="splash-fade">
    <canvas
      v-if="visible"
      ref="canvasRef"
      class="splash-canvas"
    ></canvas>
  </Transition>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { scoreSegments, type ScoreSegment } from '@/data/mushroomCloudData'

interface Particle {
  x: number
  y: number
  targetX: number
  targetY: number
  radius: number
  color: string
  alpha: number
  speed: number
  phase: number
  scoreSegment: ScoreSegment
  showScore: boolean
  scoreText: string
  progress: number
  delay: number
}

const props = withDefaults(
  defineProps<{
    duration?: number // 总持续时间（毫秒）
    particleDensity?: number
  }>(),
  {
    duration: 3500,
    particleDensity: 35,
  }
)

const emit = defineEmits<{
  (e: 'complete'): void
}>()

const visible = ref(true)
const canvasRef = ref<HTMLCanvasElement | null>(null)
let animationId: number | null = null
let particles: Particle[] = []
let startTime = 0

// 颜色方案 - 鲜艳的霓虹色，适合深色背景
const COLORS = {
  top: '#00FFFF',     // 青色 - 最高分
  high: '#00BFFF',    // 天蓝
  midHigh: '#8B5CF6',  // 紫色
  mid: '#EC4899',     // 粉红
  low: '#F97316',      // 橙色
  bottom: '#FBBF24',   // 金黄 - 最低分
}

// 背景颜色
const BG_COLOR = '#030712'

const getColorForScore = (score: number): string => {
  const minScore = 400
  const maxScore = 720
  const t = Math.max(0, Math.min(1, (score - minScore) / (maxScore - minScore)))
  return lerpColor(COLORS.bottom, COLORS.top, t)
}

const lerpColor = (c1: string, c2: string, t: number): string => {
  const r1 = parseInt(c1.slice(1, 3), 16)
  const g1 = parseInt(c1.slice(3, 5), 16)
  const b1 = parseInt(c1.slice(5, 7), 16)
  const r2 = parseInt(c2.slice(1, 3), 16)
  const g2 = parseInt(c2.slice(3, 5), 16)
  const b2 = parseInt(c2.slice(5, 7), 16)
  const r = Math.round(r1 + (r2 - r1) * t)
  const g = Math.round(g1 + (g2 - g1) * t)
  const b = Math.round(b1 + (b2 - b1) * t)
  return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`
}

const initParticles = () => {
  if (!canvasRef.value) return

  const canvas = canvasRef.value
  const dpr = window.devicePixelRatio || 1
  const width = canvas.width / dpr
  const height = canvas.height / dpr

  particles = []
  startTime = performance.now()

  const maxCount = Math.max(...scoreSegments.map((s) => s.count))
  const minScore = 400
  const maxScore = 720

  scoreSegments.forEach((segment, segIndex) => {
    const normalizedScore = (segment.scoreValue - minScore) / (maxScore - minScore)
    const baseMultiplier = normalizedScore < 0.35 ? 4 : normalizedScore < 0.5 ? 2.5 : 1.5
    const count = Math.max(6, Math.floor((segment.count / maxCount) * props.particleDensity * 20 * baseMultiplier))
    const targetY = height * (0.04 + (1 - normalizedScore) * 0.9)

    let spreadFactor: number
    if (normalizedScore > 0.92) spreadFactor = 0.48
    else if (normalizedScore > 0.8) spreadFactor = 0.42 + (0.92 - normalizedScore) * 0.2
    else if (normalizedScore > 0.65) spreadFactor = 0.32 + (0.8 - normalizedScore) * 0.4
    else if (normalizedScore > 0.5) spreadFactor = 0.18 + (0.65 - normalizedScore) * 0.5
    else if (normalizedScore > 0.35) spreadFactor = 0.10 + (0.5 - normalizedScore) * 0.3
    else spreadFactor = 0.06 + (0.35 - normalizedScore) * 0.08
    const spreadX = width * spreadFactor

    for (let i = 0; i < count; i++) {
      const u1 = Math.random()
      const u2 = Math.random()
      const gaussian = Math.sqrt(-2 * Math.log(Math.max(0.0001, u1))) * Math.cos(2 * Math.PI * u2)
      const targetX = width * 0.5 + gaussian * spreadX
      const startX = width * 0.5 + (Math.random() - 0.5) * 40
      const startY = height + 10 + Math.random() * 40
      const sizeFactor = 0.5 + normalizedScore * 0.5
      const radius = Math.max(2, (2.5 + Math.random() * 4) * sizeFactor)
      const showScoreProbability = normalizedScore > 0.8 ? 0.05 : normalizedScore > 0.6 ? 0.1 : 0.15
      const showScore = Math.random() < showScoreProbability && normalizedScore > 0.4
      const scoreText = segment.label.replace('分', '').replace('以上', '+')
      const delay = segIndex * 15 + Math.random() * 80

      particles.push({
        x: startX,
        y: startY,
        targetX,
        targetY,
        radius,
        color: getColorForScore(segment.scoreValue),
        alpha: 0.95 + normalizedScore * 0.05,
        speed: 0.7 + Math.random() * 0.5,
        phase: Math.random() * Math.PI * 2,
        scoreSegment: segment,
        showScore,
        scoreText,
        progress: 0,
        delay,
      })
    }
  })
}

const resizeCanvas = () => {
  if (!canvasRef.value) return
  const canvas = canvasRef.value
  const dpr = window.devicePixelRatio || 1
  canvas.width = window.innerWidth * dpr
  canvas.height = window.innerHeight * dpr
  canvas.style.width = `${window.innerWidth}px`
  canvas.style.height = `${window.innerHeight}px`
  const ctx = canvas.getContext('2d')
  if (ctx) ctx.scale(dpr, dpr)
  initParticles()
}

const drawBackground = (ctx: CanvasRenderingContext2D, width: number, height: number, globalAlpha: number) => {
  // 深色半透明背景
  ctx.fillStyle = `rgba(3, 7, 18, ${0.92 * globalAlpha})`
  ctx.fillRect(0, 0, width, height)

  // 顶部辉光
  const gradient = ctx.createRadialGradient(width / 2, height * 0.15, 0, width / 2, height * 0.15, height * 0.7)
  gradient.addColorStop(0, `rgba(0, 255, 255, ${0.35 * globalAlpha})`)
  gradient.addColorStop(0.2, `rgba(139, 92, 246, ${0.25 * globalAlpha})`)
  gradient.addColorStop(0.5, `rgba(236, 72, 153, ${0.15 * globalAlpha})`)
  gradient.addColorStop(1, 'rgba(0, 0, 0, 0)')
  ctx.fillStyle = gradient
  ctx.fillRect(0, 0, width, height)
}

const drawParticle = (ctx: CanvasRenderingContext2D, particle: Particle, globalAlpha: number) => {
  const { x, y, radius, color, alpha, showScore, scoreText } = particle
  const finalAlpha = alpha * globalAlpha

  if (finalAlpha < 0.01) return

  const glow = showScore ? 12 : particle.scoreSegment.scoreValue > 620 ? 6 : 0
  if (glow > 0) {
    ctx.shadowBlur = glow
    ctx.shadowColor = color
  }

  ctx.beginPath()
  ctx.arc(x, y, radius, 0, Math.PI * 2)
  ctx.fillStyle = color + Math.round(finalAlpha * 255).toString(16).padStart(2, '0')
  ctx.fill()
  ctx.shadowBlur = 0

  if (showScore && particle.progress > 0.3) {
    const textAlpha = Math.min(0.6, (particle.progress - 0.3) * 2) * globalAlpha
    const fontSize = Math.max(12, radius * 4)
    ctx.font = `bold ${fontSize}px "SF Pro Display", -apple-system, sans-serif`
    ctx.fillStyle = color + Math.round(textAlpha * 255).toString(16).padStart(2, '0')
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText(scoreText, x, y - radius * 4)
  }
}

const easeOutExpo = (t: number): number => (t === 1 ? 1 : 1 - Math.pow(2, -10 * t))

let lastTime = 0
let completed = false

const animate = (time: number) => {
  if (!canvasRef.value || !visible.value) return

  const canvas = canvasRef.value
  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const dpr = window.devicePixelRatio || 1
  const width = canvas.width / dpr
  const height = canvas.height / dpr
  const elapsed = time - startTime

  // 计算全局透明度（淡出效果）
  const fadeOutStart = props.duration - 800
  let globalAlpha = 1
  if (elapsed > fadeOutStart) {
    globalAlpha = Math.max(0, 1 - (elapsed - fadeOutStart) / 800)
  }

  ctx.clearRect(0, 0, width, height)
  drawBackground(ctx, width, height, globalAlpha)

  const deltaTime = Math.min((time - lastTime) / 1000, 0.1)
  lastTime = time

  particles.forEach((particle) => {
    const effectiveTime = Math.max(0, elapsed - particle.delay)
    const duration = 1200 / particle.speed

    if (effectiveTime > 0) {
      if (particle.progress < 1) {
        particle.progress = Math.min(1, effectiveTime / duration)
        const eased = easeOutExpo(particle.progress)
        const wobble = Math.sin(effectiveTime * 0.005) * (1 - eased) * 12
        particle.x += (particle.targetX + wobble - particle.x) * eased * 0.15
        particle.y += (particle.targetY - particle.y) * eased * 0.15
      } else {
        particle.phase += deltaTime * 0.7
        particle.x = particle.targetX + Math.sin(particle.phase) * 2
        particle.y = particle.targetY + Math.cos(particle.phase * 0.6) * 1.2
      }
    }

    if (particle.delay < elapsed) {
      drawParticle(ctx, particle, globalAlpha)
    }
  })

  // 检查是否完成
  if (elapsed >= props.duration && !completed) {
    completed = true
    visible.value = false
    emit('complete')
    return
  }

  animationId = requestAnimationFrame(animate)
}

onMounted(() => {
  resizeCanvas()
  window.addEventListener('resize', resizeCanvas)
  lastTime = performance.now()
  startTime = lastTime
  animationId = requestAnimationFrame(animate)
})

onUnmounted(() => {
  if (animationId) cancelAnimationFrame(animationId)
  window.removeEventListener('resize', resizeCanvas)
})
</script>

<style lang="scss" scoped>
.splash-canvas {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 9999;
  pointer-events: none;
}

.splash-fade-leave-active {
  transition: opacity 0.5s ease;
}

.splash-fade-leave-to {
  opacity: 0;
}
</style>
