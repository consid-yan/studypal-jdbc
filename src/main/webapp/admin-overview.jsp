<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Admin Overview</title>
<link rel="stylesheet" href="assets/css/workspace.css">
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
        <div class="warm-card stat-card"><p class="stat-label">Task Completion</p><p class="stat-value">64%</p><p class="stat-hint">Completed student tasks</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Highest Workload</p><p class="stat-value accent">DB</p><p class="stat-hint">Database Systems</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Planned Workload</p><p class="stat-value">392h</p><p class="stat-hint">Last 30 days</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Enrollments</p><p class="stat-value accent">184</p><p class="stat-hint">Course registrations</p></div>
      </section>
      <section class="warm-card fade-in-d1">
        <h2>System Metrics</h2>
        <div class="table-like">
          <div class="soft-card admin-row"><p class="strong-title">Task Completion Rate</p><span class="muted">By course</span><span class="badge">64%</span><p class="muted">Student task progress</p></div>
          <div class="soft-card admin-row"><p class="strong-title">Course Workload</p><span class="muted">Deadlines and effort</span><span class="badge accent">High</span><p class="muted">Courses needing attention</p></div>
          <div class="soft-card admin-row"><p class="strong-title">Planned Workload</p><span class="muted">SubTask time windows</span><span class="badge">392h</span><p class="muted">Last 30 days</p></div>
        </div>
      </section>
    </div></main>
  </div>
</div>
</body>
</html>
