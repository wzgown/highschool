<template>
  <div class="home-view">
    <div class="hero-section">
      <div class="hero-content">
        <h1 class="hero-title">
          <el-icon :size="48" color="#409EFF"><School /></el-icon>
          上海中考招生模拟系统
        </h1>
        <p class="hero-subtitle">
          基于历年录取数据和智能算法，帮助考生科学评估录取概率，优化志愿填报策略
        </p>
        <div class="hero-actions">
          <el-button type="primary" size="large" @click="startAnalysis">
            <el-icon><EditPen /></el-icon>
            开始志愿分析
          </el-button>
          <el-button size="large" @click="viewHistory">
            <el-icon><Clock /></el-icon>
            查看历史记录
          </el-button>
        </div>
      </div>
    </div>

    <div class="features-section">
      <h2 class="section-title">核心功能</h2>
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">
            <el-icon :size="32" color="#67C23A"><TrendCharts /></el-icon>
          </div>
          <h3 class="feature-title">录取概率评估</h3>
          <p class="feature-desc">
            基于蒙特卡洛模拟，预测每个志愿的录取概率，帮助您了解被各校录取的可能性
          </p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <el-icon :size="32" color="#E6A23C"><DataAnalysis /></el-icon>
          </div>
          <h3 class="feature-title">志愿策略分析</h3>
          <p class="feature-desc">
            分析志愿梯度分布，识别风险点，提供科学的志愿填报优化建议
          </p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <el-icon :size="32" color="#F56C6C"><User /></el-icon>
          </div>
          <h3 class="feature-title">竞争态势模拟</h3>
          <p class="feature-desc">
            生成虚拟竞争对手，模拟真实录取环境，更准确地评估录取难度
          </p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <el-icon :size="32" color="#409EFF"><Histogram /></el-icon>
          </div>
          <h3 class="feature-title">历年数据对比</h3>
          <p class="feature-desc">
            展示目标学校近2-3年录取分数线，帮助您了解分数变化趋势
          </p>
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
  School,
  EditPen,
  Clock,
  TrendCharts,
  DataAnalysis,
  User,
  Histogram,
  Medal,
  OfficeBuilding,
  List,
} from '@element-plus/icons-vue';

const router = useRouter();

function startAnalysis() {
  router.push('/form');
}

function viewHistory() {
  router.push('/history');
}
</script>

<style lang="scss" scoped>
.home-view {
  padding-bottom: 40px;
}

.hero-section {
  background: linear-gradient(135deg, #ecf5ff 0%, #f5f7fa 100%);
  border-radius: 16px;
  padding: 60px 40px;
  margin-bottom: 40px;
  text-align: center;
}

.hero-title {
  font-size: 36px;
  color: #303133;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.hero-subtitle {
  font-size: 18px;
  color: #606266;
  max-width: 600px;
  margin: 0 auto 30px;
  line-height: 1.6;
}

.hero-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.section-title {
  font-size: 24px;
  color: #303133;
  text-align: center;
  margin-bottom: 30px;
}

.features-section {
  margin-bottom: 40px;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 24px;
}

.feature-card {
  background: #fff;
  border-radius: 12px;
  padding: 30px;
  text-align: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s, box-shadow 0.3s;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
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
  max-width: 800px;
  margin: 0 auto;
}

@media (max-width: 768px) {
  .hero-section {
    padding: 40px 20px;
  }

  .hero-title {
    font-size: 24px;
    flex-direction: column;
    gap: 12px;
  }

  .hero-subtitle {
    font-size: 15px;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .batch-list {
    grid-template-columns: 1fr;
  }
}
</style>
