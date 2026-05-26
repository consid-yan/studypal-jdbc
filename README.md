# StudyPal

StudyPal is a database-focused Java Web coursework project for academic support scenarios where advisors, tutors, teaching assistants, and students need to track coursework pressure, study plans, schedules, and actual study effort across multiple students.

The application uses Java Servlet/JSP, pure JDBC, and MySQL. It does not use Spring, Spring MVC, Hibernate, JPA, MyBatis, or any ORM framework.

## Project Positioning

StudyPal is not positioned as a single-user personal todo list. A pure single-student todo tool would not strongly justify shared course tasks, `enrollment`, role-based `user` records, student-template progress records, reporting views, and study-session analytics.

The project is positioned as a student coursework planning and study tracking system for university academic support scenarios. It helps advisors, tutors, teaching assistants, learning support staff, and students understand coursework load, break large assignments into manageable steps, plan study time, record actual learning effort, and identify procrastination or academic risk early.

In this positioning, students are represented by rows in the shared `user` table with role `STUDENT`. A student can enroll in different courses, receive student-specific progress records linked to course-level sub-task templates, update individual progress, record study sessions, and show different workload or delay patterns.

### Target Users

Primary users:

- Academic advisors, tutors, teaching assistants, and learning support center staff who need to monitor multiple students and provide study guidance.
- University instructors or course support staff who want to understand whether students are overloaded, falling behind, or spending enough time on course tasks.

Secondary users:

- University students who need to organize coursework, decompose assignments, plan study sessions, and reflect on actual study time.

### Value to Users

- Make each student's coursework pressure visible across all enrolled courses.
- Help students and advisors decide which tasks should be handled first based on deadline, importance, task progress, and actual study effort.
- Turn large coursework items into reusable sub-task templates and student-specific progress records.
- Compare estimated study effort with actual study sessions, so students can understand whether they are underestimating work.
- Support early intervention by identifying urgent tasks, insufficient study time, low progress, or repeated procrastination patterns.

## Database Design Rationale

The current database design is built around a multi-role, multi-student academic support model:

- `user` stores administrators, lecturers, and students in one account table. The `role` column identifies whether a row is an `ADMIN`, `LECTURER`, or `STUDENT`.
- `course` represents university courses and links each course to a lecturer through `lecturer_id`.
- `enrollment` connects students and courses. It is necessary because one student can take many courses, and one course can include many students.
- `main_task` stores course-level coursework items such as assignments, exams, projects, and readings.
- `sub_task_template` decomposes a course-level task into reusable steps with estimated hours, sequence order, and planned time ranges.
- `student_sub_task` links students to shared templates and stores only student-specific progress or override fields, such as status, completion time, notes, and optional personal title/description/planned-time adjustments.
- `study_session` records planned or actual study effort for a student, optionally linked to a student-specific sub-task. Duration is calculated from `start_time` and `end_time` in queries and views rather than stored as a base-table column.
- Reporting views calculate task priority, main-task progress, study efficiency, daily study totals, and course workload summaries.
- Stored procedures batch-create templates, create student-template progress records, and generate procrastination reports.
- The schema avoids storing derived duration values in base tables, keeping reporting calculations in views and queries.

The schema is designed to align with Third Normal Form (3NF):

- Course, lecturer, enrollment, task template, student progress, and study-session facts are stored in separate relations.
- `course` stores `lecturer_id` rather than duplicating lecturer names.
- `enrollment` represents the many-to-many relationship between students and courses.
- `student_sub_task` stores student-specific facts and optional overrides; default title, description, estimates, and planned time remain in `sub_task_template`.
- `study_session.duration_hours` is not stored because it is derived from `start_time` and `end_time`.

The project intentionally keeps administrators, lecturers, and students in one `user` table with a `role` column. This still satisfies the current 3NF design because the current version has no role-specific profile attributes. If future requirements add student numbers, majors, lecturer offices, or academic titles, those fields should be moved into `student_profile` and `lecturer_profile` tables keyed by `user_id`.

This design gives the project a stronger database purpose than a simple task list. The system can answer questions such as:

- Which students are overloaded this week?
- Which courses create the most workload?
- Which students spend less time than expected on high-priority coursework?
- Which students repeatedly complete tasks late?
- How different is a student's estimated workload from actual study time?

## Project Structure

```text
StudyPal/
+-- .github/
+-- .mvn/
+-- docs/
|   +-- README.md
+-- lib/
|   +-- README.md
+-- preview/
|   +-- courses.html
|   +-- dashboard.html
|   +-- index.html
|   +-- main-tasks.html
|   +-- schedule.html
|   +-- study-sessions.html
|   +-- sub-tasks.html
|   +-- task-detail.html
+-- sql/
|   +-- schema.sql
|   +-- insert_test_data.sql
|   +-- queries.sql
|   +-- procedures.sql
|   +-- triggers.sql
|   +-- views.sql
+-- src/
|   +-- main/
|       +-- java/
|       |   +-- com/
|       |       +-- studypal/
|       |           +-- dao/
|       |           +-- exception/
|       |           +-- listener/
|       |           +-- model/
|       |           +-- service/
|       |           +-- servlet/
|       |           +-- util/
|       +-- webapp/
|           +-- assets/
|           |   +-- css/
|           |   |   +-- style.css
|           |   +-- js/
|           |       +-- app.js
|           +-- WEB-INF/
|           |   +-- jsp/
|           |   |   +-- common/
|           |   |   |   +-- header.jsp
|           |   |   +-- course-list.jsp
|           |   |   +-- dashboard.jsp
|           |   |   +-- main-task-list.jsp
|           |   |   +-- schedule.jsp
|           |   |   +-- study-statistics.jsp
|           |   |   +-- sub-task-list.jsp
|           |   |   +-- task-detail.jsp
|           |   +-- web.xml
|           +-- index.jsp
+-- LICENSE
+-- pom.xml
+-- README.md
```

## Architecture

StudyPal follows a simple coursework-friendly layered structure:

```text
JSP pages -> Servlets -> Services -> DAOs -> MySQL
```

Models are intended to map closely to database tables. DAOs contain direct JDBC database access. Services coordinate DAOs and hold application rules. Servlets receive browser requests and forward to JSP pages.

The SQL scripts are the current source of truth for the refactored database design. Some Java model, DAO, service, servlet, and JSP files still reflect the pre-refactor table names and should be migrated before the full web application is run against the current schema.

This is a traditional WAR-based Servlet/JSP application. It does not have a `public static void main` startup class. The application is started by a Jakarta Servlet container such as Tomcat 10.1+.

## Main Packages

```text
com.studypal.model      Domain models and enums
com.studypal.dao        JDBC data access classes
com.studypal.service    Application rules and orchestration
com.studypal.servlet    HTTP request handlers
com.studypal.listener   Servlet container lifecycle listeners
com.studypal.util       Shared utility classes
com.studypal.exception  Custom runtime exceptions
```

## Core Database Entities

The current SQL schema centers on these core entities:

```text
user
course
enrollment
main_task
sub_task_template
student_sub_task
study_session
```

Task priority, progress, study efficiency, and course workload summaries are calculated dynamically through SQL views and are not stored as persistent model fields.

After the database refactor, the core Java web flows should use the current SQL schema instead of pre-refactor table-backed queries. Legacy schedule and dependency classes may remain as compatibility shells until those features are redesigned.

## Java Schema Migration Plan

This implementation round aligns the Java web layer with the current SQL schema:

- Course, main-task, student sub-task, and study-session pages keep create, read, update, and delete flows.
- Course records use `lecturer_id` and display lecturer names from `user` rows with role `LECTURER`.
- Main tasks are course-level records. Student progress is tracked through `student_sub_task`, not through `main_task.status`.
- Sub-task screens display student-specific sub-tasks by joining `student_sub_task` with `sub_task_template` and applying personal overrides with `COALESCE`.
- Study sessions link to `study_session.student_sub_task_id`; displayed duration is calculated dynamically.
- The schedule page is not exposed in navigation because the refactored schema does not include schedule slots.

## Current Table Structure

`schema.sql` creates the following current tables:

```text
user
- user_id
- username
- email
- password_hash
- full_name
- role
- created_at

course
- course_id
- course_code
- course_name
- lecturer_id
- semester
- description
- created_at

enrollment
- enrollment_id
- student_id
- course_id
- enrollment_date

main_task
- main_task_id
- course_id
- title
- description
- deadline
- importance_level
- created_at

sub_task_template
- template_id
- main_task_id
- title
- description
- estimated_hours
- sequence_order
- planned_start
- planned_end
- created_at

student_sub_task
- student_sub_task_id
- student_id
- template_id
- custom_title
- custom_description
- custom_planned_start_time
- custom_planned_end_time
- completed_time
- status
- notes
- created_at
- updated_at

study_session
- study_session_id
- student_id
- student_sub_task_id
- start_time
- end_time
- session_type
- notes
```

`duration_hours` appears in some DAO result objects and reporting views as a calculated value:

```text
ROUND(TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60, 2)
```

## Web Layer

Servlets use Jakarta Servlet APIs and annotation-based routing. The current codebase includes these routes:

```text
DashboardServlet      /dashboard
CourseServlet         /courses
MainTaskServlet       /main-tasks
SubTaskServlet        /sub-tasks
TaskDetailServlet     /task-detail
ScheduleServlet       /schedule
StudySessionServlet   /study-sessions
```

The `/schedule` route is left as a compatibility shell and is not exposed in navigation because the refactored SQL schema no longer stores standalone schedule slots.

`src/main/webapp/index.jsp` forwards to `/dashboard`. JSP files are stored under `src/main/webapp/WEB-INF/jsp/` so they are reached through servlets rather than direct browser URLs.

`AppStartupListener` listens for application startup and shutdown events. `ServletLogUtil` records system exceptions through the Servlet container log while leaving expected business validation errors as page-level messages.

## SQL Scripts

Database scripts are stored in the `sql/` folder. Run `schema.sql` first, then load optional views, procedures, triggers, and sample data as needed:

```text
schema.sql            Creates the database, tables, constraints, and indexes
views.sql             Creates reporting views for priority, progress, efficiency, study stats, and workload
procedures.sql        Creates stored procedures for template creation, student-template records, and reports
triggers.sql          Removes legacy triggers; no duration trigger is required in the 3NF schema
insert_test_data.sql  Inserts sample users, courses, tasks, sub-task templates, student progress records, and sessions
queries.sql           Stores useful test and report queries
```

## Build and Deployment

Build the WAR package with Maven:

```powershell
mvn clean package
```

The generated WAR uses the final name configured in `pom.xml`:

```text
target/studypal.war
```

Deploy the WAR to Tomcat 10.1+ and visit:

```text
http://localhost:8080/studypal/
```

The default JDBC connection is configured in `DBUtil`:

```text
jdbc:mysql://localhost:3306/studypal?useSSL=false&serverTimezone=UTC
username: root
password: password
```

Update these values locally if your MySQL setup uses different credentials.

## Development Notes

- Use pure JDBC for database access.
- Use MySQL as the database.
- Use Jakarta Servlet imports for Tomcat 10.
- Keep model classes as simple POJOs.
- Keep SQL out of JSP pages.
- Keep calculated priority scores dynamic.
- Keep user-facing validation errors separate from system exception logging.
- Do not add unsupported tables, ORM frameworks, or unnecessary inheritance.
