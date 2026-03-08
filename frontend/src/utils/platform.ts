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
 * Get platform-specific base URL for API
 */
export function getApiBaseUrl(): string {
  // In uni-app, we can use environment variables
  const baseUrl = import.meta.env.VITE_API_BASE_URL || '';

  // For mini programs, we might need to use different domains
  // due to domain whitelist requirements
  if (isMiniProgram() && !baseUrl) {
    // Default production URL for mini programs
    return 'https://api.example.com';
  }

  return baseUrl;
}
