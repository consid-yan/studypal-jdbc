<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.CourseService" %>
<%@ page import="com.studypal.service.TaskService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
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
    CourseService courseService = new CourseService();
    TaskService taskService = new TaskService();

    List<Course> myCourses = null;
    List<MainTask> activeTasks = null;
    int courseCount = 0, publishedTaskCount = 0, totalStudents = 0;
    try {
        myCourses = courseService.getCoursesByLecturerId(lecturerId);
        courseCount = courseService.getLecturerCourseCount(lecturerId);
        publishedTaskCount = courseService.getPublishedTaskCount(lecturerId);
        totalStudents = courseService.getLecturerEnrollmentCount(lecturerId);
        activeTasks = taskService.getTasksByCreatorId(lecturerId);
    } catch (Exception ignored) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Lecturer Home</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css?v=4">
</head>
<body>
<div class="workspace-shell">
  <aside class="workspace-sidebar">
    <div class="sidebar-brand">
      <div class="brand-line"><span class="pixel-word">StudyPal</span><span class="pixel-word accent">Campus</span></div>
      <div class="mascot float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#B76E45"/><rect x="4" y="2" width="6" height="4" fill="#B76E45"/><rect x="5" y="3" width="1" height="1" fill="#2E241B"/><rect x="8" y="3" width="1" height="1" fill="#2E241B"/><rect x="3" y="6" width="8" height="5" fill="#B76E45" opacity="0.6"/><rect x="5" y="11" width="2" height="2" fill="#B76E45"/><rect x="7" y="11" width="2" height="2" fill="#B76E45"/></svg></div>
    </div>
    <nav class="workspace-nav">
      <a class="sidebar-link active" href="${pageContext.request.contextPath}/lecturer-home.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/lecturer-courses.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>My Courses</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>MainTasks</a>
      <span class="sidebar-link" style="opacity:.6;cursor:not-allowed" title="Open from a specific task"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>Task Detail</span>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header">
      <div class="header-inner">
        <div><h1>Lecturer Home</h1></div>
        <div class="header-badges"><span class="pill">Active Lecturer</span><span class="pill strong">Spring 2026</span></div>
      </div>
    </header>
    <main class="workspace-content">
      <div class="content-inner">
        <section class="hero-card fade-in">
          <p class="eyebrow">LECTURER WORKSPACE</p>
          <h2>Teaching progress stays visible.</h2>
        </section>
        <section class="stats-grid stats-grid-3 fade-in-d1">
          <div class="warm-card stat-card"><p class="stat-label">Courses</p><p class="stat-value"><%= courseCount %></p><p class="stat-hint">Currently teaching</p></div>
          <div class="warm-card stat-card"><p class="stat-label">Published Tasks</p><p class="stat-value accent"><%= publishedTaskCount %></p><p class="stat-hint">Across active courses</p></div>
          <div class="warm-card stat-card"><p class="stat-label">Students</p><p class="stat-value accent"><%= totalStudents %></p><p class="stat-hint">Enrolled across courses</p></div>
        </section>
        <section class="panel-grid">
          <div class="panel-stack">
            <div class="warm-card fade-in-d2">
              <div class="row-between" style="align-items:center;margin-bottom:16px"><h2 style="margin:0">Active Tasks</h2><a class="action-btn action-btn-primary" href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER">Publish Task</a></div>
              <div class="table-like">
                <% if (activeTasks != null && !activeTasks.isEmpty()) {
                     for (MainTask mt : activeTasks) {
                       String dl = mt.getDeadline() != null ? mt.getDeadline().toString().substring(0, 10) : "N/A";
                       int tc = mt.getTemplateCount();
                       double avg = 0;
                       try { avg = taskService.getTaskAvgCompletion(mt.getMainTaskId()); } catch (Exception ignored) {}
                %>
                     <div class="soft-card">
                       <div class="row-between"><div><p class="strong-title"><%= mt.getTitle() %></p><p class="muted"><%= mt.getCourseName() != null ? mt.getCourseName() : "Personal" %> · <%= tc %> steps · <%= dl %></p></div><span class="badge accent"><%= (int)avg %>%</span></div>
                       <div class="progress-track" style="margin-top:12px"><div class="progress-fill" style="--target-width:<%= (int)avg %>%"></div></div>
                     </div>
                <%   }
                   } else { %><div class="soft-card"><p class="muted" style="text-align:center;padding:20px;">No tasks published yet.</p></div><% } %>
              </div>
            </div>

            <% if (myCourses != null && !myCourses.isEmpty()) { %>
            <div class="warm-card fade-in-d2">
              <div class="row-between"><h2>My Courses</h2></div>
              <div class="table-like">
                <% for (Course c : myCourses) { %>
                  <div class="soft-card course-row">
                    <div><p class="strong-title"><%= c.getCourseName() %></p><p class="muted"><%= c.getCourseCode() %> · <%= c.getSemester() %></p></div>
                    <span class="badge"><%= c.getEnrollmentCount() %> students</span>
                  </div>
                <% } %>
              </div>
            </div>
            <% } %>
          </div>
          <aside class="warm-card fade-in-d3">
            <h2>Teaching Actions</h2>
            <div class="table-like">
              <a class="soft-card" href="${pageContext.request.contextPath}/lecturer-courses.jsp?role=LECTURER"><p class="strong-title">Review Courses</p><p class="muted">Check enrollment and course workload.</p></a>
              <a class="soft-card" href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER"><p class="strong-title">Create Task</p><p class="muted">Publish work for enrolled students.</p></a>
              <% if (activeTasks != null && !activeTasks.isEmpty()) { %>
                <a class="soft-card" href="${pageContext.request.contextPath}/lecturer-task-detail.jsp?role=LECTURER&id=<%= activeTasks.get(0).getMainTaskId() %>"><p class="strong-title">Open Task Detail</p><p class="muted">Inspect student completion and progress.</p></a>
              <% } else { %>
                <div class="soft-card"><p class="strong-title">Open Task Detail</p><p class="muted">No published task yet. Create a task first.</p></div>
              <% } %>
            </div>
          </aside>
        </section>
      </div>
    </main>
  </div>
</div>
</body>
</html>
