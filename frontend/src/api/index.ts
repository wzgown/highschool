/**
 * API module exports
 * Central export point for all API functions and types
 */

// Connect-RPC clients
export { referenceClient, candidateClient } from './connect';

// Candidate API
export {
  submitAnalysis,
  getAnalysisResult,
  getHistory,
  deleteHistory,
  deleteAllHistory,
} from './candidate';
export type {
  AnalysisResult,
  HistorySummary,
  CandidateInfo,
  CandidateScores,
  RankingInfo,
  Volunteers,
  SubmitAnalysisRequest,
} from './candidate';

// Reference API
export {
  getDistricts,
  getMiddleSchools,
  getSchools,
  getSchoolDetail,
  getHistoryScores,
  getSchoolsWithQuotaDistrict,
  getSchoolsWithQuotaSchool,
  getSchoolsForUnified,
  getVolunteerRecommendations,
} from './reference';
export type {
  District,
  MiddleSchool,
  School,
  SchoolDetail,
  HistoryScore,
  SchoolWithQuota,
  SchoolForUnified,
  RecommendedSchool,
  ScoreConversion,
} from './reference';
export { ExamType } from './reference';

// Transport utilities
export { createUniFetch, getPlatformFetch, createTransportConfig } from './transport';
export type { TransportOptions, TransportResponse } from './transport';
