/**
 * 考生相关API路由
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  SubmitAnalysisRequest,
  AnalysisResultResponse,
  AnalysisStatus,
  SimulationHistoryListResponse,
} from '@shared/types/simulation';
import { ApiResponse, PaginationParams } from '@shared/types/api';
import { BadRequestError, NotFoundError, InternalError } from '@shared/utils/errors';
import { validateCandidateScores, validateDeviceId, sanitizeDeviceId } from '@shared/utils/validation';
import { getOrCreateDeviceId, extractDeviceInfoFromHeaders } from '@shared/utils/device-fingerprint';
import { getScoreRange } from '@shared/types/candidate';
import { admissionSimulationEngine } from '../../domain/simulation';
import * as simulationHistoryRepository from '../../infrastructure/database/simulation-history.repository';
import { logger } from '@shared/utils';
import { randomUUID } from 'crypto';

/**
 * 考生API路由
 */
export async function candidateRoutes(fastify: FastifyInstance) {
  // 提交模拟分析请求
  fastify.post('/analysis', async (request, reply) => {
    const body = request.body as SubmitAnalysisRequest;

    // 验证设备ID
    const deviceId = sanitizeDeviceId(
      getOrCreateDeviceId(
        request.headers as Record<string, string>,
        body.deviceId
      )
    );

    const validation = validateDeviceId(deviceId);
    if (!validation.valid) {
      throw new BadRequestError(validation.error || 'Invalid device ID');
    }

    // 验证成绩
    const scoresValidation = validateCandidateScores(body.scores);
    if (!scoresValidation.valid) {
      throw new BadRequestError('成绩验证失败', { errors: scoresValidation.errors });
    }

    try {
      // 构建考生数据
      const candidate = {
        id: randomUUID(),
        info: body.candidate,
        scores: body.scores,
        ranking: {
          ...body.ranking,
          percentile: (body.ranking.totalStudents - body.ranking.rank) / body.ranking.totalStudents * 100,
        },
        volunteers: body.volunteers,
        comprehensiveQuality: body.comprehensiveQuality,
        isTiePreferred: body.isTiePreferred,
        deviceId,
      };

      // 执行模拟分析
      const result = await admissionSimulationEngine.simulate({
        candidate,
        deviceId,
      });

      // 脱敏考生数据
      const anonymizedData = {
        districtId: body.candidate.districtId,
        middleSchoolId: body.candidate.middleSchoolId,
        scoreRange: getScoreRange(body.scores.total),
        totalScore: body.scores.total,
        volunteerCount: [
          body.volunteers.quotaDistrict ? 1 : 0,
          body.volunteers.quotaSchool.filter(v => v !== null).length,
          body.volunteers.unified.filter(v => v !== null).length,
        ].reduce((sum, count) => sum + count, 0),
        hasQuotaSchoolEligibility: body.candidate.hasQuotaSchoolEligibility,
        createdAt: new Date(),
      };

      // 保存历史记录
      const historyId = await simulationHistoryRepository.saveSimulationHistory(
        deviceId,
        extractDeviceInfoFromHeaders(request.headers as Record<string, string>),
        anonymizedData,
        {
          id: randomUUID(),
          deviceId,
          deviceInfo: extractDeviceInfoFromHeaders(request.headers as Record<string, string>),
          candidateData: anonymizedData,
          simulationResult: result,
          createdAt: new Date(),
        }
      );

      // 返回结果
      const response: AnalysisResultResponse = {
        id: historyId,
        status: AnalysisStatus.COMPLETED,
        results: result,
        createdAt: new Date(),
        completedAt: new Date(),
      };

      return reply.code(200).send(response);

    } catch (error) {
      logger.error('Simulation analysis failed', error);
      throw new InternalError('模拟分析失败，请稍后重试');
    }
  });

  // 获取分析结果
  fastify.get<{ Params: { id: string } }>('/analysis/:id', async (request, reply) => {
    const { id } = request.params;

    const history = await simulationHistoryRepository.getSimulationHistoryById(id);

    if (!history) {
      throw new NotFoundError('分析记录');
    }

    // 验证设备ID
    const deviceId = sanitizeDeviceId(
      getOrCreateDeviceId(request.headers as Record<string, string>)
    );

    if (history.deviceId !== deviceId) {
      throw new BadRequestError('无权访问该记录');
    }

    const response: AnalysisResultResponse = {
      id: history.id,
      status: AnalysisStatus.COMPLETED,
      results: history.simulationResult,
      createdAt: history.createdAt,
      completedAt: history.createdAt,
    };

    return reply.code(200).send(response);
  });

  // 导出PDF报告（占位）
  fastify.get<{ Params: { id: string } }>('/analysis/:id/pdf', async (request, reply) => {
    const { id } = request.params;

    const history = await simulationHistoryRepository.getSimulationHistoryById(id);

    if (!history) {
      throw new NotFoundError('分析记录');
    }

    // 验证设备ID
    const deviceId = sanitizeDeviceId(
      getOrCreateDeviceId(request.headers as Record<string, string>)
    );

    if (history.deviceId !== deviceId) {
      throw new BadRequestError('无权访问该记录');
    }

    // TODO: 生成PDF报告
    reply.header('Content-Type', 'application/pdf');
    reply.header('Content-Disposition', `attachment; filename="analysis-${id}.pdf"`);

    // 占位：返回空PDF
    return reply.send(Buffer.from('%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n2 0 obj\n<<\n/Type /Pages\n/Count 0\n/Kids []\n>>\nendobj\nxref\n0 3\n0000000000 65535 f\n0000000009 00000 n\n0000000056 00000 n\ntrailer\n<<\n/Size 3\n/Root 1 0 R\n>>\nstartxref\n110\n%%EOF'));
  });

  // 获取历史记录列表
  fastify.get<{
    Querystring: { page?: string; pageSize?: string };
  }>('/history', async (request, reply) => {
    const deviceId = sanitizeDeviceId(
      getOrCreateDeviceId(request.headers as Record<string, string>)
    );

    const page = parseInt(request.query.page || '1');
    const pageSize = parseInt(request.query.pageSize || '20');

    const { histories, total } = await simulationHistoryRepository.getSimulationHistoryByDevice(
      deviceId,
      {
        limit: pageSize,
        offset: (page - 1) * pageSize,
      }
    );

    // 转换为摘要格式
    const summaryHistories = histories.map((h) => {
      const probabilities = h.simulationResult.probabilities || [];
      const safeCount = probabilities.filter(p => p.riskLevel === 'safe').length;
      const moderateCount = probabilities.filter(p => p.riskLevel === 'moderate').length;
      const riskyCount = probabilities.filter(p => p.riskLevel === 'risky').length;
      const highRiskCount = probabilities.filter(p => p.riskLevel === 'high_risk').length;

      return {
        id: h.id,
        createdAt: h.createdAt,
        summary: {
          totalVolunteers: probabilities.length,
          safeCount,
          moderateCount,
          riskyCount,
          highRiskCount,
        },
        result: h.simulationResult,
      };
    });

    const response: SimulationHistoryListResponse = {
      histories: summaryHistories,
      total,
    };

    return reply.code(200).send(response);
  });

  // 删除单条历史记录
  fastify.delete<{ Params: { id: string } }>('/history/:id', async (request, reply) => {
    const { id } = request.params;

    const history = await simulationHistoryRepository.getSimulationHistoryById(id);

    if (!history) {
      throw new NotFoundError('分析记录');
    }

    // 验证设备ID
    const deviceId = sanitizeDeviceId(
      getOrCreateDeviceId(request.headers as Record<string, string>)
    );

    if (history.deviceId !== deviceId) {
      throw new BadRequestError('无权删除该记录');
    }

    const deleted = await simulationHistoryRepository.deleteSimulationHistory(id);

    if (!deleted) {
      throw new InternalError('删除失败');
    }

    return reply.code(204).send();
  });

  // 删除所有历史记录
  fastify.delete('/history', async (request, reply) => {
    const deviceId = sanitizeDeviceId(
      getOrCreateDeviceId(request.headers as Record<string, string>)
    );

    const count = await simulationHistoryRepository.deleteAllSimulationHistory(deviceId);

    return reply.code(200).send({ deletedCount: count });
  });
}
