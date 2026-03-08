/**
 * Device ID utility for uni-app
 * Cross-platform device identification using uni-app storage APIs
 */
import { isH5, isWeixinMiniProgram, getPlatform } from './platform';

let deviceId: string | null = null;

const STORAGE_KEY = 'device_id';

/**
 * Generate a random device ID
 */
function generateDeviceId(): string {
  const timestamp = Date.now().toString(36);
  const randomPart = Math.random().toString(36).substring(2, 15);
  return `${timestamp}-${randomPart}`;
}

/**
 * Get device ID from storage
 */
async function getStoredDeviceId(): Promise<string | null> {
  try {
    // Use uni-app storage API for cross-platform compatibility
    const result = await new Promise<string | null>((resolve) => {
      uni.getStorage({
        key: STORAGE_KEY,
        success: (res) => resolve(res.data as string),
        fail: () => resolve(null),
      });
    });
    return result;
  } catch {
    return null;
  }
}

/**
 * Save device ID to storage
 */
async function saveDeviceId(id: string): Promise<void> {
  try {
    await new Promise<void>((resolve, reject) => {
      uni.setStorage({
        key: STORAGE_KEY,
        data: id,
        success: () => resolve(),
        fail: (err) => reject(err),
      });
    });
  } catch (error) {
    console.error('Failed to save device ID:', error);
  }
}

/**
 * Get device ID for H5 using FingerprintJS (lazy loaded)
 */
async function getH5DeviceId(): Promise<string> {
  // For H5, try to use FingerprintJS if available
  try {
    const FingerprintJS = await import('@fingerprintjs/fingerprintjs');
    const fp = await FingerprintJS.load();
    const result = await fp.get();
    return result.visitorId;
  } catch {
    // Fallback to stored or generated ID
    const stored = await getStoredDeviceId();
    if (stored) return stored;
    return generateDeviceId();
  }
}

/**
 * Get device ID for mini program
 */
async function getMiniProgramDeviceId(): Promise<string> {
  // For WeChat mini program, use device info if available
  // #ifdef MP-WEIXIN
  try {
    const systemInfo = uni.getSystemInfoSync();
    const deviceIdSource = `${systemInfo.brand}-${systemInfo.model}-${systemInfo.system}`;
    // Create a simple hash from device info
    let hash = 0;
    for (let i = 0; i < deviceIdSource.length; i++) {
      const char = deviceIdSource.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return `wx-${Math.abs(hash).toString(36)}`;
  } catch {
    // Fallback
  }
  // #endif

  return generateDeviceId();
}

/**
 * Get or create device ID
 * This is the main function to get a unique device identifier
 */
export async function getDeviceId(): Promise<string> {
  if (deviceId) {
    return deviceId;
  }

  // Try to get from storage first
  const stored = await getStoredDeviceId();
  if (stored) {
    deviceId = stored;
    return deviceId;
  }

  // Generate new device ID based on platform
  if (isH5()) {
    deviceId = await getH5DeviceId();
  } else if (isWeixinMiniProgram()) {
    deviceId = await getMiniProgramDeviceId();
  } else {
    deviceId = generateDeviceId();
  }

  // Save to storage
  await saveDeviceId(deviceId);

  return deviceId;
}

/**
 * Get device information for analytics/debugging
 */
export function getDeviceInfo() {
  const platform = getPlatform();

  try {
    const systemInfo = uni.getSystemInfoSync();
    return {
      platform,
      brand: systemInfo.brand,
      model: systemInfo.model,
      system: systemInfo.system,
      screenWidth: systemInfo.screenWidth,
      screenHeight: systemInfo.screenHeight,
      language: systemInfo.language,
      version: systemInfo.version,
      SDKVersion: systemInfo.SDKVersion,
    };
  } catch {
    return {
      platform,
      brand: 'unknown',
      model: 'unknown',
      system: 'unknown',
      screenWidth: 0,
      screenHeight: 0,
      language: 'unknown',
      version: 'unknown',
      SDKVersion: 'unknown',
    };
  }
}
