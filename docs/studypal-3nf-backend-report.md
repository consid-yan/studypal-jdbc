# StudyPal 3NF 表结构与后端修改报告

生成日期：2026-05-26

## 1. 本次修改目标

本次修改的目标是在不偏离 StudyPal 需求文档总体方向的前提下，让数据库设计更符合老师课件中第三范式（3NF）的要求，并同步后端 JDBC 代码、SQL 脚本、README 和项目文档。

核心原则：

- 不在基础表中保存可由其他字段计算出的派生数据。
- 不在学生个人表中无条件复制模板字段。
- 课程级任务模板和学生个人进度记录分离。
- 保留当前 `user.role` 账户模型，因为现阶段没有学生/教师专属字段。

## 2. 新的数据库表结构

| 表名 | 主要字段 | 作用 | 3NF 说明 |
| --- | --- | --- | --- |
| `user` | `user_id`, `username`, `email`, `password_hash`, `full_name`, `role`, `created_at` | 统一存储 Admin、Lecturer、Student 账户。 | 当前没有角色专属字段，因此用 `role` 区分用户类型即可；未来如有学号/办公室等字段再拆 profile 表。 |
| `course` | `course_id`, `course_code`, `course_name`, `lecturer_id`, `semester`, `description`, `created_at` | 存储课程信息。 | 只保存 `lecturer_id`，不复制教师姓名、邮箱等用户信息。 |
| `enrollment` | `enrollment_id`, `student_id`, `course_id`, `enrollment_date` | 存储学生和课程的多对多关系。 | 避免在学生表或课程表中保存多值课程/学生列表。 |
| `main_task` | `main_task_id`, `course_id`, `title`, `description`, `deadline`, `importance_level`, `created_at` | 存储课程级主任务。 | 主任务属于课程，不存学生状态或学生进度。 |
| `sub_task_template` | `template_id`, `main_task_id`, `title`, `description`, `estimated_hours`, `sequence_order`, `planned_start`, `planned_end`, `created_at` | 存储共享子任务模板。 | 模板只描述标准任务拆分，不存个人完成状态。 |
| `student_sub_task` | `student_sub_task_id`, `student_id`, `template_id`, `custom_title`, `custom_description`, `custom_planned_start_time`, `custom_planned_end_time`, `completed_time`, `status`, `notes`, `created_at`, `updated_at` | 存储学生个人进度和覆盖字段。 | 不再复制模板默认标题、描述、计划时间；只在学生个性化调整时保存 `custom_*` 覆盖值。 |
| `study_session` | `study_session_id`, `student_id`, `student_sub_task_id`, `start_time`, `end_time`, `session_type`, `notes` | 存储学习记录。 | 不再存 `duration_hours`，学习时长由 `start_time` 和 `end_time` 动态计算。 |

## 3. 与旧结构相比的主要变化

| 旧设计问题 | 新设计 | 原因 |
| --- | --- | --- |
| `study_session.duration_hours` 存在派生冗余。 | 删除基础列，在 DAO、SQL 查询和视图中动态计算。 | `duration_hours` 由 `start_time` 和 `end_time` 决定，基础表保存它不符合严格 3NF。 |
| `student_sub_task` 直接保存 `title`, `description`, `planned_start_time`, `planned_end_time`。 | 改为 `custom_title`, `custom_description`, `custom_planned_start_time`, `custom_planned_end_time`。 | 模板默认字段留在 `sub_task_template`，学生表只保存个性化覆盖值。 |
| 复制学生子任务时复制模板标题和计划时间。 | 存储过程只创建学生-模板进度记录。 | 避免同一模板数据在多个学生记录中重复出现。 |
| 进度视图无法显示未生成学生子任务的情况。 | `main_task_progress_view` 从 `enrollment` 出发并使用 `LEFT JOIN`。 | 可以正确显示 `Not generated` 状态。 |
| 文档中仍提到 duration 触发器和模板复制。 | README、需求文档、项目状态文档已同步为 3NF 口径。 | 保证代码、SQL 和文档一致。 |

## 4. 后端代码修改清单

| 文件 | 修改内容 | 影响 |
| --- | --- | --- |
| `sql/schema.sql` | 更新 `student_sub_task` 字段为 `custom_*`；删除 `study_session.duration_hours`。 | 基础数据库结构更符合 3NF。 |
| `sql/views.sql` | 用 `COALESCE` 合并学生覆盖值和模板默认值；动态计算学习时长；修复进度视图的 `LEFT JOIN`。 | 报表仍能显示标题、计划时间、进度、效率和学习时长。 |
| `sql/procedures.sql` | 创建 StudentSubTask 时不再复制模板字段；拖延报告动态计算学习时长。 | 存储过程与新表结构一致。 |
| `sql/triggers.sql` | 移除 duration 维护触发器，只保留旧触发器清理语句。 | 不再依赖触发器维护派生字段。 |
| `sql/insert_test_data.sql` | 测试数据不再插入重复模板字段和 `duration_hours`。 | 样例数据可用于新 schema。 |
| `sql/queries.sql` | 查询示例改用 `COALESCE` 和 `TIMESTAMPDIFF`。 | 手动测试和报告查询与新 schema 一致。 |
| `src/main/java/com/studypal/dao/SubTaskDao.java` | 读取时用 `COALESCE` 得到展示标题/描述/计划时间；更新时写入 `custom_*` 字段。 | 页面保持原来的展示体验，同时底层符合 3NF。 |
| `src/main/java/com/studypal/dao/StudySessionDao.java` | 查询时计算 `duration_hours` 别名；插入/更新不再写 `duration_hours`。 | Java 对象仍可显示时长，但数据库不存冗余值。 |
| `src/main/java/com/studypal/service/StudySessionService.java` | 移除写库前设置 duration 的逻辑。 | 时长变成查询/展示计算值。 |
| `src/main/java/com/studypal/model/StudentSubTask.java` | 字段语义改为 `custom*`，保留旧 getter 兼容展示层。 | 模型与新 schema 对齐。 |
| `README.md` | 增加 3NF 设计说明和新表字段说明。 | 项目说明与实际 schema 一致。 |
| `docs/requirements.md` | 将 “personal copy” 改为 “student-specific progress record with optional overrides”。 | 需求文档避免被理解为无条件复制模板字段。 |
| `docs/database-3nf-report.md` | 新增 3NF 数据库结构说明。 | 方便答辩和数据库设计汇报。 |
| `CLAUDE.md` | 更新本地协作说明，删除旧表和旧触发器描述。 | 后续协作不再沿用过时 schema。 |

## 5. 后端需求完成情况

| 后端需求 | 当前状态 | 说明 |
| --- | --- | --- |
| 使用 Java Servlet/JSP + JDBC + MySQL | 已完成 | 项目仍保持纯 Servlet/JSP 和 JDBC。 |
| 建立核心数据库表 | 已完成 | `user`, `course`, `enrollment`, `main_task`, `sub_task_template`, `student_sub_task`, `study_session` 已建立。 |
| 表结构满足 3NF 大方向 | 已完成 | 已去除主要派生冗余和模板字段重复。 |
| 课程、主任务、学生子任务、学习记录基础 CRUD | 部分完成 | 页面和 DAO 已有基础流程，但权限和不可变规则未完整实现。 |
| SQL 视图支持进度、优先级、效率、学习统计 | 已完成基础版 | 视图已适配新 schema，但页面还没有充分使用全部视图。 |
| 存储过程支持模板批量创建和学生进度记录创建 | 已完成 SQL 层 | Java Service 层还没有系统调用这些存储过程。 |
| MainTask 发布后不可编辑/删除 | 未完成 | 需求文档要求不可变，但当前 Java 页面仍支持编辑/删除。 |
| AI 自动生成 SubTask 模板 | 未完成 | 还没有 AI API 调用、重试、fallback 和事务整合。 |
| 学生加入课程后自动创建 StudentSubTask | 未完成 | 数据库过程已有基础能力，页面流程未接入。 |
| 登录、当前用户、角色权限 | 未完成 | 目前仍有 demo 学生 ID 和缺少权限拦截的问题。 |
| 教师/Admin/学生分角色 Dashboard | 未完成 | 当前 Dashboard 还是基础展示。 |

## 6. 下一步建议

| 优先级 | 下一步任务 | 原因 |
| --- | --- | --- |
| 高 | 统一并实现 MainTask 不可编辑/不可删除规则。 | 这是需求文档和当前代码最大的冲突点。 |
| 高 | 实现 MainTask 创建事务：创建主任务、生成模板、创建学生进度记录。 | 这是课程任务发布的核心后端流程。 |
| 高 | 接入 AI 子任务生成，包含三次重试和四步 fallback 模板。 | 对应需求文档中的 AI 功能。 |
| 高 | 实现最小当前用户机制，替换硬编码学生 ID。 | 后续权限控制都依赖当前用户。 |
| 中 | 新增学生选课页面并调用 StudentSubTask 创建逻辑。 | 支撑学生加入课程后的完整数据流。 |
| 中 | 把 Dashboard 和进度页面接入 `main_task_progress_view`、`study_efficiency_view`。 | 让已有 SQL 视图真正服务页面。 |
| 中 | 清理或隔离剩余遗留页面和说明。 | 避免组员误用旧概念。 |

## 7. 验证结果

已运行：

```text
mvn test
mvn package
```

结果：Java 编译通过，WAR 打包成功。当前没有自动化测试用例，因此 Maven 输出为 “No tests to run”。尚未在本机 MySQL 中执行建库脚本，以避免误改现有数据库数据。
