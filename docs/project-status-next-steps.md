# StudyPal 项目进度与下一步任务

更新时间：2026-05-26

## 当前总体状态

项目已经完成了数据库核心结构设计，并且 Java Web 层已经做了一轮适配，让课程、主任务、学生子任务、学习记录等核心页面开始使用新的数据库表结构。本轮进一步按 3NF 调整了数据库：学生子任务只保存个人进度与覆盖字段，学习时长由开始/结束时间动态计算，不再作为基础表冗余字段保存。

但项目还没有完全达到 `docs/requirements.md` 中的完整需求。当前代码更接近“数据库结构完成 + 基础 CRUD 初步迁移完成”的阶段，后续还需要补角色权限、AI 生成子任务、学生选课、进度看板等功能。

## 模块完成情况

| 模块 | 已完成 | 未完成 / 问题 | 下一步要做 | 优先级 |
| --- | --- | --- | --- | --- |
| 数据库表结构 | 已建立 `user`、`course`、`enrollment`、`main_task`、`sub_task_template`、`student_sub_task`、`study_session` 等核心表，并按 3NF 去除了 `study_session.duration_hours` 基础列。 | 当前继续使用 `user.role` 区分 Admin / Lecturer / Student；因为暂无角色专属字段，所以不单独拆 profile 表。 | 若后续增加学号、专业、教师办公室等角色专属字段，再新增 `student_profile` / `lecturer_profile`。 | 中 |
| SQL 视图 | 已有优先级、主任务进度、学习效率、每日学习统计、课程负载等视图；视图使用 `COALESCE` 合并模板默认值和学生覆盖值，并动态计算学习时长。 | 页面没有充分使用这些视图。 | 把进度页、Dashboard、教师视图接入 `main_task_progress_view`、`study_efficiency_view`。 | 中 |
| SQL 存储过程 | 已有批量创建模板、创建学生-模板进度记录、生成拖延报告等过程。 | Java Service 层还没有系统调用这些存储过程。 | 在创建 MainTask、学生加入课程时调用记录创建逻辑，或用 Java 事务实现等价逻辑。 | 高 |
| SQL 触发器 | 当前 3NF schema 不再需要自动计算 `study_session.duration_hours` 的触发器。 | 为了页面 CRUD，当前仍未恢复禁止 `main_task` 更新/删除的触发器定义；这和需求文档“发布后不可改不可删”冲突。 | 必须二选一：恢复 MainTask 不可编辑/删除，或修改需求文档承认 MainTask 可编辑/删除。 | 高 |
| README 文档 | 已更新当前数据库结构、3NF 设计说明、Java 迁移说明、当前表字段说明。 | MainTask 是否不可变仍需要和代码实现统一。 | 在决定 MainTask 规则后同步 README 和 requirements。 | 中 |
| 需求文档 | 已同步为 3NF 口径：StudentSubTask 是学生进度记录和个人覆盖值，不是无条件复制模板字段；StudySession duration 为动态计算值。 | 和当前实现仍存在冲突：MainTask 不可编辑/删除、AI 生成、权限等还没实现。 | 按实际项目目标重审需求，标记“本版本必须做”和“可选扩展”。 | 高 |
| Java Model 层 | 已新增 `User`、`UserRole`、`SubTaskTemplate`、`StudentSubTask`；调整了 `Course`、`MainTask`、`StudySession`、`SubTask`。 | `SubTask` 现在是兼容展示对象，不是数据库真实表；`ScheduleSlot`、`TaskDependency` 仍是遗留模型。 | 后续可清理遗留模型，或者明确保留为将来扩展。 | 中 |
| Java DAO 层 | 核心 DAO 已迁移到新表：`CourseDao`、`MainTaskDao`、`SubTaskDao`、`StudySessionDao`、`StudentDao`。 | `ScheduleSlotDao`、`TaskDependencyDao` 现在只是兼容壳；真实功能已不可用。 | 删除或隔离废弃 DAO，避免组员误用。 | 中 |
| Course 功能 | 课程列表、创建、编辑、删除已适配 `lecturer_id`；教师来自 `user(role='LECTURER')`。 | 还没有权限控制，任何人理论上都能管理课程。 | 后续加当前用户与角色判断，限制 Lecturer 只能管理自己的课程。 | 中 |
| MainTask 功能 | 主任务页面已去掉旧的 `student_id` 和 `status` 字段，改为课程级任务。 | 当前仍支持编辑和删除，但需求要求发布后不可编辑/删除；创建时也没有确认弹窗。 | 决定 MainTask 是否不可变；若按需求，应禁用编辑/删除并恢复保护。 | 高 |
| SubTask / StudentSubTask 功能 | 页面显示的是学生个人子任务，底层使用 `student_sub_task` 关联 `sub_task_template`，并通过个人覆盖字段展示自定义标题、描述和计划时间。 | 创建子任务时目前偏向手动创建，不是 AI 自动生成；模板管理和学生个人覆盖值的界面边界还不够清晰。 | 实现 MainTask 创建后自动生成模板，并给已选课学生创建 StudentSubTask 进度记录。 | 高 |
| StudySession 功能 | 学习记录已改为关联 `student_sub_task_id`，支持基本 CRUD。 | 没有权限检查，不能保证学生只能改自己的学习记录。 | 加当前学生身份校验，避免跨学生访问和修改。 | 中 |
| Dashboard | 可以显示课程数量、任务数量、近 7 天学习时长；原 schedule 指标改为今日计划子任务数。 | 还不是按 Admin / Lecturer / Student 分角色 dashboard；进度、风险、效率展示不足。 | 接入 SQL 视图，分别做学生看板和教师进度看板。 | 中 |
| Schedule 功能 | 导航中已隐藏 `/schedule`。 | 新 schema 没有 `schedule_slot`，`ScheduleServlet`、`ScheduleService`、`schedule.jsp` 仍是遗留代码。 | 要么删除 schedule 功能，要么重做成基于 `COALESCE(student_sub_task.custom_planned_start_time, sub_task_template.planned_start)` 和对应结束时间的计划视图。 | 低 |
| TaskDependency 功能 | 当前主流程不再使用任务依赖。 | `TaskDependency`、`TaskDependencyDao`、`TaskDependencyException` 是冗余遗留。 | 删除相关代码，或重新设计依赖表并加入 schema。 | 低 |
| 用户角色与权限 | 数据库 `user.role` 支持 Admin / Lecturer / Student。 | 没有登录系统、当前用户、权限拦截；代码中仍使用硬编码学生 ID `6`。 | 实现最小登录/用户切换机制，替换硬编码用户 ID。 | 高 |
| 学生选课 | 数据库有 `enrollment` 表。 | 没有学生自助加入课程页面；加入课程后自动复制子任务也没接到页面流程。 | 新增“Join Course”功能，加入后调用复制学生子任务逻辑。 | 高 |
| AI 子任务生成 | 需求文档已定义 AI 生成与 fallback 规则。 | 代码完全没有 AI API 调用、重试、fallback、事务控制。 | 实现 AI 生成服务：失败重试 3 次，失败后使用四步 fallback 模板。 | 高 |
| 进度计算 | SQL 视图已有 `main_task_progress_view`。 | Java 页面没有完整展示学生/教师/Admin 进度。 | 教师页展示每个 MainTask 下学生完成率；学生页展示自己的进度。 | 高 |
| 测试验证 | `mvn test`、`mvn package` 已通过。 | 没有自动化测试用例；本地 MySQL 当前未连上，没跑真实数据库 smoke test。 | 建立测试数据库，执行 SQL 脚本，手动验证课程、任务、子任务、学习记录 CRUD。 | 高 |

## 目前最需要优先解决的 5 件事

1. **统一 MainTask 规则**
   - 需求文档说发布后不可编辑、不可删除。
   - 当前代码支持编辑、删除。
   - 必须先决定最终规则，否则后面页面、触发器、README 都会继续冲突。

2. **实现 MainTask 创建后的完整工作流**
   - 创建 MainTask。
   - 生成 SubTask 模板。
   - 给课程内所有学生创建 StudentSubTask 进度记录。
   - 整个流程最好放在一个事务里。

3. **补 AI 子任务生成**
   - 调用 AI API。
   - 失败最多重试 3 次。
   - 仍失败则使用默认四步模板：
     1. Understand requirements
     2. Collect materials
     3. Complete main work
     4. Review and submit

4. **实现最小用户/角色机制**
   - 目前使用硬编码学生 ID `6`，只能用于 demo。
   - 至少需要一个简单的当前用户选择或登录机制。
   - 后续权限判断都依赖它。

5. **清理或隔离遗留代码**
   - `ScheduleServlet`
   - `ScheduleService`
   - `ScheduleSlot`
   - `ScheduleSlotDao`
   - `TaskDependency`
   - `TaskDependencyDao`
   - `TaskDependencyException`

## 当前代码是否完全符合需求

不完全符合。

当前代码已经完成了核心数据库结构、3NF 调整和部分 CRUD 迁移，但还没有达到需求文档中完整的角色权限、AI 生成、自动创建学生进度记录、进度看板和 MainTask 不可变规则。

## 明显冗余或需要注意的代码

| 代码 | 当前状态 | 建议 |
| --- | --- | --- |
| `ScheduleServlet` / `ScheduleService` / `ScheduleSlotDao` / `ScheduleSlot` | 新 schema 没有 `schedule_slot`，导航已隐藏。 | 暂时保留会造成误解，建议删除或标记废弃。 |
| `TaskDependencyDao` / `TaskDependency` / `TaskDependencyException` | 新 schema 没有 `task_dependency`，主流程不使用。 | 建议删除，除非后续明确要恢复依赖功能。 |
| `SubTask` | 现在是兼容展示对象，底层实际来自 `student_sub_task + sub_task_template`。 | 后续可以改名为 `StudentSubTaskView` 或直接用 `StudentSubTask`。 |
| 硬编码 `DEFAULT_STUDENT_ID = 6` | 只能用于 demo。 | 后续替换成登录用户或会话用户。 |
| MainTask 编辑/删除 | 当前代码支持，但需求不允许。 | 需要和需求统一。 |

## 建议下一阶段分工

| 组员方向 | 建议任务 |
| --- | --- |
| 数据库同学 | 确认 MainTask 是否不可变；检查 schema 和 requirements 是否一致；准备可重复执行的建库脚本。 |
| 后端 DAO/Service 同学 | 实现 MainTask 创建事务：创建任务、生成模板、创建学生进度记录。 |
| AI 功能同学 | 实现 AI 子任务生成、三次重试、fallback 模板。 |
| Web 页面同学 | 做学生选课页、教师进度页、学生个人进度页。 |
| 测试同学 | 准备本地 MySQL 测试流程，验证 SQL 脚本和四条核心 CRUD 流程。 |
