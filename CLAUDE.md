# CLAUDE.md

## 项目概述

StudyPal — 学习任务管理系统，COMP2013J 数据库与信息系统课程项目。采用 JSP + JDBC + MySQL 技术栈，运行于 Apache Tomcat，实现基于角色的工作空间（管理员、教师、学生）。

课程参考教材：*Fundamentals of Database Systems (7th Edition)*、*Database Systems: A Practical Approach to Design, Implementation, and Management (6th Edition)*。

## 技术栈与运行环境

- **Web 服务器**: Apache Tomcat (开源 Servlet 容器)
- **后端**: JSP (JavaServer Pages)，使用 Scriptlet (`<% %>`)、Expression (`<%= %>`)、Directive (`<%@ %>`)
- **数据库**: MySQL，客户端/服务器架构 (mysqld 守护进程)
- **数据库连接**: JDBC，使用 MySQL Connector/J (Type 4 驱动，纯 Java 实现，直连数据库)
- **前端**: JSP + HTML/CSS，通过 `<form>` 提交 POST/GET 请求，无现代前端框架
- **构建**: Maven 风格目录结构 (`src/main/webapp/`)，依赖 `mysql-connector-java.jar` 置于 `WEB-INF/lib/`

## 项目结构

```
src/main/webapp/          # 运行时 JSP 页面与应用资源
  *.jsp                   # 角色主页 (admin-home, student-home, lecturer-home, auth, index)
  assets/                 # 静态资源 (css/style.css, css/workspace.css, js/app.js)
  WEB-INF/jsp/            # 可复用 JSP 组件 (header, dashboard, course-list, task-list, etc.)
preview/                  # 前端静态 HTML 原型（仅 UI 参考，非运行时文件）
docs/                     # 前后端集成指南
sql/                      # 数据库建表脚本
课件/                     # 课程课件 (PDF, 01-10)
```

## 数据库核心设计

### 用户体系（EER 超类型/子类型模式）

- **基表 `USER_ACCOUNT`**: 统一认证入口，存储 `user_id`, `username`, `email`, `password_hash`, `role` 枚举 (`PROFESSOR`, `STUDENT`, `ADMIN`)
- **子表 `PROFESSOR` / `STUDENT` / `ADMIN`**: 通过 `user_id` 外键 1:1 关联基表，各自存储角色专属字段
- 设计原则：继承 EER 模型中 disjoint（互斥）+ mandatory participation（强制参与）模式——每个用户必须有且仅有一种角色
- 登录流程：查 `USER_ACCOUNT` 验证密码 → 根据 `role` 字段查对应子表获取详情 → 存入 session

### 课程与选课模块

- `COURSE` 表通过 `lecturer_id` 外键关联 `PROFESSOR`
- `STUDENT` ↔ `COURSE` 通过 `ENROLLMENT` 中间表实现多对多，含 `student_id + course_id` 联合唯一约束

### 任务管理模块（模板-实例分离模式）

- `MAIN_TASK`: 主任务，`course_id` 可为空（支持课程任务和自主任务），`creator_id` 指向 `USER_ACCOUNT`
- `SUB_TASK_TEMPLATE`: 标准化子步骤模板，含 `sequence_order`, `estimated_hours`, `planned_start/end`
- `STUDENT_SUB_TASK`: 学生实例化后的子任务，可自定义标题/描述/时间，含 `status` (`未开始`, `进行中`, `已完成`) 和 `completed_time`
- 实例化逻辑：学生查看课程任务时，若 `STUDENT_SUB_TASK` 无对应记录，则根据模板自动生成

完整表结构见 `实现逻辑.txt` 第二部分。

## JDBC 数据库访问规范

### 连接生命周期（严格5步流程）

1. **建立连接**: `DriverManager.getConnection(DB_URL, USERNAME, PASSWORD)`
   - URL 格式: `jdbc:mysql://hostname:port/database_name`（本地开发用 `localhost:3306`）
2. **创建 Statement**: 优先使用 `PreparedStatement`（预编译），禁止直接拼接字符串
3. **执行**: `executeQuery()` 用于 SELECT（返回 `ResultSet`），`executeUpdate()` 用于 INSERT/DELETE/UPDATE（返回影响行数）
4. **处理结果**: `ResultSet` 通过游标遍历，`rs.next()` 逐行移动，`rs.getInt()`, `rs.getString()` 等按列名取值
5. **关闭资源**: 按 `rs.close()` → `st.close()` → `conn.close()` 逆序关闭，置于 `finally` 块或 try-with-resources

### PreparedStatement（强制要求，防 SQL 注入）

- 所有带用户输入的 SQL 必须使用 `?` 参数绑定
- 示例: `PreparedStatement ps = conn.prepareStatement("SELECT * FROM USER_ACCOUNT WHERE username=? AND password_hash=?");`
- 禁止: `Statement st = conn.createStatement(); st.executeQuery("SELECT * FROM user WHERE name='" + input + "'");`

### 异常处理

- JDBC 操作需 `try/catch` 捕获 `SQLException`
- 建议封装 `DBUtils` 工具类统一管理连接获取与释放

## JSP 实现规范

### 隐式对象（课程要求使用）

| 对象 | 类型 | 用途 |
|------|------|------|
| `request` | `HttpServletRequest` | 获取请求参数 `request.getParameter("key")` |
| `response` | `HttpServletResponse` | 重定向 `response.sendRedirect("url")` |
| `session` | `HttpSession` | 存取会话 `session.setAttribute("key", obj)` / `session.getAttribute("key")` |
| `out` | `JspWriter` | 输出内容到页面 `out.println()` |

### 标签类型

- **Scriptlet** `<% ... %>`: 嵌入任意 Java 代码（请求处理、逻辑判断）
- **Expression** `<%= ... %>`: 输出 Java 表达式值（等同于 `out.println()`），末尾不加分号
- **Directive** `<%@ ... %>`: 页面配置
  - `<%@ page language="java" import="java.util.*" %>`
  - `<%@ include file="header.jsp" %>` — 提取公共组件（导航栏、页头、页脚）

### 会话管理

- 登录成功后: `session.setAttribute("user", userObject)`
- 敏感页面入口校验: 检查 `session.getAttribute("user")` 是否为 null，null 则重定向登录页
- `getAttribute` 返回 `Object`，需强制类型转换

### 注解规范

- JSP 注解 `<%-- ... --%>`: 不发送到浏览器（推荐用于逻辑说明）
- HTML 注解 `<!-- ... -->`: 会出现在页面源码中（仅内容说明）

## 数据库设计方法论（课程要求的3阶段）

1. **概念设计** (Conceptual): 使用 E-R 模型 / 增强 E-R 模型 (EER)，识别实体、属性、关系，绘制 E-R 图，输出概念模式
2. **逻辑设计** (Logical): 将概念模式转换为关系模式 = 定义表结构和字段，遵循规范化规则，输出逻辑模式
3. **物理设计** (Physical): 在目标 DBMS (MySQL) 上实现，包括文件组织、索引、存储引擎选择，输出物理模式

### EER 建模关键概念

- **超类型/子类型**: 如 `USER_ACCOUNT` 是超类型，`STUDENT`/`PROFESSOR`/`ADMIN` 是子类型
- **继承**: 子类型继承超类型的所有属性、键和关系
- **Disjoint (d)**: 一个实体只能属于一个子类型；**Overlapping (o)**: 可属于多个
- **Mandatory（双线）**: 每个超类型实例必须属于至少一个子类型；**Optional（单线）**: 可以不归属任何子类型

## 数据库完整性约束

- **域完整性** (Domain): 每列有明确的数据类型（`VARCHAR`, `INT`, `DECIMAL`, `DATETIME`, `TIMESTAMP` 等）
- **实体完整性** (Entity): 每表必须有主键 (`PRIMARY KEY`)，值唯一且非空
- **引用完整性** (Referential): 外键 (`FOREIGN KEY ... REFERENCES ...`) + 级联策略 (`ON DELETE CASCADE`, `ON UPDATE CASCADE`, `SET NULL`, `SET DEFAULT`, `NO ACTION`)

## MySQL 数据类型速查

| 类别 | 类型 | 说明 |
|------|------|------|
| 整数 | `INT`, `BIGINT`, `SMALLINT`, `TINYINT` | 标准整数 |
| 浮点 | `FLOAT`, `DOUBLE` | 不精确 |
| 定点 | `DECIMAL(P,S)` | 精确小数，如 `DECIMAL(5,2)` |
| 定长串 | `CHAR(N)` | 固定长度，不足补空格 |
| 变长串 | `VARCHAR(N)` | 可变长度 |
| 枚举 | `ENUM('a','b','c')` | 限定值集合 |
| 日期 | `DATE` (`YYYY-MM-DD`) | 仅日期 |
| 时间 | `TIME` (`HH:MM:SS`) | 仅时间 |
| 日期时间 | `DATETIME`, `TIMESTAMP` | 日期+时间 |
| 文本 | `TEXT` | 大文本 |
| 自增 | `AUTO_INCREMENT` | 自动递增主键 |

## SQL 核心操作速查

- `CREATE DATABASE` / `CREATE TABLE` / `ALTER TABLE` / `DROP TABLE`
- `SELECT ... FROM ... [WHERE ...] [ORDER BY ...] [GROUP BY ...] [LIMIT N OFFSET M]`
- `INSERT INTO ... VALUES ...` / `UPDATE ... SET ... WHERE ...` / `DELETE FROM ... WHERE ...`
- 聚合: `COUNT()`, `SUM()`, `AVG()`, `MAX()`, `MIN()`
- 连接: 隐式连接 (`FROM t1, t2 WHERE t1.fk = t2.pk`) — 课程采用的笛卡尔积+WHERE 过滤方式
- 嵌套查询: 子查询嵌套在 WHERE 或 FROM 中
- 视图: `CREATE VIEW ... AS SELECT ...`

## 开发顺序（按课程要求迭代式开发）

1. **数据底座**: 编写建表 SQL 脚本 → MySQL 执行建库建表 → 建立外键约束和级联策略
2. **环境配置**: 安装 Tomcat → 创建 Dynamic Web Project → 放入 `mysql-connector-java.jar`
3. **数据通道**: 编写 `DBUtils` 工具类 + 各表实体类 (POJO/JavaBean)
4. **用户认证**: login 表单 → `login.jsp` 查库验证 → `session` 存状态 → 按角色重定向
5. **课程选课**: 教师创建课程 (INSERT `COURSE`) → 学生选课 (INSERT `ENROLLMENT`) → 多表查询展示
6. **任务管理**: 教师发布任务 (INSERT `MAIN_TASK` + `SUB_TASK_TEMPLATE`) → 学生查看时自动实例化 → 勾选完成更新 `STUDENT_SUB_TASK.status`
7. **安全审查**: 检查全部 SQL 是否使用 `PreparedStatement` → 测试级联删除 → 规范注解
