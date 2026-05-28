USE studypal_db;

INSERT INTO USER_ACCOUNT (user_id, username, email, password_hash, full_name, role) VALUES
  (1, 'admin', 'admin@studypal.test', 'admin123', 'System Admin', 'ADMIN'),
  (2, 'lecturer', 'lecturer@studypal.test', 'lecturer123', 'Dr. Wang', 'LECTURER'),
  (3, 'student', 'student@studypal.test', 'student123', 'Lei Student', 'STUDENT');

INSERT INTO ADMIN (admin_id, admin_no, department, position) VALUES
  (1, 'ADM001', 'Academic Affairs', 'System Manager');

INSERT INTO LECTURER (lecturer_id, employee_no, department, title, office, phone) VALUES
  (2, 'EMP001', 'Computer Science', 'Lecturer', 'Room 301', '13800000002');

INSERT INTO STUDENT (student_id, student_no, major, grade, class_name, phone) VALUES
  (3, 'STU001', 'Software Engineering', 'Stage 2', 'SE-2401', '13800000003');

INSERT INTO COURSE (course_id, course_code, course_name, lecturer_id, semester, description) VALUES
  (1, 'DB101', 'Database Systems', 2, 'Spring 2026', 'Relational modeling, SQL, JDBC, and web integration.'),
  (2, 'JAVA201', 'Java Web Development', 2, 'Spring 2026', 'Servlet, JSP, and MVC-style web applications.');

INSERT INTO ENROLLMENT (student_id, course_id) VALUES
  (3, 1),
  (3, 2);

INSERT INTO MAIN_TASK (main_task_id, course_id, creator_id, title, description, deadline, importance_level, role_enum) VALUES
  (1, 1, 2, 'StudyPal JDBC Integration', 'Finish the database-backed StudyPal pages and verify role workflows.', '2026-06-05 23:59:00', 5, 'COURSE_TASK'),
  (2, 2, 2, 'JSP Page Review', 'Review page routing, form submissions, and session guards.', '2026-06-10 18:00:00', 3, 'COURSE_TASK');

INSERT INTO SUB_TASK_TEMPLATE (template_id, main_task_id, title, description, estimated_hours, sequence_order) VALUES
  (1, 1, 'Create schema', 'Run the SQL schema and confirm all core tables exist.', 1.5, 1),
  (2, 1, 'Wire services', 'Connect JSP pages to JDBC service methods.', 2.0, 2),
  (3, 1, 'Manual verification', 'Log in as each role and test the main workflows.', 1.0, 3),
  (4, 2, 'Check navigation', 'Verify sidebar links and detail pages.', 1.0, 1),
  (5, 2, 'Check permissions', 'Confirm users cannot open pages for another role.', 1.0, 2);

INSERT INTO STUDENT_SUB_TASK (student_id, template_id, status, notes, completed_time) VALUES
  (3, 1, 'COMPLETED', 'Schema imported successfully.', '2026-05-28 10:30:00'),
  (3, 2, 'IN_PROGRESS', 'Services are being checked through the UI.', NULL),
  (3, 3, 'NOT_STARTED', NULL, NULL),
  (3, 4, 'IN_PROGRESS', 'Navigation mostly works.', NULL),
  (3, 5, 'NOT_STARTED', NULL, NULL);
