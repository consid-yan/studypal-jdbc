-- StudyPal reporting views.
-- Run after schema.sql.

USE studypal;

CREATE OR REPLACE VIEW task_priority_view AS
SELECT
    st.sub_task_id,
    mt.main_task_id,
    mt.student_id,
    c.course_code,
    c.course_name,
    mt.title AS main_task_title,
    st.title AS sub_task_title,
    st.status,
    mt.importance_level,
    COALESCE(st.planned_end_time, mt.deadline) AS due_time,
    st.estimated_hours,
    DATEDIFF(COALESCE(st.planned_end_time, mt.deadline), NOW()) AS days_remaining,
    CASE
        WHEN st.status = 'COMPLETED' THEN 'DONE'
        WHEN st.status = 'CANCELLED' THEN 'CANCELLED'
        WHEN COALESCE(st.planned_end_time, mt.deadline) IS NULL THEN 'UNSCHEDULED'
        WHEN DATEDIFF(COALESCE(st.planned_end_time, mt.deadline), NOW()) <= 1 THEN 'URGENT'
        WHEN DATEDIFF(COALESCE(st.planned_end_time, mt.deadline), NOW()) <= 3 THEN 'SOON'
        ELSE 'NORMAL'
    END AS urgency_level,
    CASE
        WHEN st.status = 'COMPLETED' THEN 1000
        WHEN st.status = 'CANCELLED' THEN 999
        ELSE
            (CASE mt.importance_level
                WHEN 'VERY_HIGH' THEN 1
                WHEN 'HIGH' THEN 2
                WHEN 'MEDIUM' THEN 3
                WHEN 'LOW' THEN 4
                WHEN 'VERY_LOW' THEN 5
            END) * 10
            + GREATEST(
                0,
                COALESCE(DATEDIFF(COALESCE(st.planned_end_time, mt.deadline), NOW()), 90)
            )
    END AS priority_score
FROM sub_task st
JOIN main_task mt ON st.main_task_id = mt.main_task_id
JOIN course c ON mt.course_id = c.course_id;

CREATE OR REPLACE VIEW main_task_progress_view AS
SELECT
    mt.main_task_id,
    mt.student_id,
    c.course_code,
    mt.title,
    mt.status,
    mt.deadline,
    COUNT(st.sub_task_id) AS total_sub_tasks,
    SUM(CASE WHEN st.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_sub_tasks,
    ROUND(
        CASE
            WHEN COUNT(st.sub_task_id) = 0 THEN 0
            ELSE SUM(CASE WHEN st.status = 'COMPLETED' THEN 1 ELSE 0 END)
                / COUNT(st.sub_task_id) * 100
        END,
        2
    ) AS completion_percentage,
    COALESCE(SUM(st.estimated_hours), 0) AS total_estimated_hours,
    COALESCE(SUM(CASE WHEN st.status = 'COMPLETED' THEN st.estimated_hours ELSE 0 END), 0)
        AS completed_estimated_hours
FROM main_task mt
JOIN course c ON mt.course_id = c.course_id
LEFT JOIN sub_task st ON mt.main_task_id = st.main_task_id
GROUP BY
    mt.main_task_id,
    mt.student_id,
    c.course_code,
    mt.title,
    mt.status,
    mt.deadline;

CREATE OR REPLACE VIEW study_efficiency_view AS
SELECT
    st.sub_task_id,
    mt.main_task_id,
    mt.student_id,
    mt.title AS main_task_title,
    st.title AS sub_task_title,
    st.estimated_hours,
    COALESCE(SUM(ss.duration_hours), 0) AS actual_hours,
    COALESCE(SUM(ss.duration_hours), 0) - COALESCE(st.estimated_hours, 0) AS time_overrun,
    CASE
        WHEN st.estimated_hours IS NULL THEN 'NO_ESTIMATE'
        WHEN COALESCE(SUM(ss.duration_hours), 0) = 0 THEN 'NOT_STARTED'
        WHEN COALESCE(SUM(ss.duration_hours), 0) <= st.estimated_hours * 0.8 THEN 'AHEAD'
        WHEN COALESCE(SUM(ss.duration_hours), 0) <= st.estimated_hours * 1.2 THEN 'ON_TRACK'
        ELSE 'OVERRUN'
    END AS efficiency_status
FROM sub_task st
JOIN main_task mt ON st.main_task_id = mt.main_task_id
LEFT JOIN study_session ss ON st.sub_task_id = ss.sub_task_id
GROUP BY
    st.sub_task_id,
    mt.main_task_id,
    mt.student_id,
    mt.title,
    st.title,
    st.estimated_hours;

CREATE OR REPLACE VIEW daily_study_stats_view AS
SELECT
    student_id,
    DATE(start_time) AS study_date,
    COUNT(study_session_id) AS session_count,
    SUM(duration_hours) AS total_study_hours,
    AVG(duration_hours) AS average_session_hours
FROM study_session
WHERE session_type = 'ACTUAL'
  AND duration_hours IS NOT NULL
GROUP BY student_id, DATE(start_time);

CREATE OR REPLACE VIEW task_dependency_chain_view AS
SELECT
    td.sub_task_id,
    st.title AS sub_task_title,
    td.depends_on_sub_task_id,
    dependency.title AS depends_on_title,
    dependency.status AS depends_on_status
FROM task_dependency td
JOIN sub_task st ON td.sub_task_id = st.sub_task_id
JOIN sub_task dependency ON td.depends_on_sub_task_id = dependency.sub_task_id;
