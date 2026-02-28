import FingerprintJS from '@fingerprintjs/fingerprintjs';

let deviceId: string | null = null;

export async function getDeviceId(): Promise<string> {
  if (deviceId) {
    return deviceId;
  }
  
  // 先尝试从 localStorage 获取
  const stored = localStorage.getItem('device_id');
  if (stored) {
    deviceId = stored;
    return deviceId;
  }
  
  // 生成新的设备指纹
  const fp = await FingerprintJS.load();
  const result = await fp.get();
  deviceId = result.visitorId;
  
  // 保存到 localStorage
  localStorage.setItem('device_id', deviceId);
  
  return deviceId;
}

export function getDeviceInfo() {
  return {
    userAgent: navigator.userAgent,
    screenResolution: `${window.screen.width}x${window.screen.height}`,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    language: navigator.language,
    platform: 'web',
  };
}
