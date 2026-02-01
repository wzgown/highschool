/**
 * 参考数据API路由
 */

import type { FastifyInstance } from 'fastify';
import {
  DistrictsResponse,
  SchoolsListParams,
  SchoolsListResponse,
  SchoolDetailResponse,
  MiddleSchoolsResponse,
  HistoryScoresParams,
  HistoryScoresResponse,
  DistrictExamCountResponse,
} from '@shared/types/api';
import { getDb } from '../../infrastructure/database';
import { refDistrict, refSchool, refMiddleSchool, refDistrictExamCount } from '../../infrastructure/database';
import { eq, like, sql, desc } from 'drizzle-orm';
import { BadRequestError, NotFoundError } from '@shared/utils/errors';
import { logger } from '@shared/utils';

/**
 * 参考数据API路由
 */
export async function referenceRoutes(fastify: FastifyInstance) {
  /**
   * 获取区县列表
   */
  fastify.get('/districts', async (request, reply) => {
    const db = getDb();

    const districts = await db
      .select({
        id: refDistrict.id,
        code: refDistrict.code,
        name: refDistrict.name,
        nameEn: refDistrict.nameEn,
        displayOrder: refDistrict.displayOrder,
      })
      .from(refDistrict)
      .orderBy(refDistrict.displayOrder);

    const response: DistrictsResponse = {
      districts: districts.map((d) => ({
        id: d.id,
        code: d.code,
        name: d.name,
        nameEn: d.nameEn ?? undefined,
        displayOrder: d.displayOrder,
      })),
    };

    return reply.code(200).send(response);
  });

  /**
   * 获取学校列表
   */
  fastify.get<{
    Querystring: SchoolsListParams;
  }>('/schools', async (request, reply) => {
    const db = getDb();
    const {
      districtId,
      schoolTypeId,
      schoolNatureId,
      hasInternationalCourse,
      keyword,
      page = '1',
      pageSize = '20',
    } = request.query;

    const pageNum = parseInt(page);
    const size = parseInt(pageSize);
    const offset = (pageNum - 1) * size;

    // 构建查询条件
    const conditions = [];

    if (districtId) {
      conditions.push(eq(refSchool.districtId, districtId));
    }

    if (schoolTypeId) {
      conditions.push(eq(refSchool.schoolTypeId, schoolTypeId));
    }

    if (schoolNatureId) {
      conditions.push(eq(refSchool.schoolNatureId, schoolNatureId));
    }

    if (hasInternationalCourse !== undefined) {
      conditions.push(eq(refSchool.hasInternationalCourse, hasInternationalCourse));
    }

    if (keyword) {
      conditions.push(
        sql`${refSchool.fullName} ILIKE ${`%${keyword}%`} OR ${refSchool.shortName} ILIKE ${`%${keyword}%`}`
      );
    }

    // 只查询启用的学校
    conditions.push(eq(refSchool.isActive, true));

    // 获取总数
    const totalCountResult = await db
      .select({ count: sql<number>`count(*)` })
      .from(refSchool)
      .where(conditions.length > 0 ? sql.join(conditions, sql` AND `) : undefined);

    const total = parseInt(totalCountResult[0]?.count || '0');

    // 获取学校列表
    const schools = await db
      .select({
        id: refSchool.id,
        code: refSchool.code,
        fullName: refSchool.fullName,
        shortName: refSchool.shortName,
        districtId: refSchool.districtId,
        schoolNatureId: refSchool.schoolNatureId,
        schoolTypeId: refSchool.schoolTypeId,
        hasInternationalCourse: refSchool.hasInternationalCourse,
      })
      .from(refSchool)
      .where(conditions.length > 0 ? sql.join(conditions, sql` AND `) : undefined)
      .orderBy(refSchool.code)
      .limit(size)
      .offset(offset);

    // 关联查询区县名称
    const districtIds = [...new Set(schools.map(s => s.districtId))];
    const districts = await db
      .select()
      .from(refDistrict)
      .where(sql`${refDistrict.id} = ANY(${districtIds})`);

    const districtMap = new Map(districts.map(d => [d.id, d.name]));

    const response: SchoolsListResponse = {
      schools: schools.map((s) => ({
        id: s.id,
        code: s.code,
        fullName: s.fullName,
        shortName: s.shortName ?? undefined,
        districtId: s.districtId,
        districtName: districtMap.get(s.districtId),
        schoolNatureId: s.schoolNatureId,
        schoolTypeId: s.schoolTypeId ?? undefined,
        hasInternationalCourse: s.hasInternationalCourse ?? undefined,
      })),
      total,
    };

    return reply.code(200).send(response);
  });

  /**
   * 获取学校详情
   */
  fast.get<{
    Params: { id: string };
  }>('/schools/:id', async (request, reply) => {
    const { id } = request.params;
    const db = getDb();
    const schoolId = parseInt(id);

    const [school] = await db
      .select()
      .from(refSchool)
      .where(eq(refSchool.id, schoolId));

    if (!school) {
      throw new NotFoundError('学校');
    }

    // 获取区县信息
    const [district] = await db
      .select()
      .from(refDistrict)
      .where(eq(refDistrict.id, school.districtId));

    // TODO: 获取历年分数线

    const response: SchoolDetailResponse = {
      id: school.id,
      code: school.code,
      fullName: school.fullName,
      shortName: school.shortName ?? undefined,
      districtId: school.districtId,
      districtName: district?.name,
      schoolNatureId: school.schoolNatureId,
      schoolNatureName: undefined, // TODO: 关联查询
      schoolTypeId: school.schoolTypeId ?? undefined,
      schoolTypeName: undefined, // TODO: 关联查询
      boardingTypeId: school.boardingTypeId ?? undefined,
      boardingTypeName: undefined, // TODO: 关联查询
      hasInternationalCourse: school.hasInternationalCourse ?? undefined,
      remarks: school.remarks ?? undefined,
      historyScores: [],
    };

    return reply.code(200).send(response);
  });

  /**
   * 获取初中学校列表
   */
  fastify.get<{
    Querystring: { districtId?: string; isNonSelective?: string };
  }>('/middle-schools', async (request, reply) => {
    const db = getDb();
    const { districtId, isNonSelective } = request.query;

    const conditions = [];

    if (districtId) {
      conditions.push(eq(refMiddleSchool.districtId, parseInt(districtId)));
    }

    if (isNonSelective !== undefined) {
      conditions.push(eq(refMiddleSchool.isNonSelective, isNonSelective === 'true'));
    }

    conditions.push(eq(refMiddleSchool.isActive, true));

    const middleSchools = await db
      .select()
      .from(refMiddleSchool)
      .where(conditions.length > 0 ? sql.join(conditions, sql` AND `) : undefined)
      .orderBy(refMiddleSchool.name);

    // 关联区县信息
    const districtIds = [...new Set(middleSchools.map(ms => ms.districtId))];
    const districts = await db
      .select()
      .from(refDistrict)
      .where(sql`${refDistrict.id} = ANY(${districtIds})`);

    const districtMap = new Map(districts.map(d => [d.id, d.name]));

    const response: MiddleSchoolsResponse = {
      middleSchools: middleSchools.map((ms) => ({
        id: ms.id,
        code: ms.code ?? undefined,
        name: ms.name,
        shortName: ms.shortName ?? undefined,
        districtId: ms.districtId,
        districtName: districtMap.get(ms.districtId),
        isNonSelective: ms.isNonSelective,
      })),
    };

    return reply.code(200).send(response);
  });

  /**
   * 获取历年分数线
   */
  fastify.get<{
    Querystring: HistoryScoresParams;
  }>('/history-scores', async (request, reply) => {
    const { districtId, schoolId, year, batch } = request.query;

    if (!districtId) {
      throw new BadRequestError('缺少区县ID');
    }

    // TODO: 实现历年分数线查询
    const response: HistoryScoresResponse = {
      scores: [],
    };

    return reply.code(200).send(response);
  });

  /**
   * 获取各区中考人数
   */
  fastify.get<{
    Querystring: { year?: string };
  }>('/district-exam-count', async (request, reply) => {
    const db = getDb();
    const { year = '2025' } = request.query;
    const yearNum = parseInt(year);

    const counts = await db
      .select()
      .from(refDistrictExamCount)
      .where(eq(refDistrictExamCount.year, yearNum));

    // 关联区县信息
    const districtIds = [...new Set(counts.map(c => c.districtId))];
    const districts = await db
      .select()
      .from(refDistrict)
      .where(sql`${refDistrict.id} = ANY(${districtIds})`);

    const districtMap = new Map(districts.map(d => [d.id, d]));

    const response: DistrictExamCountResponse = {
      year: yearNum,
      districts: counts.map((c) => {
        const district = districtMap.get(c.districtId);
        return {
          districtId: c.districtId,
          districtName: district?.name || '',
          examCount: c.examCount,
        };
      }),
    };

    return reply.code(200).send(response);
  });
}
