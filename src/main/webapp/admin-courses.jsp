<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Admin Course Management</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/workspace.css">
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
        <div class="warm-card stat-card"><p class="stat-label">Courses</p><p class="stat-value">18</p><p class="stat-hint">Current semester</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Lecturers</p><p class="stat-value accent">14</p><p class="stat-hint">Registered lecturer accounts</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Unassigned</p><p class="stat-value">2</p><p class="stat-hint">No lecturer selected</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Enrollments</p><p class="stat-value accent">184</p><p class="stat-hint">Across all courses</p></div>
      </section>
      <section class="panel-grid">
        <div class="warm-card fade-in-d2">
          <div class="row-between">
            <h2>Courses</h2>
            <a class="action-btn action-btn-secondary" href="#course-form">Add Course</a>
          </div>
          <div class="table-like">
            <div class="soft-card course-row"><div><p class="strong-title">Database Systems</p><p class="muted">DB2026 · Spring 2026</p></div><span class="muted">Dr. Emily Carter</span><span class="muted">ecarter@studypal.test</span><span class="badge">42 students</span><a class="action-btn action-btn-secondary" href="#course-form">Edit</a></div>
            <div class="soft-card course-row"><div><p class="strong-title">Software Engineering</p><p class="muted">SE2026 · Spring 2026</p></div><span class="muted">Prof. Daniel Hughes</span><span class="muted">dhughes@studypal.test</span><span class="badge">36 students</span><a class="action-btn action-btn-secondary" href="#course-form">Edit</a></div>
            <div class="soft-card course-row"><div><p class="strong-title">Data Visualization</p><p class="muted">DV2026 · Spring 2026</p></div><span class="muted">Unassigned</span><span class="muted">Select lecturer</span><span class="badge accent">28 students</span><a class="action-btn action-btn-primary" href="#course-form">Assign</a></div>
          </div>
        </div>
        <aside class="warm-card fade-in-d3" id="course-form">
          <h2>Create Course</h2>
          <form class="form-stack" data-ui-message="Course saved.">
            <div><label>Course Name</label><input name="courseName" value="Data Visualization" placeholder="Course name" required></div>
            <div><label>Course Code</label><input name="courseCode" value="DV2026" placeholder="Course code" required></div>
            <div><label>Semester</label><input name="semester" value="Spring 2026" placeholder="Semester"></div>
            <div><label>Lecturer Account</label><select name="lecturer" required><option value="">Select registered lecturer</option><option>ecarter - Dr. Emily Carter</option><option>dhughes - Prof. Daniel Hughes</option><option>lwilson - Ms. Laura Wilson</option></select></div>
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
