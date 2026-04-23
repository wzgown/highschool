<template>
  <div class="home-view">
    <div class="hero-section">
      <div class="hero-content">
        <h1 class="hero-title">
          <img src="/logo.png" alt="折桂登高" class="logo-icon-hero" />
          折桂登高
        </h1>
        <p class="hero-subtitle">
          基于历年录取数据和智能算法，帮助考生科学评估录取概率，优化志愿填报策略
        </p>
        <div class="features-grid">
          <div class="feature-card feature-card-highlight" @click="startRecommendation">
            <div class="feature-icon">
              <el-icon :size="32" color="#67C23A"><MagicStick /></el-icon>
            </div>
            <h3 class="feature-title">智能志愿推荐</h3>
            <p class="feature-desc">
              输入成绩信息，智能推荐三个批次的志愿学校，包含"冲稳保"梯度建议
            </p>
            <el-tag type="success" size="small">推荐使用</el-tag>
          </div>

          <div class="feature-card" @click="startAnalysis">
            <div class="feature-icon">
              <el-icon :size="32" color="#409EFF"><EditPen /></el-icon>
            </div>
            <h3 class="feature-title">志愿模拟分析</h3>
            <p class="feature-desc">
              填写志愿后基于蒙特卡洛模拟，预测每个志愿的录取概率与竞争态势
            </p>
          </div>

          <div class="feature-card" @click="viewHistory">
            <div class="feature-icon">
              <el-icon :size="32" color="#E6A23C"><Clock /></el-icon>
            </div>
            <h3 class="feature-title">历史记录</h3>
            <p class="feature-desc">
              查看之前的分析与推荐记录，对比不同策略的录取概率
            </p>
          </div>
        </div>
      </div>
    </div>

    <div class="batch-section">
      <h2 class="section-title">支持批次</h2>
      <div class="batch-list">
        <el-card class="batch-card">
          <template #header>
            <div class="batch-header">
              <el-icon><Medal /></el-icon>
              <span>名额分配到区</span>
            </div>
          </template>
          <div class="batch-content">
            <p>市实验性示范性高中将部分招生计划分配到各区</p>
            <p class="batch-detail">1个志愿 | 全区排名竞争</p>
          </div>
        </el-card>

        <el-card class="batch-card">
          <template #header>
            <div class="batch-header">
              <el-icon><OfficeBuilding /></el-icon>
              <span>名额分配到校</span>
            </div>
          </template>
          <div class="batch-content">
            <p>市实验性示范性高中将部分招生计划分配到各初中</p>
            <p class="batch-detail">2个志愿 | 校内排名竞争</p>
          </div>
        </el-card>

        <el-card class="batch-card">
          <template #header>
            <div class="batch-header">
              <el-icon><List /></el-icon>
              <span>统一招生1-15志愿</span>
            </div>
          </template>
          <div class="batch-content">
            <p>平行志愿方式录取</p>
            <p class="batch-detail">15个志愿 | "分数优先、遵循志愿"</p>
          </div>
        </el-card>
      </div>
    </div>

    <div class="notice-section">
      <el-alert
        title="免责声明"
        type="warning"
        :closable="false"
        show-icon
      >
        <p>
          本系统模拟结果仅供参考，不构成任何录取承诺。实际录取结果以官方发布为准。
          建议考生结合自身情况、学校特色等因素综合考虑填报志愿。
        </p>
      </el-alert>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';
import {
  EditPen,
  Clock,
  MagicStick,
  Medal,
  OfficeBuilding,
  List,
} from '@element-plus/icons-vue';

const router = useRouter();

function startRecommendation() {
  router.push('/recommendation');
}

function startAnalysis() {
  router.push('/form');
}

function viewHistory() {
  router.push('/history');
}
</script>

<style lang="scss" scoped>
.home-view {
  position: relative;
  padding-bottom: 40px;
  overflow: hidden;
  min-height: calc(100vh - 100px);
}

.hero-section {
  position: relative;
  z-index: 1;
  background: linear-gradient(135deg, #ecf5ff 0%, #f5f7fa 100%);
  border-radius: 16px;
  padding: 48px 40px 40px;
  margin-bottom: 40px;
  text-align: center;
}

.logo-icon-hero {
  width: 48px;
  height: 48px;
}

.hero-title {
  font-size: 36px;
  color: #303133;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.hero-subtitle {
  font-size: 16px;
  color: #606266;
  max-width: 600px;
  margin: 0 auto 36px;
  line-height: 1.6;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  max-width: 900px;
  margin: 0 auto;
}

.feature-card {
  background: #fff;
  border-radius: 12px;
  padding: 28px 24px;
  text-align: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s, box-shadow 0.3s;
  cursor: pointer;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  }

  &.feature-card-highlight {
    border: 2px solid #67C23A;
    background: linear-gradient(135deg, #f0f9eb 0%, #fff 100%);

    &:hover {
      border-color: #4CAF50;
      box-shadow: 0 8px 24px rgba(103, 194, 58, 0.3);
    }
  }
}

.feature-icon {
  margin-bottom: 16px;
}

.feature-title {
  font-size: 18px;
  color: #303133;
  margin-bottom: 12px;
}

.feature-desc {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
}

.batch-section {
  position: relative;
  z-index: 1;
  margin-bottom: 40px;
}

.batch-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.batch-card {
  :deep(.el-card__header) {
    padding: 16px 20px;
  }
}

.batch-header {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.batch-content {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;

  p {
    margin-bottom: 8px;
  }
}

.batch-detail {
  color: #909399;
  font-size: 13px;
}

.notice-section {
  position: relative;
  z-index: 1;
  max-width: 800px;
  margin: 0 auto;
}

@media (max-width: 768px) {
  .hero-section {
    padding: 32px 20px 24px;
  }

  .hero-title {
    font-size: 24px;
    flex-direction: column;
    gap: 12px;
  }

  .hero-subtitle {
    font-size: 14px;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .batch-list {
    grid-template-columns: 1fr;
  }
}
</style>
