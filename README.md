# StudyPal JDBC

StudyPal is a JSP + JDBC + MySQL learning task management system for the COMP2013J Database and Information Systems course project.

## Features

- Role-based login for students, lecturers, and administrators
- Course creation, enrollment, and course progress display
- Main task and sub-task management
- Student task progress updates and completion tracking
- Administrator user, course, and system overview pages

## Tech Stack

- Java 21
- Jakarta Servlet 6.0
- JSP
- JDBC
- MySQL
- Maven WAR packaging

## Project Structure

```text
src/main/java/com/studypal/     Java models, services, and database utilities
src/main/webapp/                JSP pages and static assets
src/main/resources/             Local configuration template
sql/                            Database schema and demo data
pom.xml                         Maven build configuration
```

## Database Setup

1. Create a MySQL database named `studypal_db`.
2. Run the schema script:

   ```bash
   mysql -u root -p studypal_db < sql/creat-tables.sql
   ```

3. Optionally load demo data:

   ```bash
   mysql -u root -p studypal_db < sql/demo-data.sql
   ```

## Local Configuration

Copy the example configuration file and adjust the database connection and sub-task generation service values if needed:

```bash
cp src/main/resources/studypal-local.properties.example src/main/resources/studypal-local.properties
```

The local configuration file is ignored by Git and should not be committed.

## Build

```bash
mvn clean package
```

The generated WAR file will be created under `target/`.
