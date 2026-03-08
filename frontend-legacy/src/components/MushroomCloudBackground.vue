<template>
  <canvas
    ref="canvasRef"
    class="mushroom-cloud-canvas"
  ></canvas>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
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
    particleDensity?: number
    animationSpeed?: number
  }>(),
  {
    particleDensity: 35,
    animationSpeed: 1,
  }
)

const canvasRef = ref<HTMLCanvasElement | null>(null)
let animationId: number | null = null
let particles: Particle[] = []
let prefersReducedMotion = false
let startTime = 0

// 颜色方案 - 单一蓝色系，明暗变化
const COLORS = {
  top: '#60A5FA', // 亮蓝
  bottom: '#1E3A5F', // 深蓝
}

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
  t = Math.max(0, Math.min(1, t))
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

    // 粒子数量：放大视觉效果，低分区域也增加基础数量
    const baseMultiplier = normalizedScore < 0.35 ? 4 : normalizedScore < 0.5 ? 2.5 : 1.5
    const count = Math.max(6, Math.floor((segment.count / maxCount) * props.particleDensity * 20 * baseMultiplier))

    // Y轴位置
    const targetY = height * (0.04 + (1 - normalizedScore) * 0.9)

    // 蘑菇云形状 - 夸张的顶部，收窄的中部
    let spreadFactor: number
    if (normalizedScore > 0.92) {
      spreadFactor = 0.48 // 蘑菇帽最顶部
    } else if (normalizedScore > 0.8) {
      spreadFactor = 0.42 + (0.92 - normalizedScore) * 0.2
    } else if (normalizedScore > 0.65) {
      spreadFactor = 0.32 + (0.8 - normalizedScore) * 0.4
    } else if (normalizedScore > 0.5) {
      spreadFactor = 0.18 + (0.65 - normalizedScore) * 0.5
    } else if (normalizedScore > 0.35) {
      spreadFactor = 0.10 + (0.5 - normalizedScore) * 0.3
    } else {
      spreadFactor = 0.06 + (0.35 - normalizedScore) * 0.08
    }
    const spreadX = width * spreadFactor

    for (let i = 0; i < count; i++) {
      const u1 = Math.random()
      const u2 = Math.random()
      const gaussian = Math.sqrt(-2 * Math.log(Math.max(0.0001, u1))) * Math.cos(2 * Math.PI * u2)

      const targetX = width * 0.5 + gaussian * spreadX

      // 从底部中心爆发
      const startX = width * 0.5 + (Math.random() - 0.5) * 40
      const startY = height + 10 + Math.random() * 40

      // 粒子大小 - 高分更大
      const sizeFactor = 0.5 + normalizedScore * 0.5
      const radius = Math.max(2, (2.5 + Math.random() * 4) * sizeFactor)

      // 曳光弹效果 - 高分区域减少，低分区域增加
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
        alpha: 0.12 + normalizedScore * 0.15,
        speed: (0.7 + Math.random() * 0.5) * props.animationSpeed,
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
  const width = window.innerWidth
  const height = window.innerHeight

  canvas.width = width * dpr
  canvas.height = height * dpr
  canvas.style.width = `${width}px`
  canvas.style.height = `${height}px`

  const ctx = canvas.getContext('2d')
  if (ctx) ctx.scale(dpr, dpr)

  initParticles()
}

const drawBackground = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
  // 清除画布（透明背景）
  ctx.clearRect(0, 0, width, height)

  // 顶部辉光
  const gradient = ctx.createRadialGradient(
    width / 2,
    height * 0.15,
    0,
    width / 2,
    height * 0.15,
    height * 0.7
  )
  gradient.addColorStop(0, 'rgba(0, 255, 255, 0.15)')
  gradient.addColorStop(0.1, 'rgba(0, 191, 255, 0.1)')
  gradient.addColorStop(0.25, 'rgba(129, 140, 248, 0.06)')
  gradient.addColorStop(0.45, 'rgba(192, 132, 252, 0.03)')
  gradient.addColorStop(1, 'rgba(0, 0, 0, 0)')
  ctx.fillStyle = gradient
  ctx.fillRect(0, 0, width, height)
}

const drawParticle = (ctx: CanvasRenderingContext2D, particle: Particle) => {
  const { x, y, radius, color, alpha, showScore, scoreText } = particle

  // 轻微发光
  const glow = showScore ? 12 : particle.scoreSegment.scoreValue > 620 ? 6 : 0
  if (glow > 0) {
    ctx.shadowBlur = glow
    ctx.shadowColor = color
  }

  ctx.beginPath()
  ctx.arc(x, y, radius, 0, Math.PI * 2)
  ctx.fillStyle = color + Math.round(alpha * 255).toString(16).padStart(2, '0')
  ctx.fill()

  ctx.shadowBlur = 0

  // 分值文字
  if (showScore && particle.progress > 0.3) {
    const textAlpha = Math.min(0.6, (particle.progress - 0.3) * 2)
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
const animate = (time: number) => {
  if (!canvasRef.value) return

  const canvas = canvasRef.value
  const ctx = canvas.getContext('2d')
  if (!ctx) return

  const dpr = window.devicePixelRatio || 1
  const width = canvas.width / dpr
  const height = canvas.height / dpr

  const deltaTime = Math.min((time - lastTime) / 1000, 0.1)
  lastTime = time
  const elapsed = time - startTime

  ctx.clearRect(0, 0, width, height)
  drawBackground(ctx, width, height)

  particles.forEach((particle) => {
    if (!prefersReducedMotion) {
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
    }

    if (particle.delay < elapsed) {
      drawParticle(ctx, particle)
    }
  })

  animationId = requestAnimationFrame(animate)
}

onMounted(() => {
  prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
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

watch(() => props.particleDensity, initParticles)
watch(() => props.animationSpeed, initParticles)

</script>

<style lang="scss" scoped>
.mushroom-cloud-canvas {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 9999;
  pointer-events: none;
}
</style>
