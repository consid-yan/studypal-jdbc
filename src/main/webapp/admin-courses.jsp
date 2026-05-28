<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.CourseService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/auth.jsp");
        return;
    }
    UserAccount currentUser = (UserAccount) session.getAttribute("user");
    if (!"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission");
        return;
    }
    CourseService courseService = new CourseService();
    String error = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("createCourse".equals(action)) {
            String courseName = request.getParameter("courseName");
            String courseCode = request.getParameter("courseCode");
            String semester = request.getParameter("semester");
            String lecturerIdStr = request.getParameter("lecturerId");
            String description = request.getParameter("description");
            try {
                Long lecturerId = Long.parseLong(lecturerIdStr);
                String result = courseService.createCourse(courseCode, courseName, lecturerId, semester, description);
                if (result == null) {
                    response.sendRedirect(request.getContextPath() + "/admin-courses.jsp?role=ADMIN");
                    return;
                } else {
                    error = result;
                }
            } catch (Exception e) {
                error = "Failed to create course: " + e.getMessage();
            }
        }
    }

    List<Course> courses = null;
    List<Lecturer> lecturers = null;
    int totalCourses = 0, totalLecturers = 0, totalEnrollments = 0;
    try {
        courses = courseService.getAllCourses();
        lecturers = courseService.getAllLecturers();
        totalCourses = courseService.getTotalCourseCount();
        totalLecturers = courseService.getTotalLecturerCount();
        totalEnrollments = courseService.getTotalEnrollmentCount();
    } catch (Exception e) {
        error = "Failed to load data: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Admin Course Management</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css?v=2">
</head>
<body>
<div class="workspace-shell">
  <aside class="workspace-sidebar">
    <div class="sidebar-brand">
      <div class="brand-line"><span class="pixel-word">StudyPal</span><span class="pixel-word accent">Campus</span></div>
      <div class="mascot float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#766A5D"/><rect x="4" y="2" width="6" height="4" fill="#766A5D"/><rect x="5" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="8" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="3" y="6" width="8" height="5" fill="#766A5D" opacity="0.5"/><rect x="5" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/><rect x="7" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/></svg></div>
    </div>
    <nav class="workspace-nav">
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-home.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="5" r="3"/><path d="M3 14c.8-3 2.4-4 5-4s4.2 1 5 4"/></svg>User Management</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12h12M3 8h10M4 4h8"/></svg>System Overview</a>
      <a class="sidebar-link active" href="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>Course Management</a>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>Course Management</h1></div><div class="header-badges"><span class="pill">Active Admin</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="hero-card fade-in"><p class="eyebrow">COURSE SETUP</p><h2>Create courses and assign registered lecturers.</h2></section>
      <section class="stats-grid fade-in-d1">
        <div class="warm-card stat-card"><p class="stat-label">Courses</p><p class="stat-value"><%= totalCourses %></p><p class="stat-hint">Current semester</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Lecturers</p><p class="stat-value accent"><%= totalLecturers %></p><p class="stat-hint">Registered lecturer accounts</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Students</p><p class="stat-value accent"><%= totalEnrollments %></p><p class="stat-hint">Enrolled across all courses</p></div>
      </section>
      <section class="panel-grid">
        <div class="warm-card fade-in-d2">
          <div class="row-between">
            <h2>Courses</h2>
            <a class="action-btn action-btn-secondary" href="#course-form">Add Course</a>
          </div>
          <div class="table-like">
            <% if (courses != null && !courses.isEmpty()) {
                 for (Course c : courses) { %>
                   <div class="soft-card course-row">
                     <div><p class="strong-title"><%= c.getCourseName() %></p><p class="muted"><%= c.getCourseCode() %> · <%= c.getSemester() %></p></div>
                     <span class="muted"><%= c.getLecturerName() != null ? c.getLecturerName() : "N/A" %></span>
                     <span class="badge"><%= c.getEnrollmentCount() %> students</span>
                     <a class="action-btn action-btn-secondary" href="#course-form">Edit</a>
                   </div>
            <%   }
               } else { %>
                 <div class="soft-card"><p class="muted" style="text-align:center;padding:20px;">No courses yet. Create one using the form.</p></div>
            <% } %>
          </div>
        </div>
        <aside class="warm-card fade-in-d3" id="course-form">
          <h2>Create Course</h2>
          <% if (error != null) { %>
            <div style="margin-bottom:16px;padding:12px;border-radius:8px;background:#FEF2F2;color:#991B1B;border:1px solid #FECACA;font-size:13px;"><%= error %></div>
          <% } %>
          <form class="form-stack" method="post" action="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN">
            <input type="hidden" name="action" value="createCourse">
            <div><label>Course Name</label><input name="courseName" placeholder="Course name" required></div>
            <div><label>Course Code</label><input name="courseCode" placeholder="Course code" required></div>
            <div><label>Semester</label><input name="semester" placeholder="e.g. 2026-Spring"></div>
            <div><label>Lecturer Account</label><select name="lecturerId" required>
              <option value="">Select registered lecturer</option>
              <% if (lecturers != null) {
                   for (Lecturer lec : lecturers) { %>
                     <option value="<%= lec.getLecturerId() %>"><%= lec.getFullName() %> (<%= lec.getEmployeeNo() %>)</option>
              <%   }
                 } %>
            </select></div>
            <div><label>Description</label><textarea name="description" placeholder="Course description"></textarea></div>
            <button class="action-btn action-btn-primary" type="submit">Save Course</button>
          </form>
        </aside>
      </section>
    </div></main>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
