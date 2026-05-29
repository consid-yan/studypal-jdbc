-- =========================================================================
-- 核心设计说明：
-- 1. 采用 utf8mb4 字符集，完美支持中文。
-- 2. 严格遵循 EER 映射规范，STUDENT/LECTURER/ADMIN 主键同时作为指向 USER_ACCOUNT 的外键。
-- 3. 建表顺序严格按照外键依赖拓扑结构排布。
-- 4. 设置了完善的级联删除（ON DELETE CASCADE）和唯一约束。
-- =========================================================================

-- =========================================================================
-- 0. 环境准备与数据库创建
-- =========================================================================
DROP DATABASE IF EXISTS studypal_db;
CREATE DATABASE studypal_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE studypal_db;


-- =========================================================================
-- 1. 用户中心模块表结构 (User Management)
-- =========================================================================

-- 用户基表 (Supertype)
CREATE TABLE USER_ACCOUNT (
        user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        email VARCHAR(100) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(100) NOT NULL,
        role VARCHAR(20) NOT NULL, -- 枚举值: 'STUDENT', 'LECTURER', 'ADMIN'
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 讲师详情表 (Subtype)
CREATE TABLE LECTURER (
        lecturer_id BIGINT PRIMARY KEY, -- 既是主键，又是外键
        employee_no VARCHAR(50) NOT NULL UNIQUE,
        department VARCHAR(100) NOT NULL,
        title VARCHAR(50),
        office VARCHAR(100),
        phone VARCHAR(20),
        FOREIGN KEY (lecturer_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 学生详情表 (Subtype)
CREATE TABLE STUDENT (
        student_id BIGINT PRIMARY KEY, -- 既是主键，又是外键
        student_no VARCHAR(50) NOT NULL UNIQUE,
        major VARCHAR(100) NOT NULL,
        grade VARCHAR(20) NOT NULL,
        class_name VARCHAR(50),
        phone VARCHAR(20),
        FOREIGN KEY (student_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 管理员详情表 (Subtype)
CREATE TABLE ADMIN (
        admin_id BIGINT PRIMARY KEY, -- 既是主键，又是外键
        admin_no VARCHAR(50) NOT NULL UNIQUE,
        department VARCHAR(100) NOT NULL,
        position VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (admin_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================================
-- 2. 课程与选课模块表结构 (Course & Enrollment)
-- =========================================================================

-- 课程表
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

-- 选课表 (M:N 映射中间表)
CREATE TABLE ENROLLMENT (
        enrollment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        student_id BIGINT NOT NULL,
        course_id BIGINT NOT NULL,
        enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT idx_student_course UNIQUE (student_id, course_id), -- 联合唯一约束，防止重复选课
        FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================================
-- 3. 任务与进度管理模块表结构 (Task & Progress)
-- =========================================================================

-- 主任务表
CREATE TABLE MAIN_TASK (
        main_task_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        course_id BIGINT NULL, -- 允许为 NULL。NULL 代表学生的“自主任务”，非 NULL 代表“课程任务”
        creator_id BIGINT NOT NULL, -- 关联创建者（学生或讲师）
        title VARCHAR(200) NOT NULL,
        description TEXT,
        deadline DATETIME NOT NULL,
        importance_level INT DEFAULT 3, -- 1-5 优先级
        role_enum VARCHAR(20) NOT NULL, -- 'COURSE_TASK' 或 'PERSONAL_TASK'
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE,
        FOREIGN KEY (creator_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 子任务模板表
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

-- 学生进度/子任务实例表
CREATE TABLE STUDENT_SUB_TASK (
        student_sub_task_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        student_id BIGINT NOT NULL,
        template_id BIGINT NOT NULL,
        custom_title VARCHAR(200) NULL, -- 允许学生个性化修改标题
        custom_description TEXT NULL,
        custom_planned_start_time DATETIME NULL,
        custom_planned_end_time DATETIME NULL,
        completed_time DATETIME NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED', -- 'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'
        notes TEXT,
        CONSTRAINT idx_student_template UNIQUE (student_id, template_id), -- 每个学生对一个模板只有一条实例记录
        FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
        FOREIGN KEY (template_id) REFERENCES SUB_TASK_TEMPLATE(template_id) ON DELETE CASCADE
) ENGINE=InnoDB;