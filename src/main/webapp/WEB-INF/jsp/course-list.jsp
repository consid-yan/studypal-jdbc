<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.CourseService" %>
<%@ page import="com.studypal.service.TaskService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null) { response.sendRedirect(request.getContextPath() + "/auth.jsp"); return; }
    UserAccount cu = (UserAccount) session.getAttribute("user");
    if (!"LECTURER".equals(cu.getRole())) { response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission"); return; }
    CourseService cs = new CourseService(); TaskService ts = new TaskService();
    List<Course> myCourses = null; List<MainTask> lecturerTasks = null; int tcs = 0, tss = 0, taskCount = 0; double avgP = 0;
    try {
        myCourses = cs.getCoursesByLecturerId(cu.getUserId());
        lecturerTasks = ts.getTasksByCreatorId(cu.getUserId());
        tcs = cs.getLecturerCourseCount(cu.getUserId());
        tss = cs.getLecturerEnrollmentCount(cu.getUserId());
        taskCount = lecturerTasks != null ? lecturerTasks.size() : 0;
        if (lecturerTasks != null) {
            for (MainTask mt : lecturerTasks) { avgP += ts.getTaskAvgCompletion(mt.getMainTaskId()); }
            if (!lecturerTasks.isEmpty()) avgP /= lecturerTasks.size();
        }
    } catch (Exception ignored) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Lecturer Courses</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css?v=3">
</head>
<body>
<div class="workspace-shell">
  <aside class="workspace-sidebar">
    <div class="sidebar-brand"><div class="brand-line"><span class="pixel-word">StudyPal</span><span class="pixel-word accent">Campus</span></div><div class="mascot float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#B76E45"/><rect x="4" y="2" width="6" height="4" fill="#B76E45"/><rect x="5" y="3" width="1" height="1" fill="#2E241B"/><rect x="8" y="3" width="1" height="1" fill="#2E241B"/><rect x="3" y="6" width="8" height="5" fill="#B76E45" opacity="0.6"/><rect x="5" y="11" width="2" height="2" fill="#B76E45"/><rect x="7" y="11" width="2" height="2" fill="#B76E45"/></svg></div></div>
    <nav class="workspace-nav">
      <a class="sidebar-link" href="${pageContext.request.contextPath}/lecturer-home.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link active" href="${pageContext.request.contextPath}/lecturer-courses.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>My Courses</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>MainTasks</a>
      <% if (lecturerTasks != null && !lecturerTasks.isEmpty()) { %>
        <a class="sidebar-link" href="${pageContext.request.contextPath}/lecturer-task-detail.jsp?role=LECTURER&id=<%= lecturerTasks.get(0).getMainTaskId() %>"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>Task Detail</a>
      <% } else { %>
        <span class="sidebar-link" style="opacity:.6;cursor:not-allowed" title="请先创建任务"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>Task Detail</span>
      <% } %>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>My Courses</h1></div><div class="header-badges"><span class="pill">Active Lecturer</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="stats-grid fade-in">
        <div class="warm-card stat-card"><p class="stat-label">Teaching Courses</p><p class="stat-value"><%= tcs %></p><p class="stat-hint">Owned by lecturer</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Enrolled Students</p><p class="stat-value accent"><%= tss %></p><p class="stat-hint">Across all courses</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Tasks</p><p class="stat-value"><%= taskCount %></p><p class="stat-hint">Active MainTasks</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Avg. Progress</p><p class="stat-value accent"><%= (int)avgP %>%</p><p class="stat-hint">Student completion</p></div>
      </section>
      <section class="panel-grid" style="margin-top:24px">
        <div class="warm-card">
          <h2>Course List</h2>
          <div class="course-list-stack" style="margin-top:16px">
            <% if (myCourses != null && !myCourses.isEmpty()) {
                 for (Course c : myCourses) {
                   double cp = 0; int courseTaskCount = 0;
                   try {
                     if (lecturerTasks != null) {
                       for (MainTask mt : lecturerTasks) {
                         if (mt.getCourseId() != null && mt.getCourseId().equals(c.getCourseId())) {
                           cp += ts.getTaskAvgCompletion(mt.getMainTaskId());
                           courseTaskCount++;
                         }
                       }
                     }
                     if (courseTaskCount > 0) cp /= courseTaskCount;
                   } catch (Exception ignored) {}
            %>
                   <div class="soft-card" <%= myCourses.indexOf(c) > 0 ? "style='margin-top:14px'" : "" %>>
                     <div class="row-between"><h2><%= c.getCourseName() %></h2><span class="badge"><%= c.getCourseCode() %></span></div>
                     <p class="muted"><%= c.getSemester() %> · <%= c.getEnrollmentCount() %> enrolled students</p>
                     <div class="progress-track" style="margin:12px 0"><div class="progress-fill" style="--target-width:<%= (int)cp %>%"></div></div>
                     <span class="muted"><%= (int)cp %>% completion across all tasks</span>
                     <div class="row-between" style="margin-top:18px"><a class="action-btn action-btn-primary" href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER">Publish Task</a></div>
                   </div>
            <%   }
               } else { %><p class="muted" style="text-align:center;padding:20px;">No courses assigned.</p><% } %>
          </div>
        </div>
      </section>
    </div></main>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
