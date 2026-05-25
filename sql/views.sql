-- StudyPal reporting views.
-- Run after schema.sql.

USE studypal;

CREATE OR REPLACE VIEW student_task_priority_view AS
SELECT
    sst.student_sub_task_id,
    sst.student_id,
    u.full_name AS student_name,
    st.template_id,
    mt.main_task_id,
    c.course_code,
    c.course_name,
    mt.title AS main_task_title,
    sst.title AS sub_task_title,
    sst.status,
    mt.importance_level,
    COALESCE(sst.planned_end_time, mt.deadline) AS due_time,
    st.estimated_hours,
    DATEDIFF(COALESCE(sst.planned_end_time, mt.deadline), NOW()) AS days_remaining,
    CASE
        WHEN sst.status = 'COMPLETED' THEN 'DONE'
        WHEN sst.status = 'CANCELLED' THEN 'CANCELLED'
        WHEN COALESCE(sst.planned_end_time, mt.deadline) IS NULL THEN 'UNSCHEDULED'
        WHEN DATEDIFF(COALESCE(sst.planned_end_time, mt.deadline), NOW()) <= 1 THEN 'URGENT'
        WHEN DATEDIFF(COALESCE(sst.planned_end_time, mt.deadline), NOW()) <= 3 THEN 'SOON'
        ELSE 'NORMAL'
    END AS urgency_level,
    CASE
        WHEN sst.status = 'COMPLETED' THEN 1000
        WHEN sst.status = 'CANCELLED' THEN 999
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
                COALESCE(DATEDIFF(COALESCE(sst.planned_end_time, mt.deadline), NOW()), 90)
            )
    END AS priority_score
FROM student_sub_task sst
JOIN sub_task_template st ON sst.template_id = st.template_id
JOIN main_task mt ON st.main_task_id = mt.main_task_id
JOIN course c ON mt.course_id = c.course_id
JOIN user u ON sst.student_id = u.user_id;

CREATE OR REPLACE VIEW main_task_progress_view AS
SELECT
    mt.main_task_id,
    sst.student_id,
    u.full_name AS student_name,
    c.course_code,
    c.course_name,
    mt.title,
    mt.deadline,
    mt.importance_level,
    COUNT(sst.student_sub_task_id) AS total_student_sub_tasks,
    SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_student_sub_tasks,
    ROUND(
        CASE
            WHEN COUNT(sst.student_sub_task_id) = 0 THEN NULL
            ELSE SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END)
                / COUNT(sst.student_sub_task_id) * 100
        END,
        2
    ) AS completion_percentage,
    CASE
        WHEN COUNT(sst.student_sub_task_id) = 0 THEN 'Not generated'
        ELSE 'Calculated'
    END AS progress_status,
    COALESCE(SUM(st.estimated_hours), 0) AS total_estimated_hours,
    COALESCE(SUM(CASE WHEN sst.status = 'COMPLETED' THEN st.estimated_hours ELSE 0 END), 0)
        AS completed_estimated_hours
FROM main_task mt
JOIN course c ON mt.course_id = c.course_id
JOIN sub_task_template st ON mt.main_task_id = st.main_task_id
JOIN student_sub_task sst ON st.template_id = sst.template_id
JOIN user u ON sst.student_id = u.user_id
GROUP BY
    mt.main_task_id,
    sst.student_id,
    u.full_name,
    c.course_code,
    c.course_name,
    mt.title,
    mt.deadline,
    mt.importance_level;

CREATE OR REPLACE VIEW study_efficiency_view AS
SELECT
    sst.student_sub_task_id,
    sst.student_id,
    u.full_name AS student_name,
    mt.main_task_id,
    mt.title AS main_task_title,
    sst.title AS sub_task_title,
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
FROM student_sub_task sst
JOIN sub_task_template st ON sst.template_id = st.template_id
JOIN main_task mt ON st.main_task_id = mt.main_task_id
JOIN user u ON sst.student_id = u.user_id
LEFT JOIN study_session ss ON sst.student_sub_task_id = ss.student_sub_task_id
GROUP BY
    sst.student_sub_task_id,
    sst.student_id,
    u.full_name,
    mt.main_task_id,
    mt.title,
    sst.title,
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

CREATE OR REPLACE VIEW course_workload_view AS
SELECT
    c.course_id,
    c.course_code,
    c.course_name,
    u.full_name AS lecturer_name,
    COUNT(DISTINCT e.student_id) AS enrolled_student_count,
    COUNT(DISTINCT mt.main_task_id) AS main_task_count,
    COUNT(DISTINCT st.template_id) AS template_count,
    COUNT(DISTINCT sst.student_sub_task_id) AS student_sub_task_count
FROM course c
JOIN user u ON c.lecturer_id = u.user_id
LEFT JOIN enrollment e ON c.course_id = e.course_id
LEFT JOIN main_task mt ON c.course_id = mt.course_id
LEFT JOIN sub_task_template st ON mt.main_task_id = st.main_task_id
LEFT JOIN student_sub_task sst ON st.template_id = sst.template_id
GROUP BY
    c.course_id,
    c.course_code,
    c.course_name,
    u.full_name;
