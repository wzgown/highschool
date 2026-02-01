/**
 * 设备指纹工具
 */

import { randomBytes, createHash } from 'crypto';

/**
 * 设备信息接口
 */
export interface DeviceInfo {
  platform: 'web' | 'mp-weixin' | 'app';
  userAgent?: string;
  screenResolution?: string;
  timezone?: string;
  language?: string;
  systemInfo?: {
    brand?: string;
    model?: string;
    system?: string;
    platform?: string;
  };
}

/**
 * 生成设备指纹
 */
export function generateDeviceFingerprint(deviceInfo: DeviceInfo): string {
  // 收集设备特征
  const features: string[] = [
    deviceInfo.platform,
    deviceInfo.userAgent || '',
    deviceInfo.screenResolution || '',
    deviceInfo.timezone || 'UTC',
    deviceInfo.language || 'zh',
    JSON.stringify(deviceInfo.systemInfo || {}),
  ];

  // 生成哈希
  const hash = createHash('sha256')
    .update(features.join('|'))
    .digest('hex');

  return hash;
}

/**
 * 验证设备指纹格式
 */
export function isValidDeviceFingerprint(fingerprint: string): boolean {
  // SHA256哈希应该是64个十六进制字符
  return /^[a-f0-9]{64}$/i.test(fingerprint);
}

/**
 * 生成简单的设备ID（用于无法生成指纹的情况）
 */
export function generateSimpleDeviceId(): string {
  return randomBytes(16).toString('hex');
}

/**
 * 规范化设备信息
 */
export function normalizeDeviceInfo(raw: Record<string, unknown>): DeviceInfo {
  const platform = String(raw.platform || 'web');

  return {
    platform: ['web', 'mp-weixin', 'app'].includes(platform)
      ? (platform as DeviceInfo['platform'])
      : 'web',
    userAgent: String(raw.userAgent || ''),
    screenResolution: String(raw.screenResolution || ''),
    timezone: String(raw.timezone || 'UTC'),
    language: String(raw.language || 'zh'),
    systemInfo: raw.systemInfo
      ? {
          brand: raw.systemInfo.brand ? String(raw.systemInfo.brand) : undefined,
          model: raw.systemInfo.model ? String(raw.systemInfo.model) : undefined,
          system: raw.systemInfo.system ? String(raw.systemInfo.system) : undefined,
          platform: raw.systemInfo.platform ? String(raw.systemInfo.platform) : undefined,
        }
      : undefined,
  };
}

/**
 * 提取设备信息头
 */
export function extractDeviceInfoFromHeaders(headers: Record<string, string>): Partial<DeviceInfo> {
  return {
    platform: (headers['x-client-platform'] as DeviceInfo['platform']) || 'web',
    userAgent: headers['user-agent'],
    screenResolution: headers['x-screen-resolution'],
    timezone: headers['x-timezone'] || 'UTC',
    language: headers['accept-language']?.split(',')[0] || 'zh',
  };
}

/**
 * 从请求中生成或获取设备ID
 */
export function getOrCreateDeviceId(
  headers: Record<string, string>,
  existingDeviceId?: string
): string {
  // 如果有现有的设备ID且格式正确，直接使用
  if (existingDeviceId && isValidDeviceFingerprint(existingDeviceId)) {
    return existingDeviceId;
  }

  // 从请求头提取设备信息
  const deviceInfo = extractDeviceInfoFromHeaders(headers);

  // 生成新的设备指纹
  return generateDeviceFingerprint(deviceInfo);
}
