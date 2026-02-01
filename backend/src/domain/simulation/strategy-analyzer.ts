/**
 * 策略分析器
 * 分析考生志愿填报策略，提供建议和风险评估
 */

import type { VolunteerProbability } from '@shared/types/simulation';
import type { StrategyAnalysis, StrategyGradient, RiskLevel } from '@shared/types/simulation';
import {
  getRiskLevelByProbability,
  calculateStrategyScore,
} from '@shared/types/simulation';
import { PROBABILITY_THRESHOLDS, GRADIENT_STANDARDS, STRATEGY_SCORE_STANDARDS } from '@shared/constants/admission';
import { logger } from '@shared/utils';

/**
 * 策略分析选项
 */
export interface StrategyAnalyzerOptions {
  /** 各志愿录取概率列表 */
  probabilities: VolunteerProbability[];
  /** 是否具备名额分配到校资格 */
  hasQuotaSchoolEligibility: boolean;
  /** 总志愿数 */
  totalVolunteers: number;
}

/**
 * 策略分析器
 */
export class StrategyAnalyzer {
  private logger = logger;

  /**
   * 分析策略
   */
  analyze(options: StrategyAnalyzerOptions): StrategyAnalysis {
    const { probabilities, hasQuotaSchoolEligibility, totalVolunteers } = options;

    // 统计各风险等级的志愿数量
    const gradient = this.analyzeGradient(probabilities, hasQuotaSchoolEligibility);

    // 生成建议
    const suggestions = this.generateSuggestions(gradient, probabilities);

    // 生成警告
    const warnings = this.generateWarnings(gradient, probabilities);

    // 计算策略评分
    const score = calculateStrategyScore(probabilities, gradient);

    // 分析志愿填报合理性
    const volunteerRationality = this.analyzeVolunteerRationality(probabilities);

    this.logger.info(`策略分析完成`, {
      score,
      gradient,
      suggestionCount: suggestions.length,
      warningCount: warnings.length,
    });

    return {
      score,
      gradient,
      suggestions,
      warnings,
      volunteerRationality,
    };
  }

  /**
   * 分析志愿梯度
   */
  private analyzeGradient(
    probabilities: VolunteerProbability[],
    hasQuotaSchoolEligibility: boolean
  ): StrategyGradient {
    const gradient: StrategyGradient = {
      reach: 0,
      target: 0,
      safety: 0,
    };

    for (const p of probabilities) {
      switch (p.riskLevel) {
        case RiskLevel.HIGH_RISK:
        case RiskLevel.RISKY:
          gradient.reach++;
          break;
        case RiskLevel.MODERATE:
          gradient.target++;
          break;
        case RiskLevel.SAFE:
          gradient.safety++;
          break;
      }
    }

    // 如果没有名额分配到校资格，检查是否填报了相关志愿
    if (!hasQuotaSchoolEligibility) {
      const quotaSchoolCount = probabilities.filter(
        p => p.batch === 'QUOTA_SCHOOL'
      ).length;
      if (quotaSchoolCount > 0) {
        // 这些志愿会被忽略，不计入梯度
        gradient.reach -= quotaSchoolCount;
      }
    }

    return gradient;
  }

  /**
   * 生成建议
   */
  private generateSuggestions(
    gradient: StrategyGradient,
    probabilities: VolunteerProbability[]
  ): string[] {
    const suggestions: string[] = [];

    // 梯度建议
    if (gradient.reach < GRADIENT_STANDARDS.minReach) {
      suggestions.push('建议增加1-2个冲刺志愿，充分利用高分机会');
    }

    if (gradient.target < GRADIENT_STANDARDS.minTarget) {
      suggestions.push('建议增加稳妥志愿数量，确保录取机会');
    }

    if (gradient.safety < GRADIENT_STANDARDS.minSafety) {
      suggestions.push('⚠️ 强烈建议添加保底志愿，避免滑档风险');
    }

    // 高风险志愿建议
    const highRiskCount = probabilities.filter(p => p.riskLevel === RiskLevel.HIGH_RISK).length;
    if (highRiskCount > GRADIENT_STANDARDS.maxHighRisk) {
      suggestions.push(`建议减少高风险志愿数量（当前${highRiskCount}个），避免浪费志愿机会`);
    }

    // 概率接近的志愿建议
    const similarProbabilities = this.findSimilarProbabilities(probabilities);
    if (similarProbabilities.length > 0) {
      suggestions.push(
        `部分志愿录取概率较为接近（${similarProbabilities.map(p => p.schoolName).join('、')}），可考虑拉开梯度`
      );
    }

    // 批次建议
    const batchDistribution = this.analyzeBatchDistribution(probabilities);
    if (batchDistribution.missingQuotaDistrict) {
      suggestions.push('考虑填报名额分配到区志愿，增加录取机会');
    }

    // 志愿数量建议
    const totalUnified = probabilities.filter(p => p.batch === 'UNIFIED').length;
    if (totalUnified < 10) {
      suggestions.push('建议充分利用1-15志愿，填报更多学校以增加录取机会');
    }

    return suggestions;
  }

  /**
   * 生成警告
   */
  private generateWarnings(
    gradient: StrategyGradient,
    probabilities: VolunteerProbability[]
  ): string[] {
    const warnings: string[] = [];

    // 严重警告：没有保底志愿
    if (gradient.safety === 0) {
      warnings.push('🚨 严重警告：当前志愿配置没有保底学校，存在较高滑档风险！');
    }

    // 警告：梯度不合理
    if (gradient.reach === 0 && gradient.target > 5) {
      warnings.push('当前志愿配置过于保守，可能错过更好的学校机会');
    }

    if (gradient.reach > 5 && gradient.safety < 2) {
      warnings.push('当前志愿配置过于激进，冲刺志愿过多而保底不足');
    }

    // 警告：高分低报
    const wastedHighScores = probabilities.filter(
      p => p.probability > 95 && p.volunteerIndex && p.volunteerIndex > 5
    );
    if (wastedHighScores.length > 0) {
      warnings.push(
        `部分志愿录取概率过高（${wastedHighScores.map(p => p.schoolName).join('、')}），可能存在高分低报`
      );
    }

    // 警告：连续高风险
    const consecutiveHighRisk = this.findConsecutiveHighRisk(probabilities);
    if (consecutiveHighRisk.length >= 3) {
      warnings.push(
        `存在连续${consecutiveHighRisk.length}个高风险志愿（${consecutiveHighRisk.map(p => p.schoolName).join('、')}），建议调整`
      );
    }

    return warnings;
  }

  /**
   * 分析志愿填报合理性
   */
  private analyzeVolunteerRationality(probabilities: VolunteerProbability[]): {
    hasSafetySchool: boolean;
    isGradientReasonable: boolean;
    hasDuplicateOrInvalid: boolean;
  } {
    const hasSafetySchool = probabilities.some(p => p.riskLevel === RiskLevel.SAFE);

    // 检查梯度是否合理（有冲刺、稳妥、保底）
    const hasReach = probabilities.some(p => p.riskLevel === RiskLevel.RISKY || p.riskLevel === RiskLevel.HIGH_RISK);
    const hasTarget = probabilities.some(p => p.riskLevel === RiskLevel.MODERATE);
    const isGradientReasonable = hasReach && hasTarget && hasSafetySchool;

    // 检查是否有重复或无效志愿
    const schoolIds = probabilities.map(p => p.schoolId);
    const hasDuplicateOrInvalid = new Set(schoolIds).size !== schoolIds.length;

    return {
      hasSafetySchool,
      isGradientReasonable,
      hasDuplicateOrInvalid,
    };
  }

  /**
   * 查找概率相近的志愿
   */
  private findSimilarProbabilities(
    probabilities: VolunteerProbability[],
    threshold = 10
  ): VolunteerProbability[] {
    const similar: VolunteerProbability[] = [];

    for (let i = 0; i < probabilities.length - 1; i++) {
      const diff = Math.abs(probabilities[i].probability - probabilities[i + 1].probability);
      if (diff < threshold) {
        similar.push(probabilities[i], probabilities[i + 1]);
      }
    }

    return similar;
  }

  /**
   * 分析批次分布
   */
  private analyzeBatchDistribution(probabilities: VolunteerProbability[]): {
    hasQuotaDistrict: boolean;
    hasQuotaSchool: boolean;
    hasUnified: boolean;
    missingQuotaDistrict: boolean;
  } {
    const hasQuotaDistrict = probabilities.some(p => p.batch === 'QUOTA_DISTRICT');
    const hasQuotaSchool = probabilities.some(p => p.batch === 'QUOTA_SCHOOL');
    const hasUnified = probabilities.some(p => p.batch === 'UNIFIED');

    return {
      hasQuotaDistrict,
      hasQuotaSchool,
      hasUnified,
      missingQuotaDistrict: !hasQuotaDistrict,
    };
  }

  /**
   * 查找连续的高风险志愿
   */
  private findConsecutiveHighRisk(probabilities: VolunteerProbability[]): VolunteerProbability[] {
    const consecutive: VolunteerProbability[] = [];
    let currentStreak: VolunteerProbability[] = [];

    for (const p of probabilities) {
      if (p.riskLevel === RiskLevel.HIGH_RISK || p.riskLevel === RiskLevel.RISKY) {
        currentStreak.push(p);
      } else {
        if (currentStreak.length >= 3) {
          consecutive.push(...currentStreak);
        }
        currentStreak = [];
      }
    }

    if (currentStreak.length >= 3) {
      consecutive.push(...currentStreak);
    }

    return consecutive;
  }

  /**
   * 获取策略等级描述
   */
  getStrategyGrade(score: number): string {
    if (score >= 90) return '优秀';
    if (score >= 75) return '良好';
    if (score >= 60) return '一般';
    if (score >= 40) return '较差';
    return '危险';
  }

  /**
   * 获取策略等级颜色
   */
  getStrategyGradeColor(score: number): string {
    if (score >= 90) return '#52c41a'; // 绿色
    if (score >= 75) return '#1890ff'; // 蓝色
    if (score >= 60) return '#faad14'; // 橙色
    if (score >= 40) return '#ff7a45'; // 深橙色
    return '#f5222d'; // 红色
  }
}

// 导出单例
export const strategyAnalyzer = new StrategyAnalyzer();
