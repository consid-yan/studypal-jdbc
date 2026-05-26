-- StudyPal triggers.
-- Run after schema.sql.
--
-- The current 3NF schema does not store derived study-session duration in
-- study_session. Duration is calculated in views and queries from start_time
-- and end_time, so no duration-maintenance trigger is required.

USE studypal;

DROP TRIGGER IF EXISTS prevent_main_task_update;
DROP TRIGGER IF EXISTS prevent_main_task_delete;
DROP TRIGGER IF EXISTS calculate_study_session_duration_before_insert;
DROP TRIGGER IF EXISTS calculate_study_session_duration_before_update;
