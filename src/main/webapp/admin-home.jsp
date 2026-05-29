<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.AdminService" %>
<%@ page import="com.studypal.model.UserAccount" %>
<% if (session.getAttribute("user") == null) { response.sendRedirect(request.getContextPath() + "/auth.jsp"); return; }
   UserAccount currentUser = (UserAccount) session.getAttribute("user");
   if (!"ADMIN".equals(currentUser.getRole())) { response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission"); return; }
   AdminService as = new AdminService(); int[] st = null; try { st = as.getStats(); } catch (Exception e) {}
   int us = st != null ? st[0] : 0; int stu = st != null ? st[1] : 0;
   int lec = st != null ? st[2] : 0; int ad = st != null ? st[3] : 0;
   int cs = st != null ? st[4] : 0; int ts = st != null ? st[5] : 0; %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Admin Home</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css?v=2">
</head>
<body>
<div class="workspace-shell">
  <aside class="workspace-sidebar">
    <div class="sidebar-brand"><div class="brand-line"><span class="pixel-word">StudyPal</span><span class="pixel-word accent">Campus</span></div><div class="mascot float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#766A5D"/><rect x="4" y="2" width="6" height="4" fill="#766A5D"/><rect x="5" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="8" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="3" y="6" width="8" height="5" fill="#766A5D" opacity="0.5"/><rect x="5" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/><rect x="7" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/></svg></div></div>
    <nav class="workspace-nav">
      <a class="sidebar-link active" href="${pageContext.request.contextPath}/admin-home.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="5" r="3"/><path d="M3 14c.8-3 2.4-4 5-4s4.2 1 5 4"/></svg>User Management</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12h12M3 8h10M4 4h8"/></svg>System Overview</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>Course Management</a>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>Admin Home</h1></div><div class="header-badges"><span class="pill">Active Admin</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="hero-card fade-in"><p class="eyebrow">ADMIN CONSOLE</p><h2>Manage users, courses, and learning activity.</h2></section>
      <section class="stats-grid fade-in-d1">
        <div class="warm-card stat-card"><p class="stat-label">Users</p><p class="stat-value"><%= us %></p><p class="stat-hint"><%= stu %> students / <%= lec %> lecturers / <%= ad %> admins</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Courses</p><p class="stat-value accent"><%= cs %></p><p class="stat-hint">All courses</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Tasks</p><p class="stat-value"><%= ts %></p><p class="stat-hint">All published tasks</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Enrollments</p><p class="stat-value accent"><%= st != null ? st[6] : 0 %></p><p class="stat-hint">Total enrollment records (not unique students)</p></div>
      </section>
      <section class="panel-grid">
        <div class="warm-card fade-in-d2">
          <h2>System Focus</h2>
          <div class="table-like">
            <a class="soft-card" href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN"><p class="strong-title">User Account Control</p><p class="muted">View registered users, reset passwords, and suspend accounts.</p></a>
            <a class="soft-card" href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN"><p class="strong-title">Course Workload</p><p class="muted">Find courses with dense deadlines or higher estimated hours.</p></a>
            <a class="soft-card" href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN"><p class="strong-title">Progress Tracking</p><p class="muted">Review student course progress and study activity.</p></a>
          </div>
        </div>
        <aside class="warm-card fade-in-d3">
          <h2>Role Setup</h2>
          <div class="table-like">
            <div class="soft-card"><p class="strong-title">Students</p><p class="muted">Can register from public auth page.</p></div>
            <div class="soft-card"><p class="strong-title">Lecturers</p><p class="muted">Created by administrator accounts.</p></div>
            <div class="soft-card"><p class="strong-title">Admins</p><p class="muted">Created only by the initial super administrator.</p></div>
          </div>
        </aside>
      </section>
    </div></main>
  </div>
</div>
</body>
</html>
