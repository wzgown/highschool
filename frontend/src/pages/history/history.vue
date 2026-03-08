<template>
  <view class="page-container">
    <!-- 页面头部 -->
    <view class="page-header">
      <text class="page-title">历史记录</text>
      <text class="page-desc">查看您之前的志愿分析记录</text>
    </view>

    <!-- 加载中 -->
    <view v-if="loading" class="loading-container">
      <view class="skeleton-card" v-for="i in 3" :key="i">
        <view class="skeleton-line skeleton-title"></view>
        <view class="skeleton-line skeleton-text"></view>
        <view class="skeleton-line skeleton-text short"></view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-else-if="!histories.length" class="empty-container">
      <uni-icons type="info" size="80" color="#c0c4cc" />
      <text class="empty-text">暂无历史记录</text>
      <AppButton type="primary" @click="goToForm">开始新的分析</AppButton>
    </view>

    <!-- 历史列表 -->
    <template v-else>
      <!-- 操作栏 -->
      <view class="action-bar">
        <view class="total-info">
          <text class="total-text">共 {{ total }} 条记录</text>
        </view>
        <view class="clear-btn" @click="clearAll">
          <uni-icons type="trash" size="32" color="#f56c6c" />
          <text class="clear-text">清空全部</text>
        </view>
      </view>

      <!-- 列表 -->
      <view class="history-list">
        <AppCard
          v-for="item in histories"
          :key="item.id"
          class="history-card"
          @click="viewDetail(item.id)"
        >
          <view class="history-item">
            <!-- 时间和志愿数 -->
            <view class="history-info">
              <view class="history-time">
                <uni-icons type="clock" size="28" color="#909399" />
                <text class="time-text">{{ formatTime(item.createdAt) }}</text>
              </view>
              <view class="history-stats" v-if="item.summary">
                <view class="stat-tag total">
                  <text>{{ item.summary.totalVolunteers }}个志愿</text>
                </view>
                <view class="stat-tag safe">
                  <text>安全 {{ item.summary.safeCount }}</text>
                </view>
                <view class="stat-tag moderate">
                  <text>稳妥 {{ item.summary.moderateCount }}</text>
                </view>
                <view class="stat-tag risky">
                  <text>冲刺 {{ item.summary.riskyCount }}</text>
                </view>
              </view>
            </view>

            <!-- 操作按钮 -->
            <view class="history-actions">
              <view class="action-btn view" @click.stop="viewDetail(item.id)">
                <text>查看详情</text>
              </view>
              <view class="action-btn delete" @click.stop="deleteItem(item.id)">
                <text>删除</text>
              </view>
            </view>
          </view>
        </AppCard>
      </view>

      <!-- 加载更多 -->
      <view v-if="hasMore" class="load-more" @click="loadMore">
        <text class="load-more-text">加载更多</text>
      </view>
      <view v-else-if="histories.length > 5" class="no-more">
        <text>没有更多记录了</text>
      </view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app';
import { useHistoryStore } from '@/stores/history';
import { getHistory, deleteHistory, deleteAllHistory } from '@/api/candidate';
import type { HistorySummary } from '@/api/candidate';
import { AppCard, AppButton } from '@/components/common';

const store = useHistoryStore();

const histories = ref<HistorySummary[]>([]);
const total = ref(0);
const loading = ref(false);
const pageSize = 10;
const currentPage = ref(1);

// 是否还有更多数据
const hasMore = computed(() => histories.value.length < total.value);

// 格式化时间
function formatTime(time: string | Date): string {
  const date = typeof time === 'string' ? new Date(time) : time;
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
}

// 加载历史记录
async function loadHistory() {
  loading.value = true;
  try {
    const data = await getHistory();
    histories.value = data.histories;
    total.value = data.total;
    store.setHistories(data.histories, data.total);
  } catch (error) {
    console.error('加载历史记录失败:', error);
    uni.showToast({
      title: '加载失败',
      icon: 'error',
    });
  } finally {
    loading.value = false;
  }
}

// 查看详情
function viewDetail(id: string) {
  uni.navigateTo({
    url: `/pages/result/result?id=${id}`,
  });
}

// 删除单条记录
async function deleteItem(id: string) {
  uni.showModal({
    title: '提示',
    content: '确定要删除这条记录吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deleteHistory(id);
          store.removeHistory(id);
          histories.value = histories.value.filter((h) => h.id !== id);
          total.value--;
          uni.showToast({
            title: '删除成功',
            icon: 'success',
          });
        } catch (error) {
          console.error('删除失败:', error);
          uni.showToast({
            title: '删除失败',
            icon: 'error',
          });
        }
      }
    },
  });
}

// 清空所有记录
function clearAll() {
  uni.showModal({
    title: '警告',
    content: '确定要清空所有历史记录吗？此操作不可恢复！',
    confirmColor: '#f56c6c',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deleteAllHistory();
          store.clearAll();
          histories.value = [];
          total.value = 0;
          uni.showToast({
            title: '已清空所有记录',
            icon: 'success',
          });
        } catch (error) {
          console.error('操作失败:', error);
          uni.showToast({
            title: '操作失败',
            icon: 'error',
          });
        }
      }
    },
  });
}

// 跳转到填报页
function goToForm() {
  uni.navigateTo({
    url: '/pages/form/form',
  });
}

// 加载更多
async function loadMore() {
  if (loading.value || !hasMore.value) return;

  loading.value = true;
  currentPage.value++;

  try {
    // 注意：当前API不支持分页，这里仅作为扩展预留
    // 实际分页需要后端支持
    const data = await getHistory();
    histories.value = [...histories.value, ...data.histories];
  } catch (error) {
    console.error('加载更多失败:', error);
    uni.showToast({
      title: '加载失败',
      icon: 'error',
    });
  } finally {
    loading.value = false;
  }
}

// 初始化
onMounted(() => {
  loadHistory();
});

// 小程序分享功能
/* #ifdef MP-WEIXIN */
onShareAppMessage(() => ({
  title: '上海中考招生模拟系统 - 历史记录',
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
.page-container {
  min-height: 100vh;
  padding: 32rpx;
  background-color: #f5f7fa;
}

.page-header {
  text-align: center;
  margin-bottom: 40rpx;
}

.page-title {
  display: block;
  font-size: 48rpx;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12rpx;
}

.page-desc {
  display: block;
  font-size: 28rpx;
  color: #909399;
}

/* 加载骨架屏 */
.loading-container {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.skeleton-card {
  padding: 32rpx;
  background: #fff;
  border-radius: 16rpx;
}

.skeleton-line {
  background: linear-gradient(90deg, #f2f2f2 25%, #e6e6e6 37%, #f2f2f2 63%);
  background-size: 400% 100%;
  animation: skeleton-loading 1.4s ease infinite;
  border-radius: 8rpx;
}

.skeleton-title {
  width: 60%;
  height: 36rpx;
  margin-bottom: 24rpx;
}

.skeleton-text {
  width: 100%;
  height: 28rpx;
  margin-bottom: 16rpx;

  &.short {
    width: 40%;
  }
}

@keyframes skeleton-loading {
  0% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0 50%;
  }
}

/* 空状态 */
.empty-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120rpx 40rpx;
}

.empty-text {
  font-size: 32rpx;
  color: #909399;
  margin: 32rpx 0 48rpx;
}

/* 操作栏 */
.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
  padding: 0 8rpx;
}

.total-text {
  font-size: 28rpx;
  color: #606266;
}

.clear-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 12rpx 20rpx;
}

.clear-text {
  font-size: 28rpx;
  color: #f56c6c;
}

/* 历史列表 */
.history-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.history-card {
  cursor: pointer;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 24rpx;
}

.history-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  min-width: 0;
}

.history-time {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.time-text {
  font-size: 28rpx;
  color: #606266;
}

.history-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.stat-tag {
  padding: 8rpx 16rpx;
  border-radius: 8rpx;
  font-size: 24rpx;

  &.total {
    background-color: #ecf5ff;
    color: #409eff;
  }

  &.safe {
    background-color: #f0f9eb;
    color: #67c23a;
  }

  &.moderate {
    background-color: #fdf6ec;
    color: #e6a23c;
  }

  &.risky {
    background-color: #fef0f0;
    color: #f56c6c;
  }
}

/* 操作按钮 */
.history-actions {
  display: flex;
  gap: 16rpx;
}

.action-btn {
  padding: 12rpx 24rpx;
  border-radius: 8rpx;
  font-size: 26rpx;

  &.view {
    color: #409eff;

    &:active {
      opacity: 0.7;
    }
  }

  &.delete {
    color: #f56c6c;

    &:active {
      opacity: 0.7;
    }
  }
}

/* 加载更多 */
.load-more {
  display: flex;
  justify-content: center;
  padding: 40rpx 0;
}

.load-more-text {
  font-size: 28rpx;
  color: #409eff;
}

.no-more {
  display: flex;
  justify-content: center;
  padding: 40rpx 0;
  font-size: 26rpx;
  color: #909399;
}

/* 响应式 - 小屏幕 */
@media (max-width: 600rpx) {
  .history-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .history-actions {
    width: 100%;
    justify-content: flex-end;
    margin-top: 16rpx;
  }
}

/* ========================================
   H5 桌面端优化
   ======================================== */

/* #ifdef H5 */
// 桌面端 (>= 1024px)
@media screen and (min-width: 1024px) {
  .history-view {
    max-width: 960px;
    margin: 0 auto;
    padding: 48rpx;
  }

  .page-header {
    margin-bottom: 40rpx;
  }

  .page-title {
    font-size: 44rpx;
  }

  .page-subtitle {
    font-size: 30rpx;
  }

  .summary-section {
    margin-bottom: 40rpx;
  }

  .summary-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: 32rpx;
  }

  .summary-item {
    padding: 28rpx;
    border-radius: 20rpx;
    transition: transform 0.2s ease, box-shadow 0.2s ease;

    &:hover {
      transform: translateY(-4rpx);
      box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.1);
    }
  }

  .summary-value {
    font-size: 48rpx;
    margin-bottom: 8rpx;
  }

  .summary-label {
    font-size: 26rpx;
  }

  .empty-state {
    padding: 160rpx 80rpx;
  }

  .empty-title {
    font-size: 36rpx;
  }

  .empty-desc {
    font-size: 30rpx;
  }

  .history-list {
    gap: 28rpx;
  }

  .history-card {
    border-radius: 20rpx;
    transition: transform 0.2s ease, box-shadow 0.2s ease;

    &:hover {
      transform: translateY(-4rpx);
      box-shadow: 0 12rpx 32rpx rgba(0, 0, 0, 0.1);
    }
  }

  .history-item {
    padding: 32rpx;
    gap: 32rpx;
  }

  .history-info {
    gap: 20rpx;
  }

  .time-text {
    font-size: 30rpx;
  }

  .stat-tag {
    padding: 10rpx 20rpx;
    font-size: 26rpx;
  }

  .action-btn {
    padding: 16rpx 28rpx;
    font-size: 28rpx;
    transition: background-color 0.2s ease;

    &.view:hover {
      background-color: #ecf5ff;
    }

    &.delete:hover {
      background-color: #fef0f0;
    }
  }

  .load-more {
    padding: 48rpx 0;
  }

  .load-more-text {
    font-size: 30rpx;
    cursor: pointer;

    &:hover {
      color: #337ecc;
    }
  }

  .no-more {
    font-size: 28rpx;
  }
}

// 大桌面端 (>= 1440px)
@media screen and (min-width: 1440px) {
  .history-view {
    max-width: 1080px;
    padding: 64rpx;
  }

  .summary-grid {
    gap: 40rpx;
  }
}
/* #endif */
</style>
