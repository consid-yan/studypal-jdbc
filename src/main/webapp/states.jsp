<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal System Messages</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css">
</head>
<body>
<div class="workspace-shell">
  <aside class="workspace-sidebar">
    <div class="sidebar-brand"><div class="brand-line"><span class="pixel-word">StudyPal</span><span class="pixel-word accent">Campus</span></div><div class="mascot float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#766A5D"/><rect x="4" y="2" width="6" height="4" fill="#766A5D"/><rect x="5" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="8" y="3" width="1" height="1" fill="#F4EBDD"/><rect x="3" y="6" width="8" height="5" fill="#766A5D" opacity="0.5"/><rect x="5" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/><rect x="7" y="11" width="2" height="2" fill="#766A5D" opacity="0.7"/></svg></div></div>
    <nav class="workspace-nav">
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-home.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="5" r="3"/><path d="M3 14c.8-3 2.4-4 5-4s4.2 1 5 4"/></svg>User Management</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12h12M3 8h10M4 4h8"/></svg>System Overview</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>Course Management</a>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>System Messages</h1></div><div class="header-badges"><span class="pill">Active Admin</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="hero-card fade-in"><p class="eyebrow">MESSAGES</p><h2>Clear feedback for every action.</h2></section>
      <section class="two-grid">
        <div class="warm-card fade-in-d1"><span class="badge muted">EMPTY</span><h2 style="margin-top:14px">No MainTask yet</h2><p class="muted">After a lecturer publishes a MainTask, it appears here with generated templates.</p><a class="action-btn action-btn-primary" href="${pageContext.request.contextPath}/main-tasks?role=LECTURER">Publish MainTask</a></div>
        <div class="warm-card state-warning fade-in-d2"><span class="badge accent">ERROR</span><h2 style="margin-top:14px">Validation failed</h2><p class="muted">End time must be later than start time. Please review the StudySession form.</p><button class="action-btn action-btn-secondary">Return to Form</button></div>
        <div class="warm-card state-warning fade-in-d3"><span class="badge accent">NO PERMISSION</span><h2 style="margin-top:14px">Role cannot access this page</h2><p class="muted">The current account role does not match the required page permission.</p><a class="action-btn action-btn-secondary" href="${pageContext.request.contextPath}/auth.jsp">Back to Login</a></div>
        <div class="warm-card state-success fade-in-d4"><span class="badge">SUCCESS</span><h2 style="margin-top:14px">MainTask published</h2><p class="muted">Student progress records are ready.</p><a class="action-btn action-btn-primary" href="${pageContext.request.contextPath}/lecturer-task-detail.jsp?role=LECTURER&id=1">View Detail</a></div>
      </section>
    </div></main>
  </div>
</div>
</body>
</html>
