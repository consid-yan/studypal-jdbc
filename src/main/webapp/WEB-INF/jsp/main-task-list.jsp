<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.TaskService" %>
<%@ page import="com.studypal.service.CourseService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Timestamp" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/auth.jsp");
        return;
    }
    UserAccount currentUser = (UserAccount) session.getAttribute("user");
    if (!"LECTURER".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission");
        return;
    }
    Long lecturerId = currentUser.getUserId();
    TaskService taskService = new TaskService();
    CourseService courseService = new CourseService();
    String error = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("createTask".equals(action)) {
            String title = request.getParameter("title");
            String courseIdStr = request.getParameter("courseId");
            String deadlineStr = request.getParameter("deadline");
            String importanceStr = request.getParameter("importance");
            String description = request.getParameter("description");
            try {
                Long courseId = (courseIdStr != null && !courseIdStr.isEmpty()) ? Long.parseLong(courseIdStr) : null;
                int importance = (importanceStr != null && !importanceStr.isEmpty()) ? Integer.parseInt(importanceStr) : 3;
                Timestamp deadline = Timestamp.valueOf(deadlineStr.replace("T", " ") + ":00");
                String result = taskService.createMainTask(courseId, lecturerId, title, description, deadline, importance, "COURSE_TASK");
                if (result == null) {
                    // AI-generated sub-task templates
                    List<MainTask> tasks = taskService.getTasksByCreatorId(lecturerId);
                    if (tasks != null && !tasks.isEmpty()) {
                        Long newTaskId = tasks.get(0).getMainTaskId();
                        String cName = tasks.get(0).getCourseName();
                        taskService.generateSubTaskTemplates(newTaskId, cName, title, description);
                    }
                    response.sendRedirect(request.getContextPath() + "/main-tasks.jsp?role=LECTURER");
                    return;
                } else {
                    error = result;
                }
            } catch (Exception e) {
                error = "Failed to create task: " + e.getMessage();
            }
        }
    }

    List<MainTask> publishedTasks = null;
    List<Course> myCourses = null;
    try {
        publishedTasks = taskService.getTasksByCreatorId(lecturerId);
        myCourses = courseService.getCoursesByLecturerId(lecturerId);
    } catch (Exception e) {
        error = (error != null) ? error : "Failed to load data: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Lecturer MainTasks</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css?v=3">
</head>
<body>
<div class="workspace-shell">
  <aside class="workspace-sidebar">
    <div class="sidebar-brand"><div class="brand-line"><span class="pixel-word">StudyPal</span><span class="pixel-word accent">Campus</span></div><div class="mascot float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#B76E45"/><rect x="4" y="2" width="6" height="4" fill="#B76E45"/><rect x="5" y="3" width="1" height="1" fill="#2E241B"/><rect x="8" y="3" width="1" height="1" fill="#2E241B"/><rect x="3" y="6" width="8" height="5" fill="#B76E45" opacity="0.6"/><rect x="5" y="11" width="2" height="2" fill="#B76E45"/><rect x="7" y="11" width="2" height="2" fill="#B76E45"/></svg></div></div>
    <nav class="workspace-nav">
      <a class="sidebar-link" href="${pageContext.request.contextPath}/lecturer-home.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/lecturer-courses.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>My Courses</a>
      <a class="sidebar-link active" href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>MainTasks</a>
      <span class="sidebar-link" style="opacity:.6;cursor:not-allowed" title="Open from a specific task"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>Task Detail</span>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>MainTasks</h1></div><div class="header-badges"><span class="pill">Active Lecturer</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="panel-grid">
        <div class="warm-card fade-in">
          <h2>Create Task</h2>
          <% if (error != null) { %>
            <div style="margin-bottom:16px;padding:12px;border-radius:8px;background:#FEF2F2;color:#991B1B;border:1px solid #FECACA;font-size:13px;"><%= error %></div>
          <% } %>
          <form class="form-stack" method="post" action="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER">
            <input type="hidden" name="action" value="createTask">
            <div class="form-grid"><div><label>Title</label><input name="title" placeholder="Task title" required></div><div><label>Course</label><select name="courseId" required>
              <option value="">Select course</option>
              <% if (myCourses != null) {
                   for (Course c : myCourses) { %>
                     <option value="<%= c.getCourseId() %>"><%= c.getCourseCode() %> - <%= c.getCourseName() %></option>
              <%   }
                 } %>
            </select></div></div>
            <div class="form-grid"><div><label>Deadline</label><input name="deadline" type="datetime-local" required></div><div><label>Importance</label><select name="importance">
              <option value="1">LOW</option><option value="2">MEDIUM</option><option value="3" selected>HIGH</option><option value="4">VERY_HIGH</option><option value="5">CRITICAL</option>
            </select></div></div>
            <div><label>Description</label><textarea name="description" placeholder="Task description"></textarea></div>
            <button class="action-btn action-btn-primary" type="submit">Publish MainTask</button>
          </form>
        </div>
        <aside class="warm-card fade-in-d1">
          <h2>Publish Rules</h2>
          <div class="table-like">
            <div class="soft-card"><p class="strong-title">Defines Task Steps</p><p class="muted">Steps describe what students need to finish.</p></div>
            <div class="soft-card"><p class="strong-title">Tracks Student Progress</p><p class="muted">Enrolled students receive progress records.</p></div>
            <div class="soft-card"><p class="strong-title">Published Task</p><p class="muted">Students can view the task after publishing.</p></div>
          </div>
        </aside>
      </section>
      <section class="warm-card fade-in-d2" style="margin-top:24px">
        <h2>Published Tasks</h2>
        <div class="table-like">
          <% if (publishedTasks != null && !publishedTasks.isEmpty()) {
               for (MainTask mt : publishedTasks) {
                 String impLabel = "MEDIUM"; String impClass = "";
                 switch (mt.getImportanceLevel() != null ? mt.getImportanceLevel() : 3) {
                     case 1: impLabel = "LOW"; impClass = "muted"; break;
                     case 2: impLabel = "MEDIUM"; impClass = ""; break;
                     case 3: impLabel = "HIGH"; impClass = ""; break;
                     case 4: impLabel = "VERY_HIGH"; impClass = "accent"; break;
                     case 5: impLabel = "CRITICAL"; impClass = "accent"; break;
                 }
                 String deadlineStr = mt.getDeadline() != null ? mt.getDeadline().toString().substring(0, 10) : "N/A";
          %>
                 <div class="soft-card table-row">
                   <div><p class="strong-title"><%= mt.getTitle() %></p><p class="muted"><%= mt.getCourseName() != null ? mt.getCourseName() : "Personal Task" %></p></div>
                   <span class="muted"><%= deadlineStr %></span>
                   <span class="badge <%= impClass %>"><%= impLabel %></span>
                   <span class="muted">Published</span>
                   <a class="action-btn action-btn-secondary" href="${pageContext.request.contextPath}/lecturer-task-detail.jsp?role=LECTURER&id=<%= mt.getMainTaskId() %>">View</a>
                 </div>
          <%   }
             } else { %>
               <div class="soft-card"><p class="muted" style="text-align:center;padding:20px;">No tasks published yet.</p></div>
          <% } %>
        </div>
      </section>
    </div></main>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
