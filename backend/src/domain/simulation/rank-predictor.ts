/**
 * 区内排名预测服务
 * 基于考生分数和历年数据预测区内排名
 */

import type { CandidateScores } from '@shared/types/candidate';
import type { ConfidenceLevel } from '@shared/types/simulation';
import { getExamCount } from '@shared/constants/district';
import { RANK_ESTIMATION_COEFFICIENTS } from '@shared/constants/admission';
import { logger } from '@shared/utils';

/**
 * 排名预测结果
 */
export interface RankPrediction {
  /** 预测的区内排名 */
  districtRank: number;
  /** 排名范围（最低-最高） */
  districtRankRange: [number, number];
  /** 信心等级 */
  confidence: ConfidenceLevel;
  /** 排名百分比 */
  percentile: number;
}

/**
 * 历史分数分布数据
 */
interface ScoreDistribution {
  /** 分数区间 */
  scoreRange: [number, number];
  /** 人数 */
  count: number;
  /** 累计人数 */
  cumulativeCount: number;
}

/**
 * 分数段信息
 */
interface ScoreSegment {
  /** 分数段下限 */
  minScore: number;
  /** 分数段上限 */
  maxScore: number;
  /** 平均分 */
  avgScore: number;
  /** 人数 */
  count: number;
  /** 累计人数占比 */
  cumulativePercentile: number;
}

/**
 * 区内排名预测器
 */
export class RankPredictor {
  private logger = logger;

  /**
   * 预测区内排名
   */
  async predict(
    districtId: number,
    scores: CandidateScores,
    year: number = 2025
  ): Promise<RankPrediction> {
    const totalStudents = getExamCount(districtId, year);

    if (totalStudents === 0) {
      throw new Error(`区 ${districtId} 在 ${year} 年的考试人数数据不存在`);
    }

    // 获取分数分布
    const distribution = this.generateScoreDistribution(districtId, year, totalStudents);

    // 基于分数计算排名
    const prediction = this.calculateRankFromScore(scores.total, distribution, totalStudents);

    this.logger.info(`预测区内排名`, {
      districtId,
      score: scores.total,
      predictedRank: prediction.districtRank,
      range: prediction.districtRankRange,
      confidence: prediction.confidence,
    });

    return prediction;
  }

  /**
   * 从分数计算排名
   */
  private calculateRankFromScore(
    score: number,
    distribution: ScoreDistribution[],
    totalStudents: number
  ): RankPrediction {
    // 找到分数所在的区间
    const segment = distribution.find(d => score >= d.scoreRange[0] && score <= d.scoreRange[1]);

    if (!segment) {
      // 分数超出范围，使用极值
      if (score > distribution[0].scoreRange[1]) {
        return {
          districtRank: 1,
          districtRankRange: [1, 10],
          confidence: 'high',
          percentile: 100,
        };
      } else {
        return {
          districtRank: totalStudents,
          districtRankRange: [totalStudents - 10, totalStudents],
          confidence: 'medium',
          percentile: 0,
        };
      }
    }

    // 在区间内线性插值估算排名
    const [minScore, maxScore] = segment.scoreRange;
    const rangeSize = maxScore - minScore;
    const positionInSegment = (score - minScore) / rangeSize;

    // 估算排名：累计人数 + 区间内位置
    const estimatedRank = Math.round(
      segment.cumulativeCount - segment.count + segment.count * (1 - positionInSegment)
    );

    // 计算排名范围（基于方差）
    const variance = Math.round(RANK_ESTIMATION_COEFFICIENTS.baseVariance * (1 - positionInSegment));
    const minRank = Math.max(1, estimatedRank - variance);
    const maxRank = Math.min(totalStudents, estimatedRank + variance);

    // 计算信心等级
    const confidence = this.calculateConfidence(score, rangeSize, segment.count);

    // 计算百分位
    const percentile = ((totalStudents - estimatedRank) / totalStudents) * 100;

    return {
      districtRank: estimatedRank,
      districtRankRange: [minRank, maxRank],
      confidence,
      percentile: Math.max(0, Math.min(100, percentile)),
    };
  }

  /**
   * 计算信心等级
   */
  private calculateConfidence(score: number, rangeSize: number, count: number): ConfidenceLevel {
    // 分数段越小，信心越高
    if (rangeSize <= 5 && count >= 10) {
      return 'high';
    }
    if (rangeSize <= 10 && count >= 5) {
      return 'medium';
    }
    return 'low';
  }

  /**
   * 生成分数分布（基于正态分布估算）
   */
  private generateScoreDistribution(
    districtId: number,
    year: number,
    totalStudents: number
  ): ScoreDistribution[] {
    // 估算平均分和标准差（基于历史数据）
    const { mean, stdDev } = this.estimateDistributionParams(districtId, year);

    // 生成分数分布
    const distribution: ScoreDistribution[] = [];
    const binSize = 5; // 5分一个区间

    // 从最低分到最高分
    for (let score = 500; score <= 750; score += binSize) {
      // 计算该分数区间的人数（正态分布PDF）
      const midScore = score + binSize / 2;
      const probability = this.normalPDF(midScore, mean, stdDev);
      const count = Math.round(probability * totalStudents * binSize);

      // 计算累计人数
      const cumulativeCount = distribution.reduce((sum, d) => sum + d.count, 0) + count;

      distribution.push({
        scoreRange: [score, score + binSize],
        count: Math.max(0, count),
        cumulativeCount,
      });
    }

    return distribution.filter(d => d.count > 0);
  }

  /**
   * 估算正态分布参数
   */
  private estimateDistributionParams(districtId: number, year: number): {
    mean: number;
    stdDev: number;
  } {
    // 基于区县和年份的参数估算
    // 这里使用简化模型，实际应该从历史数据统计

    // 基础平均分（全市）
    const baseMean = 620;

    // 区县调整系数（不同区的教育水平差异）
    const districtFactors: Record<number, number> = {
      1: 15, // 黄浦区
      2: 20, // 徐汇区
      3: 12, // 长宁区
      4: 13, // 静安区
      5: 8, // 普陀区
      6: 10, // 虹口区
      7: 12, // 杨浦区
      8: 5, // 闵行区
      9: 3, // 宝山区
      10: 5, // 嘉定区
      11: 2, // 浦东新区
      12: 0, // 金山区
      13: 2, // 松江区
      14: 3, // 青浦区
      15: 0, // 奉贤区
      16: -2, // 崇明区
    };

    const districtAdjustment = districtFactors[districtId] || 0;

    // 年份调整（逐年上涨趋势）
    const yearAdjustment = (year - 2024) * 3;

    const mean = baseMean + districtAdjustment + yearAdjustment;

    // 标准差（约50分）
    const stdDev = 50;

    return { mean, stdDev };
  }

  /**
   * 正态分布概率密度函数
   */
  private normalPDF(x: number, mean: number, stdDev: number): number {
    const variance = stdDev * stdDev;
    const exponent = -((x - mean) ** 2) / (2 * variance);
    return (1 / (stdDev * Math.sqrt(2 * Math.PI))) * Math.exp(exponent);
  }

  /**
   * 从排名反推分数
   */
  scoreFromRank(rank: number, totalStudents: number, districtId: number, year: number): number {
    const percentile = (totalStudents - rank) / totalStudents;
    const { mean, stdDev } = this.estimateDistributionParams(districtId, year);

    // 使用正态分布的反函数估算
    const zScore = this.inverseNormalCDF(percentile);
    const estimatedScore = mean + zScore * stdDev;

    return Math.round(estimatedScore);
  }

  /**
   * 正态分布累积分布函数的反函数（近似）
   */
  private inverseNormalCDF(p: number): number {
    // Beasley-Springer-Moro近似算法
    if (p <= 0 || p >= 1) {
      throw new Error('p must be between 0 and 1');
    }

    const a = [0, -3.969683028665376e1, 2.209460984245205e2, -2.759285104469687e2, 1.383577518672690e2, -3.066479806614716e1, 2.506628277459239e0];
    const b = [0, -5.447609879822406e1, 1.615858368580409e2, -1.556989798598866e2, 6.680131188771972e1, -1.328068155288572e1];
    const c = [0, -7.784894002430293e-3, -3.223964580411365e-1, -2.400758277161838e0, -2.549732539343734e0, 4.374664141464968e0, 2.938163982698783e0];
    const d = [0, 7.784695709041462e-3, 3.224671290700398e-1, 2.445134137142996e0, 3.754408661907416e0];

    const pLow = 0.02425;
    const pHigh = 1 - pLow;
    let q: number, r: number;

    if (p < pLow) {
      q = Math.sqrt(-2 * Math.log(p));
      return (((((c[1] * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) * q + c[6]) /
             ((((d[1] * q + d[2]) * q + d[3]) * q + d[4]) * q + 1);
    }

    if (p <= pHigh) {
      q = p - 0.5;
      r = q * q;
      return (((((a[1] * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) * r + a[6]) * q /
             (((((b[1] * r + b[2]) * r + b[3]) * r + b[4]) * r + b[5]) * r + 1);
    }

    q = Math.sqrt(-2 * Math.log(1 - p));
    return -(((((c[1] * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) * q + c[6]) /
            ((((d[1] * q + d[2]) * q + d[3]) * q + d[4]) * q + 1);
  }

  /**
   * 获取分数段信息
   */
  getScoreSegments(districtId: number, year: number): ScoreSegment[] {
    const totalStudents = getExamCount(districtId, year);
    const distribution = this.generateScoreDistribution(districtId, year, totalStudents);

    return distribution.map((d, idx) => ({
      minScore: d.scoreRange[0],
      maxScore: d.scoreRange[1],
      avgScore: (d.scoreRange[0] + d.scoreRange[1]) / 2,
      count: d.count,
      cumulativePercentile: ((totalStudents - d.cumulativeCount) / totalStudents) * 100,
    }));
  }
}

// 导出单例
export const rankPredictor = new RankPredictor();
