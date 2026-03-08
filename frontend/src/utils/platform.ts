/**
 * Platform detection utilities for uni-app
 * Provides cross-platform detection for Web/H5, WeChat Mini Program, etc.
 */

export type Platform = 'h5' | 'mp-weixin' | 'mp-alipay' | 'app' | 'unknown';

/**
 * Get current platform
 */
export function getPlatform(): Platform {
  // #ifdef H5
  return 'h5';
  // #endif

  // #ifdef MP-WEIXIN
  return 'mp-weixin';
  // #endif

  // #ifdef MP-ALIPAY
  return 'mp-alipay';
  // #endif

  // #ifdef APP-PLUS
  return 'app';
  // #endif

  return 'unknown';
}

/**
 * Check if running in H5 (browser) environment
 */
export function isH5(): boolean {
  return getPlatform() === 'h5';
}

/**
 * Check if running in WeChat Mini Program
 */
export function isWeixinMiniProgram(): boolean {
  return getPlatform() === 'mp-weixin';
}

/**
 * Check if running in any mini program environment
 */
export function isMiniProgram(): boolean {
  const platform = getPlatform();
  return platform.startsWith('mp-');
}

/**
 * Check if running in native app
 */
export function isApp(): boolean {
  return getPlatform() === 'app';
}

/**
 * Production API base URL for WeChat mini program
 * This domain must be configured in WeChat Mini Program Admin Console
 * under: Development -> Development Settings -> Server Domain -> request合法域名
 */
const MP_PRODUCTION_API_URL = 'https://api.shhighschool.example.com';

/**
 * Get platform-specific base URL for API
 */
export function getApiBaseUrl(): string {
  // In uni-app, we can use environment variables
  const envBaseUrl = import.meta.env.VITE_API_BASE_URL as string | undefined;

  // If environment variable is set, use it
  if (envBaseUrl) {
    return envBaseUrl;
  }

  // For mini programs in production without env variable, use production URL
  // This handles cases where env variables might not be injected in MP builds
  if (isMiniProgram()) {
    return MP_PRODUCTION_API_URL;
  }

  // Default to localhost for H5 development
  return 'http://localhost:8080';
}

/**
 * Check if debug mode is enabled
 */
export function isDebugMode(): boolean {
  return import.meta.env.VITE_DEBUG === 'true';
}
