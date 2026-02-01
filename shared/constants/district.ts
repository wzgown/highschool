/**
 * 区县相关常量
 * 前后端共享
 */

import { DistrictCode } from '../types/school';

/**
 * 上海16区信息
 */
export const SHANGHAI_DISTRICTS = [
  { id: 1, code: DistrictCode.HUANGPU, name: '黄浦区', nameEn: 'Huangpu', displayOrder: 1 },
  { id: 2, code: DistrictCode.XUHUI, name: '徐汇区', nameEn: 'Xuhui', displayOrder: 2 },
  { id: 3, code: DistrictCode.CHANGNING, name: '长宁区', nameEn: 'Changning', displayOrder: 3 },
  { id: 4, code: DistrictCode.JINGAN, name: '静安区', nameEn: 'Jingan', displayOrder: 4 },
  { id: 5, code: DistrictCode.PUTUO, name: '普陀区', nameEn: 'Putuo', displayOrder: 5 },
  { id: 6, code: DistrictCode.HONGKOU, name: '虹口区', nameEn: 'Hongkou', displayOrder: 6 },
  { id: 7, code: DistrictCode.YANGPU, name: '杨浦区', nameEn: 'Yangpu', displayOrder: 7 },
  { id: 8, code: DistrictCode.MINHANG, name: '闵行区', nameEn: 'Minhang', displayOrder: 8 },
  { id: 9, code: DistrictCode.BAOSHAN, name: '宝山区', nameEn: 'Baoshan', displayOrder: 9 },
  { id: 10, code: DistrictCode.JIADING, name: '嘉定区', nameEn: 'Jiading', displayOrder: 10 },
  { id: 11, code: DistrictCode.PUDONG, name: '浦东新区', nameEn: 'Pudong New Area', displayOrder: 11 },
  { id: 12, code: DistrictCode.JINSHAN, name: '金山区', nameEn: 'Jinshan', displayOrder: 12 },
  { id: 13, code: DistrictCode.SONGJIANG, name: '松江区', nameEn: 'Songjiang', displayOrder: 13 },
  { id: 14, code: DistrictCode.QINGPU, name: '青浦区', nameEn: 'Qingpu', displayOrder: 14 },
  { id: 15, code: DistrictCode.FENGXIAN, name: '奉贤区', nameEn: 'Fengxian', displayOrder: 15 },
  { id: 16, code: DistrictCode.CHONGMING, name: '崇明区', nameEn: 'Chongming', displayOrder: 16 },
  { id: 17, code: DistrictCode.SHANGHAI, name: '上海市', nameEn: 'Shanghai', displayOrder: 0 },
] as const;

/**
 * 委属市实验性示范性高中（6所）
 */
export const MUNICIPAL_SCHOOLS = [
  { code: '042032', name: '上海市上海中学', districtId: 1 },
  { code: '102056', name: '上海交通大学附属中学', districtId: 17 },
  { code: '102057', name: '复旦大学附属中学', districtId: 17 },
  { code: '152003', name: '华东师范大学第二附属中学', districtId: 17 },
  { code: '152006', name: '上海师范大学附属中学', districtId: 17 },
  { code: '155001', name: '上海市实验学校', districtId: 11 },
] as const;

/**
 * 2025年各区中考人数
 */
export const EXAM_COUNT_2025: Record<DistrictCode, number> = {
  [DistrictCode.HUANGPU]: 3800,
  [DistrictCode.XUHUI]: 6400,
  [DistrictCode.CHANGNING]: 3600,
  [DistrictCode.JINGAN]: 4700,
  [DistrictCode.PUTUO]: 5000,
  [DistrictCode.HONGKOU]: 4200,
  [DistrictCode.YANGPU]: 5600,
  [DistrictCode.MINHANG]: 9500,
  [DistrictCode.BAOSHAN]: 7100,
  [DistrictCode.JIADING]: 5800,
  [DistrictCode.PUDONG]: 25000,
  [DistrictCode.JINSHAN]: 4200,
  [DistrictCode.SONGJIANG]: 7200,
  [DistrictCode.QINGPU]: 5400,
  [DistrictCode.FENGXIAN]: 5800,
  [DistrictCode.CHONGMING]: 3800,
  [DistrictCode.SHANGHAI]: 0,
} as const;

/**
 * 2024年各区中考人数（估算）
 */
export const EXAM_COUNT_2024: Record<DistrictCode, number> = {
  [DistrictCode.HUANGPU]: 3700,
  [DistrictCode.XUHUI]: 6200,
  [DistrictCode.CHANGNING]: 3500,
  [DistrictCode.JINGAN]: 4600,
  [DistrictCode.PUTUO]: 4900,
  [DistrictCode.HONGKOU]: 4100,
  [DistrictCode.YANGPU]: 5500,
  [DistrictCode.MINHANG]: 9200,
  [DistrictCode.BAOSHAN]: 6900,
  [DistrictCode.JIADING]: 5600,
  [DistrictCode.PUDONG]: 24000,
  [DistrictCode.JINSHAN]: 4100,
  [DistrictCode.SONGJIANG]: 7000,
  [DistrictCode.QINGPU]: 5200,
  [DistrictCode.FENGXIAN]: 5600,
  [DistrictCode.CHONGMING]: 3700,
  [DistrictCode.SHANGHAI]: 0,
} as const;

/**
 * 区代码到区ID的映射
 */
export const DISTRICT_CODE_TO_ID: Record<DistrictCode, number> = SHANGHAI_DISTRICTS.reduce(
  (acc, district) => ({ ...acc, [district.code]: district.id }),
  {} as Record<DistrictCode, number>
);

/**
 * 区ID到区代码的映射
 */
export const DISTRICT_ID_TO_CODE: Record<number, DistrictCode> = SHANGHAI_DISTRICTS.reduce(
  (acc, district) => ({ ...acc, [district.id]: district.code }),
  {} as Record<number, DistrictCode>
);

/**
 * 区ID到区名称的映射
 */
export const DISTRICT_ID_TO_NAME: Record<number, string> = SHANGHAI_DISTRICTS.reduce(
  (acc, district) => ({ ...acc, [district.id]: district.name }),
  {} as Record<number, string>
);

/**
 * 根据区ID获取区信息
 */
export function getDistrictById(id: number) {
  return SHANGHAI_DISTRICTS.find(d => d.id === id);
}

/**
 * 根据区代码获取区信息
 */
export function getDistrictByCode(code: DistrictCode | string) {
  return SHANGHAI_DISTRICTS.find(d => d.code === code);
}

/**
 * 根据区ID获取区名称
 */
export function getDistrictNameById(id: number): string {
  return DISTRICT_ID_TO_NAME[id] || '未知';
}

/**
 * 根据区ID获取区代码
 */
export function getDistrictCodeById(id: number): DistrictCode | undefined {
  return DISTRICT_ID_TO_CODE[id];
}

/**
 * 获取区中考人数
 */
export function getExamCount(districtId: number, year: number): number {
  const counts = year === 2025 ? EXAM_COUNT_2025 : EXAM_COUNT_2024;
  const code = getDistrictCodeById(districtId);
  return code ? counts[code] || 0 : 0;
}

/**
 * 获取全市中考总人数
 */
export function getTotalExamCount(year: number): number {
  const counts = year === 2025 ? EXAM_COUNT_2025 : EXAM_COUNT_2024;
  return Object.values(counts).reduce((sum, count) => sum + count, 0);
}

/**
 * 判断是否为委属学校
 */
export function isMunicipalSchool(schoolCode: string): boolean {
  return MUNICIPAL_SCHOOLS.some(s => s.code === schoolCode);
}

/**
 * 获取委属学校列表
 */
export function getMunicipalSchools() {
  return MUNICIPAL_SCHOOLS;
}
