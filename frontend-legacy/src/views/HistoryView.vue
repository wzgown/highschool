<template>
  <div class="history-view">
    <div class="history-header">
      <h1 class="page-title">历史记录</h1>
      <p class="page-desc">查看您之前的志愿分析记录</p>
    </div>

    <!-- 加载中 -->
    <div v-if="loading" class="loading-container">
      <el-skeleton :rows="5" animated />
    </div>

    <!-- 空状态 -->
    <el-empty
      v-else-if="!histories.length"
      description="暂无历史记录"
    >
      <el-button type="primary" @click="goToForm">
        开始新的分析
      </el-button>
    </el-empty>

    <!-- 历史列表 -->
    <template v-else>
      <div class="history-actions">
        <el-button type="danger" plain :icon="Delete" @click="clearAll">
          清空所有记录
        </el-button>
      </div>

      <div class="history-list">
        <el-card
          v-for="item in histories"
          :key="item.id"
          class="history-card"
          shadow="hover"
        >
          <div class="history-item">
            <div class="history-info">
              <div class="history-time">
                <el-icon><Clock /></el-icon>
                <span>{{ formatTime(item.createdAt) }}</span>
              </div>
              <div class="history-stats">
                <el-tag size="small">{{ item.summary.totalVolunteers }}个志愿</el-tag>
                <el-tag type="success" size="small">安全 {{ item.summary.safeCount }}</el-tag>
                <el-tag type="warning" size="small">稳妥 {{ item.summary.moderateCount }}</el-tag>
                <el-tag type="danger" size="small">冲刺 {{ item.summary.riskyCount }}</el-tag>
              </div>
            </div>
            <div class="history-actions-btns">
              <el-button type="primary" link @click="viewDetail(item.id)">
                查看详情
              </el-button>
              <el-button type="danger" link @click="deleteItem(item.id)">
                删除
              </el-button>
            </div>
          </div>
        </el-card>
      </div>

      <!-- 分页 -->
      <div class="pagination" v-if="total > 10">
        <el-pagination
          background
          layout="prev, pager, next"
          :total="total"
          :page-size="10"
          @current-change="handlePageChange"
        />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { Delete, Clock } from '@element-plus/icons-vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { useHistoryStore } from '@/stores/history';
import { getHistory, deleteHistory, deleteAllHistory } from '@/api/candidate';
import type { HistorySummary } from '@/api/candidate';

const router = useRouter();
const store = useHistoryStore();

const histories = ref<HistorySummary[]>([]);
const total = ref(0);
const loading = ref(false);

// 方法
async function loadHistory() {
  loading.value = true;
  try {
    const data = await getHistory();
    histories.value = data.histories;
    total.value = data.total;
    store.setHistories(data.histories, data.total);
  } catch (error) {
    ElMessage.error('加载历史记录失败');
  } finally {
    loading.value = false;
  }
}

function formatTime(time: string): string {
  return new Date(time).toLocaleString('zh-CN');
}

function viewDetail(id: string) {
  router.push(`/result/${id}`);
}

async function deleteItem(id: string) {
  try {
    await ElMessageBox.confirm('确定要删除这条记录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    });
    
    await deleteHistory(id);
    store.removeHistory(id);
    histories.value = histories.value.filter(h => h.id !== id);
    total.value--;
    ElMessage.success('删除成功');
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
}

async function clearAll() {
  try {
    await ElMessageBox.confirm(
      '确定要清空所有历史记录吗？此操作不可恢复！',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    
    await deleteAllHistory();
    store.clearAll();
    histories.value = [];
    total.value = 0;
    ElMessage.success('已清空所有记录');
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败');
    }
  }
}

function goToForm() {
  router.push('/form');
}

function handlePageChange(page: number) {
  // 分页逻辑
  console.log('Page changed:', page);
}

// 初始化
onMounted(() => {
  loadHistory();
});
</script>

<style lang="scss" scoped>
.history-view {
  max-width: 800px;
  margin: 0 auto;
}

.history-header {
  text-align: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 28px;
  color: #303133;
  margin-bottom: 8px;
}

.page-desc {
  color: #909399;
  font-size: 14px;
}

.loading-container {
  padding: 40px;
}

.history-actions {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 20px;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.history-card {
  :deep(.el-card__body) {
    padding: 16px 20px;
  }
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}

.history-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.history-time {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #606266;
  font-size: 14px;
}

.history-stats {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.history-actions-btns {
  display: flex;
  gap: 10px;
}

.pagination {
  margin-top: 30px;
  display: flex;
  justify-content: center;
}

@media (max-width: 768px) {
  .history-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .history-actions-btns {
    width: 100%;
    justify-content: flex-end;
  }
}
</style>
