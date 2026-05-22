# StudyPal

StudyPal is a database-focused Java Web coursework project for university students who need to manage courses, coursework tasks, schedules, and study sessions.

The application uses Java Servlet/JSP, pure JDBC, and MySQL. It does not use Spring, Spring MVC, Hibernate, JPA, MyBatis, or any ORM framework.

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
