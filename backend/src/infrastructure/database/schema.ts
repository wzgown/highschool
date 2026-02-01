/**
 * Drizzle ORM 数据库模型定义
 */

import {
  pgTable,
  serial,
  varchar,
  text,
  integer,
  boolean,
  timestamp,
  decimal,
  jsonb,
  index,
  unique,
} from 'drizzle-orm/pg-core';

// =============================================================================
// 参考表
// =============================================================================

/**
 * 区县表
 */
export const refDistrict = pgTable(
  'ref_district',
  {
    id: serial('id').primaryKey(),
    code: varchar('code', { length: 20 }).notNull().unique(),
    name: varchar('name', { length: 50 }).notNull(),
    nameEn: varchar('name_en', { length: 50 }),
    displayOrder: integer('display_order').notNull().default(0),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    codeIdx: index('idx_ref_district_code').on(table.code),
  })
);

/**
 * 学校类型枚举表
 */
export const refSchoolType = pgTable('ref_school_type', {
  id: serial('id').primaryKey(),
  code: varchar('code', { length: 50 }).notNull().unique(),
  name: varchar('name', { length: 100 }).notNull(),
  description: text('description'),
  displayOrder: integer('display_order').notNull().default(0),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

/**
 * 学校办别枚举表
 */
export const refSchoolNature = pgTable('ref_school_nature', {
  id: serial('id').primaryKey(),
  code: varchar('code', { length: 20 }).notNull().unique(),
  name: varchar('name', { length: 20 }).notNull(),
  displayOrder: integer('display_order').notNull().default(0),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

/**
 * 寄宿情况枚举表
 */
export const refBoardingType = pgTable('ref_boarding_type', {
  id: serial('id').primaryKey(),
  code: varchar('code', { length: 20 }).notNull().unique(),
  name: varchar('name', { length: 20 }).notNull(),
  description: text('description'),
  displayOrder: integer('display_order').notNull().default(0),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

/**
 * 招生批次枚举表
 */
export const refAdmissionBatch = pgTable('ref_admission_batch', {
  id: serial('id').primaryKey(),
  code: varchar('code', { length: 50 }).notNull().unique(),
  name: varchar('name', { length: 100 }).notNull(),
  description: text('description'),
  displayOrder: integer('display_order').notNull().default(0),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

/**
 * 学校主表
 */
export const refSchool = pgTable(
  'ref_school',
  {
    id: serial('id').primaryKey(),
    code: varchar('code', { length: 20 }).notNull(),
    fullName: varchar('full_name', { length: 200 }).notNull(),
    shortName: varchar('short_name', { length: 100 }),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    schoolNatureId: integer('school_nature_id')
      .notNull()
      .references(() => refSchoolNature.id),
    schoolTypeId: integer('school_type_id').references(() => refSchoolType.id),
    boardingTypeId: integer('boarding_type_id').references(() => refBoardingType.id),
    hasInternationalCourse: boolean('has_international_course').default(false),
    remarks: text('remarks'),
    dataYear: integer('data_year').notNull().default(2025),
    isActive: boolean('is_active').notNull().default(true),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    codeDataYearUnique: unique('unique_ref_school_code_data_year').on(table.code, table.dataYear),
    districtIdx: index('idx_ref_school_district').on(table.districtId),
    typeIdx: index('idx_ref_school_type').on(table.schoolTypeId),
  })
);

/**
 * 初中学校表
 */
export const refMiddleSchool = pgTable(
  'ref_middle_school',
  {
    id: serial('id').primaryKey(),
    code: varchar('code', { length: 20 }),
    name: varchar('name', { length: 200 }).notNull(),
    shortName: varchar('short_name', { length: 100 }),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    schoolNatureId: integer('school_nature_id').references(() => refSchoolNature.id),
    isNonSelective: boolean('is_non_selective').notNull().default(true),
    dataYear: integer('data_year').notNull().default(2025),
    isActive: boolean('is_active').notNull().default(true),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    codeDataYearUnique: unique('unique_ref_middle_school_code_data_year').on(table.code, table.dataYear),
    districtIdx: index('idx_ref_middle_school_district').on(table.districtId),
    nonSelectiveIdx: index('idx_ref_middle_school_non_selective').on(table.isNonSelective),
  })
);

/**
 * 科目表
 */
export const refSubject = pgTable('ref_subject', {
  id: serial('id').primaryKey(),
  code: varchar('code', { length: 20 }).notNull().unique(),
  name: varchar('name', { length: 50 }).notNull(),
  maxScore: decimal('max_score', { precision: 5, scale: 2 }).notNull().default('150'),
  description: text('description'),
  displayOrder: integer('display_order').notNull().default(0),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

/**
 * 最低投档控制分数线表
 */
export const refControlScore = pgTable(
  'ref_control_score',
  {
    id: serial('id').primaryKey(),
    year: integer('year').notNull(),
    admissionBatchId: integer('admission_batch_id')
      .notNull()
      .references(() => refAdmissionBatch.id),
    category: varchar('category', { length: 100 }).notNull(),
    minScore: decimal('min_score', { precision: 5, scale: 2 }).notNull(),
    description: text('description'),
    dataYear: integer('data_year').notNull(),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    yearBatchCategoryUnique: unique('unique_ref_control_score_year_batch_category').on(
      table.year,
      table.admissionBatchId,
      table.category
    ),
    yearIdx: index('idx_ref_control_score_year').on(table.year),
  })
);

/**
 * 名额分配到区招生计划表
 */
export const refQuotaAllocationDistrict = pgTable(
  'ref_quota_allocation_district',
  {
    id: serial('id').primaryKey(),
    year: integer('year').notNull(),
    schoolId: integer('school_id')
      .notNull()
      .references(() => refSchool.id),
    schoolCode: varchar('school_code', { length: 20 }).notNull(),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    quotaCount: integer('quota_count').notNull(),
    dataYear: integer('data_year').notNull().default(2025),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    yearSchoolCodeDistrictUnique: unique('unique_ref_quota_allocation_district').on(
      table.year,
      table.schoolCode,
      table.districtId
    ),
    yearIdx: index('idx_ref_quota_allocation_year').on(table.year),
    schoolIdx: index('idx_ref_quota_allocation_school').on(table.schoolId),
    districtIdx: index('idx_ref_quota_allocation_district').on(table.districtId),
  })
);

/**
 * 名额分配到校招生计划表
 */
export const refQuotaAllocationSchool = pgTable(
  'ref_quota_allocation_school',
  {
    id: serial('id').primaryKey(),
    year: integer('year').notNull(),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    highSchoolId: integer('high_school_id')
      .notNull()
      .references(() => refSchool.id),
    highSchoolCode: varchar('high_school_code', { length: 20 }).notNull(),
    middleSchoolId: integer('middle_school_id').references(() => refMiddleSchool.id),
    middleSchoolName: varchar('middle_school_name', { length: 200 }),
    quotaCount: integer('quota_count').notNull(),
    dataYear: integer('data_year').notNull(),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    yearHighSchoolCodeMiddleSchoolUnique: unique('unique_ref_quota_allocation_school').on(
      table.year,
      table.highSchoolCode,
      table.middleSchoolName
    ),
    yearIdx: index('idx_ref_quota_allocation_school_year').on(table.year),
    districtIdx: index('idx_ref_quota_allocation_school_district').on(table.districtId),
    highSchoolIdx: index('idx_ref_quota_allocation_school_high').on(table.highSchoolId),
  })
);

/**
 * 各区中考人数表
 */
export const refDistrictExamCount = pgTable(
  'ref_district_exam_count',
  {
    id: serial('id').primaryKey(),
    year: integer('year').notNull(),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    examCount: integer('exam_count').notNull(),
    dataSource: varchar('data_source', { length: 255 }),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    yearDistrictUnique: unique('unique_ref_district_exam_count').on(table.year, table.districtId),
    yearIdx: index('idx_ref_district_exam_count_year').on(table.year),
    districtIdx: index('idx_ref_district_exam_count_district').on(table.districtId),
  })
);

/**
 * 名额分配到区录取最低分数线表
 */
export const refAdmissionScoreQuotaDistrict = pgTable(
  'ref_admission_score_quota_district',
  {
    id: serial('id').primaryKey(),
    year: integer('year').notNull(),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    schoolId: integer('school_id').references(() => refSchool.id),
    schoolName: varchar('school_name', { length: 200 }).notNull(),
    minScore: decimal('min_score', { precision: 6, scale: 2 }).notNull(),
    isTiePreferred: boolean('is_tie_preferred').default(false),
    chineseMathForeignSum: decimal('chinese_math_foreign_sum', { precision: 6, scale: 2 }),
    mathScore: decimal('math_score', { precision: 5, scale: 2 }),
    chineseScore: decimal('chinese_score', { precision: 5, scale: 2 }),
    integratedTestScore: decimal('integrated_test_score', { precision: 5, scale: 2 }),
    comprehensiveQualityScore: decimal('comprehensive_quality_score', { precision: 4, scale: 1 }).default('50'),
    dataYear: integer('data_year').notNull(),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    yearDistrictSchoolUnique: unique('unique_ref_admission_score_quota_district').on(
      table.year,
      table.districtId,
      table.schoolName
    ),
    yearIdx: index('idx_ref_admission_score_quota_year').on(table.year),
    districtIdx: index('idx_ref_admission_score_quota_district').on(table.districtId),
    schoolIdx: index('idx_ref_admission_score_quota_school').on(table.schoolId),
    minScoreIdx: index('idx_ref_admission_score_quota_min_score').on(table.minScore),
  })
);

/**
 * 名额分配到校录取最低分数线表
 */
export const refAdmissionScoreQuotaSchool = pgTable(
  'ref_admission_score_quota_school',
  {
    id: serial('id').primaryKey(),
    year: integer('year').notNull(),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    schoolId: integer('school_id').references(() => refSchool.id),
    schoolName: varchar('school_name', { length: 200 }).notNull(),
    middleSchoolName: varchar('middle_school_name', { length: 200 }),
    minScore: decimal('min_score', { precision: 6, scale: 2 }).notNull(),
    isTiePreferred: boolean('is_tie_preferred').default(false),
    chineseMathForeignSum: decimal('chinese_math_foreign_sum', { precision: 6, scale: 2 }),
    mathScore: decimal('math_score', { precision: 5, scale: 2 }),
    chineseScore: decimal('chinese_score', { precision: 5, scale: 2 }),
    integratedTestScore: decimal('integrated_test_score', { precision: 5, scale: 2 }),
    comprehensiveQualityScore: decimal('comprehensive_quality_score', { precision: 4, scale: 1 }).default('50'),
    dataYear: integer('data_year').notNull(),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    yearDistrictSchoolMiddleSchoolUnique: unique('unique_ref_admission_score_quota_school').on(
      table.year,
      table.districtId,
      table.schoolName,
      table.middleSchoolName
    ),
    yearIdx: index('idx_ref_admission_score_quota_school_year').on(table.year),
    districtIdx: index('idx_ref_admission_score_quota_school_district').on(table.districtId),
    highSchoolIdx: index('idx_ref_admission_score_quota_school_high').on(table.schoolId),
    minScoreIdx: index('idx_ref_admission_score_quota_school_min_score').on(table.minScore),
  })
);

/**
 * 1-15志愿录取分数线表
 */
export const refAdmissionScoreUnified = pgTable(
  'ref_admission_score_unified',
  {
    id: serial('id').primaryKey(),
    year: integer('year').notNull(),
    districtId: integer('district_id')
      .notNull()
      .references(() => refDistrict.id),
    schoolId: integer('school_id').references(() => refSchool.id),
    schoolName: varchar('school_name', { length: 200 }).notNull(),
    minScore: decimal('min_score', { precision: 6, scale: 2 }).notNull(),
    chineseMathForeignSum: decimal('chinese_math_foreign_sum', { precision: 6, scale: 2 }),
    mathScore: decimal('math_score', { precision: 5, scale: 2 }),
    chineseScore: decimal('chinese_score', { precision: 5, scale: 2 }),
    dataYear: integer('data_year').notNull(),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  },
  (table) => ({
    yearDistrictSchoolUnique: unique('unique_ref_admission_score_unified').on(
      table.year,
      table.districtId,
      table.schoolName
    ),
    yearIdx: index('idx_ref_admission_score_unified_year').on(table.year),
    districtIdx: index('idx_ref_admission_score_unified_district').on(table.districtId),
    schoolIdx: index('idx_ref_admission_score_unified_school').on(table.schoolId),
    minScoreIdx: index('idx_ref_admission_score_unified_min_score').on(table.minScore),
  })
);

// =============================================================================
// 模拟历史表
// =============================================================================

/**
 * 模拟历史记录表
 */
export const simulationHistory = pgTable(
  'simulation_history',
  {
    id: serial('id').primaryKey(),
    deviceId: varchar('device_id', { length: 255 }).notNull(),
    deviceInfo: jsonb('device_info'),
    candidateData: jsonb('candidate_data').notNull(),
    simulationResult: jsonb('simulation_result').notNull(),
    createdAt: timestamp('created_at').notNull().defaultNow(),
  },
  (table) => ({
    deviceCreatedIdx: index('idx_simulation_history_device_created').on(table.deviceId, table.createdAt),
  })
);

/**
 * 虚拟竞争对手生成记录表
 */
export const competitorGenerationLog = pgTable('competitor_generation_log', {
  id: serial('id').primaryKey(),
  deviceId: varchar('device_id', { length: 255 }).notNull(),
  candidateScoreRange: varchar('candidate_score_range', { length: 20 }).notNull(),
  generatedCompetitors: jsonb('generated_competitors').notNull(),
  actualSuccessRate: decimal('actual_success_rate', { precision: 5, scale: 2 }),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});
