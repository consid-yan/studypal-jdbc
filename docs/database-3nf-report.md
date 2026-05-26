# StudyPal 3NF Database Structure Report

更新时间：2026-05-26

## 1. 设计目标

本次调整的目标是在保留 StudyPal 需求文档大方向的前提下，让数据库表结构更符合第三范式（3NF）。

调整重点：

- 避免在基础表中保存可由其他字段计算出的派生数据。
- 避免在学生个人子任务表中无条件复制模板字段。
- 保留课程级任务模板和学生个人进度分离的业务设计。
- 保留 `user.role` 的简化账户模型，并说明其符合当前需求下的 3NF 设计。

## 2. 当前核心表结构

### user

账户表，统一存储 Admin、Lecturer、Student。

```text
user(
  user_id PK,
  username UNIQUE,
  email UNIQUE,
  password_hash,
  full_name,
  role,
  created_at
)
```

3NF 说明：当前版本没有学生或教师专属字段，因此 `role` 只是用户分类属性，不产生传递依赖。后续如果加入学号、专业、办公室等专属属性，应拆到 `student_profile` / `lecturer_profile`。

### course

课程表。

```text
course(
  course_id PK,
  course_code UNIQUE,
  course_name,
  lecturer_id FK -> user.user_id,
  semester,
  description,
  created_at
)
```

3NF 说明：课程只保存 `lecturer_id`，不复制教师姓名、邮箱等用户信息。

### enrollment

学生选课关系表。

```text
enrollment(
  enrollment_id PK,
  student_id FK -> user.user_id,
  course_id FK -> course.course_id,
  enrollment_date,
  UNIQUE(student_id, course_id)
)
```

3NF 说明：学生和课程是多对多关系，拆成独立关系表，避免在学生表或课程表中存多个课程/多个学生。

### main_task

课程级主任务表。

```text
main_task(
  main_task_id PK,
  course_id FK -> course.course_id,
  title,
  description,
  deadline,
  importance_level,
  created_at
)
```

3NF 说明：主任务属于课程，不直接属于学生；学生进度不存放在该表。

### sub_task_template

课程任务的共享子任务模板表。

```text
sub_task_template(
  template_id PK,
  main_task_id FK -> main_task.main_task_id,
  title,
  description,
  estimated_hours,
  sequence_order,
  planned_start,
  planned_end,
  created_at
)
```

3NF 说明：模板字段只描述模板本身，学生状态、完成时间、个人备注不存放在该表。

### student_sub_task

学生个人进度记录和覆盖字段表。

```text
student_sub_task(
  student_sub_task_id PK,
  student_id FK -> user.user_id,
  template_id FK -> sub_task_template.template_id,
  custom_title,
  custom_description,
  custom_planned_start_time,
  custom_planned_end_time,
  completed_time,
  status,
  notes,
  created_at,
  updated_at,
  UNIQUE(student_id, template_id)
)
```

3NF 说明：该表不再默认复制模板的 `title`、`description`、`planned_start`、`planned_end`。这些默认值保留在 `sub_task_template` 中。只有学生确实个性化调整时，才在 `custom_*` 字段中保存覆盖值。

显示时使用：

```text
COALESCE(student_sub_task.custom_title, sub_task_template.title)
COALESCE(student_sub_task.custom_description, sub_task_template.description)
COALESCE(student_sub_task.custom_planned_start_time, sub_task_template.planned_start)
COALESCE(student_sub_task.custom_planned_end_time, sub_task_template.planned_end)
```

### study_session

学习记录表。

```text
study_session(
  study_session_id PK,
  student_id FK -> user.user_id,
  student_sub_task_id FK -> student_sub_task.student_sub_task_id NULL,
  start_time,
  end_time,
  session_type,
  notes
)
```

3NF 说明：`duration_hours` 不再作为基础列保存，因为它由 `start_time` 和 `end_time` 决定。查询和视图中动态计算：

```text
ROUND(TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60, 2)
```

`student_id` 保留在 `study_session` 中，因为学习记录允许不关联任何具体子任务。

## 3. 本次主要修改

- 删除基础表 `study_session.duration_hours`。
- 移除维护学习时长的触发器逻辑。
- 将 `student_sub_task.title`、`description`、`planned_start_time`、`planned_end_time` 改为 `custom_title`、`custom_description`、`custom_planned_start_time`、`custom_planned_end_time`。
- 更新视图和查询，使用 `COALESCE` 合并学生覆盖值和模板默认值。
- 更新学习统计视图和查询，动态计算学习时长。
- 更新存储过程，创建学生子任务时只建立学生-模板进度记录，不再复制模板字段。
- 更新测试数据，避免重复插入模板标题、描述、计划时间和学习时长。
- 更新 Java DAO，使页面仍能读取展示用标题、描述、计划时间和时长。
- 更新 README、需求文档和项目状态文档中的数据库设计说明。

## 4. 与需求文档的关系

调整后的结构仍满足需求文档的大方向：

- 课程级任务和学生个人进度分离。
- Lecturer 创建 `main_task` 和 `sub_task_template`。
- Student 通过 `student_sub_task` 维护自己的状态、完成时间、备注和个性化计划。
- Study Session 可以独立记录，也可以关联到某个 Student SubTask。
- 进度、效率、学习时长等统计由视图和查询动态计算。

需求文档中原来“personal copy”的说法已调整为“student-specific progress record with optional overrides”，避免被理解成无条件复制模板字段。

## 5. 仍需后续处理的点

- 当前 Java 页面仍支持 MainTask 编辑和删除，而需求文档要求发布后不可编辑、不可删除。
- AI 子任务生成、三次重试和 fallback 模板还未实现。
- 登录、当前用户和角色权限还未实现，部分流程仍使用 demo 学生 ID。
- 学生选课页面和选课后自动创建 StudentSubTask 记录还未完整接入页面流程。
