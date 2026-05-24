# StudyPal

StudyPal is a database-focused Java Web coursework project for academic support scenarios where advisors, tutors, teaching assistants, and students need to track coursework pressure, study plans, schedules, and actual study effort across multiple students.

The application uses Java Servlet/JSP, pure JDBC, and MySQL. It does not use Spring, Spring MVC, Hibernate, JPA, MyBatis, or any ORM framework.

## Project Positioning

StudyPal is not positioned as a single-user personal todo list. A pure single-student todo tool would not strongly justify tables such as `student`, `enrollment`, `schedule_slot`, and `study_session`.

The project is positioned as a student coursework planning and study tracking system for university academic support scenarios. It helps advisors, tutors, teaching assistants, learning support staff, and students understand coursework load, break large assignments into manageable steps, schedule study time, record actual learning effort, and identify procrastination or academic risk early.

In this positioning, the `student` table is not just a login account table. It is the central entity being tracked by the system. Each student can enroll in different courses, have different coursework tasks, maintain a personal schedule, record study sessions, and show different workload or delay patterns.

### Target Users

Primary users:

- Academic advisors, tutors, teaching assistants, and learning support center staff who need to monitor multiple students and provide study guidance.
- University instructors or course support staff who want to understand whether students are overloaded, falling behind, or spending enough time on course tasks.

Secondary users:

- University students who need to organize coursework, decompose assignments, plan study sessions, and reflect on actual study time.

### Value to Users

- Make each student's coursework pressure visible across all enrolled courses.
- Help students and advisors decide which tasks should be handled first based on deadline, importance, task progress, and actual study effort.
- Turn large coursework items into executable sub-tasks with planned time ranges and dependency relationships.
- Compare estimated study effort with actual study sessions, so students can understand whether they are underestimating work.
- Support early intervention by identifying overdue tasks, insufficient study time, overloaded schedules, or repeated procrastination patterns.

## Database Design Rationale

The current database design is built around a multi-student academic support model:

- `student` represents each learner being tracked. It supports advisor-facing views such as a student's courses, workload, task progress, schedule, study records, and risk indicators.
- `course` represents university courses. It allows the system to analyze which courses create the most tasks, deadlines, or study effort.
- `enrollment` connects students and courses. It is necessary because one student can take many courses, and one course can include many students.
- `main_task` stores course-level coursework items such as assignments, exams, projects, and readings for a specific student.
- `sub_task` decomposes a large task into smaller executable steps, making progress easier to plan and monitor.
- `task_dependency` models prerequisite relationships between sub-tasks, so the system can explain why a task is blocked.
- `schedule_slot` stores each student's class time, free time, and unavailable time, which allows the system to reason about whether a student has enough available time to complete planned work.
- `study_session` records actual study effort. It allows comparison between planned work and real learning behavior.

This design gives the project a stronger database purpose than a simple task list. The system can answer questions such as:

- Which students are overloaded this week?
- Which courses create the most workload?
- Which tasks are blocked by unfinished prerequisites?
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

Models are plain Java objects that map closely to database tables. DAOs contain direct JDBC database access. Services coordinate DAOs and hold application rules. Servlets receive browser requests and forward to JSP pages.

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

`ScheduleSlot` supports timetable blocks and conflict detection. Task priority is calculated dynamically and is not stored as a persistent model field.

## Web Layer

Servlets use Jakarta Servlet APIs and annotation-based routing:

```text
DashboardServlet      /dashboard
CourseServlet         /courses
MainTaskServlet       /main-tasks
SubTaskServlet        /sub-tasks
TaskDetailServlet     /task-detail
ScheduleServlet       /schedule
StudySessionServlet   /study-sessions
```

`src/main/webapp/index.jsp` forwards to `/dashboard`. JSP files are stored under `src/main/webapp/WEB-INF/jsp/` so they are reached through servlets rather than direct browser URLs.

`AppStartupListener` listens for application startup and shutdown events. `ServletLogUtil` records system exceptions through the Servlet container log while leaving expected business validation errors as page-level messages.

## SQL Scripts

Database scripts are stored in the `sql/` folder:

```text
schema.sql            Creates the database tables
insert_test_data.sql  Inserts sample data
queries.sql           Stores useful test and report queries
procedures.sql        Stores stored procedures
triggers.sql          Stores database triggers
views.sql             Stores database views
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
