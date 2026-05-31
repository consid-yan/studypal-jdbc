<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    String taskIdStr = request.getParameter("id");
    Long taskId = null;
    try { taskId = Long.parseLong(taskIdStr); } catch (Exception ignored) {}

    TaskService taskService = new TaskService();
    MainTask task = null;
    int enrolledCount = 0, completedCount = 0, atRiskCount = 0;
    double avgCompletion = 0.0;
    List<StudentSubTask> studentProgress = null;
    List<SubTaskTemplate> stepProgress = null;

    if (taskId != null) {
        try {
            task = taskService.getTaskById(taskId);
            if (task == null || task.getCreatorId() == null || !task.getCreatorId().equals(currentUser.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission");
                return;
            }
            enrolledCount = taskService.getTaskEnrollmentCount(taskId);
            avgCompletion = taskService.getTaskAvgCompletion(taskId);
            completedCount = taskService.getTaskCompletedStudentCount(taskId);
            atRiskCount = taskService.getTaskAtRiskStudentCount(taskId);
            studentProgress = taskService.getStudentProgressByTask(taskId);
            stepProgress = taskService.getStepAggregateProgress(taskId);
        } catch (Exception ignored) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Lecturer Task Detail</title>
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
      <a class="sidebar-link" href="${pageContext.request.contextPath}/lecturer-home.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/lecturer-courses.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>My Courses</a>
      <a class="sidebar-link" href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>MainTasks</a>
      <% if (taskId != null) { %>
        <a class="sidebar-link active" href="${pageContext.request.contextPath}/lecturer-task-detail.jsp?role=LECTURER&id=<%= taskId %>"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>Task Detail</a>
      <% } else { %>
        <span class="sidebar-link active" style="opacity:.6;cursor:not-allowed" title="Open from a specific task"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>Task Detail</span>
      <% } %>
    </nav>
    <div class="sidebar-footer"><a class="sidebar-link" href="${pageContext.request.contextPath}/auth.jsp"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>Log out</a></div>
  </aside>
  <div class="workspace-main">
    <header class="workspace-header"><div class="header-inner"><div><h1>Task Detail</h1></div><div class="header-badges"><span class="pill">Active Lecturer</span><span class="pill strong">Spring 2026</span></div></div></header>
    <main class="workspace-content"><div class="content-inner">
      <section class="hero-card fade-in">
        <p class="eyebrow"><%= task != null && task.getCourseName() != null ? (task.getCourseName() + " · " + task.getCourseCode()) : "Personal Task" %></p>
        <h2><%= task != null ? task.getTitle() : "N/A" %></h2>
      </section>
      <section class="stats-grid fade-in-d1">
        <div class="warm-card stat-card"><p class="stat-label">Students</p><p class="stat-value"><%= enrolledCount %></p><p class="stat-hint">Enrolled</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Average Completion</p><p class="stat-value accent"><%= (int)avgCompletion %>%</p><p class="stat-hint">Across all students</p></div>
        <div class="warm-card stat-card"><p class="stat-label">Completed</p><p class="stat-value"><%= completedCount %></p><p class="stat-hint">Submitted all steps</p></div>
        <div class="warm-card stat-card"><p class="stat-label">At Risk</p><p class="stat-value accent"><%= atRiskCount %></p><p class="stat-hint">Below 40%</p></div>
      </section>
      <section class="management-grid">
        <div class="warm-card fade-in-d2">
          <div class="row-between" style="align-items:center;margin-bottom:16px">
            <h2 style="margin:0">Student Completion</h2>
            <button class="action-btn action-btn-secondary" type="button" id="exportTaskReportButton">Export CSV</button>
          </div>
          <div class="table-like">
            <% if (studentProgress != null && !studentProgress.isEmpty()) {
                 for (StudentSubTask sp : studentProgress) {
                   int pct = sp.getProgressPercentage();
                   String badgeLabel = pct >= 100 ? "COMPLETED" : (pct == 0 ? "TODO" : "IN_PROGRESS");
                   String badgeClass = pct >= 100 ? "badge" : (pct < 40 ? "badge muted" : "badge accent");
                   String btnLabel = pct < 40 ? "Follow Up" : "View";
                   String btnClass = pct < 40 ? "action-btn action-btn-primary" : "action-btn action-btn-secondary";
            %>
                   <div class="soft-card student-progress-row" id="student-progress-<%= sp.getStudentId() %>">
                     <div class="user-meta"><p class="strong-title"><%= sp.getStudentName() %></p><span class="muted"><%= sp.getStudentEmail() %></span></div>
                     <span class="<%= badgeClass %>"><%= badgeLabel %></span>
                     <div class="student-progress-cell"><div class="progress-track"><div class="progress-fill <%= badgeClass.contains("accent") ? "accent" : "" %>" style="--target-width:<%= pct %>%"></div></div></div>
                     <span class="muted student-progress-pct"><%= pct %>%</span>
                     <span class="muted">--</span>
                     <button class="<%= btnClass %>" type="button" data-followup-name="<%= sp.getStudentName() %>" data-followup-email="<%= sp.getStudentEmail() != null ? sp.getStudentEmail() : "" %>" data-followup-task="<%= task != null && task.getTitle() != null ? task.getTitle() : "" %>"><%= btnLabel %></button>
                   </div>
            <%   }
               } else { %>
                 <div class="soft-card"><p class="muted" style="text-align:center;padding:20px;">No students enrolled yet.</p></div>
            <% } %>
          </div>
        </div>
        <aside class="warm-card fade-in-d3">
          <h2>Task Steps</h2>
          <div class="table-like">
            <% if (stepProgress != null && !stepProgress.isEmpty()) {
                 for (SubTaskTemplate st : stepProgress) {
                   int done = st.getCompletedCount();
                   int total = st.getTotalStudentCount();
                   int pct = total > 0 ? (done * 100 / total) : 0;
            %>
                   <div class="soft-card step-progress-row">
                     <div><p class="strong-title"><%= st.getTitle() %></p><p class="muted"><%= done %> of <%= total %> completed</p></div>
                     <span class="badge accent"><%= pct %>%</span>
                     <div class="progress-track"><div class="progress-fill accent" style="--target-width:<%= pct %>%"></div></div>
                   </div>
            <%   }
               } else { %>
                 <div class="soft-card"><p class="muted" style="text-align:center;padding:20px;">No steps defined.</p></div>
            <% } %>
          </div>
        </aside>
      </section>
    </div></main>
  </div>
</div>
<script>
(function () {
  function csvCell(value) {
    var text = (value || '').replace(/\s+/g, ' ').trim();
    return '"' + text.replace(/"/g, '""') + '"';
  }

  var exportButton = document.getElementById('exportTaskReportButton');
  if (exportButton) {
    exportButton.addEventListener('click', function () {
      var rows = Array.prototype.slice.call(document.querySelectorAll('.student-progress-row'));
      if (!rows.length) {
        window.alert('No student progress to export for this task yet.');
        return;
      }
      var lines = [['Student', 'Email', 'Status', 'Progress'].map(csvCell).join(',')];
      rows.forEach(function (row) {
        var name = row.querySelector('.user-meta .strong-title');
        var email = row.querySelector('.user-meta .muted');
        var status = row.querySelector('.badge');
        var progress = row.querySelector('.student-progress-pct');
        lines.push([name, email, status, progress].map(function (node) {
          return csvCell(node ? node.textContent : '');
        }).join(','));
      });
      var blob = new Blob(['\ufeff' + lines.join('\n')], { type: 'text/csv;charset=utf-8;' });
      var link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = 'studypal-task-progress.csv';
      document.body.appendChild(link);
      link.click();
      URL.revokeObjectURL(link.href);
      link.remove();
    });
  }

  document.querySelectorAll('[data-followup-email]').forEach(function (button) {
    button.addEventListener('click', function () {
      var name = button.getAttribute('data-followup-name') || 'this student';
      var email = (button.getAttribute('data-followup-email') || '').trim();
      var taskTitle = button.getAttribute('data-followup-task') || '';
      if (!email) {
        window.alert('No email on file for ' + name + '. Unable to start a follow-up.');
        return;
      }
      var proceed = window.confirm('Follow up with ' + name + ' (' + email + ')?\n\nClick OK to open your email client.');
      if (!proceed) {
        return;
      }
      var subject = 'StudyPal follow-up' + (taskTitle ? ': ' + taskTitle : '');
      var body = 'Hi ' + name + ',\n\nI noticed your progress on "' + taskTitle + '" is falling behind. '
        + 'Let me know if you need any help catching up.\n\nBest regards';
      window.location.href = 'mailto:' + encodeURIComponent(email)
        + '?subject=' + encodeURIComponent(subject)
        + '&body=' + encodeURIComponent(body);
    });
  });
})();
</script>
</body>
</html>
