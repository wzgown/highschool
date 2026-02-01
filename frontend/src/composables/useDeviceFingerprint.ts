/**
 * 设备指纹组合式API
 */

import { ref, computed } from 'vue';

interface DeviceInfo {
  platform: string;
  brand?: string;
  model?: string;
  system?: string;
  screenWidth?: number;
  screenHeight?: number;
}

const deviceId = ref<string>('');
const deviceInfo = ref<DeviceInfo>({
  platform: 'unknown',
});

/**
 * 使用设备指纹
 */
export function useDeviceFingerprint() {
  const isInitialized = computed(() => !!deviceId.value);

  /**
   * 初始化设备指纹
   */
  function init() {
    // 获取已存储的设备ID
    const storedDeviceId = uni.getStorageSync('deviceId');
    if (storedDeviceId) {
      deviceId.value = storedDeviceId;
    }

    // 获取已存储的设备信息
    const storedDeviceInfo = uni.getStorageSync('deviceInfo');
    if (storedDeviceInfo) {
      deviceInfo.value = storedDeviceInfo;
    }

    // 获取系统信息
    const systemInfo = uni.getSystemInfoSync();
    const info: DeviceInfo = {
      platform: systemInfo.uniPlatform || 'unknown',
      brand: systemInfo.brand,
      model: systemInfo.model,
      system: systemInfo.system,
      screenWidth: systemInfo.screenWidth,
      screenHeight: systemInfo.screenHeight,
    };

    deviceInfo.value = info;
    uni.setStorageSync('deviceInfo', info);

    // 如果没有设备ID，生成一个新的
    if (!deviceId.value) {
      generateDeviceId();
    }
  }

  /**
   * 生成设备ID
   */
  function generateDeviceId() {
    const systemInfo = uni.getSystemInfoSync();

    // 简化版设备ID生成（实际应该使用更复杂的算法）
    const components = [
      systemInfo.platform || 'unknown',
      systemInfo.brand || 'unknown',
      systemInfo.model || 'unknown',
      systemInfo.system || 'unknown',
      systemInfo.screenWidth || 0,
      systemInfo.screenHeight || 0,
    ];

    // 生成简单的哈希
    const str = components.join('|');
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }

    deviceId.value = `device-${Math.abs(hash)}-${Date.now().toString(36)}`;
    uni.setStorageSync('deviceId', deviceId.value);
  }

  /**
   * 获取设备ID
   */
  function getDeviceId(): string {
    return deviceId.value;
  }

  /**
   * 重置设备ID
   */
  function resetDeviceId() {
    uni.removeStorageSync('deviceId');
    generateDeviceId();
  }

  return {
    deviceId: computed(() => deviceId.value),
    deviceInfo: computed(() => deviceInfo.value),
    isInitialized,
    init,
    getDeviceId,
    resetDeviceId,
  };
}
