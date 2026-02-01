/**
 * Fastify 应用配置
 */

import Fastify, { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import websocket from '@fastify/websocket';
import multipart from '@fastify/multipart';
import rateLimit from '@fastify/rate-limit';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import { registerV1Routes } from './api/v1';
import { testConnection } from './infrastructure/database';
import { logger } from '@shared/utils';
import { ApiError } from '@shared/utils/errors';

/**
 * 创建 Fastify 应用实例
 */
export async function createApp(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: false, // 使用自定义 logger
    disableRequestLogging: true,
    trustProxy: true,
    requestIdHeader: 'x-request-id',
    requestIdLogLabel: 'reqId',
    genReqId: () => `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
  });

  // 注册 CORS
  await app.register(cors, {
    origin: true, // 允许所有来源（生产环境应该限制）
    credentials: true,
  });

  // 注册 WebSocket
  await app.register(websocket);

  // 注册 multipart（用于文件上传）
  await app.register(multipart, {
    limits: {
      fileSize: 10 * 1024 * 1024, // 10MB
    },
  });

  // 注册速率限制
  await app.register(rateLimit, {
    max: 100, // 每分钟100次请求
    timeWindow: '1 minute',
    skipOnError: true,
  });

  // 注册 Swagger 文档
  await app.register(swagger, {
    openapi: {
      info: {
        title: '上海中考招生模拟系统 API',
        description: '提供中考志愿模拟分析服务',
        version: '1.0.0',
      },
      servers: [
        {
          url: process.env.API_BASE_URL || 'http://localhost:3000',
          description: 'API服务器',
        },
      ],
      tags: [
        { name: 'candidates', description: '考生相关API' },
        { name: 'reference', description: '参考数据API' },
        { name: 'admin', description: '管理员API' },
      ],
      components: {
        securitySchemes: {
          apiKey: {
            type: 'apiKey',
            in: 'header',
            name: 'x-api-key',
            description: '管理员API密钥',
          },
        },
      },
    },
  });

  await app.register(swaggerUi, {
    routePrefix: '/docs',
    uiConfig: {
      docExpansion: 'list',
      deepLinking: false,
    },
  });

  // 全局错误处理
  app.setErrorHandler((error, request, reply) => {
    logger.error('Request error', {
      error: error.message,
      stack: error.stack,
      reqId: request.id,
    });

    if (error instanceof ApiError) {
      reply.status(error.statusCode).send({
        code: error.code,
        message: error.message,
        details: error.details,
        timestamp: Date.now(),
      });
      return;
    }

    // 验证错误
    if (error.validation) {
      reply.status(400).send({
        code: 'VALIDATION_ERROR',
        message: '请求参数验证失败',
        details: error.validation,
        timestamp: Date.now(),
      });
      return;
    }

    // 默认错误响应
    reply.status(500).send({
      code: 'INTERNAL_ERROR',
      message: '服务器内部错误',
      timestamp: Date.now(),
    });
  });

  // 404 处理
  app.setNotFoundHandler((request, reply) => {
    reply.status(404).send({
      code: 'NOT_FOUND',
      message: `路由 ${request.method} ${request.url} 不存在`,
      timestamp: Date.now(),
    });
  });

  // 请求日志
  app.addHook('onRequest', (request, reply, done) => {
    logger.info('Request received', {
      method: request.method,
      url: request.url,
      reqId: request.id,
    });
    done();
  });

  // 响应日志
  app.addHook('onResponse', (request, reply, done) => {
    logger.info('Response sent', {
      method: request.method,
      url: request.url,
      statusCode: reply.statusCode,
      reqId: request.id,
      duration: reply.getResponseTime(),
    });
    done();
  });

  // 注册路由
  await app.register(async function (fastify) {
    await registerV1Routes(fastify);
  }, { prefix: '/api/v1' });

  // WebSocket 路由
  app.register(async function (fastify) {
    fastify.register(async function (fastify) {
      fastify.get('/ws', { websocket: true }, (connection, req) => {
        logger.info('WebSocket connection established', {
          reqId: req.id,
        });

        // 发送欢迎消息
        connection.socket.send(JSON.stringify({
          type: 'connected',
          data: { message: 'WebSocket连接已建立' },
          timestamp: Date.now(),
        }));

        // 处理消息
        connection.socket.on('message', (message: string) => {
          try {
            const data = JSON.parse(message.toString());
            logger.info('WebSocket message received', { data, reqId: req.id });

            // 处理不同类型的消息
            switch (data.type) {
              case 'ping':
                connection.socket.send(JSON.stringify({
                  type: 'pong',
                  timestamp: Date.now(),
                }));
                break;

              case 'subscribe':
                // 订阅模拟进度
                connection.socket.send(JSON.stringify({
                  type: 'subscribed',
                  data: { analysisId: data.analysisId },
                  timestamp: Date.now(),
                }));
                break;

              default:
                connection.socket.send(JSON.stringify({
                  type: 'error',
                  data: { message: 'Unknown message type' },
                  timestamp: Date.now(),
                }));
            }
          } catch (error) {
            logger.error('WebSocket message error', { error, reqId: req.id });
          }
        });

        connection.socket.on('close', () => {
          logger.info('WebSocket connection closed', { reqId: req.id });
        });
      });
    }, { prefix: '/api/v1' });
  });

  return app;
}

/**
 * 启动应用
 */
export async function startServer(host?: string, port?: number): Promise<FastifyInstance> {
  const app = await createApp();

  // 测试数据库连接
  const dbConnected = await testConnection();
  if (!dbConnected) {
    logger.warn('Database connection test failed, but continuing...');
  }

  const serverHost = host || process.env.HOST || '0.0.0.0';
  const serverPort = port || parseInt(process.env.PORT || '3000');

  await app.listen({ port: serverPort, host: serverHost });

  logger.info(`Server started`, {
    url: `http://${serverHost}:${serverPort}`,
    docs: `http://${serverHost}:${serverPort}/docs`,
    env: process.env.NODE_ENV || 'development',
  });

  return app;
}
