/**
 * 模拟引擎
 * 执行中考志愿录取模拟，计算各志愿录取概率
 */

import type { Candidate, CandidateScores } from '@shared/types/candidate';
import type {
  SimulationResult,
  SimulationRunResult,
  VirtualCompetitor,
  VolunteerProbability,
  CompetitorAnalysis,
} from '@shared/types/simulation';
import type { AdmissionBatchCode } from '@shared/types/school';
import { getRiskLevelByProbability } from '@shared/types/simulation';
import { DEFAULT_SIMULATION_CONFIG } from '@shared/constants/admission';
import { rankPredictor, type RankPrediction } from './rank-predictor';
import { competitorGenerator } from './competitor-generator';
import { strategyAnalyzer } from './strategy-analyzer';
import { admissionRulesEngine } from '../admission/rules';
import { logger } from '@shared/utils';
import { randomInt } from './random-utils';
import { Worker } from 'worker_threads';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * 模拟配置
 */
export interface SimulationConfig {
  /** 模拟次数 */
  simulationCount: number;
  /** 是否使用Worker线程 */
  useWorker?: boolean;
  /** Worker超时时间（毫秒） */
  workerTimeout?: number;
}

/**
 * 模拟分析请求
 */
export interface AnalysisRequest {
  /** 考生数据 */
  candidate: Candidate;
  /** 设备ID */
  deviceId: string;
  /** 模拟配置 */
  config?: Partial<SimulationConfig>;
}

/**
 * 学校招生计划数据
 */
interface SchoolQuotaData {
  /** 名额分配到区招生计划 */
  quotaDistrict: Map<number, number>;
  /** 名额分配到校招生计划 */
  quotaSchool: Map<number, number>;
  /** 统一招生计划 */
  unified: Map<number, number>;
}

/**
 * 模拟引擎
 */
export class AdmissionSimulationEngine {
  private logger = logger;
  private defaultConfig: SimulationConfig = DEFAULT_SIMULATION_CONFIG;

  /**
   * 执行模拟分析
   */
  async simulate(request: AnalysisRequest): Promise<SimulationResult> {
    const { candidate, deviceId, config } = request;
    const simulationConfig = { ...this.defaultConfig, ...config };

    this.logger.info(`开始模拟分析`, {
      candidateId: candidate.id,
      deviceId,
      simulationCount: simulationConfig.simulationCount,
    });

    // 1. 预测考生区内排名
    const rankPrediction = await this.predictRank(candidate);

    // 2. 获取学校招生计划数据
    const schoolQuotas = await this.getSchoolQuotaData(candidate);

    // 3. 生成虚拟竞争对手
    const competitors = await this.generateCompetitors(candidate, rankPrediction, simulationConfig);

    // 4. 执行多次模拟
    const simulationResults = await this.runMultipleSimulations(
      candidate,
      competitors,
      schoolQuotas,
      simulationConfig
    );

    // 5. 统计各志愿录取概率
    const probabilities = this.calculateProbabilities(candidate, simulationResults);

    // 6. 分析策略
    const strategy = strategyAnalyzer.analyze({
      probabilities,
      hasQuotaSchoolEligibility: candidate.info.hasQuotaSchoolEligibility,
      totalVolunteers: this.getTotalVolunteerCount(candidate),
    });

    // 7. 分析竞争对手
    const competitorAnalysis = this.analyzeCompetitors(competitors);

    // 8. 预测录取结果
    const { predictedBatch, predictedSchool } = this.predictAdmission(
      probabilities,
      simulationResults
    );

    const result: SimulationResult = {
      predictions: rankPrediction,
      probabilities,
      strategy,
      competitors: competitorAnalysis,
      simulationCount: simulationConfig.simulationCount,
      predictedBatch,
      predictedSchool,
    };

    this.logger.info(`模拟分析完成`, {
      candidateId: candidate.id,
      strategyScore: strategy.score,
      predictedBatch,
      predictedSchool: predictedSchool?.name,
    });

    return result;
  }

  /**
   * 预测区内排名
   */
  private async predictRank(candidate: Candidate): Promise<RankPrediction> {
    return rankPredictor.predict(
      candidate.info.districtId,
      candidate.scores,
      new Date().getFullYear()
    );
  }

  /**
   * 获取学校招生计划数据
   */
  private async getSchoolQuotaData(candidate: Candidate): Promise<SchoolQuotaData> {
    // 这里应该从数据库查询实际数据
    // 简化处理，返回空数据
    return {
      quotaDistrict: new Map(),
      quotaSchool: new Map(),
      unified: new Map(),
    };
  }

  /**
   * 生成虚拟竞争对手
   */
  private async generateCompetitors(
    candidate: Candidate,
    rankPrediction: RankPrediction,
    config: SimulationConfig
  ): Promise<VirtualCompetitor[]> {
    return competitorGenerator.generate({
      districtId: candidate.info.districtId,
      candidateScore: candidate.scores.total,
      candidateRank: rankPrediction.districtRank,
      count: Math.round(config.simulationCount / 2), // 竞争对手数量约为模拟次数的一半
      useHistoricalPattern: true,
    });
  }

  /**
   * 执行多次模拟
   */
  private async runMultipleSimulations(
    candidate: Candidate,
    competitors: VirtualCompetitor[],
    schoolQuotas: SchoolQuotaData,
    config: SimulationConfig
  ): Promise<Map<string, SimulationRunResult[]>> {
    const results = new Map<string, SimulationRunResult[]>();

    // 初始化各志愿的结果数组
    this.initializeVolunteerResults(candidate, results);

    // 执行模拟
    if (config.useWorker) {
      // 使用Worker线程执行
      await this.runSimulationsWithWorker(candidate, competitors, schoolQuotas, config, results);
    } else {
      // 在主线程执行
      await this.runSimulationsInMainThread(candidate, competitors, schoolQuotas, config, results);
    }

    return results;
  }

  /**
   * 初始化志愿结果数组
   */
  private initializeVolunteerResults(
    candidate: Candidate,
    results: Map<string, SimulationRunResult[]>
  ): void {
    // 为每个志愿初始化结果数组
    const allVolunteers = this.getAllVolunteers(candidate);

    for (const v of allVolunteers) {
      const key = `${v.batch}-${v.schoolId}`;
      results.set(key, []);
    }
  }

  /**
   * 获取所有志愿
   */
  private getAllVolunteers(candidate: Candidate): Array<{
    batch: AdmissionBatchCode;
    schoolId: number;
    index: number;
  }> {
    const volunteers: Array<{ batch: AdmissionBatchCode; schoolId: number; index: number }> = [];

    // 名额分配到区
    if (candidate.volunteers.quotaDistrict) {
      volunteers.push({
        batch: 'QUOTA_DISTRICT' as AdmissionBatchCode,
        schoolId: candidate.volunteers.quotaDistrict,
        index: 1,
      });
    }

    // 名额分配到校
    candidate.volunteers.quotaSchool.forEach((schoolId, idx) => {
      if (schoolId) {
        volunteers.push({
          batch: 'QUOTA_SCHOOL' as AdmissionBatchCode,
          schoolId,
          index: idx + 1,
        });
      }
    });

    // 统一招生
    candidate.volunteers.unified.forEach((schoolId, idx) => {
      if (schoolId) {
        volunteers.push({
          batch: 'UNIFIED_1_15' as AdmissionBatchCode,
          schoolId,
          index: idx + 1,
        });
      }
    });

    return volunteers;
  }

  /**
   * 在主线程执行模拟
   */
  private async runSimulationsInMainThread(
    candidate: Candidate,
    competitors: VirtualCompetitor[],
    schoolQuotas: SchoolQuotaData,
    config: SimulationConfig,
    results: Map<string, SimulationRunResult[]>
  ): Promise<void> {
    for (let i = 0; i < config.simulationCount; i++) {
      // 执行单次模拟
      const result = this.runSingleSimulation(candidate, competitors, schoolQuotas);

      // 记录结果
      const allVolunteers = this.getAllVolunteers(candidate);
      for (const v of allVolunteers) {
        const key = `${v.batch}-${v.schoolId}`;
        const volunteerResults = results.get(key);
        if (volunteerResults) {
          // 判断该志愿是否录取
          const admitted = result.admitted &&
            result.admittedSchoolId === v.schoolId &&
            result.admittedBatch === v.batch;

          volunteerResults.push({
            admitted: admitted || false,
            admittedBatch: admitted ? result.admittedBatch : undefined,
            admittedSchoolId: admitted ? result.admittedSchoolId : undefined,
            admittedSchoolName: admitted ? result.admittedSchoolName : undefined,
            admittedVolunteerIndex: admitted ? result.admittedVolunteerIndex : undefined,
          });
        }
      }
    }
  }

  /**
   * 使用Worker线程执行模拟
   */
  private async runSimulationsWithWorker(
    candidate: Candidate,
    competitors: VirtualCompetitor[],
    schoolQuotas: SchoolQuotaData,
    config: SimulationConfig,
    results: Map<string, SimulationRunResult[]>
  ): Promise<void> {
    // 将模拟任务分配给多个Worker
    const workerCount = Math.min(4, config.simulationCount); // 最多4个Worker
    const simulationsPerWorker = Math.ceil(config.simulationCount / workerCount);

    const workerPromises: Promise<void>[] = [];

    for (let i = 0; i < workerCount; i++) {
      const startSim = i * simulationsPerWorker;
      const endSim = Math.min((i + 1) * simulationsPerWorker, config.simulationCount);

      if (startSim >= config.simulationCount) break;

      workerPromises.push(
        this.runWorkerSimulation(
          candidate,
          competitors,
          schoolQuotas,
          startSim,
          endSim,
          config.workerTimeout || 300000
        )
      );
    }

    await Promise.all(workerPromises);
  }

  /**
   * 在Worker中执行模拟
   */
  private async runWorkerSimulation(
    candidate: Candidate,
    competitors: VirtualCompetitor[],
    schoolQuotas: SchoolQuotaData,
    startSim: number,
    endSim: number,
    timeout: number
  ): Promise<void> {
    const workerPath = join(__dirname, 'simulation-worker.js');

    const worker = new Worker(workerPath, {
      workerData: {
        candidate,
        competitors,
        schoolQuotas,
        startSim,
        endSim,
      },
    });

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        worker.terminate();
        reject(new Error('Worker timeout'));
      }, timeout);

      worker.on('message', (results) => {
        clearTimeout(timer);
        // 处理Worker返回的结果
        resolve();
      });

      worker.on('error', (error) => {
        clearTimeout(timer);
        reject(error);
      });

      worker.on('exit', (code) => {
        clearTimeout(timer);
        if (code !== 0) {
          reject(new Error(`Worker stopped with exit code ${code}`));
        } else {
          resolve();
        }
      });
    });
  }

  /**
   * 执行单次模拟
   */
  private runSingleSimulation(
    candidate: Candidate,
    competitors: VirtualCompetitor[],
    schoolQuotas: SchoolQuotaData
  ): SimulationRunResult {
    // 将考生和竞争对手合并
    const allCandidates = [candidate, ...this.convertCompetitorsToCandidates(competitors)];

    // 执行完整录取流程
    const admissionResults = admissionRulesEngine.executeFullAdmission(
      allCandidates,
      new Map([
        ['QUOTA_DISTRICT', schoolQuotas.quotaDistrict],
        ['QUOTA_SCHOOL', schoolQuotas.quotaSchool],
        ['UNIFIED_1_15', schoolQuotas.unified],
      ])
    );

    // 获取考生的录取结果
    const result = admissionResults.get(candidate.id);

    if (!result || !result.admitted) {
      return {
        admitted: false,
      };
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
   * 将虚拟竞争对手转换为Candidate格式
   */
  private convertCompetitorsToCandidates(competitors: VirtualCompetitor[]): Candidate[] {
    return competitors.map((c, idx) => ({
      id: c.id,
      info: {
        districtId: 1, // 简化处理
        middleSchoolId: c.middleSchoolId || 1,
        hasQuotaSchoolEligibility: !!c.middleSchoolId,
      },
      scores: {
        total: c.totalScore,
        chinese: c.chineseScore,
        math: c.mathScore,
        foreign: c.chineseMathForeignSum - c.chineseScore - c.mathScore,
        integrated: c.integratedTestScore,
        ethics: 30, // 简化
        history: 30, // 简化
        pe: 30, // 简化
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
    }));
  }

  /**
   * 计算各志愿录取概率
   */
  private calculateProbabilities(
    candidate: Candidate,
    simulationResults: Map<string, SimulationRunResult[]>
  ): VolunteerProbability[] {
    const probabilities: VolunteerProbability[] = [];

    const allVolunteers = this.getAllVolunteers(candidate);

    for (const v of allVolunteers) {
      const key = `${v.batch}-${v.schoolId}`;
      const results = simulationResults.get(key) || [];

      const admittedCount = results.filter(r => r.admitted).length;
      const totalCount = results.length;
      const probability = totalCount > 0 ? (admittedCount / totalCount) * 100 : 0;

      probabilities.push({
        batch: v.batch as 'QUOTA_DISTRICT' | 'QUOTA_SCHOOL' | 'UNIFIED',
        schoolId: v.schoolId,
        schoolName: `学校${v.schoolId}`, // 应该从数据库查询
        schoolCode: `${v.schoolId}`,
        probability: Math.round(probability * 10) / 10,
        riskLevel: getRiskLevelByProbability(probability),
        scoreDiff: null, // 应该从历史数据查询
        historyMinScore: undefined,
        volunteerIndex: v.index,
      });
    }

    return probabilities;
  }

  /**
   * 分析竞争对手
   */
  private analyzeCompetitors(competitors: VirtualCompetitor[]): CompetitorAnalysis {
    const scoreDistribution = this.calculateScoreDistribution(competitors);

    return {
      count: competitors.length,
      scoreDistribution,
    };
  }

  /**
   * 计算分数分布
   */
  private calculateScoreDistribution(competitors: VirtualCompetitor[]): Array<{
    range: string;
    count: number;
    percentage: number;
  }> {
    const distribution: Map<string, number> = new Map();

    for (const c of competitors) {
      const range = this.getScoreRange(c.totalScore);
      distribution.set(range, (distribution.get(range) || 0) + 1);
    }

    const total = competitors.length;
    return Array.from(distribution.entries()).map(([range, count]) => ({
      range,
      count,
      percentage: Math.round((count / total) * 100),
    }));
  }

  /**
   * 获取分数区间
   */
  private getScoreRange(score: number): string {
    const lower = Math.floor(score / 10) * 10;
    const upper = lower + 10;
    return `${lower}-${upper}`;
  }

  /**
   * 预测录取结果
   */
  private predictAdmission(
    probabilities: VolunteerProbability[],
    simulationResults: Map<string, SimulationRunResult[]>
  ): {
    predictedBatch?: 'QUOTA_DISTRICT' | 'QUOTA_SCHOOL' | 'UNIFIED';
    predictedSchool?: { id: number; name: string; batch: string };
  } {
    // 找到录取概率最高的学校
    let maxProbability = 0;
    let bestMatch: VolunteerProbability | undefined;

    for (const p of probabilities) {
      if (p.probability > maxProbability) {
        maxProbability = p.probability;
        bestMatch = p;
      }
    }

    if (bestMatch && maxProbability >= 50) {
      return {
        predictedBatch: bestMatch.batch,
        predictedSchool: {
          id: bestMatch.schoolId,
          name: bestMatch.schoolName,
          batch: bestMatch.batch,
        },
      };
    }

    return {};
  }

  /**
   * 获取总志愿数量
   */
  private getTotalVolunteerCount(candidate: Candidate): number {
    let count = 0;
    if (candidate.volunteers.quotaDistrict) count++;
    count += candidate.volunteers.quotaSchool.filter(v => v !== null).length;
    count += candidate.volunteers.unified.filter(v => v !== null).length;
    return count;
  }
}

// 导出单例
export const admissionSimulationEngine = new AdmissionSimulationEngine();
