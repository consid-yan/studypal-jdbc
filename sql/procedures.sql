-- StudyPal stored procedures.
-- Run after schema.sql.

USE studypal;

DROP PROCEDURE IF EXISTS batch_create_sub_task_templates;
DROP PROCEDURE IF EXISTS copy_student_sub_tasks_for_main_task;
DROP PROCEDURE IF EXISTS copy_student_sub_tasks_for_enrollment;
DROP PROCEDURE IF EXISTS generate_procrastination_report;

DELIMITER //

CREATE PROCEDURE batch_create_sub_task_templates(
    IN p_main_task_id INT,
    IN p_task_titles JSON,
    IN p_default_estimated_hours DECIMAL(5,2),
    IN p_start_date DATE,
    IN p_days_between_tasks INT
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE task_count INT DEFAULT 0;
    DECLARE current_title VARCHAR(150);
    DECLARE planned_start DATETIME;
    DECLARE planned_end DATETIME;

    IF NOT EXISTS (
        SELECT 1
        FROM main_task
        WHERE main_task_id = p_main_task_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Main task does not exist.';
    END IF;

    SET task_count = JSON_LENGTH(p_task_titles);

    WHILE i < task_count DO
        SET current_title = JSON_UNQUOTE(JSON_EXTRACT(p_task_titles, CONCAT('$[', i, ']')));
        SET planned_start = DATE_ADD(CAST(p_start_date AS DATETIME), INTERVAL i * p_days_between_tasks DAY);
        SET planned_end = DATE_ADD(planned_start, INTERVAL 1 DAY);

        INSERT INTO sub_task_template (
            main_task_id,
            title,
            estimated_hours,
            sequence_order,
            planned_start,
            planned_end
        ) VALUES (
            p_main_task_id,
            current_title,
            p_default_estimated_hours,
            i + 1,
            planned_start,
            planned_end
        );

        SET i = i + 1;
    END WHILE;

    SELECT task_count AS created_template_count;
END//

CREATE PROCEDURE copy_student_sub_tasks_for_main_task(
    IN p_main_task_id INT
)
BEGIN
    INSERT INTO student_sub_task (
        student_id,
        template_id,
        status
    )
    SELECT
        e.student_id,
        st.template_id,
        'TODO'
    FROM sub_task_template st
    JOIN main_task mt ON st.main_task_id = mt.main_task_id
    JOIN enrollment e ON mt.course_id = e.course_id
    WHERE mt.main_task_id = p_main_task_id
      AND NOT EXISTS (
          SELECT 1
          FROM student_sub_task existing
          WHERE existing.student_id = e.student_id
            AND existing.template_id = st.template_id
      );

    SELECT ROW_COUNT() AS created_student_sub_task_count;
END//

CREATE PROCEDURE copy_student_sub_tasks_for_enrollment(
    IN p_student_id INT,
    IN p_course_id INT
)
BEGIN
    INSERT INTO student_sub_task (
        student_id,
        template_id,
        status
    )
    SELECT
        p_student_id,
        st.template_id,
        'TODO'
    FROM main_task mt
    JOIN sub_task_template st ON mt.main_task_id = st.main_task_id
    WHERE mt.course_id = p_course_id
      AND NOT EXISTS (
          SELECT 1
          FROM student_sub_task existing
          WHERE existing.student_id = p_student_id
            AND existing.template_id = st.template_id
      );

    SELECT ROW_COUNT() AS created_student_sub_task_count;
END//

CREATE PROCEDURE generate_procrastination_report(
    IN p_student_id INT,
    IN p_days_back INT
)
BEGIN
    SELECT
        sst.student_sub_task_id,
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
        ), 0) - COALESCE(st.estimated_hours, 0) AS time_overrun,
        DATEDIFF(sst.completed_time, COALESCE(sst.custom_planned_end_time, st.planned_end)) AS days_late,
        CASE
            WHEN sst.completed_time IS NULL
                 AND COALESCE(sst.custom_planned_end_time, st.planned_end) < NOW() THEN 'OVERDUE'
            WHEN DATEDIFF(sst.completed_time, COALESCE(sst.custom_planned_end_time, st.planned_end)) > 2
                THEN 'SEVERELY_LATE'
            WHEN DATEDIFF(sst.completed_time, COALESCE(sst.custom_planned_end_time, st.planned_end)) > 0
                THEN 'LATE'
            WHEN DATEDIFF(sst.completed_time, COALESCE(sst.custom_planned_end_time, st.planned_end)) <= 0
                THEN 'ON_TIME'
            ELSE 'NOT_COMPLETED'
        END AS completion_status
    FROM student_sub_task sst
    JOIN sub_task_template st ON sst.template_id = st.template_id
    JOIN main_task mt ON st.main_task_id = mt.main_task_id
    LEFT JOIN study_session ss ON sst.student_sub_task_id = ss.student_sub_task_id
    WHERE sst.student_id = p_student_id
      AND (
          COALESCE(sst.custom_planned_end_time, st.planned_end) >= DATE_SUB(NOW(), INTERVAL p_days_back DAY)
          OR sst.completed_time >= DATE_SUB(NOW(), INTERVAL p_days_back DAY)
          OR sst.completed_time IS NULL
      )
    GROUP BY
        sst.student_sub_task_id,
        mt.title,
        COALESCE(sst.custom_title, st.title),
        st.estimated_hours,
        sst.completed_time,
        COALESCE(sst.custom_planned_end_time, st.planned_end)
    ORDER BY days_late DESC;
END//

DELIMITER ;
