import axios, { type AxiosError, type AxiosResponse } from 'axios';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || '';

// 创建 axios 实例
const client = axios.create({
  baseURL: BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
client.interceptors.request.use(
  (config) => {
    // 可以在这里添加认证信息等
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
client.interceptors.response.use(
  (response: AxiosResponse<ApiResponse<unknown>>) => {
    const { data } = response;
    
    // 统一响应格式处理
    if (data.code !== 'OK' && data.code !== 'SUCCESS') {
      return Promise.reject(new Error(data.message || '请求失败'));
    }
    
    // 返回实际数据
    return { ...response, data: data.data };
  },
  (error: AxiosError<ApiResponse<unknown>>) => {
    const message = error.response?.data?.message || error.message || '网络错误';
    return Promise.reject(new Error(message));
  }
);

// API 响应类型
interface ApiResponse<T> {
  code: string;
  message: string;
  data: T;
  timestamp: number;
}

// 包装后的响应类型
export interface ApiClient {
  get: <T>(url: string, params?: Record<string, unknown>) => Promise<T>;
  post: <T>(url: string, data?: unknown) => Promise<T>;
  put: <T>(url: string, data?: unknown) => Promise<T>;
  delete: <T>(url: string) => Promise<T>;
}

export const api: ApiClient = {
  get: async <T>(url: string, params?: Record<string, unknown>) => {
    const response = await client.get<unknown, AxiosResponse<T>>(url, { params });
    return response.data as T;
  },
  post: async <T>(url: string, data?: unknown) => {
    const response = await client.post<unknown, AxiosResponse<T>>(url, data);
    return response.data as T;
  },
  put: async <T>(url: string, data?: unknown) => {
    const response = await client.put<unknown, AxiosResponse<T>>(url, data);
    return response.data as T;
  },
  delete: async <T>(url: string) => {
    const response = await client.delete<unknown, AxiosResponse<T>>(url);
    return response.data as T;
  },
};

export default client;
