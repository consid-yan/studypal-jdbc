# StudyPal

StudyPal is a database-focused Java Web coursework project for university students who need to manage courses, coursework tasks, schedules, and study sessions.

The application uses Java Servlet/JSP, pure JDBC, and MySQL. It does not use Spring, Spring MVC, Hibernate, JPA, MyBatis, or any ORM framework.

## Project Structure

```text
StudyPal/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── studypal/
│       │           ├── model/
│       │           ├── dao/
│       │           ├── service/
│       │           ├── servlet/
│       │           ├── util/
│       │           └── exception/
│       └── webapp/
│           ├── assets/
│           │   ├── css/
│           │   ├── js/
│           │   └── images/
│           ├── WEB-INF/
│           │   └── jsp/
│           └── index.jsp
├── sql/
├── docs/
├── lib/
├── pom.xml
└── README.md
```

## Layered Architecture

StudyPal follows a simple coursework-friendly layered structure:

```text
JSP pages -> Servlets -> Services -> DAOs -> MySQL
```

Models are plain Java objects that map closely to database tables. They do not contain JDBC code. DAOs contain direct JDBC database access. Services coordinate DAOs and hold application rules. Servlets receive browser requests and forward to JSP pages.

## Core Model Classes

The model package contains these core classes and enums:

```text
Student
Course
Enrollment
MainTask
SubTask
TaskDependency
ScheduleSlot
StudySession
TaskStatus
ImportanceLevel
SlotType
SessionType
```

The core database tables are:

```text
student
course
enrollment
schedule_slot
main_task
sub_task
task_dependency
study_session
```

`ScheduleSlot` is part of the database design and supports timetable blocks and conflict detection. The README, model layer, and SQL schema only describe tables that are part of the current database design.

## Task Design

`MainTask` represents a large coursework task. `SubTask` represents a smaller task under a main task. Both use the same `TaskStatus` enum:

```text
TODO
IN_PROGRESS
COMPLETED
CANCELLED
```

Tasks use `ImportanceLevel` for user-entered importance. A dynamic priority score can be calculated from importance and deadline or planned end time, but that score is not stored as a persistent model field.

## DAO Layer

The DAO layer contains one DAO class per main entity:

```text
StudentDAO
CourseDAO
EnrollmentDAO
MainTaskDAO
SubTaskDAO
TaskDependencyDAO
ScheduleSlotDAO
StudySessionDAO
```

DAO classes use `DBUtil` to obtain JDBC connections. SQL should stay in DAO classes or SQL script files, not in JSP pages or model classes.

## Service Layer

The service layer contains small classes for application rules:

```text
CourseService
TaskService
ScheduleService
StudySessionService
PriorityService
```

`PriorityService` calculates priority dynamically from `ImportanceLevel` and deadline or planned end time.

## Servlet and JSP Layer

Servlets use Jakarta Servlet APIs for Tomcat 10:

```text
DashboardServlet
CourseServlet
MainTaskServlet
SubTaskServlet
ScheduleServlet
StudySessionServlet
```

JSP pages are stored under `src/main/webapp/WEB-INF/jsp/` so they are reached through servlets rather than direct URLs.

## SQL Scripts

Database scripts are stored in the `sql/` folder:

```text
schema.sql
insert_test_data.sql
views.sql
triggers.sql
procedures.sql
queries.sql
```

`schema.sql` defines the intended MySQL tables for the current database design. Additional SQL features such as views, triggers, stored procedures, and test queries can be added in the matching files as the coursework develops.

## Development Notes

- Use pure JDBC for database access.
- Use MySQL as the database.
- Use Jakarta Servlet imports for Tomcat 10.
- Keep model classes as simple POJOs.
- Keep SQL out of JSP pages.
- Keep calculated priority scores dynamic.
- Do not add unsupported tables, ORM frameworks, or unnecessary inheritance.
