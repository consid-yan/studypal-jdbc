<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.AdminService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/auth.jsp");
        return;
    }
    AdminService adminService = new AdminService();
    String error = null, success = null;

    String roleFilter = request.getParameter("role");
    String keyword = request.getParameter("keyword");
    if ("All Roles".equals(roleFilter) || "".equals(roleFilter)) roleFilter = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("createAccount".equals(action)) {
            String uname = request.getParameter("username");
            String email = request.getParameter("email");
            String pw = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String role = request.getParameter("newRole");
            String dept = request.getParameter("department");
            try {
                String r = adminService.createAccount(uname, email, pw, fullName, role, dept, null, null, null);
                if (r == null) success = "Account created successfully.";
                else error = r;
            } catch (Exception e) { error = "Create failed: " + e.getMessage(); }
        } else if ("resetPassword".equals(action)) {
            String uidStr = request.getParameter("userId");
            String newPw = request.getParameter("newPassword");
            try {
                Long uid = Long.parseLong(uidStr);
                String r = adminService.resetPassword(uid, newPw);
                if (r == null) success = "Password reset successfully.";
                else error = r;
            } catch (Exception e) { error = "Reset failed: " + e.getMessage(); }
        }
    }

    List<UserAccount> users = null;
    int[] stats = null;
    try {
        users = adminService.getAllUsers(roleFilter, keyword);
        stats = adminService.getStats();
    } catch (Exception e) { error = "Failed to load: " + e.getMessage(); }
    int totalUsers = stats != null ? stats[0] : 0;
    int studentCount = stats != null ? stats[1] : 0;
    int lecturerCount = stats != null ? stats[2] : 0;
    int adminCount = stats != null ? stats[3] : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Admin User Management</title>
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
      <a class="sidebar-link active" href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="5" r="3"/><path d="M3 14c.8-3 2.4-4 5-4s4.2 1 5 4"/></svg>User Management</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12h12M3 8h10M4 4h8"/></svg>System Overview</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>Course Management</a>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>User Management</h1></div><div class="header-badges"><span class="pill">Active Admin</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="hero-card fade-in"><p class="eyebrow">ACCOUNT CONTROL</p><h2>Manage registered StudyPal users.</h2></section>
      <section class="stats-grid fade-in-d1">
        <div class="warm-card stat-card"><p class="stat-label">Total Users</p><p class="stat-value"><%= totalUsers %></p><p class="stat-hint">All registered accounts</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Students</p><p class="stat-value accent"><%= studentCount %></p><p class="stat-hint">Registered students</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Lecturers</p><p class="stat-value"><%= lecturerCount %></p><p class="stat-hint">Teaching staff</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Admins</p><p class="stat-value accent"><%= adminCount %></p><p class="stat-hint">System administrators</p></div>
      </section>
      <section class="management-grid">
        <div class="warm-card fade-in-d2">
          <div class="row-between">
            <h2>Registered Users</h2>
            <a class="action-btn action-btn-secondary" href="#create-account">Create Account</a>
          </div>
          <form class="filter-bar" method="GET" action="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN">
            <div><label>Search</label><input name="keyword" value="<%= keyword != null ? keyword : "" %>" placeholder="Name, username, or email"></div>
            <div><label>Role</label><select name="role"><option value="">All Roles</option><option value="STUDENT" <%= "STUDENT".equals(roleFilter) ? "selected" : "" %>>STUDENT</option><option value="LECTURER" <%= "LECTURER".equals(roleFilter) ? "selected" : "" %>>LECTURER</option><option value="ADMIN" <%= "ADMIN".equals(roleFilter) ? "selected" : "" %>>ADMIN</option></select></div>
            <button class="action-btn action-btn-primary" type="submit">Apply</button>
          </form>
          <% if (error != null) { %><div style="margin:12px 0;padding:12px;border-radius:8px;background:#FEF2F2;color:#991B1B;border:1px solid #FECACA;font-size:13px;"><%= error %></div><% } %>
          <% if (success != null) { %><div style="margin:12px 0;padding:12px;border-radius:8px;background:#ECFDF5;color:#065F46;border:1px solid #A7F3D0;font-size:13px;"><%= success %></div><% } %>
          <div class="table-like">
            <% if (users != null && !users.isEmpty()) {
                 for (UserAccount u : users) {
                   String badgeClass = "STUDENT".equals(u.getRole()) ? "badge" : ("LECTURER".equals(u.getRole()) ? "badge accent" : "badge muted");
            %>
                   <div class="soft-card user-row">
                     <div class="user-meta"><p class="strong-title"><%= u.getFullName() %></p><span class="muted"><%= u.getUsername() %></span></div>
                     <span class="<%= badgeClass %>"><%= u.getRole() %></span>
                     <span class="muted"><%= u.getEmail() %></span>
                     <span class="muted">ID: <%= u.getUserId() %></span>
                     <div class="button-row">
                       <form method="post" action="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN" style="display:inline;">
                         <input type="hidden" name="action" value="resetPassword">
                         <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                         <input type="hidden" name="newPassword" value="studypal123">
                         <button class="action-btn action-btn-secondary" type="submit">Reset to studypal123</button>
                       </form>
                     </div>
                   </div>
            <%   }
               } else { %>
                 <div class="soft-card"><p class="muted" style="text-align:center;padding:20px;">No users found.</p></div>
            <% } %>
          </div>
        </div>
        <aside class="warm-card fade-in-d3" id="create-account">
          <h2>Create Managed Account</h2>
          <form class="form-stack" method="post" action="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN">
            <input type="hidden" name="action" value="createAccount">
            <div><label>Full Name</label><input name="fullName" placeholder="Dr. Emily Carter" required></div>
            <div><label>Email</label><input name="email" type="email" placeholder="name@studypal.test" required></div>
            <div><label>Username</label><input name="username" placeholder="ecarter" required></div>
            <div><label>Role</label><select name="newRole" required><option value="LECTURER">LECTURER</option><option value="ADMIN">ADMIN</option><option value="STUDENT">STUDENT</option></select></div>
            <div><label>Department</label><input name="department" placeholder="e.g. Computer Science"></div>
            <div><label>Initial Password</label><input name="password" type="password" placeholder="Temporary password" required></div>
            <button class="action-btn action-btn-primary" type="submit">Create Account</button>
          </form>
        </aside>
      </section>
    </div></main>
  </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
