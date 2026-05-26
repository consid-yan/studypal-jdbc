# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy

```bash
mvn clean package          # Build WAR -> target/studypal.war
mvn -B verify              # Build + run verification
```

No embedded server or `main` class. Deploy `target/studypal.war` to Tomcat 10.1+ (Jakarta Servlet 6.0). Access at `http://localhost:8080/studypal/`.

## Database Setup

Run SQL scripts in order against MySQL 8.4+:

```bash
mysql -u root -p < sql/schema.sql
mysql -u root -p studypal < sql/views.sql
mysql -u root -p studypal < sql/triggers.sql
mysql -u root -p studypal < sql/procedures.sql
mysql -u root -p studypal < sql/insert_test_data.sql
```

Connection defaults in `DBUtil`: `localhost:3306/studypal`, user `root`, password `password`. Override with env vars: `STUDYPAL_DB_URL`, `STUDYPAL_DB_USERNAME`, `STUDYPAL_DB_PASSWORD`.

## Architecture

```text
JSP pages -> Servlets -> Services -> DAOs -> MySQL (pure JDBC)
```

Packages: `com.studypal.{model, dao, service, servlet, listener, util, exception}`

Key design decisions:

- No ORM: pure JDBC with PreparedStatements. No Spring, Hibernate, JPA, or MyBatis.
- 3NF-oriented schema: templates and student progress are separated.
- Dynamic calculations: priority scores, progress, efficiency, and study duration are computed through SQL views, queries, or display logic rather than stored as redundant base-table values.
- Template pattern: `sub_task_template` stores reusable course-task steps; `student_sub_task` stores student-specific progress and optional `custom_*` overrides.
- Unified users: Admin, Lecturer, and Student are stored in `user` and separated by `role`. Add profile tables only if role-specific fields become required.
- Exception separation: system exceptions are logged via `ServletLogUtil`; expected validation errors are displayed as page-level messages.

## Core Tables

```text
user
course
enrollment
main_task
sub_task_template
student_sub_task
study_session
```

Important schema notes:

- `student_sub_task` has `custom_title`, `custom_description`, `custom_planned_start_time`, and `custom_planned_end_time`; display queries should use `COALESCE(custom value, template default)`.
- `study_session` does not store `duration_hours`; calculate it from `start_time` and `end_time`.
- `enrollment` links students to courses. Reporting views join enrollment, task templates, student progress records, and study sessions.

## Current Gaps

- MainTask is still editable/deletable in the Java web layer, while requirements say published MainTasks should be immutable.
- AI-generated SubTask templates, retry logic, and fallback templates are not yet implemented.
- Authentication, current-user resolution, and role-based authorization are not yet implemented.
- Student self-enrollment and automatic StudentSubTask record creation are not fully wired into the web flow.

## Constraints

- Java 25, Maven, WAR packaging.
- Jakarta Servlet 6.0 annotations (`@WebServlet`).
- JSPs live under `WEB-INF/jsp/` and are reached through servlets.
- Models are plain POJOs.
- Keep SQL out of JSP pages.
- Keep user-facing validation errors separate from system exception logging.
