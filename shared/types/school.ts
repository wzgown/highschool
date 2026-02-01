/**
 * 学校相关类型定义
 * 前后端共享
 */

/**
 * 学校类型代码
 */
export enum SchoolTypeCode {
  /** 市实验性示范性高中 */
  CITY_MODEL = 'CITY_MODEL',
  /** 市特色普通高中 */
  CITY_FEATURED = 'CITY_FEATURED',
  /** 享受市实验性示范性高中招生政策高中 */
  CITY_POLICY = 'CITY_POLICY',
  /** 区实验性示范性高中 */
  DISTRICT_MODEL = 'DISTRICT_MODEL',
  /** 区特色普通高中 */
  DISTRICT_FEATURED = 'DISTRICT_FEATURED',
  /** 一般高中 */
  GENERAL = 'GENERAL',
  /** 委属市实验性示范性高中 */
  MUNICIPAL = 'MUNICIPAL',
}

/**
 * 学校办别代码
 */
export enum SchoolNatureCode {
  /** 公办 */
  PUBLIC = 'PUBLIC',
  /** 民办 */
  PRIVATE = 'PRIVATE',
  /** 中外合作 */
  COOPERATION = 'COOPERATION',
}

/**
 * 寄宿情况代码
 */
export enum BoardingTypeCode {
  /** 全部寄宿 */
  FULL = 'FULL',
  /** 部分寄宿 */
  PARTIAL = 'PARTIAL',
  /** 无寄宿 */
  NONE = 'NONE',
}

/**
 * 招生批次代码
 */
export enum AdmissionBatchCode {
  /** 自主招生录取 */
  AUTONOMOUS = 'AUTONOMOUS',
  /** 名额分配到区 */
  QUOTA_DISTRICT = 'QUOTA_DISTRICT',
  /** 名额分配到校 */
  QUOTA_SCHOOL = 'QUOTA_SCHOOL',
  /** 统一招生1-15志愿 */
  UNIFIED_1_15 = 'UNIFIED_1_15',
  /** 统一招生征求志愿 */
  UNIFIED_CONSULT = 'UNIFIED_CONSULT',
}

/**
 * 区县代码
 */
export enum DistrictCode {
  /** 黄浦区 */
  HUANGPU = 'HP',
  /** 徐汇区 */
  XUHUI = 'XH',
  /** 长宁区 */
  CHANGNING = 'CN',
  /** 静安区 */
  JINGAN = 'JA',
  /** 普陀区 */
  PUTUO = 'PT',
  /** 虹口区 */
  HONGKOU = 'HK',
  /** 杨浦区 */
  YANGPU = 'YP',
  /** 闵行区 */
  MINHANG = 'MH',
  /** 宝山区 */
  BAOSHAN = 'BS',
  /** 嘉定区 */
  JIADING = 'JD',
  /** 浦东新区 */
  PUDONG = 'PD',
  /** 金山区 */
  JINSHAN = 'JS',
  /** 松江区 */
  SONGJIANG = 'SJ',
  /** 青浦区 */
  QINGPU = 'QP',
  /** 奉贤区 */
  FENGXIAN = 'FX',
  /** 崇明区 */
  CHONGMING = 'CM',
  /** 上海市（委属学校） */
  SHANGHAI = 'SH',
}

/**
 * 区县信息
 */
export interface District {
  /** 区ID */
  id: number;
  /** 区代码 */
  code: DistrictCode | string;
  /** 区名称 */
  name: string;
  /** 区英文名称 */
  nameEn?: string;
  /** 显示顺序 */
  displayOrder: number;
}

/**
 * 学校类型信息
 */
export interface SchoolType {
  /** 类型ID */
  id: number;
  /** 类型代码 */
  code: SchoolTypeCode | string;
  /** 类型名称 */
  name: string;
  /** 类型描述 */
  description?: string;
  /** 显示顺序 */
  displayOrder: number;
}

/**
 * 学校办别信息
 */
export interface SchoolNature {
  /** 办别ID */
  id: number;
  /** 办别代码 */
  code: SchoolNatureCode | string;
  /** 办别名称 */
  name: string;
  /** 显示顺序 */
  displayOrder: number;
}

/**
 * 寄宿情况信息
 */
export interface BoardingType {
  /** 寄宿类型ID */
  id: number;
  /** 寄宿类型代码 */
  code: BoardingTypeCode | string;
  /** 寄宿类型名称 */
  name: string;
  /** 寄宿类型描述 */
  description?: string;
  /** 显示顺序 */
  displayOrder: number;
}

/**
 * 招生批次信息
 */
export interface AdmissionBatch {
  /** 批次ID */
  id: number;
  /** 批次代码 */
  code: AdmissionBatchCode | string;
  /** 批次名称 */
  name: string;
  /** 批次描述 */
  description?: string;
  /** 显示顺序 */
  displayOrder: number;
}

/**
 * 学校信息
 */
export interface School {
  /** 学校ID */
  id: number;
  /** 学校招生代码（6位） */
  code: string;
  /** 学校全称 */
  fullName: string;
  /** 学校简称 */
  shortName?: string;
  /** 所属区ID */
  districtId: number;
  /** 所属区 */
  district?: District;
  /** 办别ID */
  schoolNatureId: number;
  /** 办别 */
  schoolNature?: SchoolNature;
  /** 学校类型ID */
  schoolTypeId?: number;
  /** 学校类型 */
  schoolType?: SchoolType;
  /** 寄宿情况ID */
  boardingTypeId?: number;
  /** 寄宿情况 */
  boardingType?: BoardingType;
  /** 是否含国际课程班 */
  hasInternationalCourse?: boolean;
  /** 备注 */
  remarks?: string;
  /** 数据年份 */
  dataYear: number;
  /** 是否启用 */
  isActive: boolean;
}

/**
 * 初中学校信息
 */
export interface MiddleSchool {
  /** 初中学校ID */
  id: number;
  /** 学校代码 */
  code?: string;
  /** 学校全称 */
  name: string;
  /** 学校简称 */
  shortName?: string;
  /** 所属区ID */
  districtId: number;
  /** 所属区 */
  district?: District;
  /** 办别ID */
  schoolNatureId?: number;
  /** 办别 */
  schoolNature?: SchoolNature;
  /** 是否不选择生源初中（名额分配到校填报资格） */
  isNonSelective: boolean;
  /** 数据年份 */
  dataYear: number;
  /** 是否启用 */
  isActive: boolean;
}

/**
 * 名额分配到区招生计划
 */
export interface QuotaAllocationDistrict {
  /** 计划ID */
  id: number;
  /** 招生年份 */
  year: number;
  /** 学校ID */
  schoolId: number;
  /** 学校代码 */
  schoolCode: string;
  /** 学校 */
  school?: School;
  /** 分配区ID */
  districtId: number;
  /** 分配区 */
  district?: District;
  /** 计划数 */
  quotaCount: number;
  /** 数据年份 */
  dataYear: number;
}

/**
 * 名额分配到校招生计划
 */
export interface QuotaAllocationSchool {
  /** 计划ID */
  id: number;
  /** 招生年份 */
  year: number;
  /** 所属区ID */
  districtId: number;
  /** 所属区 */
  district?: District;
  /** 高中学校ID */
  highSchoolId: number;
  /** 高中学校代码 */
  highSchoolCode: string;
  /** 高中学校 */
  highSchool?: School;
  /** 初中学校ID */
  middleSchoolId?: number;
  /** 初中学校名称 */
  middleSchoolName?: string;
  /** 初中学校 */
  middleSchool?: MiddleSchool;
  /** 分配到该校的计划数 */
  quotaCount: number;
  /** 数据年份 */
  dataYear: number;
}

/**
 * 历史录取分数线 - 名额分配到区
 */
export interface AdmissionScoreQuotaDistrict {
  /** 记录ID */
  id: number;
  /** 招生年份 */
  year: number;
  /** 录取区ID */
  districtId: number;
  /** 学校ID */
  schoolId?: number;
  /** 学校名称 */
  schoolName: string;
  /** 录取最低分（总分800分） */
  minScore: number;
  /** 是否同分优待 */
  isTiePreferred?: boolean;
  /** 语数外三科合计 */
  chineseMathForeignSum?: number;
  /** 数学成绩 */
  mathScore?: number;
  /** 语文成绩 */
  chineseScore?: number;
  /** 综合测试成绩 */
  integratedTestScore?: number;
  /** 综合素质评价成绩（默认50分） */
  comprehensiveQualityScore?: number;
  /** 数据年份 */
  dataYear: number;
}

/**
 * 历史录取分数线 - 名额分配到校
 */
export interface AdmissionScoreQuotaSchool {
  /** 记录ID */
  id: number;
  /** 招生年份 */
  year: number;
  /** 录取区ID */
  districtId: number;
  /** 高中学校ID */
  schoolId?: number;
  /** 高中学校名称 */
  schoolName: string;
  /** 初中学校名称 */
  middleSchoolName?: string;
  /** 录取最低分（总分800分） */
  minScore: number;
  /** 是否同分优待 */
  isTiePreferred?: boolean;
  /** 语数外三科合计 */
  chineseMathForeignSum?: number;
  /** 数学成绩 */
  mathScore?: number;
  /** 语文成绩 */
  chineseScore?: number;
  /** 综合测试成绩 */
  integratedTestScore?: number;
  /** 综合素质评价成绩（默认50分） */
  comprehensiveQualityScore?: number;
  /** 数据年份 */
  dataYear: number;
}

/**
 * 历史录取分数线 - 统一招生1-15志愿
 */
export interface AdmissionScoreUnified {
  /** 记录ID */
  id: number;
  /** 招生年份 */
  year: number;
  /** 录取区ID */
  districtId: number;
  /** 学校ID */
  schoolId?: number;
  /** 学校名称 */
  schoolName: string;
  /** 投档分数线（总分750分） */
  minScore: number;
  /** 语数外三科合计 */
  chineseMathForeignSum?: number;
  /** 数学成绩 */
  mathScore?: number;
  /** 语文成绩 */
  chineseScore?: number;
  /** 数据年份 */
  dataYear: number;
}

/**
 * 学校筛选条件
 */
export interface SchoolFilter {
  /** 区ID */
  districtId?: number;
  /** 学校类型ID */
  schoolTypeId?: number;
  /** 办别ID */
  schoolNatureId?: number;
  /** 是否含国际课程班 */
  hasInternationalCourse?: boolean;
  /** 搜索关键词 */
  keyword?: string;
}

/**
 * 学校排序方式
 */
export enum SchoolSortBy {
  /** 按代码排序 */
  CODE = 'code',
  /** 按名称排序 */
  NAME = 'name',
}

/**
 * 学校列表响应
 */
export interface SchoolListResponse {
  /** 学校列表 */
  schools: School[];
  /** 总数 */
  total: number;
  /** 当前页 */
  page: number;
  /** 每页数量 */
  pageSize: number;
}

/**
 * 志愿选项（用于前端选择）
 */
export interface VolunteerOption {
  /** 学校ID */
  value: number;
  /** 学校名称 */
  label: string;
  /** 学校代码 */
  code: string;
  /** 所属区 */
  district: string;
  /** 学校类型 */
  schoolType?: string;
  /** 是否名额分配到区学校 */
  isQuotaDistrictSchool?: boolean;
  /** 历年分数线 */
  historyScores?: {
    year: number;
    minScore: number;
    batch: AdmissionBatchCode | string;
  }[];
}

/**
 * 获取学校的志愿选项标签
 */
export function getVolunteerOptionLabel(school: School): string {
  return `${school.code} ${school.shortName || school.fullName}`;
}

/**
 * 判断学校是否支持名额分配到区
 */
export function isQuotaDistrictSchool(school: School): boolean {
  return school.schoolType?.code === SchoolTypeCode.CITY_MODEL ||
    school.schoolType?.code === SchoolTypeCode.MUNICIPAL ||
    school.schoolType?.code === SchoolTypeCode.CITY_POLICY;
}
