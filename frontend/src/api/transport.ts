/**
 * Cross-platform transport adapter for Connect-RPC
 * Handles network requests for H5 and mini programs
 */
import { isH5, isMiniProgram, getApiBaseUrl, isDebugMode } from '@/utils/platform';

/**
 * Custom fetch adapter for uni-app
 * Provides unified network request API across platforms
 */
export interface TransportOptions {
  baseUrl: string;
  timeout?: number;
  headers?: Record<string, string>;
}

/**
 * Response type for transport
 */
export interface TransportResponse {
  status: number;
  headers: Record<string, string>;
  data: ArrayBuffer;
}

/**
 * Network error class for mini program specific errors
 */
export class MpNetworkError extends Error {
  constructor(
    message: string,
    public readonly code: number,
    public readonly originalError?: unknown
  ) {
    super(message);
    this.name = 'MpNetworkError';
  }
}

/**
 * Create a fetch-like function for uni-app
 * This wraps uni.request to behave like fetch
 */
export function createUniFetch(baseUrl: string) {
  return async function uniFetch(
    input: RequestInfo | URL,
    init?: RequestInit
  ): Promise<Response> {
    const url = typeof input === 'string' ? input : input instanceof URL ? input.href : input.url;
    const fullUrl = url.startsWith('http') ? url : `${baseUrl}${url}`;

    const method = init?.method || 'GET';
    const headers: Record<string, string> = {};
    let body: string | ArrayBuffer | undefined;

    // Convert headers
    if (init?.headers) {
      const headersObj = init.headers as Record<string, string>;
      Object.keys(headersObj).forEach(key => {
        headers[key] = headersObj[key];
      });
    }

    // Convert body
    if (init?.body) {
      if (typeof init.body === 'string') {
        body = init.body;
      } else if (init.body instanceof ArrayBuffer) {
        // Convert ArrayBuffer to base64 for mini program
        if (isMiniProgram()) {
          body = arrayBufferToBase64(init.body);
        } else {
          body = init.body;
        }
      }
    }

    // Debug logging
    if (isDebugMode()) {
      console.log(`[MP Request] ${method} ${fullUrl}`);
    }

    return new Promise((resolve, reject) => {
      uni.request({
        url: fullUrl,
        method: method as 'GET' | 'POST' | 'PUT' | 'DELETE',
        data: body,
        header: headers,
        timeout: init?.signal ? undefined : 30000,
        responseType: 'arraybuffer',
        success: (res) => {
          // Debug logging
          if (isDebugMode()) {
            console.log(`[MP Response] ${res.statusCode}`, res.header);
          }

          // Handle common HTTP errors
          if (res.statusCode === 401) {
            reject(new MpNetworkError('Unauthorized - Please login again', 401));
            return;
          }
          if (res.statusCode === 403) {
            reject(new MpNetworkError('Access forbidden', 403));
            return;
          }
          if (res.statusCode >= 500) {
            reject(new MpNetworkError(`Server error: ${res.statusCode}`, res.statusCode));
            return;
          }

          // Create a Response-like object
          const response = new Response(res.data as ArrayBuffer, {
            status: res.statusCode,
            headers: new Headers(res.header as Record<string, string>),
          });
          resolve(response);
        },
        fail: (err) => {
          // Handle mini program specific errors
          const errorMsg = err.errMsg || 'Network request failed';
          if (isDebugMode()) {
            console.error(`[MP Error] ${errorMsg}`, err);
          }

          // Check for common mini program network errors
          if (errorMsg.includes('url not in domain list')) {
            reject(new MpNetworkError(
              'API domain not configured. Please add the domain in WeChat Mini Program Admin Console.',
              -1,
              err
            ));
            return;
          }
          if (errorMsg.includes('request:fail')) {
            reject(new MpNetworkError(
              'Network connection failed. Please check your internet connection.',
              -1,
              err
            ));
            return;
          }
          if (errorMsg.includes('timeout')) {
            reject(new MpNetworkError(
              'Request timeout. Please try again.',
              -1,
              err
            ));
            return;
          }

          reject(new MpNetworkError(errorMsg, -1, err));
        },
      });
    });
  };
}

/**
 * Convert ArrayBuffer to Base64 string
 */
function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  // In browser environment, use btoa
  return btoa(binary);
}

/**
 * Get the appropriate fetch function for the current platform
 */
export function getPlatformFetch(): typeof fetch {
  const baseUrl = getApiBaseUrl();

  if (isH5()) {
    // For H5, use native fetch
    return fetch.bind(window);
  }

  // For mini programs, use uni-app adapter
  return createUniFetch(baseUrl);
}

/**
 * Create transport configuration for Connect-RPC
 */
export function createTransportConfig() {
  const baseUrl = getApiBaseUrl();

  return {
    baseUrl,
    // For H5, we can use fetch options
    ...(isH5() && {
      fetchOptions: {
        credentials: 'include' as RequestCredentials,
      },
    }),
    // For mini programs, we need custom fetch
    ...(!isH5() && {
      fetch: createUniFetch(baseUrl),
    }),
  };
}
