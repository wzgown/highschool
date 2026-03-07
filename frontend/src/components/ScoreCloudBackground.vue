<template>
  <canvas ref="canvasRef" class="score-cloud-background"></canvas>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue';

interface ScoreDistribution {
  score: number;
  count: number;
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
}

const props = withDefaults(
  defineProps<{
    scoreDistribution?: ScoreDistribution[];
    particleCount?: number;
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
    particleCount: 1200,
  }
);

const canvasRef = ref<HTMLCanvasElement | null>(null);
let animationId: number | null = null;
let particles: Particle[] = [];
let prefersReducedMotion = false;

// Check for reduced motion preference
const checkReducedMotion = () => {
  const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
  prefersReducedMotion = mediaQuery.matches;

  mediaQuery.addEventListener('change', (e) => {
    prefersReducedMotion = e.matches;
  });
};

// Get color based on score (warm palette - vibrant)
const getColorForScore = (score: number, maxScore: number, minScore: number): string => {
  const normalized = (score - minScore) / (maxScore - minScore);

  // Warm color gradient: deep red (low) -> orange -> gold (high)
  // More saturated colors for visual impact
  if (normalized > 0.7) {
    // Bright gold/yellow for top scores
    const r = 255;
    const g = Math.floor(200 + normalized * 55);
    const b = Math.floor(60);
    return `rgba(${r}, ${g}, ${b}, `;
  } else if (normalized > 0.4) {
    // Vibrant orange for middle scores
    const r = 255;
    const g = Math.floor(120 + normalized * 60);
    const b = Math.floor(40);
    return `rgba(${r}, ${g}, ${b}, `;
  } else {
    // Rich red for lower scores
    const r = Math.floor(220 + normalized * 35);
    const g = Math.floor(60 + normalized * 40);
    const b = Math.floor(50);
    return `rgba(${r}, ${g}, ${b}, `;
  }
};

// Initialize particles based on score distribution
const initParticles = () => {
  if (!canvasRef.value) return;

  const canvas = canvasRef.value;
  const dpr = window.devicePixelRatio || 1;
  // Use display dimensions for particle positioning (not scaled canvas dimensions)
  const width = canvas.width / dpr;
  const height = canvas.height / dpr;

  particles = [];

  const distribution = props.scoreDistribution;
  const maxScore = Math.max(...distribution.map((d) => d.score));
  const minScore = Math.min(...distribution.map((d) => d.score));
  const maxCount = Math.max(...distribution.map((d) => d.count));
  const totalStudents = distribution.reduce((sum, d) => sum + d.count, 0);

  // Create particles proportionally for each score band
  distribution.forEach((band) => {
    // Number of particles for this score band
    const bandParticleCount = Math.floor(
      (band.count / totalStudents) * props.particleCount
    );

    // Y position: higher score = higher on canvas (inverted because canvas Y goes down)
    const normalizedY = (band.score - minScore) / (maxScore - minScore);
    const baseY = height * (1 - normalizedY * 0.8) - height * 0.1;

    for (let i = 0; i < bandParticleCount; i++) {
      // X position: mushroom cloud shape - high scores cluster tightly at center
      // Lower scores spread out more like the stem of a mushroom
      // Box-Muller transform for Gaussian distribution
      const u1 = Math.random();
      const u2 = Math.random();
      const gaussian = Math.sqrt(-2 * Math.log(Math.max(0.0001, u1))) * Math.cos(2 * Math.PI * u2);

      // Higher scores (high normalizedY) cluster tighter, lower scores spread wider
      const spreadFactor = 0.08 + (1 - normalizedY) * 0.25;
      const x = width * 0.5 + gaussian * width * spreadFactor;

      const radius = Math.max(1.5, 2.5 + Math.random() * 3.5);
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
      });
    }
  });
};

// Resize canvas to match container
const resizeCanvas = () => {
  if (!canvasRef.value) return;

  const canvas = canvasRef.value;
  const parent = canvas.parentElement;
  if (!parent) return;

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

// Animation loop
let lastTime = 0;
const animate = (time: number) => {
  if (!canvasRef.value) return;

  const canvas = canvasRef.value;
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  const dpr = window.devicePixelRatio || 1;
  const width = canvas.width / dpr;
  const height = canvas.height / dpr;

  // Clear canvas
  ctx.clearRect(0, 0, width, height);

  // If reduced motion is preferred, just draw static particles
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

  // Animated particles
  const deltaTime = (time - lastTime) / 1000;
  lastTime = time;

  particles.forEach((particle) => {
    // Gentle floating animation
    particle.phase += particle.speed * deltaTime * 2;
    const yOffset = Math.sin(particle.phase) * 8;
    const xOffset = Math.cos(particle.phase * 0.7) * 4;

    particle.y = particle.baseY + yOffset;

    // Draw particle with glow effect
    ctx.beginPath();
    ctx.arc(
      particle.x + xOffset,
      particle.y,
      particle.radius,
      0,
      Math.PI * 2
    );

    // Add glow for higher scores
    const isHighScore = particle.targetScore > 630;
    if (isHighScore) {
      ctx.shadowBlur = 8;
      ctx.shadowColor = particle.color + '0.5)';
    } else {
      ctx.shadowBlur = 0;
    }

    ctx.fillStyle = particle.color + particle.alpha + ')';
    ctx.fill();

    // Reset shadow
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

// Reinitialize when props change
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
</script>

<style lang="scss" scoped>
.score-cloud-background {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}
</style>
