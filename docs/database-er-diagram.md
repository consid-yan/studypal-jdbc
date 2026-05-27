# StudyPal Database ER Diagram

更新时间：2026-05-26

下面是 StudyPal 数据库表之间的关系图。此版本去掉 `study_session`，并采用更规范的任务创建逻辑：

- `main_task.creator_id` 指向 `user.user_id`，表示具体是谁创建了任务。
- 教师/学生身份从 `user.role` 推出，不再在 `main_task` 中重复保存 `role`。
- `main_task.task_type` 表示任务性质，例如课程布置任务或学生个人任务。

```mermaid
erDiagram
    USER ||--o{ COURSE : teaches
    USER ||--o{ ENROLLMENT : enrolls
    USER ||--o{ MAIN_TASK : creates
    USER ||--o{ STUDENT_SUB_TASK : owns

    COURSE ||--o{ ENROLLMENT : has_students
    COURSE ||--o{ MAIN_TASK : contains

    MAIN_TASK ||--o{ SUB_TASK_TEMPLATE : has_templates

    SUB_TASK_TEMPLATE ||--o{ STUDENT_SUB_TASK : creates_progress_records

    USER {
        int user_id PK
        varchar username
        varchar email
        varchar password_hash
        varchar full_name
        enum role
        datetime created_at
    }

    COURSE {
        int course_id PK
        varchar course_code
        varchar course_name
        int lecturer_id FK
        varchar semester
        text description
        datetime created_at
    }

    ENROLLMENT {
        int enrollment_id PK
        int student_id FK
        int course_id FK
        date enrollment_date
    }

    MAIN_TASK {
        int main_task_id PK
        int course_id FK
        int creator_id FK
        varchar title
        text description
        datetime deadline
        enum importance_level
        enum task_type
        datetime created_at
    }

    SUB_TASK_TEMPLATE {
        int template_id PK
        int main_task_id FK
        varchar title
        text description
        decimal estimated_hours
        int sequence_order
        datetime planned_start
        datetime planned_end
        datetime created_at
    }

    STUDENT_SUB_TASK {
        int student_sub_task_id PK
        int student_id FK
        int template_id FK
        varchar custom_title
        text custom_description
        datetime custom_planned_start_time
        datetime custom_planned_end_time
        datetime completed_time
        enum status
        text notes
        datetime created_at
        datetime updated_at
    }
```

核心业务链路：

```text
course -> main_task -> sub_task_template -> student_sub_task
```

任务创建链路：

```text
user -> main_task.creator_id
user.role = LECTURER 或 STUDENT
main_task.task_type = COURSE_ASSIGNED 或 PERSONAL
```

学生选课链路：

```text
user(role = STUDENT) -> enrollment -> course
```

教师授课链路：

```text
user(role = LECTURER) -> course.lecturer_id
```

设计提醒：

```text
main_task.creator_id 表达具体是哪位老师或学生创建了任务。
创建者身份通过 user.role 判断，避免在 main_task 中重复保存 role。
main_task.task_type 表达任务性质，例如课程布置任务或学生个人任务。
```
