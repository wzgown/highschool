import { ref, onMounted } from 'vue';
import { getDeviceId, getDeviceInfo } from '@/utils/device';

export function useDeviceFingerprint() {
  const deviceId = ref<string>('');
  const loading = ref(true);
  const error = ref<string | null>(null);
  
  onMounted(async () => {
    try {
      loading.value = true;
      deviceId.value = await getDeviceId();
    } catch (e) {
      error.value = '获取设备标识失败';
    } finally {
      loading.value = false;
    }
  });
  
  return {
    deviceId,
    deviceInfo: getDeviceInfo(),
    loading,
    error,
  };
}
