<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.AdminService" %>
<%@ page import="com.studypal.model.UserAccount" %>
<% if (session.getAttribute("user") == null) { response.sendRedirect(request.getContextPath() + "/auth.jsp"); return; }
   UserAccount currentUser = (UserAccount) session.getAttribute("user");
   if (!"ADMIN".equals(currentUser.getRole())) { response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission"); return; }
   AdminService as = new AdminService(); int[] st = null; try { st = as.getStats(); } catch (Exception e) {}
   int us = st != null ? st[0] : 0; int stu = st != null ? st[1] : 0; int lec = st != null ? st[2] : 0;
   int cs = st != null ? st[4] : 0; int ts = st != null ? st[5] : 0; int en = st != null ? st[6] : 0; %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Admin Overview</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css?v=4">
</head>
<body>
<div class="workspace-shell">
  <aside class="workspace-sidebar">
    <div class="sidebar-brand"><div class="brand-line"><span class="pixel-word">StudyPal</span><span class="pixel-word accent">Campus</span></div><div class="mascot float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#766A5D"/><rect x="4" y="2" width="6" height="4" fill="#766A5D"/><rect x="5" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="8" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="3" y="6" width="8" height="5" fill="#766A5D" opacity="0.5"/><rect x="5" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/><rect x="7" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/></svg></div></div>
    <nav class="workspace-nav">
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-home.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="5" r="3"/><path d="M3 14c.8-3 2.4-4 5-4s4.2 1 5 4"/></svg>User Management</a>
      <a class="sidebar-link active" href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12h12M3 8h10M4 4h8"/></svg>System Overview</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>Course Management</a>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>System Overview</h1></div><div class="header-badges"><span class="pill">Active Admin</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="stats-grid fade-in">
        <div class="warm-card stat-card"><p class="stat-label">Users</p><p class="stat-value"><%= us %></p><p class="stat-hint"><%= stu %> students / <%= lec %> lecturers</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Courses</p><p class="stat-value accent"><%= cs %></p><p class="stat-hint">All available courses</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Tasks</p><p class="stat-value"><%= ts %></p><p class="stat-hint">All published tasks</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Enrollments</p><p class="stat-value accent"><%= en %></p><p class="stat-hint">Total enrollment records, not unique students</p></div>
      </section>
      <section class="warm-card fade-in-d1">
        <h2>System Metrics</h2>
        <div class="table-like">
          <div class="soft-card admin-row"><p class="strong-title">Total Courses</p><span class="muted">Active semester</span><span class="badge"><%= cs %></span><p class="muted">With assigned lecturers</p></div>
          <div class="soft-card admin-row"><p class="strong-title">Total Tasks</p><span class="muted">Published</span><span class="badge accent"><%= ts %></span><p class="muted">Across all courses</p></div>
          <div class="soft-card admin-row"><p class="strong-title">Total Enrollments</p><span class="muted">Student registrations</span><span class="badge"><%= en %></span><p class="muted">Enrollment records (one student in N courses counts N times)</p></div>
        </div>
      </section>
    </div></main>
  </div>
</div>
</body>
</html>
