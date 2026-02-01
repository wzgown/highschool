<template>
  <view class="page">
    <view class="container">
      <!-- 头部操作 -->
      <view class="header-actions">
        <button
          v-if="histories.length > 0"
          class="btn btn-danger btn-small"
          @tap="confirmClearAll"
        >
          清空全部
        </button>
      </view>

      <!-- 历史记录列表 -->
      <view v-if="loading" class="loading">
        <view class="loading-spinner"></view>
        <text class="loading-text">加载中...</text>
      </view>

      <view v-else-if="histories.length === 0" class="empty">
        <text class="empty-icon">📋</text>
        <text class="empty-text">暂无历史记录</text>
        <button class="btn btn-primary" @tap="goToForm">开始分析</button>
      </view>

      <view v-else class="history-list">
        <view
          v-for="history in histories"
          :key="history.id"
          class="history-card"
          @tap="viewHistory(history)"
        >
          <view class="history-header">
            <text class="history-date">{{ formatDate(history.createdAt) }}</text>
            <view class="history-actions" @tap.stop>
              <button
                class="btn btn-default btn-small"
                @tap="deleteHistory(history.id)"
              >
                删除
              </button>
            </view>
          </view>

          <view class="history-summary">
            <view class="summary-item">
              <text class="summary-label">总志愿</text>
              <text class="summary-value">{{ history.summary.totalVolunteers }}</text>
            </view>
            <view class="summary-item">
              <text class="summary-label">保底</text>
              <text class="summary-value safe">{{ history.summary.safeCount }}</text>
            </view>
            <view class="summary-item">
              <text class="summary-label">稳妥</text>
              <text class="summary-value moderate">{{ history.summary.moderateCount }}</text>
            </view>
            <view class="summary-item">
              <text class="summary-label">冲刺</text>
              <text class="summary-value risky">{{ history.summary.riskyCount }}</text>
            </view>
          </view>

          <view class="strategy-score">
            <text class="strategy-label">策略评分</text>
            <text
              class="strategy-value"
              :class="getScoreClass(history.summary.strategyScore)"
            >
              {{ history.summary.strategyScore }}
            </text>
          </view>
        </view>

        <!-- 加载更多 -->
        <view
          v-if="hasMore"
          class="load-more"
          @tap="loadMore"
        >
          <text class="load-more-text">加载更多</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { getHistoryList, deleteHistory as deleteHistoryApi } from '@/api';
import type { SimulationHistorySummary } from '@shared/types/simulation';
import { formatDate } from '@/utils/format';

const loading = ref(true);
const histories = ref<SimulationHistorySummary[]>([]);
const currentPage = ref(1);
const pageSize = ref(20);
const total = ref(0);

const hasMore = computed(() => {
  return currentPage.value * pageSize.value < total.value;
});

onMounted(() => {
  loadHistories();
});

async function loadHistories(append = false) {
  loading.value = true;

  try {
    const response = await getHistoryList({
      page: currentPage.value,
      pageSize: pageSize.value,
    });

    if (append) {
      histories.value.push(...response.histories);
    } else {
      histories.value = response.histories;
    }

    total.value = response.total;
  } catch (error: any) {
    uni.showToast({
      title: error.message || '加载失败',
      icon: 'none'
    });
  } finally {
    loading.value = false;
  }
}

function loadMore() {
  currentPage.value++;
  loadHistories(true);
}

async function deleteHistory(id: string) {
  uni.showModal({
    title: '确认删除',
    content: '确定要删除这条记录吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deleteHistoryApi(id);

          // 从列表中移除
          const index = histories.value.findIndex(h => h.id === id);
          if (index !== -1) {
            histories.value.splice(index, 1);
            total.value--;
          }

          uni.showToast({
            title: '删除成功',
            icon: 'success'
          });
        } catch (error: any) {
          uni.showToast({
            title: error.message || '删除失败',
            icon: 'none'
          });
        }
      }
    }
  });
}

function confirmClearAll() {
  uni.showModal({
    title: '确认清空',
    content: '确定要清空所有历史记录吗？此操作不可撤销。',
    confirmColor: '#ff4d4f',
    success: async (res) => {
      if (res.confirm) {
        // TODO: 实现清空全部功能
        uni.showToast({
          title: '功能开发中',
          icon: 'none'
        });
      }
    }
  });
}

function viewHistory(history: SimulationHistorySummary) {
  uni.navigateTo({
    url: `/pages/result/index?result=${encodeURIComponent(JSON.stringify(history.result))}`
  });
}

function goToForm() {
  uni.navigateTo({
    url: '/pages/form/index'
  });
}

function getScoreClass(score: number): string {
  if (score >= 90) return 'score-excellent';
  if (score >= 75) return 'score-good';
  if (score >= 60) return 'score-fair';
  return 'score-poor';
}
</script>

<style lang="scss" scoped>
@import '@/styles/index.scss';

.header {
  &-actions {
    display: flex;
    justify-content: flex-end;
    margin-bottom: 24rpx;
  }
}

.history {
  &-list {
    display: flex;
    flex-direction: column;
    gap: 24rpx;
  }

  &-card {
    background-color: #fff;
    border-radius: 16rpx;
    padding: 24rpx;
    box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.05);
  }

  &-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16rpx;
  }

  &-date {
    font-size: 26rpx;
    color: #8c8c8c;
  }

  &-summary {
    display: flex;
    justify-content: space-around;
    padding: 16rpx 0;
    border-top: 1rpx solid #f0f0f0;
    border-bottom: 1rpx solid #f0f0f0;
    margin-bottom: 16rpx;
  }
}

.summary {
  &-item {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  &-label {
    font-size: 24rpx;
    color: #8c8c8c;
    margin-bottom: 4rpx;
  }

  &-value {
    font-size: 32rpx;
    font-weight: 600;

    &.safe { color: #52c41a; }
    &.moderate { color: #1890ff; }
    &.risky { color: #faad14; }
  }
}

.strategy {
  &-score {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  &-label {
    font-size: 26rpx;
    color: #595959;
  }

  &-value {
    font-size: 36rpx;
    font-weight: 700;

    &.score-excellent { color: #52c41a; }
    &.score-good { color: #1890ff; }
    &.score-fair { color: #faad14; }
    &.score-poor { color: #ff4d4f; }
  }
}

.load {
  &-more {
    padding: 24rpx;
    text-align: center;
  }

  &-more-text {
    font-size: 28rpx;
    color: #1890ff;
  }
}
</style>
