import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { AnalysisResult } from '@/api/candidate';

export const useSimulationStore = defineStore('simulation', () => {
  // State
  const currentId = ref<string | null>(null);
  const result = ref<AnalysisResult | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);
  
  // Actions
  function setCurrentId(id: string) {
    currentId.value = id;
  }
  
  function setResult(data: AnalysisResult) {
    result.value = data;
  }
  
  function setLoading(value: boolean) {
    loading.value = value;
  }
  
  function setError(msg: string | null) {
    error.value = msg;
  }
  
  function reset() {
    currentId.value = null;
    result.value = null;
    loading.value = false;
    error.value = null;
  }
  
  return {
    currentId,
    result,
    loading,
    error,
    setCurrentId,
    setResult,
    setLoading,
    setError,
    reset,
  };
});
