/**
 * 模拟历史数据仓库
 */

import { eq, and, desc } from 'drizzle-orm';
import type { SimulationHistory } from '@shared/types/simulation';
import type { DeviceInfo } from '@shared/types/api';
import type { AnonymizedCandidateData } from '@shared/types/candidate';
import { getDb } from './connection';
import { simulationHistory } from './schema';
import { logger } from '@shared/utils';

/**
 * 保存模拟历史记录
 */
export async function saveSimulationHistory(
  deviceId: string,
  deviceInfo: DeviceInfo | undefined,
  candidateData: AnonymizedCandidateData,
  simulationResult: SimulationHistory
): Promise<string> {
  const db = getDb();

  const [result] = await db
    .insert(simulationHistory)
    .values({
      deviceId,
      deviceInfo: deviceInfo || null,
      candidateData: candidateData as any,
      simulationResult: simulationResult as any,
    })
    .returning();

  logger.info(`Simulation history saved`, {
    deviceId,
    historyId: result.id,
  });

  return String(result.id);
}

/**
 * 获取设备的模拟历史列表
 */
export async function getSimulationHistoryByDevice(
  deviceId: string,
  options: {
    limit?: number;
    offset?: number;
  } = {}
): Promise<{
  histories: Array<{
    id: string;
    createdAt: Date;
    candidateData: AnonymizedCandidateData;
    simulationResult: SimulationHistory;
  }>;
  total: number;
}> {
  const db = getDb();
  const { limit = 20, offset = 0 } = options;

  // 获取总数
  const totalResult = await db
    .select({ count: simulationHistory.id })
    .from(simulationHistory)
    .where(eq(simulationHistory.deviceId, deviceId));

  const total = totalResult.length;

  // 获取历史记录
  const histories = await db
    .select()
    .from(simulationHistory)
    .where(eq(simulationHistory.deviceId, deviceId))
    .orderBy(desc(simulationHistory.createdAt))
    .limit(limit)
    .offset(offset);

  return {
    histories: histories.map((h) => ({
      id: String(h.id),
      createdAt: h.createdAt,
      candidateData: h.candidateData as AnonymizedCandidateData,
      simulationResult: h.simulationResult as SimulationHistory,
    })),
    total,
  };
}

/**
 * 获取单个模拟历史记录
 */
export async function getSimulationHistoryById(
  id: string
): Promise<{
  id: string;
  deviceId: string;
  deviceInfo: DeviceInfo | undefined;
  candidateData: AnonymizedCandidateData;
  simulationResult: SimulationHistory;
  createdAt: Date;
} | null> {
  const db = getDb();

  const [result] = await db
    .select()
    .from(simulationHistory)
    .where(eq(simulationHistory.id, parseInt(id)))
    .limit(1);

  if (!result) {
    return null;
  }

  return {
    id: String(result.id),
    deviceId: result.deviceId,
    deviceInfo: result.deviceInfo as DeviceInfo | undefined,
    candidateData: result.candidateData as AnonymizedCandidateData,
    simulationResult: result.simulationResult as SimulationHistory,
    createdAt: result.createdAt,
  };
}

/**
 * 删除单个模拟历史记录
 */
export async function deleteSimulationHistory(id: string): Promise<boolean> {
  const db = getDb();

  const result = await db
    .delete(simulationHistory)
    .where(eq(simulationHistory.id, parseInt(id)))
    .returning();

  const deleted = result.length > 0;

  if (deleted) {
    logger.info(`Simulation history deleted`, { id });
  }

  return deleted;
}

/**
 * 删除设备的所有模拟历史记录
 */
export async function deleteAllSimulationHistory(deviceId: string): Promise<number> {
  const db = getDb();

  const result = await db
    .delete(simulationHistory)
    .where(eq(simulationHistory.deviceId, deviceId))
    .returning();

  const count = result.length;

  logger.info(`All simulation history deleted for device`, {
    deviceId,
    count,
  });

  return count;
}

/**
 * 获取相似考生的历史数据（用于优化竞争对手生成）
 */
export async function findSimilarCandidates(
  districtId: number,
  scoreRange: string,
  limit: number = 100
): Promise<Array<{
  candidateData: AnonymizedCandidateData;
  simulationResult: SimulationHistory;
}>> {
  const db = getDb();

  const [minScore, maxScore] = scoreRange.split('-').map(Number);

  // 使用JSON路径查询分数范围
  const histories = await db
    .select()
    .from(simulationHistory)
    .where(
      and(
        // @ts-ignore - JSON path query
        eq(simulationHistory.candidateData->>'districtId', String(districtId)),
        // @ts-ignore - JSON path query
        // @ts-ignore
        `${simulationHistory.candidateData->>'totalScore'}::numeric >= ${minScore}`,
        // @ts-ignore - JSON path query
        // @ts-ignore
        `${simulationHistory.candidateData->>'totalScore'}::numeric <= ${maxScore}`
      )
    )
    .limit(limit);

  return histories.map((h) => ({
    candidateData: h.candidateData as AnonymizedCandidateData,
    simulationResult: h.simulationResult as SimulationHistory,
  }));
}

/**
 * 获取设备的历史统计
 */
export async function getDeviceStatistics(deviceId: string): Promise<{
  totalCount: number;
  lastSimulationAt?: Date;
  averageScore?: number;
}> {
  const db = getDb();

  const histories = await db
    .select({
      createdAt: simulationHistory.createdAt,
      candidateData: simulationHistory.candidateData,
    })
    .from(simulationHistory)
    .where(eq(simulationHistory.deviceId, deviceId));

  if (histories.length === 0) {
    return { totalCount: 0 };
  }

  const totalScores = histories
    .map((h) => (h.candidateData as any).totalScore)
    .filter((s) => s !== undefined);

  const averageScore =
    totalScores.length > 0
      ? totalScores.reduce((sum, s) => sum + s, 0) / totalScores.length
      : undefined;

  return {
    totalCount: histories.length,
    lastSimulationAt: histories[0]?.createdAt,
    averageScore,
  };
}
