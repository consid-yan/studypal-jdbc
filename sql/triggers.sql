-- StudyPal triggers.
-- Run after schema.sql.

USE studypal;

DROP TRIGGER IF EXISTS prevent_main_task_update;
DROP TRIGGER IF EXISTS prevent_main_task_delete;
DROP TRIGGER IF EXISTS calculate_study_session_duration_before_insert;
DROP TRIGGER IF EXISTS calculate_study_session_duration_before_update;

DELIMITER //

CREATE TRIGGER prevent_main_task_update
BEFORE UPDATE ON main_task
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'MainTask cannot be modified after creation.';
END//

CREATE TRIGGER prevent_main_task_delete
BEFORE DELETE ON main_task
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'MainTask cannot be deleted after creation.';
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

DELIMITER ;
