/**
 * 自定义错误类
 */

/**
 * API错误基类
 */
export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'ApiError';
    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      code: this.code,
      message: this.message,
      details: this.details,
      timestamp: Date.now(),
    };
  }
}

/**
 * 参数错误
 */
export class BadRequestError extends ApiError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(400, 'BAD_REQUEST', message, details);
    this.name = 'BadRequestError';
  }
}

/**
 * 未授权错误
 */
export class UnauthorizedError extends ApiError {
  constructor(message = '未授权访问') {
    super(401, 'UNAUTHORIZED', message);
    this.name = 'UnauthorizedError';
  }
}

/**
 * 禁止访问错误
 */
export class ForbiddenError extends ApiError {
  constructor(message = '禁止访问') {
    super(403, 'FORBIDDEN', message);
    this.name = 'ForbiddenError';
  }
}

/**
 * 资源不存在错误
 */
export class NotFoundError extends ApiError {
  constructor(resource: string) {
    super(404, 'NOT_FOUND', `${resource} 不存在`);
    this.name = 'NotFoundError';
  }
}

/**
 * 服务器错误
 */
export class InternalError extends ApiError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(500, 'INTERNAL_ERROR', message, details);
    this.name = 'InternalError';
  }
}

/**
 * 业务逻辑错误
 */
export class BusinessError extends ApiError {
  constructor(code: string, message: string, details?: Record<string, unknown>) {
    super(400, code, message, details);
    this.name = 'BusinessError';
  }
}

/**
 * 验证错误
 */
export class ValidationError extends BadRequestError {
  constructor(errors: string[] | Record<string, string>) {
    const message = Array.isArray(errors)
      ? `验证失败: ${errors.join(', ')}`
      : '验证失败';
    super(message, Array.isArray(errors) ? undefined : { errors });
    this.name = 'ValidationError';
  }
}

/**
 * 模拟分析错误
 */
export class SimulationError extends InternalError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(`模拟分析失败: ${message}`, details);
    this.name = 'SimulationError';
  }
}

/**
 * 数据库错误
 */
export class DatabaseError extends InternalError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(`数据库错误: ${message}`, details);
    this.name = 'DatabaseError';
  }
}

/**
 * 缓存错误
 */
export class CacheError extends InternalError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(`缓存错误: ${message}`, details);
    this.name = 'CacheError';
  }
}

/**
 * 错误处理器中间件类型
 */
export type ErrorHandler = (error: Error) => ApiError;

/**
 * 默认错误处理器
 */
export const defaultErrorHandler: ErrorHandler = (error: Error) => {
  if (error instanceof ApiError) {
    return error;
  }

  // 记录未知错误
  console.error('Unhandled error:', error);

  return new InternalError('服务器内部错误');
};

/**
 * 判断是否为API错误
 */
export function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError;
}

/**
 * 判断是否为特定类型的错误
 */
export function isErrorCode(error: unknown, code: string): boolean {
  return isApiError(error) && error.code === code;
}
