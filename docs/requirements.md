# StudyPal Requirements Document

## 1. Product Positioning

StudyPal is a multi-student academic support system for university coursework planning and study progress tracking.

The system is designed for an academic support environment rather than a single-user personal todo list. It helps administrators, lecturers, and students manage course tasks, AI-generated study plans, student-specific sub-task progress, schedules, and actual study effort.

The core purpose of StudyPal is to make coursework pressure, student progress, and learning effort visible across courses and students.

## 2. Target Users

### 2.1 Admin

Admin users oversee the whole system. They can view all students, all courses, all main tasks, all sub-tasks, and student progress records.

Admin access is read-only for task and progress data. Admins are not responsible for creating course tasks or changing student progress.

### 2.2 Lecturer

Lecturers manage the courses they teach. Each course has exactly one lecturer.

Lecturers can create course-level main tasks. They can also view completion progress for the main tasks in their own courses.

Lecturers cannot manage courses owned by other lecturers.

### 2.3 Student

Students join courses by themselves. After joining a course, they can view the course's main tasks and manage their own personal sub-task records.

Students cannot create, edit, or delete course-level main tasks.

Students can update their own sub-task progress, adjust their own copied sub-task details, and record actual study sessions.

## 3. Core Product Concepts

### 3.1 Course

A course represents a university course. Each course belongs to exactly one lecturer.

Students can join courses without lecturer or admin approval. Once a student joins a course, the enrollment cannot be withdrawn.

### 3.2 MainTask

A MainTask is a course-level task created by a lecturer. Examples include assignments, exams, projects, readings, and coursework milestones.

MainTasks are owned by courses, not by individual students.

Once a MainTask is created and published, it cannot be edited or deleted. The system must show a confirmation popup before creation, warning the lecturer that the task cannot be changed after publishing.

### 3.3 SubTask Template

When a lecturer creates a MainTask, the system generates a set of shared SubTask templates for that MainTask.

The SubTask template represents the standard study plan or work breakdown for the task. It is shared at the course-task level.

Students do not directly edit the shared template.

### 3.4 Student SubTask

A Student SubTask is a student-specific progress record linked to a SubTask template.

Students can edit their own personal override fields, such as custom title, custom description, custom planned time, notes, and status. These edits do not affect other students or the original shared template.

Student progress is calculated from Student SubTasks rather than from the shared template.

### 3.5 Study Session

A Study Session records a student's actual study effort. It can be linked to a Student SubTask.

Study Sessions allow the system to compare planned work against actual effort. Duration is calculated from start and end time rather than stored as a separate base-table fact.

## 4. Functional Requirements

### 4.1 User Roles and Permissions

FR-001: The system must support three user roles: Admin, Lecturer, and Student.

FR-002: Admin users must be able to view all students, courses, main tasks, sub-tasks, and progress data.

FR-003: Admin users must have read-only access to task and progress data.

FR-004: Lecturer users must be able to create MainTasks only for courses they own.

FR-005: Lecturer users must be able to view student completion progress for MainTasks in their own courses.

FR-006: Student users must be able to join courses by themselves.

FR-007: Student users must be able to view MainTasks only for courses they have joined.

FR-008: Student users must not be able to create, edit, or delete MainTasks.

FR-009: Student users must be able to update and edit only their own Student SubTasks and Study Sessions.

## 4.2 Course Management

FR-010: Each course must have exactly one lecturer.

FR-011: A lecturer must only manage courses assigned to them.

FR-012: A student may join multiple courses.

FR-013: A course may contain multiple students.

FR-014: Student enrollment does not require approval.

FR-015: Once a student joins a course, the enrollment cannot be withdrawn.

FR-016: When a student joins a course, the system must create Student SubTask progress records for all existing MainTasks in that course.

## 4.3 MainTask Management

FR-017: Lecturers must be able to add MainTasks to their own courses.

FR-018: A MainTask must belong to one course.

FR-019: A MainTask must not belong directly to a student.

FR-020: A MainTask should include at least title, description, deadline, importance level, and course reference.

FR-021: Before creating a MainTask, the system must show a confirmation popup stating that the MainTask cannot be edited or deleted after publishing.

FR-022: After a MainTask is published, it must not be editable.

FR-023: After a MainTask is published, it must not be deletable.

FR-024: When a new MainTask is published, the system must generate SubTask templates for that MainTask.

FR-025: When a new MainTask is published, the system must create Student SubTask progress records for all students currently enrolled in the course.

## 4.4 AI SubTask Generation

FR-026: The system must call an AI API to generate SubTask templates when a lecturer creates a MainTask.

FR-027: The AI prompt should use MainTask information such as title, description, deadline, course information, and importance level.

FR-028: If AI generation fails, the system must retry up to three times.

FR-029: If AI generation still fails after three retries, the system must generate SubTask templates from a default fallback template.

FR-030: The default fallback template must include these four steps:

1. Understand requirements
2. Collect materials
3. Complete main work
4. Review and submit

FR-031: MainTask creation must still succeed even when the AI API fails, as long as the fallback template can be applied.

## 4.5 SubTask Template Management

FR-032: SubTask templates must belong to a MainTask.

FR-033: SubTask templates must be shared by all students in the course.

FR-034: SubTask templates should include title, description, estimated effort, planned sequence, and optional planned time range.

FR-035: Students must not directly edit shared SubTask templates.

FR-036: A shared SubTask template must be linked from Student SubTasks for each enrolled student.

## 4.6 Student SubTask Management

FR-037: Student SubTasks must belong to one student and one SubTask template.

FR-038: Student SubTasks must preserve a link to the original template.

FR-039: Students must be able to edit their own Student SubTask override fields without changing the shared template.

FR-040: Students must be able to update their own Student SubTask status.

FR-041: Student SubTask statuses should include TODO, IN_PROGRESS, COMPLETED, and CANCELLED.

FR-042: Students must be able to record completed time for their own Student SubTasks.

FR-043: Students must be able to add notes to their own Student SubTasks.

FR-044: Students must not be able to edit other students' Student SubTasks.

## 4.7 Progress Calculation

FR-045: Student progress for a MainTask must be calculated from the student's Student SubTasks.

FR-046: MainTask progress for a student must use this formula:

```text
completed_student_subtasks / total_student_subtasks * 100%
```

FR-047: If a student has no Student SubTasks for a MainTask, the progress should be displayed as "Not generated" or "Pending plan" rather than as a normal percentage.

FR-048: Lecturer progress views must show completion progress for students in their own courses.

FR-049: Admin progress views must show completion progress across all courses and students.

## 4.8 Study Sessions

FR-050: Students must be able to create Study Sessions for their own work.

FR-051: A Study Session may be linked to a Student SubTask.

FR-052: A Study Session must include start time.

FR-053: A Study Session may include end time, session type, and notes; duration is a calculated display/reporting value.

FR-054: If start time and end time are provided, the system should calculate duration automatically in queries, views, or application display logic.

FR-055: Students must only manage their own Study Sessions.

FR-056: Admins may view all Study Sessions.

FR-057: Lecturers may view Study Session summaries for students in their own courses when relevant to MainTask progress.

## 4.9 Dashboard and Reporting

FR-058: Admin dashboards must support system-wide views of student progress, course workload, overdue tasks, and study effort.

FR-059: Lecturer dashboards must show MainTask progress for students in the lecturer's own courses.

FR-060: Student dashboards must show enrolled courses, course MainTasks, personal Student SubTasks, deadlines, progress, and study records.

FR-061: The system should support identifying students who are overloaded, falling behind, or showing repeated late completion patterns.

FR-062: The system should support comparing estimated effort against actual study sessions.

## 5. Data Requirements

The target data model should separate course-level task definitions from student-specific progress.

### 5.1 Recommended Core Tables

`user`

- Stores login and role information.
- Supports Admin, Lecturer, and Student roles.

`student_profile` / `lecturer_profile` (future extension)

- Not required in the current schema because the current version has no role-specific profile attributes.
- If future requirements add student numbers, majors, lecturer offices, or academic titles, these profile tables should link to the corresponding `user` account by `user_id`.

`course`

- Stores course information.
- Includes `lecturer_id` because each course has exactly one lecturer.

`enrollment`

- Stores student-course membership.
- Students create enrollment records by joining courses.
- Enrollment has no withdrawal process in the current requirements.

`main_task`

- Stores course-level tasks created by lecturers.
- Belongs to `course`, not `student`.
- Immutable after creation.

`sub_task_template`

- Stores AI-generated shared task breakdown templates.
- Belongs to `main_task`.

`student_sub_task`

- Stores each student's progress record for a SubTask template.
- Belongs to a student user and references `sub_task_template`.
- Stores personal status, completed time, notes, and optional override fields for custom title, custom description, and custom planned time.

`study_session`

- Stores actual study effort.
- Belongs to a student user.
- May reference `student_sub_task`.
- Does not store derived duration; duration is calculated from `start_time` and `end_time`.

### 5.2 Important Data Design Rules

DR-001: `main_task` must not store `student_id`.

DR-002: `sub_task_template` must not store student-specific status.

DR-003: Student-specific progress must be stored in `student_sub_task`.

DR-004: `course` should store `lecturer_id` because one course has exactly one lecturer.

DR-005: `enrollment` should enforce one enrollment per student-course pair.

DR-006: `student_sub_task` should enforce one progress record per student-template pair.

DR-007: `study_session` should reference `student_sub_task` rather than a shared template when the session is about a specific student's work.

DR-008: Published MainTasks should be protected from update and delete operations.

DR-009: `study_session` should not store `duration_hours` as a base-table column because duration is functionally determined by `start_time` and `end_time`.

DR-010: `student_sub_task` should not duplicate template title, description, or planned time as default data. It should store only optional student-specific override values.

## 6. Non-Functional Requirements

NFR-001: The system must use Java Servlet/JSP, pure JDBC, and MySQL.

NFR-002: The system must not use Spring, Spring MVC, Hibernate, JPA, MyBatis, or any ORM framework.

NFR-003: The system should keep SQL out of JSP pages.

NFR-004: The system should keep business rules in service classes rather than directly in Servlets or JSP pages.

NFR-005: Database constraints should protect critical ownership and uniqueness rules.

NFR-006: AI API failure must not leave the database in a partially created state.

NFR-007: MainTask creation, AI template generation, and Student SubTask record creation should be handled as one consistent workflow.

NFR-008: User-facing validation errors should be separated from system exception logs.

NFR-009: The system should be designed so that future authentication and authorization checks can be added cleanly.

## 7. Out of Scope for Current Version

The following features are not required in the current version:

- Student course withdrawal.
- Lecturer approval for student enrollment.
- Multiple lecturers for one course.
- Editing or deleting published MainTasks.
- Draft MainTasks.
- Lecturer review of AI-generated SubTask templates before publishing.
- Student modification of shared SubTask templates.
- Full grade management.
- Messaging between lecturers and students.

## 8. Key User Stories

### Admin

As an Admin, I want to view all students' coursework progress so that I can identify students who may need academic support.

As an Admin, I want read-only access to all task and study records so that I can monitor the system without accidentally changing academic data.

### Lecturer

As a Lecturer, I want to create a MainTask for my course so that all enrolled students receive the same course task.

As a Lecturer, I want the system to generate SubTask templates automatically so that students receive a structured study plan.

As a Lecturer, I want to view student progress for each MainTask so that I can understand who is falling behind.

### Student

As a Student, I want to join a course by myself so that I can access its coursework tasks.

As a Student, I want to receive personal progress records linked to AI-generated SubTasks so that I can adjust my own study plan.

As a Student, I want to update my own SubTask statuses so that my progress is accurately reflected.

As a Student, I want to record study sessions so that I can compare planned work with actual effort.

## 9. Acceptance Criteria Summary

- The system supports Admin, Lecturer, and Student roles.
- Each course has exactly one Lecturer.
- Students can join courses without approval and cannot withdraw.
- Lecturers can only add MainTasks for their own courses.
- Published MainTasks cannot be edited or deleted.
- MainTasks belong to courses, not students.
- AI generates shared SubTask templates when a MainTask is created.
- AI generation retries up to three times before using the default fallback template.
- Students receive personal Student SubTask progress records linked to shared templates.
- Students may edit only their own Student SubTasks.
- Student MainTask progress is calculated from completed Student SubTasks.
- Admins can view all progress.
- Lecturers can view progress only for their own courses.
- Students can manage only their own progress and study records.
