# 前端 Bug 修复记录 — 2026-05

本文档记录 `codex/fix-full-code-errors` 分支中完成的前端 Bug 修复，对应反馈文档 `测试bug反馈/`。

## 修复清单

### 1. 登录/注册页 (`auth.jsp`)

**问题**
- 账号输入框存在硬编码默认值 `student_chen`，上线后会泄露测试账号信息。
- 注册失败后页面跳回登录表单，已填写内容全部丢失，体验差。
- 错误提示为英文且不区分错误类型（密码不一致、邮箱重复、用户名重复显示同一提示）。
- "Forgot Password" 链接为 `href="#"`，无实际功能。

**修复**
- 删除 `value="student_chen"`，改为语义 placeholder。
- 注册失败时通过 `showRegisterForm` 标志保持注册表单展开，按 `registerErrorField` 回填未出错字段（出错字段清空让用户重新输入）。
- 错误提示中文化，分三类：`"两次输入的密码不一致。"` / `"该邮箱已被使用。"` / `"该用户名已被注册。"`。
- "Forgot Password" 改为 `showPasswordHelp()` 弹窗，提示用户联系管理员重置密码。

---

### 2. 学生子任务页 (`WEB-INF/jsp/sub-task-list.jsp`)

#### 2a. 状态筛选回显失效（本次追加修复）

**问题**
筛选下拉的 `option value` 使用空格格式（`"Not Started"`），但后端取到参数后会规范化为枚举格式（`"NOT_STARTED"`），再与 `statusFilter` 比较时永远不等，导致筛选后选中项无法高亮回显。

**根本原因**
`option value` 与后端存储的枚举值不一致，中间的字符串转换逻辑制造了歧义。

**修复**
- 将三个 option 的 value 直接改为枚举格式：`NOT_STARTED` / `IN_PROGRESS` / `COMPLETED`。
- 删除后端多余的字符串转换分支（`"Not Started" → "NOT_STARTED"` 等），`statusFilter` 取到参数后只做空值清零，其余直接透传给 Service 层。

#### 2b. 任务信息展示与交互

**问题**
- "Total Tasks" 文案误导：显示的实际是 `StudentSubTask` 实例数，不是主任务数。
- 子任务无 `StudentSubTask ID` 显示，无法手动填写更新表单。
- 已完成任务筛选后进度条仍显示后端返回的 0%（后端 `progressPercentage` 字段未从子任务完成度计算）。
- 任务列表为扁平结构，课程和主任务层级不清晰。
- 侧边栏 "Task Detail" 使用固定 `id=1`。

**修复**
- 标题改为 `StudentSubTasks / 子任务实例数`。
- 每条子任务显示 `StudentSubTask ID: <id>`。
- 完成状态前端兜底：`int pct = "COMPLETED".equals(sstStatus) ? 100 : sst.getProgressPercentage()`。
- 后端数据不变，前端用 `courseName → mainTaskTitle` 两级 `LinkedHashMap` 分组展示，主任务块内嵌子任务列表。
- 侧边栏 "Task Detail" 改为无上下文时禁用的 `<span>`，不再链接到 `id=1`。
- 新增"更新此项"按钮：点击后通过 `data-fill-subtask-id` / `data-fill-status` 自动填充右侧 Update Progress 表单，并平滑滚动定位。

---

### 3. 学习统计页 (`WEB-INF/jsp/study-statistics.jsp`)

**问题**
- 侧边栏缺少 "Study Sessions" 入口，进入该页后当前项不高亮。
- 课程数卡片无论 0 还是 null 都显示 `Enrolled`，无法区分"未选课"与"暂无数据"。

**修复**
- 补回侧边栏 Study Sessions 链接并标记为 `active`。
- 课程数副标题改为三态：`null` → `"暂无课程数据"`，`0` → `"尚未加入课程"`，`>0` → `"Enrolled"`。

---

### 4. 硬编码 `id=1` 跳转全局清理

**受影响文件**：`student-home.jsp`、`student-courses.jsp`、`WEB-INF/jsp/task-detail.jsp`、`WEB-INF/jsp/sub-task-list.jsp`、`WEB-INF/jsp/course-list.jsp`、`WEB-INF/jsp/main-task-list.jsp`、`lecturer-home.jsp`、`lecturer-task-detail.jsp`、`WEB-INF/jsp/common/header.jsp`、`states.jsp`

**修复策略**
- 学生侧：无任务上下文时改为禁用 `<span>`（`cursor-not-allowed`，tooltip 提示从具体任务进入）。
- 讲师侧：取该讲师第一条真实任务 id（`activeTasks.get(0).getMainTaskId()` / `publishedTasks.get(0).getMainTaskId()`）；无任务时同样降级为禁用 `<span>`。
- header.jsp 中讲师导航 "任务详情" 直接改为跳任务列表页（`main-tasks.jsp`），避免在任意页面都做任务查询。
- states.jsp 成功卡片"View Detail"改为跳回任务列表，不再固定 `id=1`。

---

### 5. 讲师任务详情 (`lecturer-task-detail.jsp`)

**问题**
- Export 按钮只有 `data-confirm` 属性，点击无实际下载行为。
- Follow Up / View 按钮为 `<a href="#">`，点击无响应。

**修复**
- Export 改为前端 CSV 生成：读取页面 `.student-progress-row` 数据，含 BOM (`﻿`) 以保证 Excel 中文兼容，通过 `Blob + URL.createObjectURL` 触发下载，文件名 `studypal-task-progress.csv`。
- Follow Up / View 改为 `<button>`，点击后通过 `data-focus-student` 属性找到对应行，`scrollIntoView` 平滑定位并短暂高亮绿色边框（1800ms后消失）。

---

### 6. 管理员重置密码 (`admin-users.jsp`)

**问题**
- 重置按钮文案为 `"Reset to studypal123"`，不够明确。
- 成功提示为 `"Password reset successfully."`，没有说明是哪个用户。

**修复**
- 按钮文案改为"重置该用户密码为 studypal123"。
- 表单新增隐藏域 `userName`（值取 `u.getFullName()`），成功提示改为"已将 `<姓名>` 的密码重置为 studypal123。"。

---

## 测试说明

1. **注册流程**：密码不一致/邮箱重复/用户名重复 → 保留注册表单，对应字段清空，中文提示。
2. **筛选回显**：学生任务页选择 "In Progress" 筛选后提交，下拉应保持 "In Progress" 高亮。
3. **完成进度**：筛选 "Completed" 任务，所有进度条应显示 100%，不再显示 0%。
4. **更新此项**：点击子任务卡片右下角"更新此项"，右侧 SubTask ID 输入框自动填入对应 ID，状态选中当前状态。
5. **CSV 导出**：讲师任务详情页点击 "Export CSV"，下载文件用 Excel 打开中文不乱码。
6. **Follow Up/View**：点击按钮后页面平滑滚动至对应学生行并短暂绿色高亮。
7. **管理员重置**：重置密码后提示"已将 xxx 的密码重置为 studypal123。"。
