import type { CandidateForm } from '@/stores/candidate';

export function validateCandidateForm(form: CandidateForm): { valid: boolean; message?: string } {
  // 验证基本信息
  if (!form.districtId) {
    return { valid: false, message: '请选择所属区县' };
  }
  if (!form.middleSchoolId) {
    return { valid: false, message: '请选择初中学校' };
  }
  
  // 验证成绩
  if (form.scores.total <= 0 || form.scores.total > 750) {
    return { valid: false, message: '请输入有效的中考总分（0-750分）' };
  }
  
  // 验证各科成绩
  const { chinese, math, foreign, integrated, ethics, history, pe } = form.scores;
  const calculatedTotal = chinese + math + foreign + integrated + ethics + history + pe;
  if (calculatedTotal !== form.scores.total) {
    return { valid: false, message: `各科成绩合计为 ${calculatedTotal} 分，与总分不符` };
  }
  
  // 验证排名
  if (form.ranking.rank <= 0) {
    return { valid: false, message: '请输入有效的校内排名' };
  }
  if (form.ranking.totalStudents <= 0) {
    return { valid: false, message: '请输入有效的校内总人数' };
  }
  if (form.ranking.rank > form.ranking.totalStudents) {
    return { valid: false, message: '校内排名不能大于总人数' };
  }
  
  // 验证志愿
  const hasVolunteers = 
    form.volunteers.quotaDistrict !== null ||
    form.volunteers.quotaSchool.length > 0 ||
    form.volunteers.unified.length > 0;
  
  if (!hasVolunteers) {
    return { valid: false, message: '请至少填报一个志愿' };
  }
  
  return { valid: true };
}

export function getSubjectMaxScore(subject: string): number {
  const scores: Record<string, number> = {
    chinese: 150,
    math: 150,
    foreign: 150,
    integrated: 150,
    ethics: 60,
    history: 60,
    pe: 30,
  };
  return scores[subject] || 0;
}
