/**
 * API客户端基础配置
 */

import type { ApiResponse } from '@shared/types/api';

// API基础URL
const BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';

// 获取设备ID
function getDeviceId(): string {
  let deviceId = uni.getStorageSync('deviceId');
  if (!deviceId) {
    deviceId = `device-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    uni.setStorageSync('deviceId', deviceId);
  }
  return deviceId;
}

// 获取设备信息
function getDeviceInfo() {
  return uni.getStorageSync('deviceInfo') || {};
}

/**
 * API请求配置
 */
interface RequestConfig {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  data?: any;
  headers?: Record<string, string>;
  timeout?: number;
}

/**
 * API请求错误
 */
export class ApiError extends Error {
  constructor(
    public code: string,
    message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/**
 * 发送API请求
 */
async function request<T>(
  path: string,
  config: RequestConfig = {}
): Promise<T> {
  const {
    method = 'GET',
    data,
    headers = {},
    timeout = 30000,
  } = config;

  const url = `${BASE_URL}${path}`;

  // 构建请求头
  const requestHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
    'X-Device-ID': getDeviceId(),
    ...headers,
  };

  // 添加设备信息头
  const deviceInfo = getDeviceInfo();
  if (deviceInfo.platform) {
    requestHeaders['X-Client-Platform'] = deviceInfo.platform;
  }
  if (deviceInfo.screenWidth) {
    requestHeaders['X-Screen-Resolution'] = `${deviceInfo.screenWidth}x${deviceInfo.screenHeight}`;
  }

  try {
    const response = await uni.request({
      url,
      method: method as any,
      data,
      header: requestHeaders,
      timeout,
    });

    const statusCode = response.statusCode;
    const responseData = response.data as ApiResponse<T>;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseData.code === 0 || responseData.data !== undefined) {
        return responseData.data as T;
      }
      throw new ApiError(responseData.code, responseData.message, responseData.details);
    }

    if (statusCode === 401) {
      throw new ApiError('UNAUTHORIZED', '未授权访问');
    }

    if (statusCode === 404) {
      throw new ApiError('NOT_FOUND', '资源不存在');
    }

    if (statusCode === 429) {
      throw new ApiError('RATE_LIMIT', '请求过于频繁，请稍后重试');
    }

    throw new ApiError(
      responseData.code || 'UNKNOWN',
      responseData.message || '请求失败'
    );

  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    // 网络错误
    if (error instanceof Error && error.message.includes('timeout')) {
      throw new ApiError('TIMEOUT', '请求超时，请检查网络连接');
    }

    if (error instanceof Error && error.message.includes('fail')) {
      throw new ApiError('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }

    throw new ApiError('UNKNOWN', '未知错误');
  }
}

/**
 * GET请求
 */
export function get<T>(path: string, config?: Omit<RequestConfig, 'method'>): Promise<T> {
  return request<T>(path, { ...config, method: 'GET' });
}

/**
 * POST请求
 */
export function post<T>(path: string, data?: any, config?: Omit<RequestConfig, 'method' | 'data'>): Promise<T> {
  return request<T>(path, { ...config, method: 'POST', data });
}

/**
 * PUT请求
 */
export function put<T>(path: string, data?: any, config?: Omit<RequestConfig, 'method' | 'data'>): Promise<T> {
  return request<T>(path, { ...config, method: 'PUT', data });
}

/**
 * DELETE请求
 */
export function del<T>(path: string, config?: Omit<RequestConfig, 'method'>): Promise<T> {
  return request<T>(path, { ...config, method: 'DELETE' });
}

export default { get, post, put, delete: del };
