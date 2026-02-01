/**
 * 管理员API路由
 */

import type { FastifyInstance } from 'fastify';
import {
  DataImportRequest,
  DataImportResponse,
  DataImportStatus,
  SchoolUpdateRequest,
  DistrictUpdateRequest,
} from '@shared/types/api';
import { BadRequestError, NotFoundError, ForbiddenError } from '@shared/utils/errors';
import { getDb } from '../../infrastructure/database';
import { refSchool, refDistrict, refQuotaAllocationDistrict, refQuotaAllocationSchool } from '../../infrastructure/database';
import { eq } from 'drizzle-orm';
import { logger } from '@shared/utils';
import { randomUUID } from 'crypto';

/**
 * 简单的API密钥验证中间件
 */
async function validateApiKey(request: any, reply: any) {
  const apiKey = request.headers['x-api-key'];

  if (!apiKey || apiKey !== process.env.ADMIN_API_KEY) {
    throw new ForbiddenError('无效的管理员API密钥');
  }
}

/**
 * 数据导入任务存储（内存，实际应该使用Redis或数据库）
 */
const importTasks = new Map<string, DataImportResponse>();

/**
 * 管理员API路由
 */
export async function adminRoutes(fastify: FastifyInstance) {
  // 所有管理员路由需要验证API密钥
  fastify.addHook('onRequest', validateApiKey);

  /**
   * 导入数据
   */
  fastify.post('/data/import', async (request, reply) => {
    const body = request.body as DataImportRequest;
    const taskId = randomUUID();

    logger.info('Data import requested', {
      taskId,
      dataType: body.dataType,
      year: body.year,
      districtId: body.districtId,
    });

    // 创建导入任务
    const task: DataImportResponse = {
      id: taskId,
      status: DataImportStatus.PENDING,
      progress: 0,
      createdAt: new Date(),
    };

    importTasks.set(taskId, task);

    // 异步处理导入（实际应该使用任务队列）
    processImportTask(taskId, body).catch((error) => {
      logger.error('Import task failed', { taskId, error });
      const task = importTasks.get(taskId);
      if (task) {
        task.status = DataImportStatus.FAILED;
        task.errors = [error.message];
      }
    });

    return reply.code(202).send(task);
  });

  /**
   * 获取导入状态
   */
  fastify.get<{ Params: { id: string } }>('/data/import/:id', async (request, reply) => {
    const { id } = request.params;

    const task = importTasks.get(id);

    if (!task) {
      throw new NotFoundError('导入任务');
    }

    return reply.code(200).send(task);
  });

  /**
   * 获取学校列表（管理）
   */
  fastify.get<{
    Querystring: { page?: string; pageSize?: string; districtId?: string };
  }>('/data/schools', async (request, reply) => {
    const db = getDb();
    const {
      page = '1',
      pageSize = '50',
      districtId,
    } = request.query;

    const pageNum = parseInt(page);
    const size = parseInt(pageSize);
    const offset = (pageNum - 1) * size;

    const conditions = [];

    if (districtId) {
      conditions.push(eq(refSchool.districtId, parseInt(districtId)));
    }

    const schools = await db
      .select()
      .from(refSchool)
      .where(conditions.length > 0 ? sql.join(conditions, sql` AND `) : undefined)
      .orderBy(refSchool.code)
      .limit(size)
      .offset(offset);

    return reply.code(200).send({
      schools,
      page: pageNum,
      pageSize: size,
    });
  });

  /**
   * 更新学校信息
   */
  fastify.put<{
    Params: { id: string };
    Body: SchoolUpdateRequest;
  }>('/data/schools/:id', async (request, reply) => {
    const { id } = request.params;
    const body = request.body as SchoolUpdateRequest;
    const db = getDb();
    const schoolId = parseInt(id);

    // 检查学校是否存在
    const [existing] = await db
      .select()
      .from(refSchool)
      .where(eq(refSchool.id, schoolId));

    if (!existing) {
      throw new NotFoundError('学校');
    }

    // 更新学校信息
    await db
      .update(refSchool)
      .set({
        shortName: body.shortName,
        schoolTypeId: body.schoolTypeId,
        boardingTypeId: body.boardingTypeId,
        hasInternationalCourse: body.hasInternationalCourse,
        remarks: body.remarks,
        updatedAt: new Date(),
      })
      .where(eq(refSchool.id, schoolId));

    // 获取更新后的学校
    const [updated] = await db
      .select()
      .from(refSchool)
      .where(eq(refSchool.id, schoolId));

    logger.info('School updated', {
      schoolId,
      updatedBy: request.headers['x-admin-id'] || 'unknown',
    });

    return reply.code(200).send(updated);
  });

  /**
   * 获取区县列表（管理）
   */
  fastify.get('/data/districts', async (request, reply) => {
    const db = getDb();

    const districts = await db
      .select()
      .from(refDistrict)
      .orderBy(refDistrict.displayOrder);

    return reply.code(200).send({
      districts,
    });
  });

  /**
   * 更新区县信息
   */
  fastify.put<{
    Params: { id: string };
    Body: DistrictUpdateRequest;
  }>('/data/districts/:id', async (request, reply) => {
    const { id } = request.params;
    const body = request.body as DistrictUpdateRequest;
    const db = getDb();
    const districtId = parseInt(id);

    // 检查区县是否存在
    const [existing] = await db
      .select()
      .from(refDistrict)
      .where(eq(refDistrict.id, districtId));

    if (!existing) {
      throw new NotFoundError('区县');
    }

    // 更新区县信息
    await db
      .update(refDistrict)
      .set({
        name: body.name,
        nameEn: body.nameEn,
        displayOrder: body.displayOrder,
        updatedAt: new Date(),
      })
      .where(eq(refDistrict.id, districtId));

    // 获取更新后的区县
    const [updated] = await db
      .select()
      .from(refDistrict)
      .where(eq(refDistrict.id, districtId));

    logger.info('District updated', {
      districtId,
      updatedBy: request.headers['x-admin-id'] || 'unknown',
    });

    return reply.code(200).send(updated);
  });
}

/**
 * 处理数据导入任务（异步）
 */
async function processImportTask(taskId: string, request: DataImportRequest): Promise<void> {
  const task = importTasks.get(taskId);
  if (!task) return;

  task.status = DataImportStatus.PROCESSING;
  task.progress = 0;

  const db = getDb();

  try {
    switch (request.dataType) {
      case 'schools':
        await importSchools(db, task, request);
        break;

      case 'quota_district':
        await importQuotaDistrict(db, task, request);
        break;

      case 'quota_school':
        await importQuotaSchool(db, task, request);
        break;

      case 'admission_scores':
        await importAdmissionScores(db, task, request);
        break;

      default:
        throw new Error(`Unknown data type: ${request.dataType}`);
    }

    task.status = DataImportStatus.COMPLETED;
    task.progress = 100;
    task.completedAt = new Date();

  } catch (error) {
    task.status = DataImportStatus.FAILED;
    task.errors = [error instanceof Error ? error.message : String(error)];
  }
}

/**
 * 导入学校数据
 */
async function importSchools(
  db: any,
  task: DataImportResponse,
  request: DataImportRequest
): Promise<void> {
  // 解析CSV或JSON数据
  // TODO: 实现实际的导入逻辑

  task.progress = 50;

  // 模拟处理
  await new Promise(resolve => setTimeout(resolve, 1000));

  task.successCount = 100;
  task.errorCount = 0;
}

/**
 * 导入名额分配到区计划
 */
async function importQuotaDistrict(
  db: any,
  task: DataImportResponse,
  request: DataImportRequest
): Promise<void> {
  // TODO: 实现实际的导入逻辑

  task.progress = 50;

  await new Promise(resolve => setTimeout(resolve, 1000));

  task.successCount = 500;
  task.errorCount = 0;
}

/**
 * 导入名额分配到校计划
 */
async function importQuotaSchool(
  db: any,
  task: DataImportResponse,
  request: DataImportRequest
): Promise<void> {
  // TODO: 实现实际的导入逻辑

  task.progress = 50;

  await new Promise(resolve => setTimeout(resolve, 1000));

  task.successCount = 1000;
  task.errorCount = 0;
}

/**
 * 导入录取分数线
 */
async function importAdmissionScores(
  db: any,
  task: DataImportResponse,
  request: DataImportRequest
): Promise<void> {
  // TODO: 实现实际的导入逻辑

  task.progress = 50;

  await new Promise(resolve => setTimeout(resolve, 1000));

  task.successCount = 2000;
  task.errorCount = 0;
}
