-- StudyPal triggers.
-- Run after schema.sql.

USE studypal;

DROP TRIGGER IF EXISTS update_main_task_status_after_subtask_update;
DROP TRIGGER IF EXISTS update_main_task_status_after_subtask_insert;
DROP TRIGGER IF EXISTS update_main_task_status_after_subtask_delete;
DROP TRIGGER IF EXISTS calculate_study_session_duration_before_insert;
DROP TRIGGER IF EXISTS calculate_study_session_duration_before_update;
DROP TRIGGER IF EXISTS prevent_circular_dependency_before_insert;
DROP TRIGGER IF EXISTS prevent_circular_dependency_before_update;

DELIMITER //

CREATE TRIGGER update_main_task_status_after_subtask_update
AFTER UPDATE ON sub_task
FOR EACH ROW
BEGIN
    DECLARE total_subtasks INT DEFAULT 0;
    DECLARE completed_subtasks INT DEFAULT 0;

    IF OLD.status <> NEW.status THEN
        SELECT COUNT(*)
        INTO total_subtasks
        FROM sub_task
        WHERE main_task_id = NEW.main_task_id;

        SELECT COUNT(*)
        INTO completed_subtasks
        FROM sub_task
        WHERE main_task_id = NEW.main_task_id
          AND status = 'COMPLETED';

        IF total_subtasks > 0 AND total_subtasks = completed_subtasks THEN
            UPDATE main_task
            SET status = 'COMPLETED',
                updated_at = CURRENT_TIMESTAMP
            WHERE main_task_id = NEW.main_task_id;
        ELSEIF (
            SELECT status
            FROM main_task
            WHERE main_task_id = NEW.main_task_id
        ) = 'COMPLETED' THEN
            UPDATE main_task
            SET status = 'IN_PROGRESS',
                updated_at = CURRENT_TIMESTAMP
            WHERE main_task_id = NEW.main_task_id;
        END IF;
    END IF;
END//

CREATE TRIGGER update_main_task_status_after_subtask_insert
AFTER INSERT ON sub_task
FOR EACH ROW
BEGIN
    UPDATE main_task
    SET status = 'IN_PROGRESS',
        updated_at = CURRENT_TIMESTAMP
    WHERE main_task_id = NEW.main_task_id
      AND status = 'COMPLETED';
END//

CREATE TRIGGER update_main_task_status_after_subtask_delete
AFTER DELETE ON sub_task
FOR EACH ROW
BEGIN
    DECLARE total_subtasks INT DEFAULT 0;
    DECLARE completed_subtasks INT DEFAULT 0;

    SELECT COUNT(*)
    INTO total_subtasks
    FROM sub_task
    WHERE main_task_id = OLD.main_task_id;

    IF total_subtasks > 0 THEN
        SELECT COUNT(*)
        INTO completed_subtasks
        FROM sub_task
        WHERE main_task_id = OLD.main_task_id
          AND status = 'COMPLETED';

        IF total_subtasks = completed_subtasks THEN
            UPDATE main_task
            SET status = 'COMPLETED',
                updated_at = CURRENT_TIMESTAMP
            WHERE main_task_id = OLD.main_task_id;
        END IF;
    END IF;
END//

CREATE TRIGGER calculate_study_session_duration_before_insert
BEFORE INSERT ON study_session
FOR EACH ROW
BEGIN
    IF NEW.duration_hours IS NULL
       AND NEW.end_time IS NOT NULL
       AND NEW.end_time > NEW.start_time THEN
        SET NEW.duration_hours = ROUND(TIMESTAMPDIFF(MINUTE, NEW.start_time, NEW.end_time) / 60, 2);
    END IF;
END//

CREATE TRIGGER calculate_study_session_duration_before_update
BEFORE UPDATE ON study_session
FOR EACH ROW
BEGIN
    IF NEW.duration_hours IS NULL
       AND NEW.end_time IS NOT NULL
       AND NEW.end_time > NEW.start_time THEN
        SET NEW.duration_hours = ROUND(TIMESTAMPDIFF(MINUTE, NEW.start_time, NEW.end_time) / 60, 2);
    END IF;
END//

CREATE TRIGGER prevent_circular_dependency_before_insert
BEFORE INSERT ON task_dependency
FOR EACH ROW
BEGIN
    DECLARE has_cycle INT DEFAULT 0;

    IF NEW.sub_task_id = NEW.depends_on_sub_task_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A sub-task cannot depend on itself.';
    END IF;

    WITH RECURSIVE dependency_chain AS (
        SELECT depends_on_sub_task_id AS task_id
        FROM task_dependency
        WHERE sub_task_id = NEW.depends_on_sub_task_id
        UNION ALL
        SELECT td.depends_on_sub_task_id
        FROM task_dependency td
        JOIN dependency_chain dc ON td.sub_task_id = dc.task_id
    )
    SELECT COUNT(*)
    INTO has_cycle
    FROM dependency_chain
    WHERE task_id = NEW.sub_task_id;

    IF has_cycle > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create circular task dependency.';
    END IF;
END//

CREATE TRIGGER prevent_circular_dependency_before_update
BEFORE UPDATE ON task_dependency
FOR EACH ROW
BEGIN
    DECLARE has_cycle INT DEFAULT 0;

    IF NEW.sub_task_id = NEW.depends_on_sub_task_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A sub-task cannot depend on itself.';
    END IF;

    WITH RECURSIVE dependency_chain AS (
        SELECT depends_on_sub_task_id AS task_id
        FROM task_dependency
        WHERE sub_task_id = NEW.depends_on_sub_task_id
          AND dependency_id <> NEW.dependency_id
        UNION ALL
        SELECT td.depends_on_sub_task_id
        FROM task_dependency td
        JOIN dependency_chain dc ON td.sub_task_id = dc.task_id
        WHERE td.dependency_id <> NEW.dependency_id
    )
    SELECT COUNT(*)
    INTO has_cycle
    FROM dependency_chain
    WHERE task_id = NEW.sub_task_id;

    IF has_cycle > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create circular task dependency.';
    END IF;
END//

DELIMITER ;
