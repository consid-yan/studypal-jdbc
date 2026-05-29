# Changelog

## StudyPal v1.0 — 2026-05-28

### 架构搭建

- **构建系统**：创建 `pom.xml`，Maven WAR 项目，Java 21，依赖 `jakarta.servlet-api 6.0`、`mysql-connector-j 9.2.0`
- **Tomcat 部署**：配置 Context 文件 `studypal.xml`（`docBase` 指向 `target/studypal/`）
- **数据库建表**：`sql/creat-tables.sql` — utf8mb4 字符集，EER 超类型/子类型映射，外键级联策略
  - 9 张表：`USER_ACCOUNT`、`LECTURER`、`STUDENT`、`ADMIN`、`COURSE`、`ENROLLMENT`、`MAIN_TASK`、`SUB_TASK_TEMPLATE`、`STUDENT_SUB_TASK`
  - 表名 `PROFESSOR` 统一改为 `LECTURER`（与前端一致）
  - `ADMIN` 表补 `created_at` 字段

---

### 后端 Java 层（14 个类）

#### 数据模型（9 个 POJO）

| 类 | 路径 | 说明 |
|---|---|---|
| `UserAccount` | `model/` | 用户基表实体 |
| `Lecturer` | `model/` | 讲师子表，含展示字段 `fullName` |
| `Student` | `model/` | 学生子表 |
| `Admin` | `model/` | 管理员子表 |
| `Course` | `model/` | 课程实体，含展示字段 `lecturerName`、`enrollmentCount` |
| `Enrollment` | `model/` | 选课实体 |
| `MainTask` | `model/` | 主任务实体，含展示字段 `courseCode`、`courseName`、`creatorName`、`templateCount` |
| `SubTaskTemplate` | `model/` | 子步骤模板，含展示字段 `completedCount`、`totalStudentCount` |
| `StudentSubTask` | `model/` | 学生子任务实例，含展示字段 `templateTitle`、`mainTaskTitle`、`courseName`、`studentName`、`studentEmail`、`progressPercentage`、`deadline`、`mainTaskId` |

#### 工具层（1 个）

| 类 | 路径 | 说明 |
|---|---|---|
| `DBUtils` | `util/` | JDBC 连接管理（`getConnection`、`close`），含 AI API 配置常量 |

#### 业务服务（4 个）

| 类 | 路径 | 方法数 | 说明 |
|---|---|---|---|
| `AuthService` | `service/` | 5 | 认证登录、注册学生、查询各角色详情 |
| `CourseService` | `service/` | 14 | 课程 CRUD、选课、讲师课程、统计 |
| `TaskService` | `service/` | 19 | 任务创建/模板、AI 子步骤生成、自动实例化、进度更新、统计查询 |
| `AdminService` | `service/` | 4 | 用户列表/筛选、创建账号、重置密码、全局统计 |

---

### 前端 JSP 层（17 个页面）

#### 认证模块

| 页面 | 改动 |
|---|---|
| `auth.jsp` | 顶部加 Scriptlet POST 处理登录/注册，表单加 `action` 隐藏域区分请求，错误提示，注册表单拆分 Username/Email 独立字段，重复检测 |
| `index.jsp` | 着陆页底部统计改为功能描述文字 |

#### 管理员模块

| 页面 | 改动 |
|---|---|
| `admin-home.jsp` | 统计卡片全动态化（用户数/课程数/任务数/选课数，从 `AdminService.getStats()` 查询） |
| `admin-users.jsp` | Scriptlet 处理用户列表（含角色筛选+关键词搜索）、创建任意角色账号、重置密码为 `studypal123`；动态统计卡片 |
| `admin-courses.jsp` | Scriptlet 处理创建课程 POST，讲师下拉动态填充，课程列表动态渲染，统计卡片动态化 |
| `admin-overview.jsp` | 统计卡片+指标行动态化，补 session guard |

#### 讲师模块

| 页面 | 改动 |
|---|---|
| `lecturer-home.jsp` | 动态统计（课程数/任务数/学生数）、Active Tasks 动态列表（含完成率）、"我的课程"区域 |
| `main-task-list.jsp`（WEB-INF） | Scriptlet 处理创建任务 POST（含 AI 子步骤生成），动态任务列表，课程下拉按讲师过滤 |
| `lecturer-task-detail.jsp` | Scriptlet 加载任务详情，四维统计（选课数/平均完成率/全部完成数/风险数），学生进度行列表，步骤聚合统计 |
| `course-list.jsp`（WEB-INF） | Scriptlet 动态化：真实课程卡片、统计数字 |

#### 学生模块

| 页面 | 改动 |
|---|---|
| `student-home.jsp` | 统计卡片（待办/完成率/已选课程）、Today's Focus 动态循环、Course Progress 课程列表、任务进度柱状图、Upcoming Deadlines 动态循环、Student ID 从 session 取、Joined Courses 动态 |
| `student-courses.jsp` | Scriptlet 处理选课 POST、动态课程卡片（含讲师/学期）、加入课程表单、View Tasks 按课程筛选跳转、统计卡片（完成率/活跃任务数） |
| `sub-task-list.jsp`（WEB-INF） | Scriptlet 处理任务筛选（关键词/课程/状态）、摘要卡片动态化、任务列表动态渲染、进度更新表单 |
| `task-detail.jsp`（WEB-INF） | Scriptlet 处理自动实例化（`ensureStudentSubTasksExist`）、模板计划/我的进度/侧栏全动态化，移除 StudySession 区域 |
| `study-statistics.jsp`（WEB-INF） | Scriptlet 动态化：待办/完成/完成率/课程统计、Upcoming Deadlines、Course Progress、Task Summary、Earliest Deadline，移除 StudySession 假数据 |

#### 路由封装（3 个薄封装 JSP）

| 页面 | 说明 |
|---|---|
| `main-tasks.jsp` | `<%@ include file="WEB-INF/jsp/main-task-list.jsp" %>` |
| `sub-tasks.jsp` | `<%@ include file="WEB-INF/jsp/sub-task-list.jsp" %>` |
| `task-detail.jsp` | `<%@ include file="WEB-INF/jsp/task-detail.jsp" %>` |

---

### 全局修漏

- **404 修复**：所有 sidebar 链接和按钮 URL 批量补 `.jsp` 后缀（`/courses` → `/lecturer-home.jsp`，`/main-tasks` → `/main-tasks.jsp`，`/sub-tasks` → `/sub-tasks.jsp`，`/task-detail` → `/task-detail.jsp`）
- **Session guard**：所有敏感页面顶部加登录状态检查（`admin-overview.jsp` 等遗漏页面已补全）
- **字符编码修复**：JDBC URL 中 `characterEncoding=utf8mb4` 改为 `characterEncoding=UTF-8`
- **角色枚举统一**：`PROFESSOR` → `LECTURER`（表名、外键名、注释、种子数据）
- **Enum 硬编码清理**：14 项前端硬编码数据全部替换为数据库查询真实值

---

### 关键业务逻辑

- **EER 超类型/子类型映射**：`LECTURER.lecturer_id` = `USER_ACCOUNT.user_id`（既是 PK 又是 FK）
- **任务自动实例化**：学生首次访问主任务时，系统从 `SUB_TASK_TEMPLATE` 生成对应的 `STUDENT_SUB_TASK` 记录（事务保护 + 唯一约束兜底）
- **AI 子步骤生成**：讲师创建任务后，调用 DeepSeek API（OpenAI 兼容格式）自动拆解为 3-5 个模板步骤，失败时回退为默认步骤
- **PRG 模式**：所有表单提交成功后 `response.sendRedirect` 重定向，防止重复提交
- **状态自动设时间**：子任务状态变为 `COMPLETED` 时自动写入 `completed_time`
