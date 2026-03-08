<template>
  <div class="score-cloud-container" ref="containerRef">
    <canvas
      ref="canvasRef"
      class="score-cloud-background"
      @mousemove="handleMouseMove"
      @mouseleave="handleMouseLeave"
      @click="handleClick"
    ></canvas>

    <!-- 悬停浮层 -->
    <Transition name="tooltip-fade">
      <div
        v-if="hoveredParticle && tooltipVisible"
        class="district-tooltip"
        :style="tooltipStyle"
      >
        <div class="tooltip-header">
          <span class="tooltip-score">{{ hoveredParticle.targetScore }}分</span>
          <span class="tooltip-label">分数段</span>
        </div>
        <div class="tooltip-content">
          <div class="tooltip-row">
            <span class="tooltip-key">学生人数:</span>
            <span class="tooltip-value">{{ getStudentCount(hoveredParticle.targetScore) }}人</span>
          </div>
          <div v-if="hoveredDistrict" class="tooltip-row">
            <span class="tooltip-key">区县:</span>
            <span class="tooltip-value">{{ hoveredDistrict.name }}</span>
          </div>
          <div v-if="hoveredDistrict" class="tooltip-row">
            <span class="tooltip-key">中考人数:</span>
            <span class="tooltip-value">{{ hoveredDistrict.examCount }}人</span>
          </div>
        </div>
        <div class="tooltip-hint">点击查看详情</div>
      </div>
    </Transition>

    <!-- 顶部排名区域 -->
    <div v-if="showTopRanking && topDistricts.length > 0" class="top-ranking-bar">
      <div class="ranking-title">分数排名前{{ topDistricts.length }}区</div>
      <div class="ranking-list">
        <div
          v-for="(district, index) in topDistricts"
          :key="district.id"
          class="ranking-item"
          @click="navigateToDistrict(district)"
        >
          <span class="ranking-index">{{ index + 1 }}</span>
          <span class="ranking-name">{{ district.name }}</span>
          <span class="ranking-score">{{ district.avgScore }}分</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, computed } from 'vue';
import { useRouter } from 'vue-router';

interface ScoreDistribution {
  score: number;
  count: number;
}

interface DistrictData {
  id: number;
  code: string;
  name: string;
  examCount: number;
  avgScore?: number;
}

interface Particle {
  x: number;
  y: number;
  baseY: number;
  radius: number;
  color: string;
  alpha: number;
  speed: number;
  phase: number;
  targetScore: number;
  districtId?: number;
}

const props = withDefaults(
  defineProps<{
    scoreDistribution?: ScoreDistribution[];
    districtData?: DistrictData[];
    particleCount?: number;
    showTopRanking?: boolean;
    topRankingCount?: number;
  }>(),
  {
    scoreDistribution: () => [
      { score: 650, count: 280 },
      { score: 646, count: 350 },
      { score: 642, count: 420 },
      { score: 638, count: 480 },
      { score: 634, count: 520 },
      { score: 630, count: 500 },
      { score: 626, count: 460 },
      { score: 622, count: 420 },
      { score: 618, count: 380 },
      { score: 614, count: 340 },
      { score: 610, count: 300 },
      { score: 606, count: 260 },
      { score: 602, count: 220 },
      { score: 598, count: 180 },
      { score: 594, count: 150 },
      { score: 590, count: 130 },
      { score: 586, count: 110 },
      { score: 582, count: 95 },
      { score: 578, count: 85 },
      { score: 574, count: 75 },
      { score: 570, count: 70 },
      { score: 566, count: 65 },
      { score: 562, count: 60 },
      { score: 558, count: 55 },
      { score: 554, count: 50 },
      { score: 550, count: 48 },
    ],
    districtData: () => [
      { id: 1, code: 'HP', name: '黄浦区', examCount: 3788, avgScore: 625 },
      { id: 2, code: 'XH', name: '徐汇区', examCount: 8014, avgScore: 632 },
      { id: 3, code: 'CN', name: '长宁区', examCount: 3404, avgScore: 618 },
      { id: 4, code: 'JA', name: '静安区', examCount: 6747, avgScore: 620 },
      { id: 5, code: 'PT', name: '普陀区', examCount: 5200, avgScore: 615 },
      { id: 6, code: 'HK', name: '虹口区', examCount: 3800, avgScore: 622 },
      { id: 7, code: 'YK', name: '杨浦区', examCount: 6500, avgScore: 628 },
      { id: 8, code: 'MH', name: '闵行区', examCount: 12000, avgScore: 610 },
      { id: 9, code: 'BS', name: '宝山区', examCount: 7500, avgScore: 605 },
      { id: 10, code: 'JD', name: '嘉定区', examCount: 5800, avgScore: 600 },
      { id: 11, code: 'PD', name: '浦东新区', examCount: 22000, avgScore: 612 },
      { id: 12, code: 'JN', name: '金山区', examCount: 3500, avgScore: 595 },
      { id: 13, code: 'SN', name: '松江区', examCount: 7200, avgScore: 608 },
      { id: 14, code: 'QP', name: '青浦区', examCount: 4500, avgScore: 598 },
      { id: 15, code: 'FZ', name: '奉贤区', examCount: 4000, avgScore: 592 },
      { id: 16, code: 'CM', name: '崇明区', examCount: 3200, avgScore: 588 },
    ],
    particleCount: 1200,
    showTopRanking: true,
    topRankingCount: 20,
  }
);

const router = useRouter();

const containerRef = ref<HTMLDivElement | null>(null);
const canvasRef = ref<HTMLCanvasElement | null>(null);
let animationId: number | null = null;
let particles: Particle[] = [];
let prefersReducedMotion = false;

// 悬停状态
const hoveredParticle = ref<Particle | null>(null);
const hoveredDistrict = ref<DistrictData | null>(null);
const tooltipVisible = ref(false);
const tooltipPosition = ref({ x: 0, y: 0 });

const tooltipStyle = computed(() => ({
  left: `${tooltipPosition.value.x + 15}px`,
  top: `${tooltipPosition.value.y + 15}px`,
}));

// 计算排名前N的区县
const topDistricts = computed(() => {
  if (!props.districtData || props.districtData.length === 0) return [];
  return [...props.districtData]
    .filter((d) => d.avgScore)
    .sort((a, b) => (b.avgScore || 0) - (a.avgScore || 0))
    .slice(0, props.topRankingCount);
});

// 获取分数段对应的学生人数
const getStudentCount = (score: number): number => {
  const band = props.scoreDistribution.find((d) => d.score === score);
  return band?.count || 0;
};

// 根据分数获取颜色 - 蓝绿渐变配色
const getColorForScore = (score: number, maxScore: number, minScore: number): string => {
  const normalized = (score - minScore) / (maxScore - minScore);

  // 蓝绿渐变: Azure蓝(#0091B) -> 深紫(#8040c)
  // 高分 = Azure蓝, 低分 = 深紫
  if (normalized > 0.6) {
    // Azure蓝到青色
    const r = Math.floor(0 + (1 - normalized) * 20);
    const g = Math.floor(145 + normalized * 50);
    const b = Math.floor(180 + normalized * 20);
    return `rgba(${r}, ${g}, ${b}, `;
  } else if (normalized > 0.3) {
    // 青色到紫色
    const t = (normalized - 0.3) / 0.3;
    const r = Math.floor(20 + (1 - t) * 60);
    const g = Math.floor(145 - t * 80);
    const b = Math.floor(180 - t * 20);
    return `rgba(${r}, ${g}, ${b}, `;
  } else {
    // 深紫到浅紫渐变
    const t = normalized / 0.3;
    const r = Math.floor(80 + (1 - t) * 40);
    const g = Math.floor(64 + t * 30);
    const b = Math.floor(180 - t * 60);
    return `rgba(${r}, ${g}, ${b}, `;
  }
};

// 初始化粒子
const initParticles = () => {
  if (!canvasRef.value) return;

  const canvas = canvasRef.value;
  const dpr = window.devicePixelRatio || 1;
  const width = canvas.width / dpr;
  const height = canvas.height / dpr;

  particles = [];

  const distribution = props.scoreDistribution;
  const maxScore = Math.max(...distribution.map((d) => d.score));
  const minScore = Math.min(...distribution.map((d) => d.score));
  const totalStudents = distribution.reduce((sum, d) => sum + d.count, 0);

  // 为每个分数段创建粒子
  distribution.forEach((band) => {
    const bandParticleCount = Math.floor(
      (band.count / totalStudents) * props.particleCount
    );

    const normalizedY = (band.score - minScore) / (maxScore - minScore);
    const baseY = height * (1 - normalizedY * 0.8) - height * 0.1;

    // 根据区县数据分配粒子
    const districtCount = props.districtData?.length || 1;

    for (let i = 0; i < bandParticleCount; i++) {
      const u1 = Math.random();
      const u2 = Math.random();
      const gaussian = Math.sqrt(-2 * Math.log(Math.max(0.0001, u1))) * Math.cos(2 * Math.PI * u2);

      const spreadFactor = 0.08 + (1 - normalizedY) * 0.25;
      const x = width * 0.5 + gaussian * width * spreadFactor;

      // 粒子大小基于区县人数动态变化
      const districtIndex = Math.floor(Math.random() * districtCount);
      const district = props.districtData?.[districtIndex];
      const sizeMultiplier = district ? Math.sqrt(district.examCount / 10000) : 1;
      const radius = Math.max(1.5, (2.5 + Math.random() * 3.5) * sizeMultiplier);

      const color = getColorForScore(band.score, maxScore, minScore);
      const alpha = 0.5 + Math.random() * 0.4;

      particles.push({
        x,
        y: baseY + (Math.random() - 0.5) * 20,
        baseY,
        radius,
        color,
        alpha,
        speed: 0.3 + Math.random() * 0.5,
        phase: Math.random() * Math.PI * 2,
        targetScore: band.score,
        districtId: district?.id,
      });
    }
  });
};

// 调整Canvas大小
const resizeCanvas = () => {
  if (!canvasRef.value || !containerRef.value) return;

  const canvas = canvasRef.value;
  const parent = containerRef.value;
  const dpr = window.devicePixelRatio || 1;
  const rect = parent.getBoundingClientRect();

  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  canvas.style.width = `${rect.width}px`;
  canvas.style.height = `${rect.height}px`;

  const ctx = canvas.getContext('2d');
  if (ctx) {
    ctx.scale(dpr, dpr);
  }

  initParticles();
};

// 检查reduced motion偏好
const checkReducedMotion = () => {
  const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
  prefersReducedMotion = mediaQuery.matches;

  mediaQuery.addEventListener('change', (e) => {
    prefersReducedMotion = e.matches;
  });
};

// 鼠标移动处理
const handleMouseMove = (event: MouseEvent) => {
  if (!canvasRef.value) return;

  const rect = canvasRef.value.getBoundingClientRect();
  const x = event.clientX - rect.left;
  const y = event.clientY - rect.top;

  // 查找最近的粒子
  let closestParticle: Particle | null = null;
  let closestDistance = Infinity;

  for (const particle of particles) {
    const distance = Math.sqrt((particle.x - x) ** 2 + (particle.y - y) ** 2);
    if (distance < particle.radius + 10 && distance < closestDistance) {
      closestDistance = distance;
      closestParticle = particle;
    }
  }

  if (closestParticle) {
    hoveredParticle.value = closestParticle;
    tooltipPosition.value = { x: event.clientX - rect.left, y: event.clientY - rect.top };
    tooltipVisible.value = true;

    // 查找对应的区县数据
    if (closestParticle.districtId && props.districtData) {
      hoveredDistrict.value = props.districtData.find((d) => d.id === closestParticle.districtId) || null;
    } else {
      hoveredDistrict.value = null;
    }
  } else {
    hoveredParticle.value = null;
    hoveredDistrict.value = null;
    tooltipVisible.value = false;
  }
};

// 鼠标离开处理
const handleMouseLeave = () => {
  hoveredParticle.value = null;
  hoveredDistrict.value = null;
  tooltipVisible.value = false;
};

// 点击处理 - 跳转到区详情页
const handleClick = () => {
  if (hoveredDistrict.value) {
    navigateToDistrict(hoveredDistrict.value);
  }
};

// 导航到区详情页
const navigateToDistrict = (district: DistrictData) => {
  router.push(`/district/${district.code}`);
};

// 动画循环
let lastTime = 0;
const animate = (time: number) => {
  if (!canvasRef.value) return;

  const canvas = canvasRef.value;
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  const dpr = window.devicePixelRatio || 1;
  const width = canvas.width / dpr;
  const height = canvas.height / dpr;

  ctx.clearRect(0, 0, width, height);

  // 如果偏好减少动画，只绘制静态粒子
  if (prefersReducedMotion) {
    particles.forEach((particle) => {
      ctx.beginPath();
      ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
      ctx.fillStyle = particle.color + particle.alpha + ')';
      ctx.fill();
    });
    animationId = requestAnimationFrame(animate);
    return;
  }

  const deltaTime = (time - lastTime) / 1000;
  lastTime = time;

  particles.forEach((particle) => {
    particle.phase += particle.speed * deltaTime * 2;
    const yOffset = Math.sin(particle.phase) * 8;
    const xOffset = Math.cos(particle.phase * 0.7) * 4;

    particle.y = particle.baseY + yOffset;

    // 高亮悬停的粒子
    const isHovered = hoveredParticle.value === particle;
    const drawRadius = isHovered ? particle.radius * 1.5 : particle.radius;

    ctx.beginPath();
    ctx.arc(particle.x + xOffset, particle.y, drawRadius, 0, Math.PI * 2);

    // 高分粒子添加发光效果
    const isHighScore = particle.targetScore > 630;
    if (isHighScore || isHovered) {
      ctx.shadowBlur = isHovered ? 15 : 8;
      ctx.shadowColor = particle.color + '0.5)';
    } else {
      ctx.shadowBlur = 0;
    }

    const finalAlpha = isHovered ? 1 : particle.alpha;
    ctx.fillStyle = particle.color + finalAlpha + ')';
    ctx.fill();

    ctx.shadowBlur = 0;
  });

  animationId = requestAnimationFrame(animate);
};

onMounted(() => {
  checkReducedMotion();
  resizeCanvas();

  window.addEventListener('resize', resizeCanvas);
  lastTime = performance.now();
  animationId = requestAnimationFrame(animate);
});

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId);
  }
  window.removeEventListener('resize', resizeCanvas);
});

watch(
  () => props.scoreDistribution,
  () => {
    initParticles();
  },
  { deep: true }
);

watch(
  () => props.particleCount,
  () => {
    initParticles();
  }
);

watch(
  () => props.districtData,
  () => {
    initParticles();
  },
  { deep: true }
);
</script>

<style lang="scss" scoped>
.score-cloud-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.score-cloud-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  cursor: pointer;
  z-index: 0;
}

.district-tooltip {
  position: absolute;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 8px;
  padding: 12px 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  z-index: 100;
  pointer-events: none;
  min-width: 180px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(0, 145, 180, 0.2);
}

.tooltip-header {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 10px;
  padding-bottom: 8px;
  border-bottom: 1px solid rgba(0, 145, 180, 0.15);
}

.tooltip-score {
  font-size: 20px;
  font-weight: 600;
  color: #0091B;
}

.tooltip-label {
  font-size: 12px;
  color: #909399;
}

.tooltip-content {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.tooltip-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
}

.tooltip-key {
  color: #606266;
}

.tooltip-value {
  font-weight: 500;
  color: #303133;
}

.tooltip-hint {
  margin-top: 10px;
  padding-top: 8px;
  border-top: 1px solid rgba(0, 145, 180, 0.15);
  font-size: 11px;
  color: #0091B;
  text-align: center;
}

.top-ranking-bar {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  background: linear-gradient(180deg, rgba(0, 145, 180, 0.1) 0%, transparent 100%);
  padding: 12px 20px;
  z-index: 50;
}

.ranking-title {
  font-size: 14px;
  font-weight: 500;
  color: #0091B;
  margin-bottom: 10px;
  text-align: center;
}

.ranking-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(255, 255, 255, 0.8);
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid rgba(0, 145, 180, 0.2);

  &:hover {
    background: rgba(0, 145, 180, 0.1);
    border-color: #0091B;
    transform: translateY(-2px);
  }
}

.ranking-index {
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #0091B;
  color: white;
  border-radius: 50%;
  font-size: 10px;
  font-weight: 600;
}

.ranking-name {
  color: #303133;
  font-weight: 500;
}

.ranking-score {
  color: #0091B;
  font-weight: 600;
}

// 过渡动画
.tooltip-fade-enter-active,
.tooltip-fade-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.tooltip-fade-enter-from,
.tooltip-fade-leave-to {
  opacity: 0;
  transform: translateY(5px);
}

@media (max-width: 768px) {
  .top-ranking-bar {
    padding: 10px 12px;
  }

  .ranking-list {
    gap: 6px;
  }

  .ranking-item {
    padding: 4px 8px;
    font-size: 11px;
  }

  .ranking-index {
    width: 16px;
    height: 16px;
    font-size: 9px;
  }
}
</style>
