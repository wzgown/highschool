/**
 * API通用类型定义
 * 前后端共享
 */

/**
 * API响应状态码
 */
export enum ApiResponseCode {
  /** 成功 */
  SUCCESS = 0,
  /** 参数错误 */
  BAD_REQUEST = 400,
  /** 未授权 */
  UNAUTHORIZED = 401,
  /** 禁止访问 */
  FORBIDDEN = 403,
  /** 资源不存在 */
  NOT_FOUND = 404,
  /** 服务器错误 */
  INTERNAL_ERROR = 500,
}

/**
 * 通用API响应
 */
export interface ApiResponse<T = unknown> {
  /** 状态码 */
  code: ApiResponseCode;
  /** 消息 */
  message: string;
  /** 数据 */
  data?: T;
  /** 时间戳 */
  timestamp?: number;
}

/**
 * 分页请求参数
 */
export interface PaginationParams {
  /** 当前页（从1开始） */
  page: number;
  /** 每页数量 */
  pageSize: number;
}

/**
 * 分页响应
 */
export interface PaginationResponse<T> {
  /** 数据列表 */
  items: T[];
  /** 总数 */
  total: number;
  /** 当前页 */
  page: number;
  /** 每页数量 */
  pageSize: number;
  /** 总页数 */
  totalPages: number;
  /** 是否有下一页 */
  hasNext: boolean;
  /** 是否有上一页 */
  hasPrev: boolean;
}

/**
 * 排序参数
 */
export interface SortParams {
  /** 排序字段 */
  sortBy: string;
  /** 排序方向 */
  sortOrder: 'asc' | 'desc';
}

/**
 * API错误响应
 */
export interface ApiError {
  /** 状态码 */
  code: ApiResponseCode;
  /** 错误消息 */
  message: string;
  /** 错误详情 */
  details?: Record<string, unknown>;
  /** 请求ID（用于追踪） */
  requestId?: string;
}

/**
 * 创建成功响应
 */
export function createSuccessResponse<T>(data: T, message = 'Success'): ApiResponse<T> {
  return {
    code: ApiResponseCode.SUCCESS,
    message,
    data,
    timestamp: Date.now(),
  };
}

/**
 * 创建错误响应
 */
export function createErrorResponse(
  code: ApiResponseCode,
  message: string,
  details?: Record<string, unknown>
): ApiResponse {
  return {
    code,
    message,
    data: details,
    timestamp: Date.now(),
  };
}

/**
 * 参考数据API响应类型
 */

/**
 * 区县列表响应
 */
export interface DistrictsResponse {
  districts: Array<{
    id: number;
    code: string;
    name: string;
    nameEn?: string;
    displayOrder: number;
  }>;
}

/**
 * 学校列表请求参数
 */
export interface SchoolsListParams extends PaginationParams {
  /** 区ID */
  districtId?: number;
  /** 学校类型ID */
  schoolTypeId?: number;
  /** 办别ID */
  schoolNatureId?: number;
  /** 是否含国际课程班 */
  hasInternationalCourse?: boolean;
  /** 搜索关键词 */
  keyword?: string;
}

/**
 * 学校列表响应
 */
export interface SchoolsListResponse {
  schools: Array<{
    id: number;
    code: string;
    fullName: string;
    shortName?: string;
    districtId: number;
    districtName?: string;
    schoolNatureId: number;
    schoolNatureName?: string;
    schoolTypeId?: number;
    schoolTypeName?: string;
    hasInternationalCourse?: boolean;
  }>;
  total: number;
}

/**
 * 学校详情响应
 */
export interface SchoolDetailResponse {
  id: number;
  code: string;
  fullName: string;
  shortName?: string;
  districtId: number;
  districtName?: string;
  schoolNatureId: number;
  schoolNatureName?: string;
  schoolTypeId?: number;
  schoolTypeName?: string;
  boardingTypeId?: number;
  boardingTypeName?: string;
  hasInternationalCourse?: boolean;
  remarks?: string;
  /** 历年分数线 */
  historyScores?: Array<{
    year: number;
    batch: string;
    minScore: number;
  }>;
}

/**
 * 初中学校列表响应
 */
export interface MiddleSchoolsResponse {
  middleSchools: Array<{
    id: number;
    code?: string;
    name: string;
    shortName?: string;
    districtId: number;
    districtName?: string;
    isNonSelective: boolean;
  }>;
}

/**
 * 历史分数线请求参数
 */
export interface HistoryScoresParams {
  /** 区ID */
  districtId: number;
  /** 学校ID */
  schoolId?: number;
  /** 年份 */
  year?: number;
  /** 批次 */
  batch?: string;
}

/**
 * 历史分数线响应
 */
export interface HistoryScoresResponse {
  scores: Array<{
    year: number;
    batch: string;
    batchName: string;
    schoolId?: number;
    schoolName: string;
    minScore: number;
    isTiePreferred?: boolean;
  }>;
}

/**
 * 各区中考人数响应
 */
export interface DistrictExamCountResponse {
  year: number;
  districts: Array<{
    districtId: number;
    districtName: string;
    examCount: number;
  }>;
}

/**
 * 管理员API类型
 */

/**
 * 数据导入请求
 */
export interface DataImportRequest {
  /** 数据类型 */
  dataType: 'schools' | 'quota_district' | 'quota_school' | 'admission_scores';
  /** 年份 */
  year: number;
  /** 区ID（可选，某些数据需要） */
  districtId?: number;
  /** 文件URL或内容 */
  file: {
    url?: string;
    content?: string;
    fileName: string;
  };
}

/**
 * 数据导入状态
 */
export enum DataImportStatus {
  /** 等待处理 */
  PENDING = 'pending',
  /** 处理中 */
  PROCESSING = 'processing',
  /** 完成 */
  COMPLETED = 'completed',
  /** 失败 */
  FAILED = 'failed',
}

/**
 * 数据导入响应
 */
export interface DataImportResponse {
  /** 导入任务ID */
  id: string;
  /** 状态 */
  status: DataImportStatus;
  /** 进度 */
  progress: number;
  /** 成功数量 */
  successCount?: number;
  /** 失败数量 */
  errorCount?: number;
  /** 错误信息 */
  errors?: string[];
  /** 创建时间 */
  createdAt: Date;
  /** 完成时间 */
  completedAt?: Date;
}

/**
 * 学校更新请求
 */
export interface SchoolUpdateRequest {
  /** 学校ID */
  id: number;
  /** 学校简称 */
  shortName?: string;
  /** 学校类型ID */
  schoolTypeId?: number;
  /** 寄宿情况ID */
  boardingTypeId?: number;
  /** 是否含国际课程班 */
  hasInternationalCourse?: boolean;
  /** 备注 */
  remarks?: string;
}

/**
 * 区县更新请求
 */
export interface DistrictUpdateRequest {
  /** 区ID */
  id: number;
  /** 区名称 */
  name?: string;
  /** 区英文名称 */
  nameEn?: string;
  /** 显示顺序 */
  displayOrder?: number;
}

/**
 * WebSocket消息类型
 */
export enum WebSocketMessageType {
  /** 模拟进度更新 */
  SIMULATION_PROGRESS = 'simulation_progress',
  /** 模拟完成 */
  SIMULATION_COMPLETED = 'simulation_completed',
  /** 模拟失败 */
  SIMULATION_FAILED = 'simulation_failed',
  /** 心跳 */
  HEARTBEAT = 'heartbeat',
}

/**
 * WebSocket消息
 */
export interface WebSocketMessage<T = unknown> {
  /** 消息类型 */
  type: WebSocketMessageType;
  /** 数据 */
  data?: T;
  /** 时间戳 */
  timestamp: number;
}

/**
 * 模拟进度消息数据
 */
export interface SimulationProgressData {
  /** 分析ID */
  analysisId: string;
  /** 进度 (0-100) */
  progress: number;
  /** 当前阶段 */
  stage: string;
  /** 模拟次数 */
  completedSimulations?: number;
  /** 总模拟次数 */
  totalSimulations?: number;
}

/**
 * 设备信息
 */
export interface DeviceInfo {
  /** 平台 */
  platform: 'web' | 'mp-weixin' | 'app';
  /** 用户代理 */
  userAgent?: string;
  /** 屏幕分辨率 */
  screenResolution?: string;
  /** 时区 */
  timezone?: string;
  /** 语言 */
  language?: string;
  /** 系统信息 */
  systemInfo?: {
    brand?: string;
    model?: string;
    system?: string;
    platform?: string;
  };
}
