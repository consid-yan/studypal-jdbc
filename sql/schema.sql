-- StudyPal core schema draft for MySQL.
-- This file intentionally includes only the tables supported by the current design.

CREATE DATABASE IF NOT EXISTS studypal
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE studypal;

CREATE TABLE student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(30) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    lecturer VARCHAR(100),
    semester VARCHAR(30)
);

CREATE TABLE enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    UNIQUE KEY uk_enrollment_student_course (student_id, course_id),
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id) REFERENCES student (student_id),
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id) REFERENCES course (course_id)
);

CREATE TABLE schedule_slot (
    schedule_slot_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_type ENUM('CLASS', 'FREE', 'UNAVAILABLE') NOT NULL DEFAULT 'FREE',
    title VARCHAR(100),
    CONSTRAINT fk_schedule_slot_student
        FOREIGN KEY (student_id) REFERENCES student (student_id),
    CONSTRAINT chk_schedule_slot_time
        CHECK (start_time < end_time)
);

CREATE TABLE main_task (
    main_task_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    deadline DATETIME,
    importance_level ENUM('VERY_LOW', 'LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH')
        NOT NULL DEFAULT 'MEDIUM',
    status ENUM('TODO', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')
        NOT NULL DEFAULT 'TODO',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_main_task_student
        FOREIGN KEY (student_id) REFERENCES student (student_id),
    CONSTRAINT fk_main_task_course
        FOREIGN KEY (course_id) REFERENCES course (course_id)
);

CREATE TABLE sub_task (
    sub_task_id INT AUTO_INCREMENT PRIMARY KEY,
    main_task_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    estimated_hours DECIMAL(5,2),
    planned_start_time DATETIME,
    planned_end_time DATETIME,
    completed_time DATETIME,
    status ENUM('TODO', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')
        NOT NULL DEFAULT 'TODO',
    CONSTRAINT fk_sub_task_main_task
        FOREIGN KEY (main_task_id) REFERENCES main_task (main_task_id),
    CONSTRAINT chk_sub_task_estimated_hours
        CHECK (estimated_hours IS NULL OR estimated_hours >= 0),
    CONSTRAINT chk_sub_task_planned_time
        CHECK (planned_start_time IS NULL OR planned_end_time IS NULL OR planned_start_time < planned_end_time)
);

CREATE TABLE task_dependency (
    dependency_id INT AUTO_INCREMENT PRIMARY KEY,
    sub_task_id INT NOT NULL,
    depends_on_sub_task_id INT NOT NULL,
    UNIQUE KEY uk_task_dependency_pair (sub_task_id, depends_on_sub_task_id),
    CONSTRAINT fk_task_dependency_sub_task
        FOREIGN KEY (sub_task_id) REFERENCES sub_task (sub_task_id),
    CONSTRAINT fk_task_dependency_depends_on
        FOREIGN KEY (depends_on_sub_task_id) REFERENCES sub_task (sub_task_id),
    CONSTRAINT chk_task_dependency_not_self
        CHECK (sub_task_id <> depends_on_sub_task_id)
);

CREATE TABLE study_session (
    study_session_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    sub_task_id INT,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    duration_hours DECIMAL(5,2),
    session_type ENUM('PLANNED', 'ACTUAL') NOT NULL DEFAULT 'ACTUAL',
    notes TEXT,
    CONSTRAINT fk_study_session_student
        FOREIGN KEY (student_id) REFERENCES student (student_id),
    CONSTRAINT fk_study_session_sub_task
        FOREIGN KEY (sub_task_id) REFERENCES sub_task (sub_task_id),
    CONSTRAINT chk_study_session_time
        CHECK (end_time IS NULL OR start_time < end_time),
    CONSTRAINT chk_study_session_duration
        CHECK (duration_hours IS NULL OR duration_hours >= 0)
);

CREATE INDEX idx_main_task_student_status ON main_task (student_id, status);
CREATE INDEX idx_sub_task_main_task_status ON sub_task (main_task_id, status);
CREATE INDEX idx_schedule_slot_student_date ON schedule_slot (student_id, slot_date);
CREATE INDEX idx_study_session_student_start ON study_session (student_id, start_time);
