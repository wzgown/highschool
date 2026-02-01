/**
 * 虚拟竞争对手生成器
 * 为模拟考生生成虚拟竞争对手
 */

import type { Candidate, CandidateScores, CandidateTieBreaker, CandidateVolunteers } from '@shared/types/candidate';
import type { VirtualCompetitor } from '@shared/types/simulation';
import { getExamCount } from '@shared/constants/district';
import { logger } from '@shared/utils';
import { randomInt, randomNormal } from './random-utils';

/**
 * 竞争对手生成选项
 */
export interface CompetitorGeneratorOptions {
  /** 考生所在区ID */
  districtId: number;
  /** 考生分数 */
  candidateScore: number;
  /** 考生区内排名 */
  candidateRank: number;
  /** 需要生成的竞争对手数量 */
  count?: number;
  /** 分数波动范围 */
  scoreRange?: number;
  /** 是否包含历史志愿分布 */
  useHistoricalPattern?: boolean;
  /** 年份 */
  year?: number;
}

/**
 * 志愿选择模式
 */
interface VolunteerPattern {
  /** 冲刺志愿分数范围（相对于考生分数） */
  reachRange: [number, number];
  /** 稳妥志愿分数范围 */
  targetRange: [number, number];
  /** 保底志愿分数范围 */
  safetyRange: [number, number];
  /** 志愿数量分布 */
  volunteerCount: {
    quotaDistrict: number; // 0-1
    quotaSchool: number; // 0-2
    unified: number; // 0-15
  };
}

/**
 * 虚拟竞争对手生成器
 */
export class CompetitorGenerator {
  private logger = logger;

  /**
   * 生成虚拟竞争对手
   */
  async generate(options: CompetitorGeneratorOptions): Promise<VirtualCompetitor[]> {
    const {
      districtId,
      candidateScore,
      candidateRank,
      count,
      scoreRange = 30,
      useHistoricalPattern = true,
      year = 2025,
    } = options;

    // 计算竞争对手数量
    const totalStudents = getExamCount(districtId, year);
    const competitorCount = count || this.calculateCompetitorCount(totalStudents, candidateRank);

    this.logger.info(`开始生成虚拟竞争对手`, {
      districtId,
      candidateScore,
      candidateRank,
      competitorCount,
    });

    // 获取志愿选择模式
    const pattern = useHistoricalPattern
      ? this.getHistoricalVolunteerPattern(districtId, year)
      : this.getDefaultVolunteerPattern();

    // 生成竞争对手
    const competitors: VirtualCompetitor[] = [];

    // 生成不同类型的竞争对手
    const strongerCount = Math.round(competitorCount * 0.3); // 30%更强的竞争对手
    const similarCount = Math.round(competitorCount * 0.5); // 50%分数相似的竞争对手
    const weakerCount = competitorCount - strongerCount - similarCount; // 20%更弱的竞争对手

    // 生成更强的竞争对手
    for (let i = 0; i < strongerCount; i++) {
      competitors.push(this.generateCompetitor({
        districtId,
        scoreRange: [candidateScore + 5, candidateScore + scoreRange],
        pattern,
        year,
        index: i,
      }));
    }

    // 生成分数相似的竞争对手
    for (let i = 0; i < similarCount; i++) {
      competitors.push(this.generateCompetitor({
        districtId,
        scoreRange: [candidateScore - scoreRange / 2, candidateScore + scoreRange / 2],
        pattern,
        year,
        index: strongerCount + i,
      }));
    }

    // 生成更弱的竞争对手
    for (let i = 0; i < weakerCount; i++) {
      competitors.push(this.generateCompetitor({
        districtId,
        scoreRange: [candidateScore - scoreRange, candidateScore - 5],
        pattern,
        year,
        index: strongerCount + similarCount + i,
      }));
    }

    // 按分数排序
    competitors.sort((a, b) => b.totalScore - a.totalScore);

    // 更新排名
    competitors.forEach((c, idx) => {
      c.districtRank = idx + 1;
    });

    this.logger.info(`虚拟竞争对手生成完成`, {
      totalCount: competitors.length,
      strongerCount,
      similarCount,
      weakerCount,
    });

    return competitors;
  }

  /**
   * 计算竞争对手数量
   */
  private calculateCompetitorCount(totalStudents: number, candidateRank: number): number {
    // 基于考生排名估算相关竞争对手数量
    // 排名越靠前，竞争对手越少；排名越靠后，竞争对手越多
    const percentile = candidateRank / totalStudents;

    // 基础数量：200-500人
    const baseCount = 200;
    const multiplier = 1 + percentile * 2; // 1-3倍

    return Math.min(1000, Math.round(baseCount * multiplier));
  }

  /**
   * 生成单个虚拟竞争对手
   */
  private generateCompetitor(options: {
    districtId: number;
    scoreRange: [number, number];
    pattern: VolunteerPattern;
    year: number;
    index: number;
  }): VirtualCompetitor {
    const { districtId, scoreRange, pattern, year, index } = options;

    // 生成分数（使用正态分布）
    const avgScore = (scoreRange[0] + scoreRange[1]) / 2;
    const stdDev = (scoreRange[1] - scoreRange[0]) / 6; // 6σ原则
    const totalScore = Math.max(513, Math.min(750, Math.round(randomNormal(avgScore, stdDev))));

    // 生成各科成绩
    const scores = this.generateSubjectScores(totalScore);

    // 生成同分比较数据
    const tieBreaker = this.generateTieBreaker(scores);

    // 生成志愿
    const volunteers = this.generateVolunteers(scores.total, pattern, districtId);

    // 生成初中学校ID（用于名额分配到校）
    const middleSchoolId = this.generateMiddleSchoolId(districtId, year);

    return {
      id: `competitor-${Date.now()}-${index}`,
      totalScore: scores.total,
      districtRank: 0, // 将在生成后更新
      isTiePreferred: tieBreaker.isTiePreferred,
      comprehensiveQuality: tieBreaker.comprehensiveQuality,
      chineseMathForeignSum: tieBreaker.chineseMathForeignSum,
      mathScore: tieBreaker.mathScore,
      chineseScore: tieBreaker.chineseScore,
      integratedTestScore: tieBreaker.integratedTestScore,
      volunteers,
      middleSchoolId,
    };
  }

  /**
   * 生成各科成绩
   */
  private generateSubjectScores(totalScore: number): CandidateScores {
    // 基于总分生成各科成绩，使用正态分布
    // 各科平均分比例：语文(20%) 数学(22%) 外语(20%) 综合(20%) 道法(8%) 历史(8%) 体育(2%)
    const chineseTarget = totalScore * 0.20;
    const mathTarget = totalScore * 0.22;
    const foreignTarget = totalScore * 0.20;
    const integratedTarget = totalScore * 0.20;
    const ethicsTarget = totalScore * 0.08;
    const historyTarget = totalScore * 0.08;
    const peTarget = totalScore * 0.02;

    // 添加随机波动
    const chinese = Math.round(randomNormal(chineseTarget, 10));
    const math = Math.round(randomNormal(mathTarget, 12));
    const foreign = Math.round(randomNormal(foreignTarget, 10));
    const integrated = Math.round(randomNormal(integratedTarget, 10));
    const ethics = Math.round(randomNormal(ethicsTarget, 5));
    const history = Math.round(randomNormal(historyTarget, 5));
    const pe = Math.round(randomNormal(peTarget, 2));

    // 限制在有效范围内
    const clampedScores = {
      chinese: Math.max(0, Math.min(150, chinese)),
      math: Math.max(0, Math.min(150, math)),
      foreign: Math.max(0, Math.min(150, foreign)),
      integrated: Math.max(0, Math.min(150, integrated)),
      ethics: Math.max(0, Math.min(60, ethics)),
      history: Math.max(0, Math.min(60, history)),
      pe: Math.max(0, Math.min(30, pe)),
    };

    // 调整使总分匹配
    const currentTotal = Object.values(clampedScores).reduce((sum, s) => sum + s, 0);
    const diff = totalScore - currentTotal;

    // 将差值分配到主科
    clampedScores.math = Math.max(0, Math.min(150, clampedScores.math + diff));

    return {
      total: totalScore,
      ...clampedScores,
    };
  }

  /**
   * 生成同分比较数据
   */
  private generateTieBreaker(scores: CandidateScores): CandidateTieBreaker {
    return {
      comprehensiveQuality: randomInt(45, 50), // 大部分在45-50之间
      chineseMathForeignSum: scores.chinese + scores.math + scores.foreign,
      mathScore: scores.math,
      chineseScore: scores.chinese,
      integratedTestScore: scores.integrated,
      isTiePreferred: Math.random() < 0.02, // 2%概率同分优待
    };
  }

  /**
   * 生成志愿
   */
  private generateVolunteers(
    score: number,
    pattern: VolunteerPattern,
    districtId: number
  ): VirtualCompetitor['volunteers'] {
    const volunteers: VirtualCompetitor['volunteers'] = {};

    // 名额分配到区志愿（根据分数决定是否填报）
    if (pattern.volunteerCount.quotaDistrict > 0 && score >= 605) {
      // 生成一个冲刺志愿
      volunteers.quotaDistrict = this.generateSchoolId(score, pattern.reachRange, districtId);
    }

    // 名额分配到校志愿（如果符合资格）
    if (pattern.volunteerCount.quotaSchool > 0 && score >= 605) {
      const hasEligibility = Math.random() < 0.7; // 70%有资格
      if (hasEligibility) {
        volunteers.quotaSchool = [];
        for (let i = 0; i < pattern.volunteerCount.quotaSchool; i++) {
          const range = i === 0 ? pattern.reachRange : pattern.targetRange;
          volunteers.quotaSchool.push(this.generateSchoolId(score, range, districtId));
        }
      }
    }

    // 统一招生志愿
    if (pattern.volunteerCount.unified > 0) {
      volunteers.unified = [];
      const totalVolunteers = randomInt(8, 15); // 大部分填8-15个志愿

      for (let i = 0; i < totalVolunteers; i++) {
        let range: [number, number];
        if (i < totalVolunteers * 0.2) {
          range = pattern.reachRange;
        } else if (i < totalVolunteers * 0.6) {
          range = pattern.targetRange;
        } else {
          range = pattern.safetyRange;
        }
        volunteers.unified.push(this.generateSchoolId(score, range, districtId));
      }
    }

    return volunteers;
  }

  /**
   * 生成学校ID（基于分数范围）
   * 这里简化处理，实际应该从数据库查询
   */
  private generateSchoolId(score: number, scoreRange: [number, number], districtId: number): number {
    // 简化：基于分数范围生成一个虚拟的学校ID
    // 实际应该从ref_school表中查询对应分数段的学校
    const base = Math.floor((scoreRange[0] + scoreRange[1]) / 2);
    return parseInt(`${districtId}${base}`);
  }

  /**
   * 生成初中学校ID
   */
  private generateMiddleSchoolId(districtId: number, year: number): number {
    // 简化处理
    return parseInt(`${districtId}${randomInt(1, 50)}`);
  }

  /**
   * 获取历史志愿选择模式
   */
  private getHistoricalVolunteerPattern(districtId: number, year: number): VolunteerPattern {
    // 基于历史数据统计的志愿选择模式
    // 这里使用简化模式，实际应该从数据库分析历史数据

    return {
      reachRange: [10, 30], // 冲刺志愿高于考生10-30分
      targetRange: [-10, 10], // 稳妥志愿在考生±10分
      safetyRange: [-30, -5], // 保底志愿低于考生5-30分
      volunteerCount: {
        quotaDistrict: Math.random() < 0.9 ? 1 : 0, // 90%填报名额分配到区
        quotaSchool: Math.random() < 0.7 ? 2 : (Math.random() < 0.5 ? 1 : 0), // 70%填报2个
        unified: randomInt(10, 15), // 大部分填10-15个
      },
    };
  }

  /**
   * 获取默认志愿选择模式
   */
  private getDefaultVolunteerPattern(): VolunteerPattern {
    return {
      reachRange: [10, 25],
      targetRange: [-10, 10],
      safetyRange: [-25, -5],
      volunteerCount: {
        quotaDistrict: 1,
        quotaSchool: 2,
        unified: 12,
      },
    };
  }
}

// 导出单例
export const competitorGenerator = new CompetitorGenerator();
