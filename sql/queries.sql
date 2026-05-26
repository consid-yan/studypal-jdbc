-- StudyPal query examples.
-- Run after schema.sql and, where noted, after views.sql.

USE studypal;

-- Courses for one student.
SELECT
    c.course_id,
    c.course_code,
    c.course_name,
    lecturer.full_name AS lecturer_name,
    e.enrollment_date
FROM enrollment e
JOIN course c ON e.course_id = c.course_id
JOIN user lecturer ON c.lecturer_id = lecturer.user_id
WHERE e.student_id = 6
ORDER BY c.course_code;

-- Main tasks for courses a student has joined.
SELECT
    mt.main_task_id,
    c.course_code,
    mt.title,
    mt.description,
    mt.deadline,
    mt.importance_level,
    mt.created_at
FROM main_task mt
JOIN course c ON mt.course_id = c.course_id
JOIN enrollment e ON e.course_id = c.course_id
WHERE e.student_id = 6
ORDER BY mt.deadline ASC;

-- Student sub-tasks for one main task.
SELECT
    sst.student_sub_task_id,
    COALESCE(sst.custom_title, st.title) AS title,
    COALESCE(sst.custom_description, st.description) AS description,
    st.estimated_hours,
    COALESCE(sst.custom_planned_start_time, st.planned_start) AS planned_start_time,
    COALESCE(sst.custom_planned_end_time, st.planned_end) AS planned_end_time,
    sst.status,
    sst.completed_time,
    sst.notes
FROM student_sub_task sst
JOIN sub_task_template st ON sst.template_id = st.template_id
WHERE sst.student_id = 6
  AND st.main_task_id = 1
ORDER BY st.sequence_order ASC;

-- Highest priority active student sub-tasks. Requires views.sql.
SELECT
    *
FROM student_task_priority_view
WHERE student_id = 6
  AND status IN ('TODO', 'IN_PROGRESS')
ORDER BY priority_score ASC
LIMIT 10;

-- Student sub-tasks planned to end in the next three days.
SELECT
    sst.student_sub_task_id,
    mt.title AS main_task_title,
    COALESCE(sst.custom_title, st.title) AS sub_task_title,
    COALESCE(sst.custom_planned_end_time, st.planned_end) AS due_time,
    DATEDIFF(COALESCE(sst.custom_planned_end_time, st.planned_end), NOW()) AS days_remaining
FROM student_sub_task sst
JOIN sub_task_template st ON sst.template_id = st.template_id
JOIN main_task mt ON st.main_task_id = mt.main_task_id
WHERE sst.student_id = 6
  AND sst.status IN ('TODO', 'IN_PROGRESS')
  AND COALESCE(sst.custom_planned_end_time, st.planned_end)
      BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 3 DAY)
ORDER BY COALESCE(sst.custom_planned_end_time, st.planned_end) ASC;

-- Main task progress for one student. Requires views.sql.
SELECT
    main_task_id,
    course_code,
    title,
    total_student_sub_tasks,
    completed_student_sub_tasks,
    completion_percentage,
    progress_status
FROM main_task_progress_view
WHERE student_id = 6
ORDER BY deadline ASC;

-- Main task progress for all students in a lecturer's course.
SELECT
    mtp.student_id,
    mtp.student_name,
    mtp.title,
    mtp.completion_percentage,
    mtp.progress_status
FROM main_task_progress_view mtp
JOIN course c ON mtp.course_code = c.course_code
WHERE c.lecturer_id = 2
ORDER BY mtp.completion_percentage ASC;

-- Study sessions for one student.
SELECT
    ss.study_session_id,
    COALESCE(sst.custom_title, st.title) AS sub_task_title,
    mt.title AS main_task_title,
    ss.start_time,
    ss.end_time,
    CASE
        WHEN ss.end_time IS NULL THEN NULL
        ELSE ROUND(TIMESTAMPDIFF(MINUTE, ss.start_time, ss.end_time) / 60, 2)
    END AS duration_hours,
    ss.session_type,
    ss.notes
FROM study_session ss
LEFT JOIN student_sub_task sst ON ss.student_sub_task_id = sst.student_sub_task_id
LEFT JOIN sub_task_template st ON sst.template_id = st.template_id
LEFT JOIN main_task mt ON st.main_task_id = mt.main_task_id
WHERE ss.student_id = 6
ORDER BY ss.start_time DESC;

-- Study statistics for the last seven days.
SELECT
    SUM(ROUND(TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60, 2)) AS total_study_hours,
    COUNT(study_session_id) AS session_count,
    AVG(ROUND(TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60, 2)) AS average_session_hours
FROM study_session
WHERE student_id = 6
  AND session_type = 'ACTUAL'
  AND end_time IS NOT NULL
  AND start_time >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- Study hours grouped by course.
SELECT
    c.course_code,
    c.course_name,
    COUNT(ss.study_session_id) AS session_count,
    SUM(ROUND(TIMESTAMPDIFF(MINUTE, ss.start_time, ss.end_time) / 60, 2)) AS total_study_hours
FROM study_session ss
JOIN student_sub_task sst ON ss.student_sub_task_id = sst.student_sub_task_id
JOIN sub_task_template st ON sst.template_id = st.template_id
JOIN main_task mt ON st.main_task_id = mt.main_task_id
JOIN course c ON mt.course_id = c.course_id
WHERE ss.student_id = 6
  AND ss.session_type = 'ACTUAL'
  AND ss.end_time IS NOT NULL
GROUP BY c.course_code, c.course_name
ORDER BY total_study_hours DESC;

-- Compare estimated effort against actual study sessions. Requires views.sql.
SELECT
    main_task_title,
    sub_task_title,
    estimated_hours,
    actual_hours,
    time_overrun,
    efficiency_status
FROM study_efficiency_view
WHERE student_id = 6
ORDER BY time_overrun DESC;

-- Find completed student sub-tasks where actual study hours exceeded the estimate.
SELECT
    mt.title AS main_task_title,
    COALESCE(sst.custom_title, st.title) AS sub_task_title,
    st.estimated_hours,
    COALESCE(SUM(
        CASE
            WHEN ss.end_time IS NULL THEN NULL
            ELSE ROUND(TIMESTAMPDIFF(MINUTE, ss.start_time, ss.end_time) / 60, 2)
        END
    ), 0) AS actual_hours,
    COALESCE(SUM(
        CASE
            WHEN ss.end_time IS NULL THEN NULL
            ELSE ROUND(TIMESTAMPDIFF(MINUTE, ss.start_time, ss.end_time) / 60, 2)
        END
    ), 0) / st.estimated_hours AS overrun_ratio
FROM student_sub_task sst
JOIN sub_task_template st ON sst.template_id = st.template_id
JOIN main_task mt ON st.main_task_id = mt.main_task_id
LEFT JOIN study_session ss ON sst.student_sub_task_id = ss.student_sub_task_id
WHERE sst.student_id = 6
  AND sst.status = 'COMPLETED'
  AND st.estimated_hours > 0
GROUP BY sst.student_sub_task_id, mt.title, COALESCE(sst.custom_title, st.title), st.estimated_hours
HAVING overrun_ratio > 1.2
ORDER BY overrun_ratio DESC;

-- Find the student's most productive study hours.
SELECT
    HOUR(start_time) AS hour_of_day,
    COUNT(*) AS session_count,
    AVG(ROUND(TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60, 2)) AS average_duration
FROM study_session
WHERE student_id = 6
  AND session_type = 'ACTUAL'
  AND end_time IS NOT NULL
  AND ROUND(TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60, 2) > 0.5
GROUP BY HOUR(start_time)
ORDER BY average_duration DESC;

-- Admin view: course workload summary. Requires views.sql.
SELECT
    course_code,
    course_name,
    lecturer_name,
    enrolled_student_count,
    main_task_count,
    template_count,
    student_sub_task_count
FROM course_workload_view
ORDER BY course_code;

-- Admin view: students falling behind on a main task.
SELECT
    student_id,
    student_name,
    title,
    completion_percentage,
    progress_status
FROM main_task_progress_view
WHERE main_task_id = 1
  AND (completion_percentage IS NULL OR completion_percentage < 50)
ORDER BY completion_percentage ASC;

-- Lecturer view: all main tasks in owned courses.
SELECT
    mt.main_task_id,
    c.course_code,
    mt.title,
    mt.deadline,
    mt.importance_level,
    COUNT(DISTINCT st.template_id) AS template_count
FROM main_task mt
JOIN course c ON mt.course_id = c.course_id
LEFT JOIN sub_task_template st ON mt.main_task_id = st.main_task_id
WHERE c.lecturer_id = 2
GROUP BY mt.main_task_id, c.course_code, mt.title, mt.deadline, mt.importance_level
ORDER BY mt.deadline ASC;

-- Generate procrastination report for one student. Requires procedures.sql.
CALL generate_procrastination_report(6, 30);
