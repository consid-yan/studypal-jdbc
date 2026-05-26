-- StudyPal test data.
-- Run after schema.sql.

USE studypal;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE study_session;
TRUNCATE TABLE student_sub_task;
TRUNCATE TABLE sub_task_template;
TRUNCATE TABLE main_task;
TRUNCATE TABLE enrollment;
TRUNCATE TABLE course;
TRUNCATE TABLE user;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO user (username, email, password_hash, full_name, role) VALUES
    ('admin', 'admin@studypal.test', 'demo-password-hash', 'System Admin', 'ADMIN'),
    ('jsmith', 'jsmith@studypal.test', 'demo-password-hash', 'Dr. John Smith', 'LECTURER'),
    ('sjohnson', 'sjohnson@studypal.test', 'demo-password-hash', 'Dr. Sarah Johnson', 'LECTURER'),
    ('mbrown', 'mbrown@studypal.test', 'demo-password-hash', 'Dr. Michael Brown', 'LECTURER'),
    ('edavis', 'edavis@studypal.test', 'demo-password-hash', 'Dr. Emily Davis', 'LECTURER'),
    ('alexchen', 'alexchen@studypal.test', 'demo-password-hash', 'Alex Chen', 'STUDENT'),
    ('mayaliu', 'mayaliu@studypal.test', 'demo-password-hash', 'Maya Liu', 'STUDENT'),
    ('benzhou', 'benzhou@studypal.test', 'demo-password-hash', 'Ben Zhou', 'STUDENT'),
    ('ninaroy', 'ninaroy@studypal.test', 'demo-password-hash', 'Nina Roy', 'STUDENT'),
    ('sampark', 'sampark@studypal.test', 'demo-password-hash', 'Sam Park', 'STUDENT');

INSERT INTO course (course_code, course_name, lecturer_id, semester, description) VALUES
    (
        'COMP2013J',
        'Databases and Information Systems',
        2,
        'Spring 2026',
        'Database design, SQL, JDBC, and web application integration.'
    ),
    (
        'COMP2014J',
        'Data Structures and Algorithms II',
        3,
        'Spring 2026',
        'Advanced data structures including balanced trees and graph algorithms.'
    ),
    (
        'COMP2015J',
        'Software Engineering',
        4,
        'Spring 2026',
        'Software design patterns, teamwork, and project management.'
    ),
    (
        'MATH2001J',
        'Discrete Mathematics',
        5,
        'Spring 2026',
        'Logic, sets, combinatorics, and proof techniques.'
    );

INSERT INTO enrollment (student_id, course_id) VALUES
    (6, 1), (6, 2), (6, 3),
    (7, 1), (7, 2), (7, 4),
    (8, 1), (8, 3), (8, 4),
    (9, 1), (9, 2), (9, 3),
    (10, 1), (10, 2), (10, 4);

INSERT INTO main_task (
    course_id,
    title,
    description,
    deadline,
    importance_level
) VALUES
    (
        1,
        'StudyPal database project',
        'Complete the database design and JDBC implementation for StudyPal.',
        '2026-06-01 23:59:59',
        'VERY_HIGH'
    ),
    (
        2,
        'AVL tree implementation',
        'Implement AVL tree insertion, deletion, search, and rebalancing in Java.',
        '2026-05-25 23:59:59',
        'HIGH'
    ),
    (
        3,
        'Design pattern report',
        'Analyze how the Command pattern can be used in a coursework project.',
        '2026-05-30 23:59:59',
        'MEDIUM'
    ),
    (
        1,
        'Advanced SQL deliverables',
        'Prepare views, triggers, stored procedures, and advanced query examples.',
        '2026-05-28 23:59:59',
        'VERY_HIGH'
    );

INSERT INTO sub_task_template (
    main_task_id,
    title,
    description,
    estimated_hours,
    sequence_order,
    planned_start,
    planned_end
) VALUES
    (1, 'Analyze requirements and design ER diagram', 'Identify StudyPal entities and relationships.', 4.00, 1, '2026-05-15 09:00:00', '2026-05-16 18:00:00'),
    (1, 'Convert ER diagram to relational model', 'Define tables, primary keys, and foreign keys.', 3.00, 2, '2026-05-17 09:00:00', '2026-05-17 18:00:00'),
    (1, 'Write schema.sql', 'Create database tables, constraints, and indexes.', 2.00, 3, '2026-05-18 09:00:00', '2026-05-18 12:00:00'),
    (1, 'Implement DAO layer', 'Implement direct JDBC access for all core tables.', 8.00, 4, '2026-05-19 09:00:00', '2026-05-21 18:00:00'),
    (1, 'Write test data script', 'Create realistic SQL data for local testing.', 2.00, 5, '2026-05-20 14:00:00', '2026-05-20 18:00:00'),
    (1, 'Create views and triggers', 'Add reporting views and consistency triggers.', 3.00, 6, '2026-05-22 09:00:00', '2026-05-22 18:00:00'),
    (1, 'Create stored procedures', 'Add procedures for batch template creation and student copies.', 2.00, 7, '2026-05-23 09:00:00', '2026-05-23 12:00:00'),
    (1, 'Write advanced SQL queries', 'Add examples for progress and study analysis.', 3.00, 8, '2026-05-23 14:00:00', '2026-05-24 12:00:00'),
    (1, 'Run integration testing', 'Test all web flows and database operations together.', 4.00, 9, '2026-05-25 09:00:00', '2026-05-27 18:00:00'),
    (1, 'Write project report', 'Document the database design and team contribution.', 6.00, 10, '2026-05-28 09:00:00', '2026-05-31 18:00:00'),
    (2, 'Review AVL tree rotations', 'Study single and double rotations.', 2.00, 1, '2026-05-20 19:00:00', '2026-05-20 21:00:00'),
    (2, 'Implement base AVL tree', 'Code insert, delete, search, and height updates.', 5.00, 2, '2026-05-21 19:00:00', '2026-05-23 18:00:00'),
    (2, 'Implement tri-node restructuring', 'Add restructuring logic for rebalancing.', 4.00, 3, '2026-05-24 09:00:00', '2026-05-24 18:00:00'),
    (2, 'Write AVL tree tests', 'Verify rotations and ordering after updates.', 3.00, 4, '2026-05-25 09:00:00', '2026-05-25 18:00:00');

-- Alex Chen (student_id = 6): detailed progress for main task 1 and 2.
INSERT INTO student_sub_task (
    student_id,
    template_id,
    completed_time,
    status,
    notes
) VALUES
    (6, 1, '2026-05-16 17:30:00', 'COMPLETED', 'Finished ER draft early.'),
    (6, 2, '2026-05-17 17:00:00', 'COMPLETED', NULL),
    (6, 3, '2026-05-18 11:30:00', 'COMPLETED', NULL),
    (6, 4, NULL, 'IN_PROGRESS', 'Working on MainTaskDao refactor.'),
    (6, 5, '2026-05-20 16:00:00', 'COMPLETED', NULL),
    (6, 6, NULL, 'TODO', NULL),
    (6, 7, NULL, 'TODO', NULL),
    (6, 8, NULL, 'TODO', NULL),
    (6, 9, NULL, 'TODO', NULL),
    (6, 10, NULL, 'TODO', NULL),
    (6, 11, '2026-05-20 21:00:00', 'COMPLETED', NULL),
    (6, 12, NULL, 'IN_PROGRESS', NULL),
    (6, 13, NULL, 'TODO', NULL),
    (6, 14, NULL, 'TODO', NULL);

-- Maya Liu (student_id = 7): partial progress on main task 1.
INSERT INTO student_sub_task (
    student_id,
    template_id,
    completed_time,
    status,
    notes
) VALUES
    (7, 1, '2026-05-16 18:30:00', 'COMPLETED', NULL),
    (7, 2, NULL, 'IN_PROGRESS', NULL),
    (7, 3, NULL, 'TODO', NULL),
    (7, 4, NULL, 'TODO', NULL),
    (7, 5, NULL, 'TODO', NULL),
    (7, 6, NULL, 'TODO', NULL),
    (7, 7, NULL, 'TODO', NULL),
    (7, 8, NULL, 'TODO', NULL),
    (7, 9, NULL, 'TODO', NULL),
    (7, 10, NULL, 'TODO', NULL);

-- Other enrolled students receive default TODO copies for main task 1 templates.
INSERT INTO student_sub_task (
    student_id,
    template_id,
    status
)
SELECT
    e.student_id,
    st.template_id,
    'TODO'
FROM enrollment e
JOIN main_task mt ON e.course_id = mt.course_id
JOIN sub_task_template st ON mt.main_task_id = st.main_task_id
WHERE mt.main_task_id = 1
  AND e.student_id NOT IN (6, 7);

-- Default TODO copies for main task 2 templates for enrolled students except Alex Chen.
INSERT INTO student_sub_task (
    student_id,
    template_id,
    status
)
SELECT
    e.student_id,
    st.template_id,
    'TODO'
FROM enrollment e
JOIN main_task mt ON e.course_id = mt.course_id
JOIN sub_task_template st ON mt.main_task_id = st.main_task_id
WHERE mt.main_task_id = 2
  AND e.student_id <> 6;

INSERT INTO study_session (
    student_id,
    student_sub_task_id,
    start_time,
    end_time,
    session_type,
    notes
) VALUES
    (6, 1, '2026-05-15 09:30:00', '2026-05-15 13:00:00', 'ACTUAL', 'Drafted the first requirement list.'),
    (6, 1, '2026-05-16 10:00:00', '2026-05-16 10:30:00', 'ACTUAL', 'Refined the ER diagram.'),
    (6, 2, '2026-05-17 09:00:00', '2026-05-17 12:00:00', 'ACTUAL', 'Mapped entities into relational tables.'),
    (6, 3, '2026-05-18 09:00:00', '2026-05-18 11:30:00', 'ACTUAL', 'Created schema.sql with constraints and indexes.'),
    (6, 5, '2026-05-20 14:00:00', '2026-05-20 16:00:00', 'ACTUAL', 'Prepared the first test data script.'),
    (6, 4, '2026-05-19 09:00:00', '2026-05-19 12:00:00', 'ACTUAL', 'Implemented StudentDao and CourseDao.'),
    (6, 4, '2026-05-20 19:00:00', '2026-05-20 22:00:00', 'ACTUAL', 'Implemented task-related DAO methods.'),
    (6, 11, '2026-05-20 19:00:00', '2026-05-20 21:00:00', 'ACTUAL', 'Reviewed AVL tree balancing rules.'),
    (6, 12, '2026-05-21 19:00:00', '2026-05-21 21:30:00', 'ACTUAL', 'Started the AVL tree class structure.');
