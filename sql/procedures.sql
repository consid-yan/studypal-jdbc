-- StudyPal stored procedures.
-- Run after schema.sql.

USE studypal;

DROP PROCEDURE IF EXISTS batch_create_sub_tasks;
DROP PROCEDURE IF EXISTS get_full_dependency_chain;
DROP PROCEDURE IF EXISTS can_start_task;
DROP PROCEDURE IF EXISTS generate_procrastination_report;

DELIMITER //

CREATE PROCEDURE batch_create_sub_tasks(
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

        INSERT INTO sub_task (
            main_task_id,
            title,
            estimated_hours,
            planned_start_time,
            planned_end_time,
            status
        ) VALUES (
            p_main_task_id,
            current_title,
            p_default_estimated_hours,
            planned_start,
            planned_end,
            'TODO'
        );

        SET i = i + 1;
    END WHILE;

    SELECT task_count AS created_sub_task_count;
END//

CREATE PROCEDURE get_full_dependency_chain(
    IN p_sub_task_id INT,
    OUT p_dependency_chain JSON
)
BEGIN
    WITH RECURSIVE dependency_chain AS (
        SELECT
            td.depends_on_sub_task_id AS task_id,
            st.title AS task_title,
            st.status AS task_status,
            1 AS dependency_level
        FROM task_dependency td
        JOIN sub_task st ON td.depends_on_sub_task_id = st.sub_task_id
        WHERE td.sub_task_id = p_sub_task_id
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
    SELECT COALESCE(
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'task_id', task_id,
                'task_title', task_title,
                'task_status', task_status,
                'level', dependency_level
            )
        ),
        JSON_ARRAY()
    )
    INTO p_dependency_chain
    FROM dependency_chain;
END//

CREATE PROCEDURE can_start_task(
    IN p_sub_task_id INT,
    OUT p_can_start BOOLEAN,
    OUT p_blocking_tasks JSON
)
BEGIN
    DECLARE incomplete_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO incomplete_count
    FROM task_dependency td
    JOIN sub_task st ON td.depends_on_sub_task_id = st.sub_task_id
    WHERE td.sub_task_id = p_sub_task_id
      AND st.status <> 'COMPLETED';

    SELECT COALESCE(
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'task_id', st.sub_task_id,
                'task_title', st.title,
                'task_status', st.status
            )
        ),
        JSON_ARRAY()
    )
    INTO p_blocking_tasks
    FROM task_dependency td
    JOIN sub_task st ON td.depends_on_sub_task_id = st.sub_task_id
    WHERE td.sub_task_id = p_sub_task_id
      AND st.status <> 'COMPLETED';

    SET p_can_start = (incomplete_count = 0);
END//

CREATE PROCEDURE generate_procrastination_report(
    IN p_student_id INT,
    IN p_days_back INT
)
BEGIN
    SELECT
        st.sub_task_id,
        mt.title AS main_task_title,
        st.title AS sub_task_title,
        st.estimated_hours,
        COALESCE(SUM(ss.duration_hours), 0) AS actual_hours,
        COALESCE(SUM(ss.duration_hours), 0) - COALESCE(st.estimated_hours, 0) AS time_overrun,
        DATEDIFF(st.completed_time, st.planned_end_time) AS days_late,
        CASE
            WHEN st.completed_time IS NULL AND st.planned_end_time < NOW() THEN 'OVERDUE'
            WHEN DATEDIFF(st.completed_time, st.planned_end_time) > 2 THEN 'SEVERELY_LATE'
            WHEN DATEDIFF(st.completed_time, st.planned_end_time) > 0 THEN 'LATE'
            WHEN DATEDIFF(st.completed_time, st.planned_end_time) <= 0 THEN 'ON_TIME'
            ELSE 'NOT_COMPLETED'
        END AS completion_status
    FROM sub_task st
    JOIN main_task mt ON st.main_task_id = mt.main_task_id
    LEFT JOIN study_session ss ON st.sub_task_id = ss.sub_task_id
    WHERE mt.student_id = p_student_id
      AND (
          st.planned_end_time >= DATE_SUB(NOW(), INTERVAL p_days_back DAY)
          OR st.completed_time >= DATE_SUB(NOW(), INTERVAL p_days_back DAY)
          OR st.completed_time IS NULL
      )
    GROUP BY
        st.sub_task_id,
        mt.title,
        st.title,
        st.estimated_hours,
        st.completed_time,
        st.planned_end_time
    ORDER BY days_late DESC;
END//

DELIMITER ;
