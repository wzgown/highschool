/**
 * 模拟Worker
 * 在独立线程中执行模拟计算，避免阻塞主线程
 */

import { parentPort, workerData } from 'worker_threads';
import type { Candidate } from '@shared/types/candidate';
import type { VirtualCompetitor } from '@shared/types/simulation';
import type { SimulationRunResult } from '@shared/types/simulation';
import { admissionRulesEngine } from '../admission/rules';

interface WorkerMessage {
  candidate: Candidate;
  competitors: VirtualCompetitor[];
  schoolQuotas: {
    quotaDistrict: Map<number, number>;
    quotaSchool: Map<number, number>;
    unified: Map<number, number>;
  };
  startSim: number;
  endSim: number;
}

/**
 * 执行单次模拟
 */
function runSingleSimulation(
  candidate: Candidate,
  competitors: VirtualCompetitor[],
  schoolQuotas: WorkerMessage['schoolQuotas']
): SimulationRunResult {
  // 将竞争对手转换为Candidate格式
  const allCandidates = [
    candidate,
    ...competitors.map((c, idx) => ({
      id: c.id,
      info: {
        districtId: 1,
        middleSchoolId: c.middleSchoolId || 1,
        hasQuotaSchoolEligibility: !!c.middleSchoolId,
      },
      scores: {
        total: c.totalScore,
        chinese: c.chineseScore,
        math: c.mathScore,
        foreign: c.chineseMathForeignSum - c.chineseScore - c.mathScore,
        integrated: c.integratedTestScore,
        ethics: 30,
        history: 30,
        pe: 30,
      },
      ranking: {
        rank: c.districtRank,
        totalStudents: 1000,
        percentile: 0,
      },
      volunteers: {
        quotaDistrict: c.volunteers.quotaDistrict || null,
        quotaSchool: c.volunteers.quotaSchool || [null, null],
        unified: c.volunteers.unified || [],
      },
      comprehensiveQuality: c.comprehensiveQuality,
      isTiePreferred: c.isTiePreferred,
    })),
  ];

  // 执行录取
  const results = admissionRulesEngine.executeFullAdmission(
    allCandidates,
    new Map([
      ['QUOTA_DISTRICT', schoolQuotas.quotaDistrict],
      ['QUOTA_SCHOOL', schoolQuotas.quotaSchool],
      ['UNIFIED_1_15', schoolQuotas.unified],
    ])
  );

  const result = results.get(candidate.id);

  if (!result || !result.admitted) {
    return { admitted: false };
  }

  return {
    admitted: true,
    admittedBatch: result.batch,
    admittedSchoolId: result.schoolId,
    admittedSchoolName: result.schoolName,
    admittedVolunteerIndex: result.volunteerIndex,
  };
}

/**
 * Worker主逻辑
 */
function run() {
  const { candidate, competitors, schoolQuotas, startSim, endSim } = workerData as WorkerMessage;

  const results: SimulationRunResult[] = [];

  // 执行指定范围的模拟
  for (let i = startSim; i < endSim; i++) {
    const result = runSingleSimulation(candidate, competitors, schoolQuotas);
    results.push(result);
  }

  // 发送结果回主线程
  parentPort?.postMessage(results);
}

// 启动Worker
run();
