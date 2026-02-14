-- =============================================================================
-- Migration: Add student count columns to ref_middle_school
-- =============================================================================

-- Add student count columns
ALTER TABLE ref_middle_school
ADD COLUMN IF NOT EXISTS exact_student_count INTEGER,
ADD COLUMN IF NOT EXISTS estimated_student_count INTEGER;

COMMENT ON COLUMN ref_middle_school.exact_student_count IS '准确考生人数（从ETL数据解析）';
COMMENT ON COLUMN ref_middle_school.estimated_student_count IS '估算考生人数（基于名额分配占比）';

-- Create index for student count queries
CREATE INDEX IF NOT EXISTS idx_middle_school_student_count ON ref_middle_school(district_id, data_year) WHERE exact_student_count IS NOT NULL OR estimated_student_count IS NOT NULL;
