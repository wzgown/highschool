/**
 * API v1 路由入口
 */

import type { FastifyInstance } from 'fastify';
import { candidateRoutes } from './candidate';
import { referenceRoutes } from './reference';
import { adminRoutes } from './admin';

/**
 * 注册所有 v1 路由
 */
export async function registerV1Routes(fastify: FastifyInstance) {
  // 注册前缀
  await fastify.register(async function (fastify) {
    await candidateRoutes(fastify);
  }, { prefix: '/candidates' });

  await fastify.register(async function (fastify) {
    await referenceRoutes(fastify);
  }, { prefix: '/reference' });

  await fastify.register(async function (fastify) {
    await adminRoutes(fastify);
  }, { prefix: '/admin' });

  // 健康检查
  fastify.get('/health', async (request, reply) => {
    return { status: 'ok', timestamp: new Date().toISOString() };
  });
}
