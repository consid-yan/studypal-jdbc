-- StudyPal query examples.
-- Run after schema.sql and, where noted, after views.sql.

USE studypal;

-- Courses for one student.
SELECT
    c.course_id,
    c.course_code,
    c.course_name,
    c.lecturer,
    e.enrollment_date
FROM enrollment e
JOIN course c ON e.course_id = c.course_id
WHERE e.student_id = 1
ORDER BY c.course_code;

-- Main tasks for one student.
SELECT
    mt.main_task_id,
    c.course_code,
    mt.title,
    mt.description,
    mt.deadline,
    mt.importance_level,
    mt.status,
    mt.created_at
FROM main_task mt
JOIN course c ON mt.course_id = c.course_id
WHERE mt.student_id = 1
ORDER BY mt.deadline ASC;

-- Sub-tasks for one main task.
SELECT
    st.sub_task_id,
    st.title,
    st.description,
    st.estimated_hours,
    st.planned_start_time,
    st.planned_end_time,
    st.status,
    st.completed_time
FROM sub_task st
WHERE st.main_task_id = 1
ORDER BY st.planned_start_time ASC;

-- Highest priority active tasks. Requires views.sql.
SELECT
    *
FROM task_priority_view
WHERE student_id = 1
  AND status IN ('TODO', 'IN_PROGRESS')
ORDER BY priority_score ASC
LIMIT 10;

-- Tasks planned to end in the next three days.
SELECT
    st.sub_task_id,
    mt.title AS main_task_title,
    st.title AS sub_task_title,
    st.planned_end_time AS due_time,
    DATEDIFF(st.planned_end_time, NOW()) AS days_remaining
FROM sub_task st
JOIN main_task mt ON st.main_task_id = mt.main_task_id
WHERE mt.student_id = 1
  AND st.status IN ('TODO', 'IN_PROGRESS')
  AND st.planned_end_time BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 3 DAY)
ORDER BY st.planned_end_time ASC;

-- Direct prerequisites for one sub-task.
SELECT
    td.depends_on_sub_task_id,
    st.title AS depends_on_title,
    st.status AS depends_on_status
FROM task_dependency td
JOIN sub_task st ON td.depends_on_sub_task_id = st.sub_task_id
WHERE td.sub_task_id = 4;

-- Tasks blocked by one sub-task.
SELECT
    td.sub_task_id,
    st.title AS blocked_task_title,
    st.status AS blocked_task_status
FROM task_dependency td
JOIN sub_task st ON td.sub_task_id = st.sub_task_id
WHERE td.depends_on_sub_task_id = 3;

-- Full recursive dependency chain for one sub-task.
WITH RECURSIVE dependency_chain AS (
    SELECT
        td.depends_on_sub_task_id AS task_id,
        st.title AS task_title,
        st.status AS task_status,
        1 AS dependency_level
    FROM task_dependency td
    JOIN sub_task st ON td.depends_on_sub_task_id = st.sub_task_id
    WHERE td.sub_task_id = 4
    UNION ALL
    SELECT
        td.depends_on_sub_task_id,
        st.title,
        st.status,
        dc.dependency_level + 1
    FROM task_dependency td
    JOIN dependency_chain dc ON td.sub_task_id = dc.task_id
    JOIN sub_task st ON td.depends_on_sub_task_id = st.sub_task_id
)
SELECT
    task_id,
    task_title,
    task_status,
    dependency_level
FROM dependency_chain
ORDER BY dependency_level DESC;

-- Study sessions for one student.
SELECT
    ss.study_session_id,
    st.title AS sub_task_title,
    mt.title AS main_task_title,
    ss.start_time,
    ss.end_time,
    ss.duration_hours,
    ss.session_type,
    ss.notes
FROM study_session ss
LEFT JOIN sub_task st ON ss.sub_task_id = st.sub_task_id
LEFT JOIN main_task mt ON st.main_task_id = mt.main_task_id
WHERE ss.student_id = 1
ORDER BY ss.start_time DESC;

-- Study statistics for the last seven days.
SELECT
    SUM(duration_hours) AS total_study_hours,
    COUNT(study_session_id) AS session_count,
    AVG(duration_hours) AS average_session_hours
FROM study_session
WHERE student_id = 1
  AND session_type = 'ACTUAL'
  AND start_time >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Study hours grouped by course.
SELECT
    c.course_code,
    c.course_name,
    COUNT(ss.study_session_id) AS session_count,
    SUM(ss.duration_hours) AS total_study_hours
FROM study_session ss
JOIN sub_task st ON ss.sub_task_id = st.sub_task_id
JOIN main_task mt ON st.main_task_id = mt.main_task_id
JOIN course c ON mt.course_id = c.course_id
WHERE ss.student_id = 1
  AND ss.session_type = 'ACTUAL'
GROUP BY c.course_code, c.course_name
ORDER BY total_study_hours DESC;

-- Schedule for the next seven days.
SELECT
    schedule_slot_id,
    slot_date,
    start_time,
    end_time,
    slot_type,
    title
FROM schedule_slot
WHERE student_id = 1
  AND slot_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY slot_date ASC, start_time ASC;

-- Check whether a proposed slot conflicts with existing schedule entries.
SELECT
    COUNT(*) AS conflict_count
FROM schedule_slot
WHERE student_id = 1
  AND slot_date = '2026-05-21'
  AND start_time < '15:00:00'
  AND end_time > '14:00:00';

-- Find completed tasks where actual study hours exceeded the estimate.
SELECT
    mt.title AS main_task_title,
    st.title AS sub_task_title,
    st.estimated_hours,
    COALESCE(SUM(ss.duration_hours), 0) AS actual_hours,
    COALESCE(SUM(ss.duration_hours), 0) / st.estimated_hours AS overrun_ratio
FROM sub_task st
JOIN main_task mt ON st.main_task_id = mt.main_task_id
LEFT JOIN study_session ss ON st.sub_task_id = ss.sub_task_id
WHERE mt.student_id = 1
  AND st.status = 'COMPLETED'
  AND st.estimated_hours > 0
GROUP BY st.sub_task_id, mt.title, st.title, st.estimated_hours
HAVING overrun_ratio > 1.2
ORDER BY overrun_ratio DESC;

-- Find the student's most productive study hours.
SELECT
    HOUR(start_time) AS hour_of_day,
    COUNT(*) AS session_count,
    AVG(duration_hours) AS average_duration
FROM study_session
WHERE student_id = 1
  AND session_type = 'ACTUAL'
  AND duration_hours > 0.5
GROUP BY HOUR(start_time)
ORDER BY average_duration DESC;
