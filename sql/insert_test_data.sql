-- StudyPal test data.
-- Run after schema.sql.

USE studypal;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE study_session;
TRUNCATE TABLE task_dependency;
TRUNCATE TABLE sub_task;
TRUNCATE TABLE main_task;
TRUNCATE TABLE schedule_slot;
TRUNCATE TABLE enrollment;
TRUNCATE TABLE course;
TRUNCATE TABLE student;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO student (username, email, password_hash, full_name) VALUES
    ('alexchen', 'alexchen@studypal.test', 'demo-password-hash', 'Alex Chen'),
    ('mayaliu', 'mayaliu@studypal.test', 'demo-password-hash', 'Maya Liu'),
    ('benzhou', 'benzhou@studypal.test', 'demo-password-hash', 'Ben Zhou'),
    ('ninaroy', 'ninaroy@studypal.test', 'demo-password-hash', 'Nina Roy'),
    ('sampark', 'sampark@studypal.test', 'demo-password-hash', 'Sam Park');

INSERT INTO course (course_code, course_name, lecturer, semester) VALUES
    ('COMP2013J', 'Databases and Information Systems', 'Dr. John Smith', 'Spring 2026'),
    ('COMP2014J', 'Data Structures and Algorithms II', 'Dr. Sarah Johnson', 'Spring 2026'),
    ('COMP2015J', 'Software Engineering', 'Dr. Michael Brown', 'Spring 2026'),
    ('MATH2001J', 'Discrete Mathematics', 'Dr. Emily Davis', 'Spring 2026');

INSERT INTO enrollment (student_id, course_id) VALUES
    (1, 1), (1, 2), (1, 3),
    (2, 1), (2, 2), (2, 4),
    (3, 1), (3, 3), (3, 4),
    (4, 1), (4, 2), (4, 3),
    (5, 1), (5, 2), (5, 4);

INSERT INTO schedule_slot (student_id, slot_date, start_time, end_time, slot_type, title) VALUES
    (1, '2026-05-20', '09:00:00', '11:00:00', 'CLASS', 'COMP2013J Lecture'),
    (1, '2026-05-20', '14:00:00', '16:00:00', 'CLASS', 'COMP2014J Lab'),
    (1, '2026-05-21', '10:00:00', '12:00:00', 'CLASS', 'COMP2015J Tutorial'),
    (1, '2026-05-21', '16:00:00', '18:00:00', 'FREE', 'Study Time'),
    (1, '2026-05-22', '09:00:00', '11:00:00', 'CLASS', 'MATH2001J Lecture'),
    (1, '2026-05-22', '14:00:00', '17:00:00', 'FREE', 'Project Work');

INSERT INTO main_task (
    student_id,
    course_id,
    title,
    description,
    deadline,
    importance_level,
    status
) VALUES
    (
        1,
        1,
        'StudyPal database project',
        'Complete the database design and JDBC implementation for StudyPal.',
        '2026-06-01 23:59:59',
        'VERY_HIGH',
        'IN_PROGRESS'
    ),
    (
        1,
        2,
        'AVL tree implementation',
        'Implement AVL tree insertion, deletion, search, and rebalancing in Java.',
        '2026-05-25 23:59:59',
        'HIGH',
        'IN_PROGRESS'
    ),
    (
        1,
        3,
        'Design pattern report',
        'Analyze how the Command pattern can be used in a coursework project.',
        '2026-05-30 23:59:59',
        'MEDIUM',
        'TODO'
    ),
    (
        2,
        1,
        'Advanced SQL deliverables',
        'Prepare views, triggers, stored procedures, and advanced query examples.',
        '2026-05-28 23:59:59',
        'VERY_HIGH',
        'IN_PROGRESS'
    );

INSERT INTO sub_task (
    main_task_id,
    title,
    description,
    estimated_hours,
    planned_start_time,
    planned_end_time,
    completed_time,
    status
) VALUES
    (
        1,
        'Analyze requirements and design ER diagram',
        'Identify StudyPal entities and relationships.',
        4.00,
        '2026-05-15 09:00:00',
        '2026-05-16 18:00:00',
        '2026-05-16 17:30:00',
        'COMPLETED'
    ),
    (
        1,
        'Convert ER diagram to relational model',
        'Define tables, primary keys, and foreign keys.',
        3.00,
        '2026-05-17 09:00:00',
        '2026-05-17 18:00:00',
        '2026-05-17 17:00:00',
        'COMPLETED'
    ),
    (
        1,
        'Write schema.sql',
        'Create database tables, constraints, and indexes.',
        2.00,
        '2026-05-18 09:00:00',
        '2026-05-18 12:00:00',
        '2026-05-18 11:30:00',
        'COMPLETED'
    ),
    (
        1,
        'Implement DAO layer',
        'Implement direct JDBC access for all core tables.',
        8.00,
        '2026-05-19 09:00:00',
        '2026-05-21 18:00:00',
        NULL,
        'IN_PROGRESS'
    ),
    (
        1,
        'Write test data script',
        'Create realistic SQL data for local testing.',
        2.00,
        '2026-05-20 14:00:00',
        '2026-05-20 18:00:00',
        '2026-05-20 16:00:00',
        'COMPLETED'
    ),
    (
        1,
        'Create views and triggers',
        'Add reporting views and consistency triggers.',
        3.00,
        '2026-05-22 09:00:00',
        '2026-05-22 18:00:00',
        NULL,
        'TODO'
    ),
    (
        1,
        'Create stored procedures',
        'Add procedures for dependency checks and batch task creation.',
        2.00,
        '2026-05-23 09:00:00',
        '2026-05-23 12:00:00',
        NULL,
        'TODO'
    ),
    (
        1,
        'Write advanced SQL queries',
        'Add examples for dependency, schedule, and study analysis.',
        3.00,
        '2026-05-23 14:00:00',
        '2026-05-24 12:00:00',
        NULL,
        'TODO'
    ),
    (
        1,
        'Run integration testing',
        'Test all web flows and database operations together.',
        4.00,
        '2026-05-25 09:00:00',
        '2026-05-27 18:00:00',
        NULL,
        'TODO'
    ),
    (
        1,
        'Write project report',
        'Document the database design and team contribution.',
        6.00,
        '2026-05-28 09:00:00',
        '2026-05-31 18:00:00',
        NULL,
        'TODO'
    ),
    (
        2,
        'Review AVL tree rotations',
        'Study single and double rotations.',
        2.00,
        '2026-05-20 19:00:00',
        '2026-05-20 21:00:00',
        '2026-05-20 21:00:00',
        'COMPLETED'
    ),
    (
        2,
        'Implement base AVL tree',
        'Code insert, delete, search, and height updates.',
        5.00,
        '2026-05-21 19:00:00',
        '2026-05-23 18:00:00',
        NULL,
        'IN_PROGRESS'
    ),
    (
        2,
        'Implement tri-node restructuring',
        'Add restructuring logic for rebalancing.',
        4.00,
        '2026-05-24 09:00:00',
        '2026-05-24 18:00:00',
        NULL,
        'TODO'
    ),
    (
        2,
        'Write AVL tree tests',
        'Verify rotations and ordering after updates.',
        3.00,
        '2026-05-25 09:00:00',
        '2026-05-25 18:00:00',
        NULL,
        'TODO'
    );

INSERT INTO task_dependency (sub_task_id, depends_on_sub_task_id) VALUES
    (4, 3),
    (6, 5),
    (7, 6),
    (8, 7),
    (9, 8),
    (10, 9),
    (13, 12),
    (14, 13);

INSERT INTO study_session (
    student_id,
    sub_task_id,
    start_time,
    end_time,
    duration_hours,
    session_type,
    notes
) VALUES
    (1, 1, '2026-05-15 09:30:00', '2026-05-15 13:00:00', 3.50, 'ACTUAL', 'Drafted the first requirement list.'),
    (1, 1, '2026-05-16 10:00:00', '2026-05-16 10:30:00', 0.50, 'ACTUAL', 'Refined the ER diagram.'),
    (1, 2, '2026-05-17 09:00:00', '2026-05-17 12:00:00', 3.00, 'ACTUAL', 'Mapped entities into relational tables.'),
    (1, 3, '2026-05-18 09:00:00', '2026-05-18 11:30:00', 2.50, 'ACTUAL', 'Created schema.sql with constraints and indexes.'),
    (1, 5, '2026-05-20 14:00:00', '2026-05-20 16:00:00', 2.00, 'ACTUAL', 'Prepared the first test data script.'),
    (1, 4, '2026-05-19 09:00:00', '2026-05-19 12:00:00', 3.00, 'ACTUAL', 'Implemented StudentDao and CourseDao.'),
    (1, 4, '2026-05-20 19:00:00', '2026-05-20 22:00:00', 3.00, 'ACTUAL', 'Implemented task-related DAO methods.'),
    (1, 11, '2026-05-20 19:00:00', '2026-05-20 21:00:00', 2.00, 'ACTUAL', 'Reviewed AVL tree balancing rules.'),
    (1, 12, '2026-05-21 19:00:00', '2026-05-21 21:30:00', 2.50, 'ACTUAL', 'Started the AVL tree class structure.');
