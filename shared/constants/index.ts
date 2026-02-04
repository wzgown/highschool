/**
 * 上海中考招生模拟系统 - 常量定义
 *
 * 这些数据是枚举类型，适合作为代码常量，不适合存储在数据库中。
 */

// =============================================================================
// 学校办别 (SchoolNature)
// =============================================================================
export enum SchoolNature {
  PUBLIC = 'PUBLIC',           // 公办
  PRIVATE = 'PRIVATE',         // 民办
  COOPERATION = 'COOPERATION', // 中外合作
}

export const SchoolNatureMap = {
  [SchoolNature.PUBLIC]: '公办',
  [SchoolNature.PRIVATE]: '民办',
  [SchoolNature.COOPERATION]: '中外合作',
} as const;

// =============================================================================
// 学校类型 (SchoolType)
// =============================================================================
export enum SchoolType {
  CITY_MODEL = 'CITY_MODEL',           // 市实验性示范性高中
  CITY_FEATURED = 'CITY_FEATURED',     // 市特色普通高中
  CITY_POLICY = 'CITY_POLICY',         // 享受市实验性示范性高中招生政策高中
  DISTRICT_MODEL = 'DISTRICT_MODEL',   // 区实验性示范性高中
  DISTRICT_FEATURED = 'DISTRICT_FEATURED', // 区特色普通高中
  GENERAL = 'GENERAL',                 // 一般高中
  MUNICIPAL = 'MUNICIPAL',             // 委属市实验性示范性高中
}

export const SchoolTypeMap = {
  [SchoolType.CITY_MODEL]: '市实验性示范性高中',
  [SchoolType.CITY_FEATURED]: '市特色普通高中',
  [SchoolType.CITY_POLICY]: '享受市实验性示范性高中招生政策高中',
  [SchoolType.DISTRICT_MODEL]: '区实验性示范性高中',
  [SchoolType.DISTRICT_FEATURED]: '区特色普通高中',
  [SchoolType.GENERAL]: '一般高中',
  [SchoolType.MUNICIPAL]: '委属市实验性示范性高中',
} as const;

// =============================================================================
// 寄宿情况 (BoardingType)
// =============================================================================
export enum BoardingType {
  FULL = 'FULL',         // 全部寄宿
  PARTIAL = 'PARTIAL',   // 部分寄宿
  NONE = 'NONE',         // 无寄宿
}

export const BoardingTypeMap = {
  [BoardingType.FULL]: '全部寄宿',
  [BoardingType.PARTIAL]: '部分寄宿',
  [BoardingType.NONE]: '无寄宿',
} as const;

// =============================================================================
// 招生批次 (AdmissionBatch)
// =============================================================================
export enum AdmissionBatch {
  AUTONOMOUS = 'AUTONOMOUS',           // 自主招生录取
  QUOTA_DISTRICT = 'QUOTA_DISTRICT',   // 名额分配到区
  QUOTA_SCHOOL = 'QUOTA_SCHOOL',       // 名额分配到校
  UNIFIED_1_15 = 'UNIFIED_1_15',       // 统一招生1-15志愿
  UNIFIED_CONSULT = 'UNIFIED_CONSULT', // 统一招生征求志愿
}

export const AdmissionBatchMap = {
  [AdmissionBatch.AUTONOMOUS]: '自主招生录取',
  [AdmissionBatch.QUOTA_DISTRICT]: '名额分配到区',
  [AdmissionBatch.QUOTA_SCHOOL]: '名额分配到校',
  [AdmissionBatch.UNIFIED_1_15]: '统一招生1-15志愿',
  [AdmissionBatch.UNIFIED_CONSULT]: '统一招生征求志愿',
} as const;

// =============================================================================
// 考试科目 (Subject)
// =============================================================================
export enum Subject {
  CHINESE = 'chinese',               // 语文
  MATH = 'math',                     // 数学
  FOREIGN = 'foreign',               // 外语
  INTEGRATED = 'integrated',         // 综合测试
  ETHICS = 'ethics',                 // 道德与法治
  HISTORY = 'history',               // 历史
  PE = 'pe',                         // 体育与健身
  COMPREHENSIVE_QUALITY = 'comprehensive_quality', // 综合素质评价
}

export const SubjectMap = {
  [Subject.CHINESE]: '语文',
  [Subject.MATH]: '数学',
  [Subject.FOREIGN]: '外语',
  [Subject.INTEGRATED]: '综合测试',
  [Subject.ETHICS]: '道德与法治',
  [Subject.HISTORY]: '历史',
  [Subject.PE]: '体育与健身',
  [Subject.COMPREHENSIVE_QUALITY]: '综合素质评价',
} as const;

export interface SubjectInfo {
  code: Subject;
  name: string;
  maxScore: number;
  description: string;
  displayOrder: number;
}

export const SubjectList: SubjectInfo[] = [
  {
    code: Subject.CHINESE,
    name: SubjectMap[Subject.CHINESE],
    maxScore: 150,
    description: '闭卷笔试',
    displayOrder: 1,
  },
  {
    code: Subject.MATH,
    name: SubjectMap[Subject.MATH],
    maxScore: 150,
    description: '闭卷笔试',
    displayOrder: 2,
  },
  {
    code: Subject.FOREIGN,
    name: SubjectMap[Subject.FOREIGN],
    maxScore: 150,
    description: '笔试140分（含听力25分）+ 听说测试10分',
    displayOrder: 3,
  },
  {
    code: Subject.INTEGRATED,
    name: SubjectMap[Subject.INTEGRATED],
    maxScore: 150,
    description: '物理70分 + 化学50分 + 跨学科案例分析15分 + 物理实验操作10分 + 化学实验操作5分',
    displayOrder: 4,
  },
  {
    code: Subject.ETHICS,
    name: SubjectMap[Subject.ETHICS],
    maxScore: 60,
    description: '统一考试30分（开卷笔试）+ 日常考核30分',
    displayOrder: 5,
  },
  {
    code: Subject.HISTORY,
    name: SubjectMap[Subject.HISTORY],
    maxScore: 60,
    description: '统一考试30分（开卷笔试）+ 日常考核30分',
    displayOrder: 6,
  },
  {
    code: Subject.PE,
    name: SubjectMap[Subject.PE],
    maxScore: 30,
    description: '统一测试15分 + 日常考核15分',
    displayOrder: 7,
  },
  {
    code: Subject.COMPREHENSIVE_QUALITY,
    name: SubjectMap[Subject.COMPREHENSIVE_QUALITY],
    maxScore: 50,
    description: '仅名额分配批次计入，合格即赋50分',
    displayOrder: 8,
  },
];

export const getSubjectByCode = (code: Subject): SubjectInfo | undefined => {
  return SubjectList.find((s) => s.code === code);
};

export const getSubjectMaxScore = (code: Subject): number => {
  const subject = getSubjectByCode(code);
  return subject?.maxScore || 0;
};

// =============================================================================
// 导出所有常量
// =============================================================================
export default {
  SchoolNature,
  SchoolNatureMap,
  SchoolType,
  SchoolTypeMap,
  BoardingType,
  BoardingTypeMap,
  AdmissionBatch,
  AdmissionBatchMap,
  Subject,
  SubjectMap,
  SubjectList,
  getSubjectByCode,
  getSubjectMaxScore,
};
