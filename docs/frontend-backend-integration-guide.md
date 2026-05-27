# StudyPal 前后端对接文档

## 一、系统概述

StudyPal 是一个基于角色的校园学习管理系统，包含三种用户角色：
- **Student（学生）**：加入课程、完成任务、记录学习时间
- **Lecturer（讲师）**：管理课程、发布任务、查看学生进度
- **Admin（管理员）**：管理用户账号、管理课程、查看系统数据

技术栈：Java 25 + Jakarta Servlet 6.0 + JSP + MySQL 8.4 + 纯 JDBC（无框架）

---

## 二、角色入口与页面路由

### 2.1 登录与注册

| 页面 | URL | 说明 |
|------|-----|------|
| 登录/注册 | `/auth.jsp` | 统一入口，登录后根据角色跳转 |

**登录逻辑**：
- 用户提交 `username` + `password` 到 `POST /auth`
- 后端验证成功后，将用户信息存入 Session，然后根据 `role` 字段重定向：
  - `STUDENT` → `/student-home.jsp`
  - `LECTURER` → `/lecturer-home.jsp`
  - `ADMIN` → `/admin-home.jsp`

**注册逻辑**：
- 公开注册只能创建 STUDENT 账号
- 提交到 `POST /auth/register`，字段：`fullName`, `username`, `password`, `role=STUDENT`

---

### 2.2 Student（学生）页面

| 页面 | URL | 功能 |
|------|-----|------|
| 学生主页 | `/student-home.jsp` | Dashboard：统计数据、今日任务、课程进度、学习时间图表 |
| 我的课程 | `/student-courses.jsp` | 已加入课程列表、加入新课程 |
| 我的任务 | `/sub-tasks?role=STUDENT` | 学生子任务列表（状态筛选、更新进度） |
| 学习记录 | `/study-sessions?role=STUDENT` | 学习时间记录列表、新增记录 |
| 任务详情 | `/task-detail?role=STUDENT&id={id}` | 单个 MainTask 下的子任务详情 |

### 2.3 Lecturer（讲师）页面

| 页面 | URL | 功能 |
|------|-----|------|
| 讲师主页 | `/lecturer-home.jsp` | Dashboard：课程数、任务数、学生平均完成率 |
| 我的课程 | `/courses?role=LECTURER` | 讲师负责的课程列表 |
| 主任务管理 | `/main-tasks?role=LECTURER` | 创建/发布 MainTask + SubTaskTemplate |
| 任务详情 | `/lecturer-task-detail.jsp?id={id}` | 查看某任务下所有学生的完成进度 |

### 2.4 Admin（管理员）页面

| 页面 | URL | 功能 |
|------|-----|------|
| 管理员主页 | `/admin-home.jsp` | Dashboard：用户数、课程数、任务数、学习时长 |
| 用户管理 | `/admin-users.jsp` | 用户列表、创建账号、重置密码、停用账号 |
| 系统概览 | `/admin-overview.jsp` | 任务完成率、课程负载、学习时长统计 |
| 课程管理 | `/admin-courses.jsp` | 创建课程、分配讲师 |

---

## 三、后端需要实现的接口（Servlet）

### 3.1 认证模块 AuthServlet

| 方法 | URL | 功能 | 请求参数 | 响应 |
|------|-----|------|----------|------|
| POST | `/auth` | 登录 | `username`, `password` | 成功：重定向到对应角色首页；失败：回到 auth.jsp 显示错误 |
| POST | `/auth/register` | 学生注册 | `fullName`, `username`, `password`, `role=STUDENT` | 成功：重定向到 student-home；失败：回到 auth.jsp |
| GET | `/auth/logout` | 登出 | 无 | 清除 Session，重定向到 auth.jsp |

**Session 存储**：登录成功后在 `HttpSession` 中存入：
- `currentUser`：User 对象（含 userId, username, fullName, role）

---

### 3.2 Student 接口

#### 3.2.1 学生首页数据 StudentDashboardServlet

| 方法 | URL | 功能 |
|------|-----|------|
| GET | `/student/dashboard` | 获取学生首页所需的所有统计数据 |

**需要返回的数据（设置为 request attribute，转发到 JSP）**：
- `activeCourseCount`：当前学生已加入的课程数
- `pendingTaskCount`：状态为 TODO 或 IN_PROGRESS 的子任务数
- `completionRate`：已完成子任务数 / 总子任务数 × 100%
- `weeklyStudyHours`：本周学习总时长（从 study_session 计算）
- `todayTasks`：今天截止或进行中的任务列表
- `courseProgressList`：每门课程的完成百分比
- `weeklyStudyData`：本周每天的学习时长（用于柱状图）

---

#### 3.2.2 学生课程 StudentCourseServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/student/courses` | 获取已加入课程列表 | 无 |
| POST | `/student/courses/join` | 加入课程 | `courseCode` |

**GET 返回数据**：
- `enrolledCourses`：List，每项包含：
  - courseName, courseCode, lecturerName
  - activeTaskCount（该课程下未完成的任务数）
  - nextDeadline（最近截止时间）
  - progressPercent（该课程下子任务完成率）

**POST 加入课程逻辑**：
1. 根据 courseCode 查找 course
2. 在 enrollment 表插入记录
3. 为该课程下所有 sub_task_template 自动创建 student_sub_task 记录
4. 重定向回课程列表

---

#### 3.2.3 学生子任务 StudentSubTaskServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/sub-tasks` | 获取学生的所有子任务 | `status`(可选筛选) |
| POST | `/sub-tasks/update` | 更新子任务状态/备注 | `studentSubTaskId`, `status`, `notes` |

**GET 返回数据**：
- `subTaskList`：List，每项包含：
  - studentSubTaskId, 显示标题（COALESCE(custom_title, template.title)）
  - 显示描述、计划开始/结束时间（同样 COALESCE）
  - status, notes, courseName, mainTaskTitle

**POST 更新逻辑**：
- 更新 student_sub_task 的 status 字段
- 如果 status 改为 COMPLETED，设置 completed_time = NOW()
- 可选更新 notes, custom_title 等字段

---

#### 3.2.4 学习记录 StudySessionServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/study-sessions` | 获取学习记录列表 | 无 |
| POST | `/study-sessions/create` | 新增学习记录 | `studentSubTaskId`, `startTime`, `endTime`, `notes` |
| POST | `/study-sessions/delete` | 删除学习记录 | `studySessionId` |

**验证规则**：endTime 必须晚于 startTime

---

#### 3.2.5 任务详情 TaskDetailServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/task-detail` | 查看某 MainTask 的详情 | `id`(mainTaskId) |

**返回数据**：
- `mainTask`：MainTask 基本信息（title, description, deadline, importance）
- `subTasks`：该 MainTask 下当前学生的所有 student_sub_task（含模板信息）
- `courseName`：所属课程名

---

### 3.3 Lecturer 接口

#### 3.3.1 讲师首页 LecturerDashboardServlet

| 方法 | URL | 功能 |
|------|-----|------|
| GET | `/lecturer/dashboard` | 获取讲师首页统计 |

**返回数据**：
- `courseCount`：讲师负责的课程数
- `publishedTaskCount`：已发布的 MainTask 总数
- `averageCompletion`：所有学生的平均完成率
- `atRiskCount`：完成率低于 40% 的学生数
- `activeTaskList`：进行中的任务列表（含进度百分比）

---

#### 3.3.2 讲师课程 LecturerCourseServlet

| 方法 | URL | 功能 |
|------|-----|------|
| GET | `/courses?role=LECTURER` | 获取讲师负责的课程列表 |

**返回数据**：
- `courseList`：List，每项含 courseName, courseCode, studentCount, taskCount

---

#### 3.3.3 主任务管理 MainTaskServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/main-tasks` | 获取讲师的所有 MainTask | 无 |
| POST | `/main-tasks/create` | 创建 MainTask | `courseId`, `title`, `description`, `deadline`, `importanceLevel` |
| POST | `/main-tasks/publish` | 发布任务（生成学生记录） | `mainTaskId` |

**发布任务逻辑**：
1. 为该课程下所有已注册学生（enrollment 表）创建 student_sub_task 记录
2. 每个 sub_task_template 对应一条 student_sub_task（status=TODO）

---

#### 3.3.4 SubTask 模板管理 SubTaskTemplateServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| POST | `/sub-task-templates/create` | 为 MainTask 添加步骤 | `mainTaskId`, `title`, `description`, `estimatedHours`, `sequenceOrder`, `plannedStart`, `plannedEnd` |
| POST | `/sub-task-templates/delete` | 删除模板步骤 | `templateId` |

---

#### 3.3.5 讲师任务详情 LecturerTaskDetailServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/lecturer/task-detail?id={mainTaskId}` | 查看某任务所有学生进度 | `id` |

**返回数据**：
- `mainTask`：任务基本信息
- `enrolledCount`：选课学生总数
- `averageCompletion`：平均完成率
- `completedCount`：全部完成的学生数
- `atRiskCount`：完成率低于 40% 的学生数
- `studentProgressList`：每个学生的完成情况列表
  - studentName, email, status, completionPercent, totalStudyHours
- `stepProgressList`：每个步骤的完成人数
  - templateTitle, completedCount, totalCount, percent

---

### 3.4 Admin 接口

#### 3.4.1 管理员首页 AdminDashboardServlet

| 方法 | URL | 功能 |
|------|-----|------|
| GET | `/admin/dashboard` | 获取系统统计数据 |

**返回数据**：
- `totalUsers`：总用户数
- `studentCount` / `lecturerCount` / `adminCount`：各角色人数
- `totalCourses`：课程总数
- `totalTasks`：MainTask 总数
- `totalStudyHours`：近 30 天学习总时长

---

#### 3.4.2 用户管理 AdminUserServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/admin/users` | 获取用户列表 | `keyword`(可选), `role`(可选), `status`(可选) |
| POST | `/admin/users/create` | 创建账号 | `fullName`, `email`, `username`, `role`, `password` |
| POST | `/admin/users/reset-password` | 重置密码 | `userId` |
| POST | `/admin/users/suspend` | 停用账号 | `userId` |
| POST | `/admin/users/restore` | 恢复账号 | `userId` |

---

#### 3.4.3 课程管理 AdminCourseServlet

| 方法 | URL | 功能 | 参数 |
|------|-----|------|------|
| GET | `/admin/courses` | 获取所有课程 | 无 |
| POST | `/admin/courses/create` | 创建课程 | `courseName`, `courseCode`, `semester`, `lecturerId`, `description` |
| POST | `/admin/courses/update` | 编辑课程 | `courseId`, 同上字段 |

---

#### 3.4.4 系统概览 AdminOverviewServlet

| 方法 | URL | 功能 |
|------|-----|------|
| GET | `/admin/overview` | 获取系统级统计指标 |

**返回数据**：
- `taskCompletionRate`：全系统任务完成率
- `highestWorkloadCourse`：负载最高的课程
- `totalStudyHours`：近 30 天学习时长
- `totalEnrollments`：选课记录总数

---

## 四、前后端连接方式（Servlet + JSP 模式）

### 4.1 整体流程

```
浏览器请求 → Servlet（Controller）→ Service → DAO → MySQL
                ↓
         设置 request attribute
                ↓
         forward 到 JSP 页面渲染
```

### 4.2 具体实现步骤

**第一步：Servlet 接收请求**
```java
@WebServlet("/student/dashboard")
public class StudentDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // 1. 从 Session 获取当前用户
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }
        // 2. 调用 Service 获取数据
        int courseCount = enrollmentService.countByStudent(user.getUserId());
        // 3. 设置到 request attribute
        req.setAttribute("activeCourseCount", courseCount);
        // 4. 转发到 JSP
        req.getRequestDispatcher("/WEB-INF/jsp/student-home.jsp")
           .forward(req, resp);
    }
}
```

**第二步：JSP 中使用 EL 表达式读取数据**
```jsp
<p class="text-2xl font-bold">${activeCourseCount}</p>
```

**第三步：表单提交到 Servlet**
```jsp
<form method="post" action="${pageContext.request.contextPath}/student/courses/join">
    <input name="courseCode" placeholder="课程代码">
    <button type="submit">加入课程</button>
</form>
```

### 4.3 权限拦截（Filter）

后端需要实现一个 `AuthFilter`，拦截所有需要登录的页面：

```java
@WebFilter("/*")
public class AuthFilter implements Filter {
    private static final Set<String> PUBLIC_PATHS = Set.of(
        "/auth.jsp", "/auth", "/auth/register", "/index.jsp",
        "/assets/"
    );

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) {
        HttpServletRequest httpReq = (HttpServletRequest) req;
        String path = httpReq.getRequestURI()
                             .substring(httpReq.getContextPath().length());

        // 公开路径放行
        if (PUBLIC_PATHS.stream().anyMatch(path::startsWith)) {
            chain.doFilter(req, resp);
            return;
        }
        // 检查登录
        User user = (User) httpReq.getSession().getAttribute("currentUser");
        if (user == null) {
            ((HttpServletResponse) resp).sendRedirect(
                httpReq.getContextPath() + "/auth.jsp");
            return;
        }
        // 检查角色权限
        if (path.startsWith("/admin") && !"ADMIN".equals(user.getRole())) {
            req.getRequestDispatcher("/states.jsp?type=NO_PERMISSION")
               .forward(req, resp);
            return;
        }
        chain.doFilter(req, resp);
    }
}
```

---

## 五、数据库表结构速查

| 表名 | 用途 | 关键字段 |
|------|------|----------|
| `user` | 所有用户 | user_id, username, email, password_hash, full_name, role |
| `course` | 课程 | course_id, course_code, course_name, lecturer_id, semester |
| `enrollment` | 学生选课 | enrollment_id, student_id, course_id |
| `main_task` | 主任务（讲师发布） | main_task_id, course_id, title, deadline, importance_level |
| `sub_task_template` | 子任务模板 | template_id, main_task_id, title, estimated_hours, sequence_order |
| `student_sub_task` | 学生子任务进度 | student_sub_task_id, student_id, template_id, status, custom_* |
| `study_session` | 学习记录 | study_session_id, student_id, student_sub_task_id, start_time, end_time |

### 重要查询规则

1. **显示子任务标题**：`COALESCE(sst.custom_title, t.title)`
2. **计算学习时长**：`TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60.0`
3. **计算完成率**：`COUNT(CASE WHEN status='COMPLETED') / COUNT(*) * 100`
4. **学生加入课程后**：自动为所有 sub_task_template 创建 student_sub_task 记录

---

## 六、状态页面 states.jsp

前端已准备好以下状态展示页面，后端在以下场景转发到 `states.jsp`：

| 场景 | 参数 | 显示内容 |
|------|------|----------|
| 空数据 | `?type=EMPTY` | "No MainTask yet" |
| 验证失败 | `?type=ERROR&msg=xxx` | 显示错误信息 |
| 无权限 | `?type=NO_PERMISSION` | "Role cannot access this page" |
| 操作成功 | `?type=SUCCESS&msg=xxx` | 显示成功信息 |

---

## 七、后端开发优先级建议

1. **第一阶段（核心）**：AuthServlet + AuthFilter + Session 管理
2. **第二阶段（学生流程）**：StudentCourse + StudentSubTask + StudySession
3. **第三阶段（讲师流程）**：MainTask + SubTaskTemplate + LecturerTaskDetail
4. **第四阶段（管理员）**：AdminUser + AdminCourse + AdminOverview
5. **第五阶段（完善）**：Dashboard 统计数据、进度计算

---

## 八、注意事项

1. 所有 JSP 页面已经写好了 HTML 结构，后端只需要把硬编码的数据替换为 `${变量名}` 和 JSTL 循环
2. 密码存储必须使用哈希（推荐 BCrypt），不能明文存储
3. 所有 SQL 必须使用 PreparedStatement，防止注入
4. 前端表单的 action 路径使用 `${pageContext.request.contextPath}` 前缀
5. 后端处理 POST 请求后应该使用重定向（PRG 模式），避免刷新重复提交

