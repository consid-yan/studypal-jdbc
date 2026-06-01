# StudyPal JDBC

StudyPal is a JSP + JDBC + MySQL learning task management system for the COMP2013J Database and Information Systems course project. It uses a lightweight JSP Model 1 architecture with plain JDBC (no ORM, no heavyweight MVC framework).

## Features

- Role-based login for students, lecturers, and administrators
- Course creation, enrollment, and course progress display
- Main task and sub-task management
- Student task progress updates and completion tracking
- Administrator user, course, and system overview pages
- Optional AI-assisted sub-task generation (OpenAI-compatible chat endpoint)

## Tech Stack

- Java 21
- Jakarta Servlet 6.0 / JSP (Jakarta namespace)
- JDBC
- MySQL 8+
- Apache Tomcat 10
- Maven WAR packaging

## Prerequisites

- JDK 21
- Maven 3.9+
- MySQL 8 or later
- Apache Tomcat 10 (required — it provides the Jakarta Servlet/JSP runtime this project targets)

## Project Structure

```text
src/main/java/com/studypal/     Java models, services, and database utilities
src/main/webapp/                JSP pages and static assets
src/main/resources/             Local configuration template
sql/                            Database schema and demo data
pom.xml                         Maven build configuration
```

## Database Setup

The schema script creates the `studypal_db` database itself, so you do not need to create it first.

1. Run the schema script:

   ```bash
   mysql -u root -p < sql/creat-tables.sql
   ```

2. Load demo data (recommended — provides the demo accounts below):

   ```bash
   mysql -u root -p studypal_db < sql/demo-data.sql
   ```

## Local Configuration (optional)

The application ships with working defaults (host `localhost:3306`, database `studypal_db`, user `root`, empty password). If your MySQL matches these, no extra configuration is needed.

To use different connection settings, or to enable the AI sub-task generation feature, copy the example file and fill in your values:

```bash
cp src/main/resources/studypal-local.properties.example src/main/resources/studypal-local.properties
```

The local configuration file is ignored by Git and should not be committed.

## Build

```bash
mvn clean package
```

This produces `target/studypal.war`.

## Run / Deploy

1. Make sure MySQL is running and the schema + demo data are loaded.
2. Deploy `target/studypal.war` to Tomcat 10 — either copy it into Tomcat's `webapps/` directory and start Tomcat, or run it from your IDE's Tomcat 10 configuration.
3. Open the app at:

   ```text
   http://localhost:8080/studypal/
   ```

## Demo Accounts

After loading `sql/demo-data.sql`, you can log in with:

| Role     | Username   | Password      |
| -------- | ---------- | ------------- |
| Admin    | `admin`    | `admin123`    |
| Lecturer | `lecturer` | `lecturer123` |
| Student  | `student`  | `student123`  |
