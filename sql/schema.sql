-- StudyPal core schema for MySQL.
-- Multi-role academic support model with shared templates and student-specific progress.

CREATE DATABASE IF NOT EXISTS studypal
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE studypal;

CREATE TABLE user (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    role          ENUM('ADMIN', 'LECTURER', 'STUDENT') NOT NULL DEFAULT 'STUDENT',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE course (
    course_id    INT AUTO_INCREMENT PRIMARY KEY,
    course_code  VARCHAR(30)  NOT NULL UNIQUE,
    course_name  VARCHAR(100) NOT NULL,
    lecturer_id  INT          NOT NULL,
    semester     VARCHAR(30),
    description  TEXT,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_course_lecturer
        FOREIGN KEY (lecturer_id) REFERENCES user (user_id)
);

CREATE TABLE enrollment (
    enrollment_id   INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT  NOT NULL,
    course_id       INT  NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    UNIQUE KEY uk_enrollment_student_course (student_id, course_id),
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id) REFERENCES user (user_id),
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id) REFERENCES course (course_id)
);

CREATE TABLE main_task (
    main_task_id     INT AUTO_INCREMENT PRIMARY KEY,
    course_id        INT          NOT NULL,
    title            VARCHAR(150) NOT NULL,
    description      TEXT,
    deadline         DATETIME,
    importance_level ENUM('VERY_LOW', 'LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH')
        NOT NULL DEFAULT 'MEDIUM',
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_main_task_course
        FOREIGN KEY (course_id) REFERENCES course (course_id)
);

CREATE TABLE sub_task_template (
    template_id      INT AUTO_INCREMENT PRIMARY KEY,
    main_task_id     INT          NOT NULL,
    title            VARCHAR(150) NOT NULL,
    description      TEXT,
    estimated_hours  DECIMAL(5,2),
    sequence_order   INT          NOT NULL DEFAULT 0,
    planned_start    DATETIME,
    planned_end      DATETIME,
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_template_main_task
        FOREIGN KEY (main_task_id) REFERENCES main_task (main_task_id),
    CONSTRAINT chk_template_hours
        CHECK (estimated_hours IS NULL OR estimated_hours >= 0),
    CONSTRAINT chk_template_time
        CHECK (planned_start IS NULL OR planned_end IS NULL OR planned_start < planned_end)
);

CREATE TABLE student_sub_task (
    student_sub_task_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id          INT          NOT NULL,
    template_id         INT          NOT NULL,
    custom_title        VARCHAR(150),
    custom_description  TEXT,
    custom_planned_start_time DATETIME,
    custom_planned_end_time   DATETIME,
    completed_time      DATETIME,
    status              ENUM('TODO', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')
        NOT NULL DEFAULT 'TODO',
    notes               TEXT,
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_student_template (student_id, template_id),
    CONSTRAINT fk_student_sub_task_user
        FOREIGN KEY (student_id) REFERENCES user (user_id),
    CONSTRAINT fk_student_sub_task_template
        FOREIGN KEY (template_id) REFERENCES sub_task_template (template_id),
    CONSTRAINT chk_student_sub_task_time
        CHECK (custom_planned_start_time IS NULL OR custom_planned_end_time IS NULL
               OR custom_planned_start_time < custom_planned_end_time)
);

CREATE TABLE study_session (
    study_session_id    INT AUTO_INCREMENT PRIMARY KEY,
    student_id          INT      NOT NULL,
    student_sub_task_id INT,
    start_time          DATETIME NOT NULL,
    end_time            DATETIME,
    session_type        ENUM('PLANNED', 'ACTUAL') NOT NULL DEFAULT 'ACTUAL',
    notes               TEXT,
    CONSTRAINT fk_study_session_student
        FOREIGN KEY (student_id) REFERENCES user (user_id),
    CONSTRAINT fk_study_session_student_sub_task
        FOREIGN KEY (student_sub_task_id) REFERENCES student_sub_task (student_sub_task_id),
    CONSTRAINT chk_study_session_time
        CHECK (end_time IS NULL OR start_time < end_time)
);

CREATE INDEX idx_main_task_course ON main_task (course_id);
CREATE INDEX idx_template_main_task ON sub_task_template (main_task_id);
CREATE INDEX idx_student_sub_task_student_status ON student_sub_task (student_id, status);
CREATE INDEX idx_student_sub_task_template ON student_sub_task (template_id);
CREATE INDEX idx_study_session_student_start ON study_session (student_id, start_time);
CREATE INDEX idx_enrollment_course ON enrollment (course_id);
