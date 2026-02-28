import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { HistorySummary } from '@/api/candidate';

export const useHistoryStore = defineStore('history', () => {
  // State
  const histories = ref<HistorySummary[]>([]);
  const total = ref(0);
  const loading = ref(false);
  
  // Actions
  function setHistories(data: HistorySummary[], count: number) {
    histories.value = data;
    total.value = count;
  }
  
  function removeHistory(id: string) {
    const index = histories.value.findIndex(h => h.id === id);
    if (index > -1) {
      histories.value.splice(index, 1);
      total.value--;
    }
  }
  
  function clearAll() {
    histories.value = [];
    total.value = 0;
  }
  
  function setLoading(value: boolean) {
    loading.value = value;
  }
  
  return {
    histories,
    total,
    loading,
    setHistories,
    removeHistory,
    clearAll,
    setLoading,
  };
});
