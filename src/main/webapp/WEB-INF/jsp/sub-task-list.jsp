<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.TaskService" %>
<%@ page import="com.studypal.service.CourseService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Timestamp" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/auth.jsp");
        return;
    }
    UserAccount currentUser = (UserAccount) session.getAttribute("user");
    if (!"STUDENT".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission");
        return;
    }
    Long studentId = currentUser.getUserId();
    TaskService taskService = new TaskService();
    CourseService courseService = new CourseService();
    String error = null;
    String success = null;

    String keyword = request.getParameter("keyword");
    String courseFilter = request.getParameter("course");
    String statusFilter = request.getParameter("status");
    Long courseIdFilter = null;
    if (courseFilter != null && !courseFilter.isEmpty() && !"All Courses".equals(courseFilter)) {
        try { courseIdFilter = Long.parseLong(courseFilter); } catch (Exception ignored) {}
    }
    if (statusFilter != null && ("All Status".equals(statusFilter) || statusFilter.isEmpty())) {
        statusFilter = null;
    } else if ("Not Started".equals(statusFilter)) {
        statusFilter = "NOT_STARTED";
    } else if ("In Progress".equals(statusFilter)) {
        statusFilter = "IN_PROGRESS";
    } else if ("Completed".equals(statusFilter)) {
        statusFilter = "COMPLETED";
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("updateSubTask".equals(action)) {
            String sstIdStr = request.getParameter("studentSubTaskId");
            String newStatus = request.getParameter("newStatus");
            String notes = request.getParameter("notes");
            try {
                Long sstId = Long.parseLong(sstIdStr);
                Timestamp completedTime = null;
                if ("COMPLETED".equals(newStatus)) {
                    completedTime = new Timestamp(System.currentTimeMillis());
                }
                String result = taskService.updateStudentSubTaskStatus(studentId, sstId, newStatus, notes, completedTime);
                if (result == null) {
                    response.sendRedirect(request.getContextPath() + "/sub-tasks.jsp?role=STUDENT");
                    return;
                } else {
                    error = result;
                }
            } catch (Exception e) {
                error = "Failed to update: " + e.getMessage();
            }
        }
    }

    List<StudentSubTask> allTasks = null;
    List<Course> enrolledCourses = null;
    int totalCount = 0, inProgressCount = 0, completedCount = 0, dueThisWeek = 0;
    try {
        enrolledCourses = courseService.getEnrolledCourses(studentId);
        allTasks = taskService.getTasksByStudentId(studentId, keyword, courseIdFilter, statusFilter);
        if (allTasks != null) {
            totalCount = allTasks.size();
            long now = System.currentTimeMillis();
            long weekLater = now + 7L * 24 * 60 * 60 * 1000;
            for (StudentSubTask sst : allTasks) {
                if ("IN_PROGRESS".equals(sst.getStatus())) inProgressCount++;
                else if ("COMPLETED".equals(sst.getStatus())) completedCount++;
                if (!"COMPLETED".equals(sst.getStatus()) && sst.getDeadline() != null) {
                    long dl = sst.getDeadline().getTime();
                    if (dl >= now && dl <= weekLater) dueThisWeek++;
                }
            }
        }
    } catch (Exception e) {
        error = (error != null) ? error : "Failed to load: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Student Tasks</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;700;900&family=Press+Start+2P&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<script>
tailwind.config = {
  theme: {
    extend: {
      colors: {
        cream: '#F4EBDD',
        creamLight: '#F7F0E4',
        card: '#FFF9EF',
        textDark: '#2E241B',
        textMuted: '#766A5D',
        primary: '#3F5F46',
        accent: '#B76E45',
        border: '#E2D2BD',
      },
      fontFamily: {
        pixel: ['"Press Start 2P"', 'monospace'],
        sans: ['"Inter"', '"Noto Sans SC"', 'sans-serif'],
      }
    }
  }
}
</script>
<style>
@keyframes float-mascot {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-6px); }
}
@keyframes fade-in-up {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes progress-fill {
  from { width: 0%; }
  to { width: var(--target-width); }
}

.float-mascot { animation: float-mascot 3s ease-in-out infinite; }
.fade-in { animation: fade-in-up 0.6s ease-out both; }
.fade-in-d1 { animation: fade-in-up 0.6s ease-out 0.1s both; }
.fade-in-d2 { animation: fade-in-up 0.6s ease-out 0.2s both; }
.fade-in-d3 { animation: fade-in-up 0.6s ease-out 0.3s both; }
.fade-in-d4 { animation: fade-in-up 0.6s ease-out 0.4s both; }
.progress-bar-inner { animation: progress-fill 0.9s ease-out 0.2s both; }

.warm-card {
  background: #FFF9EF;
  border: 1px solid #E2D2BD;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(46, 36, 27, 0.06);
}

.paper-texture {
  background-image: url("data:image/svg+xml,%3Csvg width='40' height='40' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='40' height='40' filter='url(%23n)' opacity='0.015'/%3E%3C/svg%3E");
}

body {
  background-color: #F4EBDD;
  min-height: 100vh;
  overflow-x: hidden;
}

.sidebar-link {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  border-radius: 8px;
  font-size: 14px;
  color: #766A5D;
  transition: all 0.2s;
}
.sidebar-link:hover {
  background: #F4EBDD;
  color: #2E241B;
}
.sidebar-link.active {
  background: #3F5F46;
  color: #fff;
}

.action-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.action-btn-primary {
  background: #3F5F46;
  color: #fff;
}
.action-btn-primary:hover {
  background: #345040;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(63, 95, 70, 0.25);
}
.action-btn-secondary {
  background: transparent;
  color: #3F5F46;
  border: 1px solid #E2D2BD;
}
.action-btn-secondary:hover {
  border-color: #3F5F46;
  background: #F4EBDD;
}

.task-card {
  transition: transform 0.2s, box-shadow 0.2s;
}
.task-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(46, 36, 27, 0.1);
}

@media (max-width: 960px) {
  .student-shell {
    flex-direction: column;
  }
  .student-sidebar {
    position: static;
    width: 100%;
    height: auto;
  }
  .student-main {
    margin-left: 0;
  }
  .student-nav {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
  .task-stats,
  .task-grid {
    grid-template-columns: 1fr;
  }
  .task-list-column {
    grid-column: span 1 / span 1;
  }
  .task-toolbar {
    align-items: stretch;
    flex-direction: column;
  }
}
</style>
</head>
<body class="font-sans text-textDark paper-texture">

<div class="student-shell flex min-h-screen">

  <!-- Sidebar -->
  <aside class="student-sidebar fixed top-0 left-0 w-[240px] h-screen bg-card border-r border-border flex flex-col z-40">
    <div class="p-5 border-b border-border">
      <div class="flex items-center gap-2">
        <span class="font-pixel text-[10px] text-primary">StudyPal</span>
        <span class="font-pixel text-[10px] text-accent">Campus</span>
      </div>
      <div class="mt-3 float-mascot">
        <svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering: pixelated;">
          <rect x="5" y="0" width="4" height="2" fill="#3F5F46"/>
          <rect x="4" y="2" width="6" height="4" fill="#FFF9EF"/>
          <rect x="5" y="3" width="1" height="1" fill="#2E241B"/>
          <rect x="8" y="3" width="1" height="1" fill="#2E241B"/>
          <rect x="6" y="5" width="2" height="1" fill="#B76E45"/>
          <rect x="3" y="6" width="8" height="5" fill="#3F5F46"/>
          <rect x="5" y="11" width="2" height="2" fill="#766A5D"/>
          <rect x="7" y="11" width="2" height="2" fill="#766A5D"/>
        </svg>
      </div>
    </div>

    <nav class="student-nav flex-1 p-4 space-y-1">
      <a href="${pageContext.request.contextPath}/student-home.jsp?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>
        Dashboard
      </a>
      <a href="${pageContext.request.contextPath}/student-courses.jsp?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>
        My Courses
      </a>
      <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="sidebar-link active">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>
        My Tasks
      </a>
      <a href="${pageContext.request.contextPath}/study-statistics.jsp?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="8" r="6"/><path d="M8 4v4l3 2"/></svg>
        Study Sessions
      </a>
      <a href="${pageContext.request.contextPath}/task-detail.jsp?role=STUDENT&id=1" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>
        Task Detail
      </a>
    </nav>

    <div class="p-4 border-t border-border">
      <a href="${pageContext.request.contextPath}/auth.jsp" class="sidebar-link text-accent hover:text-accent/80">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>
        Log out
      </a>
    </div>
  </aside>

  <!-- Main Content -->
  <div class="student-main ml-[240px] flex-1 flex flex-col">

    <!-- Header -->
    <header class="sticky top-0 z-30 bg-cream/90 backdrop-blur border-b border-border px-8 py-5">
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 class="text-xl font-bold text-textDark">My Tasks</h1>
          <p class="text-sm text-textMuted mt-0.5">Track your MainTasks, StudentSubTasks, deadlines, notes, and study progress.</p>
        </div>
        <div class="flex items-center gap-4">
          <span class="text-xs text-textMuted border border-border rounded-full px-3 py-1">Active Student</span>
          <span class="text-xs text-primary font-semibold border border-primary/30 rounded-full px-3 py-1">Spring 2026</span>
        </div>
      </div>
    </header>

    <!-- Content -->
    <main class="p-8">
      <div class="max-w-[1160px] mx-auto">

        <!-- Status Summary Cards -->
        <div class="task-stats grid grid-cols-4 gap-4 mb-6 fade-in">
          <div class="warm-card task-card p-5">
            <span class="text-xs text-textMuted font-medium uppercase tracking-wide">Total Tasks</span>
            <p class="text-2xl font-bold text-primary mt-1"><%= totalCount %></p>
          </div>
          <div class="warm-card task-card p-5">
            <span class="text-xs text-textMuted font-medium uppercase tracking-wide">In Progress</span>
            <p class="text-2xl font-bold text-primary mt-1"><%= inProgressCount %></p>
          </div>
          <div class="warm-card task-card p-5">
            <span class="text-xs text-textMuted font-medium uppercase tracking-wide">Due This Week</span>
            <p class="text-2xl font-bold text-accent mt-1"><%= dueThisWeek %></p>
          </div>
          <div class="warm-card task-card p-5">
            <span class="text-xs text-textMuted font-medium uppercase tracking-wide">Completed</span>
            <p class="text-2xl font-bold text-primary mt-1"><%= completedCount %></p>
          </div>
        </div>

        <!-- Filters -->
        <div class="warm-card p-5 mb-6 fade-in-d1">
          <h3 class="text-sm font-semibold text-textDark mb-3">Task Controls</h3>
          <form action="${pageContext.request.contextPath}/sub-tasks.jsp" method="GET" class="task-toolbar flex items-center gap-3 flex-wrap">
            <input type="hidden" name="role" value="STUDENT">
            <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>" placeholder="Search by task, course, or lecturer" class="flex-1 min-w-[220px] px-3 py-2 text-sm bg-cream border border-border rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 placeholder:text-textMuted/60 transition-all">
            <select name="course" class="px-3 py-2 text-sm bg-cream border border-border rounded-lg focus:outline-none focus:border-primary text-textDark cursor-pointer">
              <option value="">All Courses</option>
              <% if (enrolledCourses != null) {
                   for (Course c : enrolledCourses) {
                     String sel = (courseIdFilter != null && courseIdFilter.equals(c.getCourseId())) ? "selected" : "";
              %>
                     <option value="<%= c.getCourseId() %>" <%= sel %>><%= c.getCourseName() %></option>
              <%   }
                 } %>
            </select>
            <select name="status" class="px-3 py-2 text-sm bg-cream border border-border rounded-lg focus:outline-none focus:border-primary text-textDark cursor-pointer">
              <option value="">All Status</option>
              <option value="Not Started" <%= "NOT_STARTED".equals(statusFilter) ? "selected" : "" %>>Not Started</option>
              <option value="In Progress" <%= "IN_PROGRESS".equals(statusFilter) ? "selected" : "" %>>In Progress</option>
              <option value="Completed" <%= "COMPLETED".equals(statusFilter) ? "selected" : "" %>>Completed</option>
            </select>
            <button type="submit" class="action-btn action-btn-primary text-sm">Apply Filters</button>
            <button type="reset" class="action-btn action-btn-secondary text-sm">Reset</button>
          </form>
        </div>

        <!-- Task Area -->
        <div class="task-grid grid grid-cols-3 gap-6 fade-in-d2">

          <!-- Task List -->
          <section class="task-list-column col-span-2 warm-card p-5">
            <div class="flex items-center justify-between gap-3 mb-4">
              <h2 class="text-sm font-semibold text-textDark">Current StudentSubTasks</h2>
              <span class="text-xs text-textMuted">Generated from SubTaskTemplate</span>
            </div>

            <% if (error != null) { %><div class="mb-3 p-3 rounded-lg text-sm bg-red-50 text-red-700 border border-red-200"><%= error %></div><% } %>
            <% if (success != null) { %><div class="mb-3 p-3 rounded-lg text-sm bg-green-50 text-green-700 border border-green-200"><%= success %></div><% } %>
            <div class="flex flex-col gap-3">
              <% if (allTasks != null && !allTasks.isEmpty()) {
                   for (StudentSubTask sst : allTasks) {
                     String sstStatus = sst.getStatus();
                     String statusClass = "COMPLETED".equals(sstStatus) ? "bg-primary/10 text-primary" : ("IN_PROGRESS".equals(sstStatus) ? "bg-accent/15 text-accent" : "border border-border bg-card text-textMuted");
                     String deadlineText = sst.getDeadline() != null ? sst.getDeadline().toString().substring(0, 16) : "No deadline";
                     int pct = sst.getProgressPercentage();
                     String barColor = "COMPLETED".equals(sstStatus) ? "bg-primary" : "bg-accent";
              %>
                     <article class="bg-cream rounded-xl border border-border/60 p-4 hover:shadow-sm transition-all">
                       <div class="flex items-start justify-between gap-4 mb-2">
                         <div>
                           <span class="text-xs text-textMuted"><%= sst.getCourseName() != null ? sst.getCourseName() : "N/A" %></span>
                           <p class="text-sm font-semibold text-textDark mt-0.5"><%= sst.getMainTaskTitle() %></p>
                           <p class="text-xs text-textDark/80 mt-0.5"><%= sst.getTemplateTitle() %></p>
                         </div>
                         <div class="flex items-center gap-2 flex-shrink-0">
                           <span class="px-2 py-0.5 text-xs font-medium rounded-full <%= statusClass %>"><%= sstStatus %></span>
                           <span class="text-xs text-accent font-medium"><%= deadlineText %></span>
                         </div>
                       </div>
                       <div class="flex items-center gap-3 mb-2">
                         <div class="flex-1 h-2 bg-border/60 rounded-full overflow-hidden">
                           <div class="h-full <%= barColor %> rounded-full" style="width: <%= pct %>%;"></div>
                         </div>
                         <span class="text-xs font-semibold text-textDark"><%= pct %>%</span>
                       </div>
                       <p class="text-xs text-textMuted mb-3 leading-relaxed"><%= sst.getNotes() != null ? sst.getNotes() : "" %></p>
                       <div class="flex items-center justify-end gap-2">
                         <a href="${pageContext.request.contextPath}/task-detail.jsp?role=STUDENT&id=<%= sst.getMainTaskId() %>" class="px-3 py-1.5 text-xs text-white bg-primary rounded-lg hover:opacity-90 transition-all font-medium">View Detail</a>
                       </div>
                     </article>
              <%   }
                 } else { %>
                   <p class="text-xs text-textMuted text-center py-8">No sub-tasks found.</p>
              <% } %>
            </div>
          </section>

          <!-- Side Panel -->
          <aside class="space-y-6">
            <section class="warm-card p-5">
              <h2 class="text-sm font-semibold text-textDark mb-4">Update Progress</h2>
              <form method="post" action="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="space-y-3">
                <input type="hidden" name="action" value="updateSubTask">
                <div>
                  <label class="block text-xs font-medium text-textMuted mb-1">SubTask ID</label>
                  <input type="number" name="studentSubTaskId" class="w-full px-3 py-2 text-sm bg-cream border border-border rounded-lg focus:outline-none focus:border-primary" placeholder="Enter sub-task ID to update" required>
                </div>
                <div>
                  <label class="block text-xs font-medium text-textMuted mb-1">Status</label>
                  <select name="newStatus" class="w-full px-3 py-2 text-sm bg-cream border border-border rounded-lg focus:outline-none focus:border-primary">
                    <option value="NOT_STARTED">NOT_STARTED</option>
                    <option value="IN_PROGRESS" selected>IN_PROGRESS</option>
                    <option value="COMPLETED">COMPLETED</option>
                  </select>
                </div>
                <div>
                  <label class="block text-xs font-medium text-textMuted mb-1">Notes</label>
                  <textarea name="notes" rows="3" class="w-full px-3 py-2 text-sm bg-cream border border-border rounded-lg focus:outline-none focus:border-primary resize-none" placeholder="Update your notes..."></textarea>
                </div>
                <button type="submit" class="action-btn action-btn-primary w-full">Save Progress</button>
              </form>
            </section>
          </aside>
        </div>

        <!-- Footer Note -->
        <div class="mt-8 text-center fade-in-d4">
        </div>
      </div>
    </main>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
