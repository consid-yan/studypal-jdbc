-- =========================================================================
-- Core Design Notes:
-- 1. Uses the utf8mb4 character set for full support of Chinese.
-- 2. Strictly adheres to the EER mapping standard; the primary keys of STUDENT, LECTURER,
-- and ADMIN also serve as foreign keys pointing to USER_ACCOUNT.
-- 3. Table creation order strictly follows the foreign key dependency topology.
-- 4. Comprehensive cascade delete (ON DELETE CASCADE) and unique constraints have been implemented.
-- =========================================================================

-- =========================================================================
-- 0. Environment Setup and Database Creation
-- =========================================================================
DROP DATABASE IF EXISTS studypal_db;
CREATE DATABASE studypal_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE studypal_db;


-- =========================================================================
-- 1. User Management Module Table Structure
-- =========================================================================

-- User Base Table (Supertype)
CREATE TABLE USER_ACCOUNT (
        user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        email VARCHAR(100) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(100) NOT NULL,
        role VARCHAR(20) NOT NULL, -- Enumeration values: ‘STUDENT’, ‘LECTURER’, ‘ADMIN’
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Lecturer Details Table (Subtype)
CREATE TABLE LECTURER (
        lecturer_id BIGINT PRIMARY KEY, -- Both primary key and foreign key
        employee_no VARCHAR(50) NOT NULL UNIQUE,
        department VARCHAR(100) NOT NULL,
        title VARCHAR(50),
        office VARCHAR(100),
        phone VARCHAR(20),
        FOREIGN KEY (lecturer_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Student Details Table (Subtype)
CREATE TABLE STUDENT (
        student_id BIGINT PRIMARY KEY, -- Both primary key and foreign key
        student_no VARCHAR(50) NOT NULL UNIQUE,
        major VARCHAR(100) NOT NULL,
        grade VARCHAR(20) NOT NULL,
        class_name VARCHAR(50),
        phone VARCHAR(20),
        FOREIGN KEY (student_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Administrator Details Table (Subtype)
CREATE TABLE ADMIN (
        admin_id BIGINT PRIMARY KEY, -- Both primary key and foreign key
        admin_no VARCHAR(50) NOT NULL UNIQUE,
        department VARCHAR(100) NOT NULL,
        position VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (admin_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================================
-- 2. Course and Enrollment Module Table Structures (Course & Enrollment)
-- =========================================================================

-- Course Table
CREATE TABLE COURSE (
        course_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        course_code VARCHAR(50) NOT NULL UNIQUE,
        course_name VARCHAR(150) NOT NULL,
        lecturer_id BIGINT NOT NULL,
        semester VARCHAR(20) NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (lecturer_id) REFERENCES LECTURER(lecturer_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Course Registration Schedule (M:N mapping intermediate table)
CREATE TABLE ENROLLMENT (
        enrollment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        student_id BIGINT NOT NULL,
        course_id BIGINT NOT NULL,
        enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT idx_student_course UNIQUE (student_id, course_id), -- Union of unique constraints to prevent
                                                                      -- duplicate course selection
        FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================================
-- 3. Task and Progress Management Module Table Structure
-- =========================================================================

-- Main Task Table
CREATE TABLE MAIN_TASK (
        main_task_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        course_id BIGINT NULL, -- NULL is allowed. NULL indicates a “self-directed assignment” for the student;
                               -- non-NULL indicates a “course assignment”
        creator_id BIGINT NOT NULL, -- Associates the creator (student or instructor)
        title VARCHAR(200) NOT NULL,
        description TEXT,
        deadline DATETIME NOT NULL,
        importance_level INT DEFAULT 3, -- Priority level 1-5
        role_enum VARCHAR(20) NOT NULL, -- ‘COURSE_TASK’ or 'PERSONAL_TASK'
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE,
        FOREIGN KEY (creator_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Subtask Template Table
CREATE TABLE SUB_TASK_TEMPLATE (
        template_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        main_task_id BIGINT NOT NULL,
        title VARCHAR(200) NOT NULL,
        description TEXT,
        estimated_hours DECIMAL(5,2) DEFAULT 1.0,
        sequence_order INT NOT NULL DEFAULT 1,
        planned_start DATETIME,
        planned_end DATETIME,
        FOREIGN KEY (main_task_id) REFERENCES MAIN_TASK(main_task_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Student Progress/Subtask Instance Table
CREATE TABLE STUDENT_SUB_TASK (
        student_sub_task_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        student_id BIGINT NOT NULL,
        template_id BIGINT NOT NULL,
        custom_title VARCHAR(200) NULL, -- Allow students to customize the title
        custom_description TEXT NULL,
        custom_planned_start_time DATETIME NULL,
        custom_planned_end_time DATETIME NULL,
        completed_time DATETIME NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED', -- 'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'
        notes TEXT,
        CONSTRAINT idx_student_template UNIQUE (student_id, template_id), -- Each student has only one instance record for a template
        FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
        FOREIGN KEY (template_id) REFERENCES SUB_TASK_TEMPLATE(template_id) ON DELETE CASCADE
) ENGINE=InnoDB;