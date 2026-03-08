<template>
  <view class="home-view">
    <!-- Hero Section -->
    <view class="hero-section">
      <view class="hero-content">
        <view class="hero-title">
          <uni-icons type="home" size="48" color="#409EFF" />
          <text class="title-text">上海中考招生模拟系统</text>
        </view>
        <text class="hero-subtitle">
          基于历年录取数据和智能算法，帮助考生科学评估录取概率，优化志愿填报策略
        </text>
        <view class="hero-actions">
          <AppButton
            type="success"
            size="large"
            icon="star"
            @click="startRecommendation"
          >
            智能志愿推荐
          </AppButton>
          <AppButton
            type="primary"
            size="large"
            icon="compose"
            @click="startAnalysis"
          >
            志愿模拟分析
          </AppButton>
          <AppButton
            size="large"
            icon="clock"
            @click="viewHistory"
          >
            历史记录
          </AppButton>
        </view>
      </view>
    </view>

    <!-- Features Section -->
    <view class="features-section">
      <text class="section-title">核心功能</text>
      <view class="features-grid">
        <view
          class="feature-card feature-card--highlight"
          @click="startRecommendation"
        >
          <view class="feature-icon">
            <uni-icons type="star" size="32" color="#67C23A" />
          </view>
          <text class="feature-title">智能志愿推荐</text>
          <text class="feature-desc">
            输入一模/二模成绩，智能推荐三个批次的志愿学校，包含"冲稳保"梯度建议
          </text>
          <view class="feature-tag feature-tag--success">
            <text class="tag-text">热门推荐</text>
          </view>
        </view>

        <view class="feature-card" @click="startAnalysis">
          <view class="feature-icon">
            <uni-icons type="bars" size="32" color="#409EFF" />
          </view>
          <text class="feature-title">录取概率模拟</text>
          <text class="feature-desc">
            基于蒙特卡洛模拟，预测每个志愿的录取概率，帮助您了解被各校录取的可能性
          </text>
        </view>

        <view class="feature-card">
          <view class="feature-icon">
            <uni-icons type="chatbubble" size="32" color="#E6A23C" />
          </view>
          <text class="feature-title">志愿策略分析</text>
          <text class="feature-desc">
            分析志愿梯度分布，识别风险点，提供科学的志愿填报优化建议
          </text>
        </view>

        <view class="feature-card">
          <view class="feature-icon">
            <uni-icons type="contact" size="32" color="#F56C6C" />
          </view>
          <text class="feature-title">竞争态势模拟</text>
          <text class="feature-desc">
            生成虚拟竞争对手，模拟真实录取环境，更准确地评估录取难度
          </text>
        </view>
      </view>
    </view>

    <!-- Batch Section -->
    <view class="batch-section">
      <text class="section-title">支持批次</text>
      <view class="batch-list">
        <AppCard title="名额分配到区" hoverable>
          <template #header>
            <view class="batch-header">
              <uni-icons type="medal" size="20" color="#409EFF" />
              <text class="batch-header-text">名额分配到区</text>
            </view>
          </template>
          <view class="batch-content">
            <text class="batch-desc">市实验性示范性高中将部分招生计划分配到各区</text>
            <text class="batch-detail">1个志愿 | 全区排名竞争</text>
          </view>
        </AppCard>

        <AppCard hoverable>
          <template #header>
            <view class="batch-header">
              <uni-icons type="shop" size="20" color="#409EFF" />
              <text class="batch-header-text">名额分配到校</text>
            </view>
          </template>
          <view class="batch-content">
            <text class="batch-desc">市实验性示范性高中将部分招生计划分配到各初中</text>
            <text class="batch-detail">2个志愿 | 校内排名竞争</text>
          </view>
        </AppCard>

        <AppCard hoverable>
          <template #header>
            <view class="batch-header">
              <uni-icons type="list" size="20" color="#409EFF" />
              <text class="batch-header-text">统一招生1-15志愿</text>
            </view>
          </template>
          <view class="batch-content">
            <text class="batch-desc">平行志愿方式录取</text>
            <text class="batch-detail">15个志愿 | "分数优先、遵循志愿"</text>
          </view>
        </AppCard>
      </view>
    </view>

    <!-- Notice Section -->
    <view class="notice-section">
      <view class="notice-card">
        <view class="notice-header">
          <uni-icons type="info" size="18" color="#E6A23C" />
          <text class="notice-title">免责声明</text>
        </view>
        <text class="notice-content">
          本系统模拟结果仅供参考，不构成任何录取承诺。实际录取结果以官方发布为准。
          建议考生结合自身情况、学校特色等因素综合考虑填报志愿。
        </text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { AppButton, AppCard } from '@/components/common'
import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app'

function startRecommendation() {
  uni.navigateTo({ url: '/pages/recommendation/recommendation' })
}

function startAnalysis() {
  uni.navigateTo({ url: '/pages/form/form' })
}

function viewHistory() {
  uni.navigateTo({ url: '/pages/history/history' })
}

// 小程序分享功能
/* #ifdef MP-WEIXIN */
onShareAppMessage(() => ({
  title: '上海中考招生模拟系统',
  path: '/pages/index/index',
  imageUrl: '/static/logo.png'
}))

onShareTimeline(() => ({
  title: '上海中考招生模拟系统 - 科学评估录取概率',
  query: '',
  imageUrl: '/static/logo.png'
}))
/* #endif */
</script>

<style lang="scss" scoped>
.home-view {
  position: relative;
  padding: 24rpx;
  padding-bottom: 80rpx;
  min-height: 100vh;
  background-color: #f5f7fa;
}

// Hero Section
.hero-section {
  position: relative;
  background: linear-gradient(135deg, #ecf5ff 0%, #f5f7fa 100%);
  border-radius: 24rpx;
  padding: 60rpx 40rpx;
  margin-bottom: 40rpx;
}

.hero-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.hero-title {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;
  margin-bottom: 24rpx;
}

.title-text {
  font-size: 40rpx;
  font-weight: 600;
  color: #303133;
}

.hero-subtitle {
  font-size: 28rpx;
  color: #606266;
  max-width: 600rpx;
  margin-bottom: 40rpx;
  line-height: 1.6;
}

.hero-actions {
  display: flex;
  gap: 16rpx;
  justify-content: center;
  flex-wrap: wrap;
}

// Section Title
.section-title {
  display: block;
  font-size: 36rpx;
  font-weight: 600;
  color: #303133;
  text-align: center;
  margin-bottom: 32rpx;
}

// Features Section
.features-section {
  margin-bottom: 40rpx;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24rpx;
}

.feature-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 32rpx;
  text-align: center;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  transition: transform 0.3s, box-shadow 0.3s;

  &:active {
    transform: scale(0.98);
  }

  &--highlight {
    grid-column: span 2;
    border: 2rpx solid #67C23A;
    background: linear-gradient(135deg, #f0f9eb 0%, #fff 100%);
  }
}

.feature-icon {
  margin-bottom: 16rpx;
}

.feature-title {
  display: block;
  font-size: 30rpx;
  font-weight: 500;
  color: #303133;
  margin-bottom: 12rpx;
}

.feature-desc {
  display: block;
  font-size: 24rpx;
  color: #606266;
  line-height: 1.6;
}

.feature-tag {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 8rpx 16rpx;
  border-radius: 8rpx;
  margin-top: 16rpx;

  &--success {
    background-color: #f0f9eb;
    border: 1rpx solid #e1f3d8;
  }
}

.tag-text {
  font-size: 22rpx;
  color: #67c23a;
}

// Batch Section
.batch-section {
  margin-bottom: 40rpx;
}

.batch-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.batch-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.batch-header-text {
  font-size: 30rpx;
  font-weight: 500;
  color: #303133;
}

.batch-content {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.batch-desc {
  font-size: 26rpx;
  color: #606266;
  line-height: 1.6;
}

.batch-detail {
  font-size: 24rpx;
  color: #909399;
}

// Notice Section
.notice-section {
  margin-bottom: 40rpx;
}

.notice-card {
  background-color: #fdf6ec;
  border: 1rpx solid #faecd8;
  border-radius: 12rpx;
  padding: 24rpx;
}

.notice-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 12rpx;
}

.notice-title {
  font-size: 28rpx;
  font-weight: 500;
  color: #e6a23c;
}

.notice-content {
  font-size: 24rpx;
  color: #606266;
  line-height: 1.6;
}

// H5 响应式适配
/* #ifdef H5 */
// 移动端触摸优化
.home-view {
  -webkit-tap-highlight-color: transparent;
}

.feature-card {
  -webkit-tap-highlight-color: transparent;
  user-select: none;
}

// 小屏幕手机优化 (< 375px)
@media screen and (max-width: 374px) {
  .title-text {
    font-size: 36rpx;
  }

  .hero-subtitle {
    font-size: 26rpx;
  }

  .hero-actions {
    flex-direction: column;
    width: 100%;

    :deep(.app-button) {
      width: 100%;
    }
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .feature-card--highlight {
    grid-column: span 1;
  }
}

// 大屏幕手机 (>= 414px)
@media screen and (min-width: 414px) {
  .hero-section {
    padding: 80rpx 48rpx;
  }

  .title-text {
    font-size: 44rpx;
  }
}

// 平板端 (>= 768px)
@media screen and (min-width: 768px) {
  .home-view {
    max-width: 960px;
    margin: 0 auto;
    padding: 32rpx 48rpx;
  }

  .hero-section {
    padding: 80rpx 64rpx;
    margin-bottom: 48rpx;
  }

  .title-text {
    font-size: 48rpx;
  }

  .hero-subtitle {
    font-size: 32rpx;
    max-width: 700rpx;
  }

  .features-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: 32rpx;
  }

  .feature-card--highlight {
    grid-column: span 1;
  }

  .batch-list {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24rpx;
  }

  .section-title {
    font-size: 40rpx;
  }
}

// 桌面端 (>= 1024px)
@media screen and (min-width: 1024px) {
  .home-view {
    max-width: 1200px;
    padding: 48rpx 64rpx;
  }

  .hero-section {
    padding: 100rpx 80rpx;
  }

  .features-section {
    margin-bottom: 56rpx;
  }

  .feature-card {
    &:hover {
      transform: translateY(-8rpx);
      box-shadow: 0 12rpx 32rpx rgba(0, 0, 0, 0.12);
    }
  }
}

// 大桌面端 (>= 1440px)
@media screen and (min-width: 1440px) {
  .home-view {
    max-width: 1320px;
    padding: 64rpx 80rpx;
  }

  .hero-section {
    padding: 120rpx 100rpx;
    border-radius: 32rpx;
  }

  .title-text {
    font-size: 52rpx;
  }

  .hero-subtitle {
    font-size: 34rpx;
    max-width: 800rpx;
  }

  .hero-actions {
    gap: 24rpx;
  }

  .features-grid {
    gap: 40rpx;
  }

  .feature-card {
    padding: 40rpx;

    &:hover {
      transform: translateY(-12rpx);
      box-shadow: 0 16rpx 40rpx rgba(0, 0, 0, 0.15);
    }
  }

  .feature-title {
    font-size: 34rpx;
  }

  .feature-desc {
    font-size: 28rpx;
  }

  .batch-list {
    gap: 32rpx;
  }

  .section-title {
    font-size: 44rpx;
    margin-bottom: 40rpx;
  }
}

// 触摸设备优化
@media (hover: none) and (pointer: coarse) {
  .feature-card {
    &:active {
      transform: scale(0.98);
    }
  }
}
/* #endif */
</style>
