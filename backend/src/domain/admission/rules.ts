/**
 * 录取规则引擎
 * 实现上海中考录取的平行志愿规则和同分比较规则
 */

import type { Candidate, CandidateScores, CandidateTieBreaker, CandidateVolunteers } from '@shared/types/candidate';
import type { AdmissionBatchCode, School } from '@shared/types/school';
import { TIE_BREAKER_ORDER } from '@shared/constants/admission';
import { logger } from '@shared/utils';

/**
 * 志愿信息
 */
export interface Volunteer {
  /** 学校ID */
  schoolId: number;
  /** 志愿序号（从1开始） */
  index: number;
  /** 批次 */
  batch: AdmissionBatchCode;
}

/**
 * 考生录取状态
 */
export interface CandidateAdmissionState {
  /** 考生ID */
  candidateId: string;
  /** 总分 */
  totalScore: number;
  /** 是否已被录取 */
  isAdmitted: boolean;
  /** 录取批次 */
  admittedBatch?: AdmissionBatchCode;
  /** 录取学校ID */
  admittedSchoolId?: number;
  /** 录取志愿序号 */
  admittedVolunteerIndex?: number;
  /** 志愿列表 */
  volunteers: Volunteer[];
  /** 同分比较数据 */
  tieBreaker: CandidateTieBreaker;
}

/**
 * 学校录取状态
 */
export interface SchoolAdmissionState {
  /** 学校ID */
  schoolId: number;
  /** 总招生计划数 */
  totalQuota: number;
  /** 已录取人数 */
  admittedCount: number;
  /** 剩余名额 */
  remainingQuota: number;
  /** 最低录取分数 */
  minScore?: number;
}

/**
 * 录取结果
 */
export interface AdmissionResult {
  /** 考生ID */
  candidateId: string;
  /** 是否被录取 */
  admitted: boolean;
  /** 录取批次 */
  batch?: AdmissionBatchCode;
  /** 录取学校ID */
  schoolId?: number;
  /** 录取学校名称 */
  schoolName?: string;
  /** 录取志愿序号 */
  volunteerIndex?: number;
}

/**
 * 平行志愿录取选项
 */
export interface ParallelAdmissionOptions {
  /** 招生批次 */
  batch: AdmissionBatchCode;
  /** 各学校的招生计划 */
  schoolQuotas: Map<number, number>;
  /** 考生列表 */
  candidates: CandidateAdmissionState[];
  /** 是否包含综合素质评价（名额分配批次为true） */
  includeComprehensiveQuality?: boolean;
}

/**
 * 录取规则引擎
 */
export class AdmissionRulesEngine {
  private logger = logger;

  /**
   * 按分数和同分规则排序考生
   */
  sortByScoreAndTieBreaker(candidates: CandidateAdmissionState[]): CandidateAdmissionState[] {
    return [...candidates].sort((a, b) => {
      // 首先比较总分
      if (a.totalScore !== b.totalScore) {
        return b.totalScore - a.totalScore;
      }

      // 总分相同，按同分比较规则排序
      return this.compareByTieBreaker(a, b);
    });
  }

  /**
   * 同分比较（6位序）
   */
  private compareByTieBreaker(a: CandidateAdmissionState, b: CandidateAdmissionState): number {
    const ta = a.tieBreaker;
    const tb = b.tieBreaker;

    // 1. 同分优待
    if (ta.isTiePreferred !== tb.isTiePreferred) {
      return ta.isTiePreferred ? -1 : 1;
    }

    // 2. 综合素质评价成绩
    if (ta.comprehensiveQuality !== tb.comprehensiveQuality) {
      return tb.comprehensiveQuality - ta.comprehensiveQuality;
    }

    // 3. 语数外三科合计
    if (ta.chineseMathForeignSum !== tb.chineseMathForeignSum) {
      return tb.chineseMathForeignSum - ta.chineseMathForeignSum;
    }

    // 4. 数学成绩
    if (ta.mathScore !== tb.mathScore) {
      return tb.mathScore - ta.mathScore;
    }

    // 5. 语文成绩
    if (ta.chineseScore !== tb.chineseScore) {
      return tb.chineseScore - ta.chineseScore;
    }

    // 6. 综合测试成绩
    if (ta.integratedTestScore !== tb.integratedTestScore) {
      return tb.integratedTestScore - ta.integratedTestScore;
    }

    // 完全相同，保持原顺序
    return 0;
  }

  /**
   * 平行志愿录取
   */
  parallelVolunteerAdmission(
    candidate: CandidateAdmissionState,
    schoolStates: Map<number, SchoolAdmissionState>
  ): AdmissionResult {
    // 如果已被录取，跳过
    if (candidate.isAdmitted) {
      return {
        candidateId: candidate.candidateId,
        admitted: true,
        batch: candidate.admittedBatch,
        schoolId: candidate.admittedSchoolId,
        volunteerIndex: candidate.admittedVolunteerIndex,
      };
    }

    // 按志愿顺序投档
    for (const volunteer of candidate.volunteers) {
      const schoolState = schoolStates.get(volunteer.schoolId);

      if (!schoolState) {
        this.logger.warn(`School ${volunteer.schoolId} not found`);
        continue;
      }

      // 检查是否有剩余名额
      if (schoolState.remainingQuota > 0) {
        // 录取该考生
        schoolState.remainingQuota--;
        schoolState.admittedCount++;
        if (!schoolState.minScore || candidate.totalScore < schoolState.minScore) {
          schoolState.minScore = candidate.totalScore;
        }

        return {
          candidateId: candidate.candidateId,
          admitted: true,
          batch: volunteer.batch,
          schoolId: volunteer.schoolId,
          volunteerIndex: volunteer.index,
        };
      }
    }

    // 所有志愿都没有录取
    return {
      candidateId: candidate.candidateId,
      admitted: false,
    };
  }

  /**
   * 执行批次的平行志愿录取
   */
  executeParallelAdmission(options: ParallelAdmissionOptions): AdmissionResult[] {
    const { batch, schoolQuotas, candidates, includeComprehensiveQuality = false } = options;

    this.logger.info(`开始执行 ${batch} 批次平行志愿录取`, {
      candidateCount: candidates.length,
      schoolCount: schoolQuotas.size,
    });

    // 初始化学校录取状态
    const schoolStates = new Map<number, SchoolAdmissionState>();
    for (const [schoolId, quota] of schoolQuotas.entries()) {
      schoolStates.set(schoolId, {
        schoolId,
        totalQuota: quota,
        admittedCount: 0,
        remainingQuota: quota,
      });
    }

    // 按分数排序考生
    const sortedCandidates = this.sortByScoreAndTieBreaker(candidates);

    // 依次录取
    const results: AdmissionResult[] = [];
    for (const candidate of sortedCandidates) {
      const result = this.parallelVolunteerAdmission(candidate, schoolStates);
      results.push(result);
    }

    // 统计录取结果
    const admittedCount = results.filter(r => r.admitted).length;
    this.logger.info(`${batch} 批次录取完成`, {
      totalCandidates: candidates.length,
      admittedCount,
      admissionRate: ((admittedCount / candidates.length) * 100).toFixed(2) + '%',
    });

    return results;
  }

  /**
   * 将考生转换为录取状态
   */
  createCandidateAdmissionState(
    candidate: Candidate,
    volunteers: Volunteer[],
    includeComprehensiveQuality = false
  ): CandidateAdmissionState {
    // 计算总分
    const totalScore = includeComprehensiveQuality
      ? candidate.scores.total + candidate.comprehensiveQuality
      : candidate.scores.total;

    return {
      candidateId: candidate.id,
      totalScore,
      isAdmitted: false,
      volunteers,
      tieBreaker: {
        comprehensiveQuality: candidate.comprehensiveQuality,
        chineseMathForeignSum: candidate.scores.chinese + candidate.scores.math + candidate.scores.foreign,
        mathScore: candidate.scores.math,
        chineseScore: candidate.scores.chinese,
        integratedTestScore: candidate.scores.integrated,
        isTiePreferred: candidate.isTiePreferred || false,
      },
    };
  }

  /**
   * 从考生志愿创建志愿列表
   */
  createVolunteersFromCandidate(candidate: Candidate): Volunteer[] {
    const volunteers: Volunteer[] = [];

    // 名额分配到区志愿
    if (candidate.volunteers.quotaDistrict) {
      volunteers.push({
        schoolId: candidate.volunteers.quotaDistrict,
        index: 1,
        batch: AdmissionBatchCode.QUOTA_DISTRICT,
      });
    }

    // 名额分配到校志愿
    candidate.volunteers.quotaSchool.forEach((schoolId, idx) => {
      if (schoolId) {
        volunteers.push({
          schoolId,
          index: idx + 1,
          batch: AdmissionBatchCode.QUOTA_SCHOOL,
        });
      }
    });

    // 统一招生志愿
    candidate.volunteers.unified.forEach((schoolId, idx) => {
      if (schoolId) {
        volunteers.push({
          schoolId,
          index: idx + 1,
          batch: AdmissionBatchCode.UNIFIED_1_15,
        });
      }
    });

    return volunteers;
  }

  /**
   * 执行完整录取流程（按批次顺序）
   */
  executeFullAdmission(
    candidates: Candidate[],
    schoolQuotas: Map<AdmissionBatchCode, Map<number, number>>
  ): Map<string, AdmissionResult> {
    const results = new Map<string, AdmissionResult>();

    // 按批次顺序执行录取
    const batches: AdmissionBatchCode[] = [
      AdmissionBatchCode.QUOTA_DISTRICT,
      AdmissionBatchCode.QUOTA_SCHOOL,
      AdmissionBatchCode.UNIFIED_1_15,
    ];

    // 创建考生录取状态
    const admissionStates = new Map<string, CandidateAdmissionState>();
    for (const candidate of candidates) {
      const volunteers = this.createVolunteersFromCandidate(candidate);
      admissionStates.set(candidate.id, this.createCandidateAdmissionState(candidate, volunteers));
    }

    // 按批次录取
    for (const batch of batches) {
      const batchQuotas = schoolQuotas.get(batch);
      if (!batchQuotas || batchQuotas.size === 0) {
        continue;
      }

      // 过滤出该批次有志愿的未录取考生
      const batchCandidates = Array.from(admissionStates.values()).filter(
        state => !state.isAdmitted && state.volunteers.some(v => v.batch === batch)
      );

      if (batchCandidates.length === 0) {
        continue;
      }

      // 只保留该批次的志愿
      const batchCandidatesWithFilteredVolunteers = batchCandidates.map(state => ({
        ...state,
        volunteers: state.volunteers.filter(v => v.batch === batch),
      }));

      // 执行录取
      const batchResults = this.executeParallelAdmission({
        batch,
        schoolQuotas: batchQuotas,
        candidates: batchCandidatesWithFilteredVolunteers,
        includeComprehensiveQuality: batch !== AdmissionBatchCode.UNIFIED_1_15,
      });

      // 更新录取状态
      for (const result of batchResults) {
        if (result.admitted) {
          const state = admissionStates.get(result.candidateId);
          if (state) {
            state.isAdmitted = true;
            state.admittedBatch = result.batch;
            state.admittedSchoolId = result.schoolId;
            state.admittedVolunteerIndex = result.volunteerIndex;
          }
          results.set(result.candidateId, result);
        }
      }
    }

    // 未被录取的考生记录结果
    for (const [candidateId, state] of admissionStates.entries()) {
      if (!state.isAdmitted) {
        results.set(candidateId, {
          candidateId,
          admitted: false,
        });
      }
    }

    return results;
  }
}

// 导出单例
export const admissionRulesEngine = new AdmissionRulesEngine();
