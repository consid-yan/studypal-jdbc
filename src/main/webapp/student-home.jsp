<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.TaskService" %>
<%@ page import="com.studypal.service.CourseService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/auth.jsp");
        return;
    }
    UserAccount currentUser = (UserAccount) session.getAttribute("user");
    Long studentId = currentUser.getUserId();
    String studentFullName = currentUser.getFullName();
    CourseService courseService = new CourseService();
    TaskService taskService = new TaskService();

    int enrolledCount = 0, pendingTaskCount = 0;
    double completionRate = 0.0;
    List<StudentSubTask> upcomingDeadlines = null;
    List<Course> enrolledCourses = null;
    try {
        enrolledCount = courseService.getEnrolledCourseCount(studentId);
        pendingTaskCount = taskService.getPendingTaskCount(studentId);
        completionRate = taskService.getCompletionRate(studentId);
        upcomingDeadlines = taskService.getUpcomingDeadlines(studentId, 3);
        enrolledCourses = courseService.getEnrolledCourses(studentId);
    } catch (Exception ignored) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Student Home</title>
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
@keyframes float-char {
  0%, 100% { transform: translate(0, 0); }
  25% { transform: translate(4px, -6px); }
  50% { transform: translate(-3px, -4px); }
  75% { transform: translate(5px, 3px); }
}
@keyframes blink-eyes {
  0%, 90%, 100% { opacity: 1; }
  95% { opacity: 0; }
}
@keyframes dash-flow {
  0% { stroke-dashoffset: 20; }
  100% { stroke-dashoffset: 0; }
}
@keyframes fade-in-up {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes float-label {
  0%, 100% { transform: translateY(0) translateX(0); opacity: 0.4; }
  33% { transform: translateY(-5px) translateX(2px); opacity: 0.6; }
  66% { transform: translateY(2px) translateX(-2px); opacity: 0.5; }
}
@keyframes progress-fill {
  from { width: 0%; }
  to { width: var(--target-width); }
}
@keyframes bar-grow {
  from { height: 0%; }
  to { height: var(--target-height); }
}

.float-char { animation: float-char 6s ease-in-out infinite; }
.float-mascot { animation: float-mascot 3s ease-in-out infinite; }
.blink-eyes { animation: blink-eyes 3s ease-in-out infinite; }
.float-label { animation: float-label 4s ease-in-out infinite; }
.fade-in { animation: fade-in-up 0.6s ease-out both; }
.fade-in-d1 { animation: fade-in-up 0.6s ease-out 0.1s both; }
.fade-in-d2 { animation: fade-in-up 0.6s ease-out 0.2s both; }
.fade-in-d3 { animation: fade-in-up 0.6s ease-out 0.3s both; }
.fade-in-d4 { animation: fade-in-up 0.6s ease-out 0.4s both; }

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

.progress-bar {
  animation: progress-fill 1s ease-out 0.5s both;
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

.stat-card {
  transition: transform 0.2s, box-shadow 0.2s;
}
.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(46, 36, 27, 0.1);
}

.action-btn {
  display: inline-flex;
  align-items: center;
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

@media (max-width: 960px) {
  .student-sidebar {
    position: static;
    width: 100%;
    height: auto;
  }
  .student-main {
    margin-left: 0;
  }
  .student-shell {
    flex-direction: column;
  }
  .student-nav {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
  .student-stats,
  .student-content {
    grid-template-columns: 1fr;
  }
  .student-primary {
    grid-column: span 1 / span 1;
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
      <a href="${pageContext.request.contextPath}/student-home.jsp?role=STUDENT" class="sidebar-link active">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>
        Dashboard
      </a>
      <a href="${pageContext.request.contextPath}/student-courses.jsp?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>
        My Courses
      </a>
      <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>
        My Tasks
      </a>
      <a href="${pageContext.request.contextPath}/study-sessions?role=STUDENT" class="sidebar-link">
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
          <h1 class="text-xl font-bold text-textDark">Student Home</h1>
          <p class="text-sm text-textMuted mt-0.5">Welcome back, <%= studentFullName %>. Your learning progress is organized and ready for today.</p>
        </div>
        <div class="flex items-center gap-4">
          <span class="text-xs text-textMuted border border-border rounded-full px-3 py-1">Active Student</span>
          <span class="text-xs text-primary font-semibold border border-primary/30 rounded-full px-3 py-1">Spring 2026</span>
        </div>
      </div>
    </header>

    <!-- Dashboard Content -->
    <main class="flex-1 p-8">
      <div class="max-w-[1160px] mx-auto">

        <!-- Statistics -->
        <div class="student-stats grid grid-cols-4 gap-5 mb-8 fade-in">
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Active Courses</p>
            <p class="text-2xl font-bold text-primary"><%= enrolledCount %></p>
            <p class="text-xs text-textMuted mt-1">Courses currently joined</p>
          </div>
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Pending Tasks</p>
            <p class="text-2xl font-bold text-accent"><%= pendingTaskCount %></p>
            <p class="text-xs text-textMuted mt-1">Tasks still waiting for action</p>
          </div>
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Completion Rate</p>
            <p class="text-2xl font-bold text-primary"><%= (int)completionRate %>%</p>
            <p class="text-xs text-textMuted mt-1">Overall task completion</p>
          </div>
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Study Time</p>
            <p class="text-2xl font-bold text-accent"><%= enrolledCount %></p>
            <p class="text-xs text-textMuted mt-1">Courses enrolled</p>
          </div>
        </div>

        <div class="student-content grid grid-cols-3 gap-6">

          <!-- Left Column: Tasks + Course Progress -->
          <div class="student-primary col-span-2 space-y-6">

            <!-- Today's Focus -->
            <div class="warm-card p-6 fade-in-d1">
              <h2 class="text-base font-bold text-textDark mb-4">Today's Focus</h2>
              <div class="space-y-3">
                <% if (upcomingDeadlines != null && !upcomingDeadlines.isEmpty()) {
                     for (StudentSubTask sst : upcomingDeadlines) {
                       String dl = sst.getDeadline() != null ? sst.getDeadline().toString().substring(0, 10) : "";
                       String sstLabel = "IN_PROGRESS".equals(sst.getStatus()) ? "In Progress" : ("NOT_STARTED".equals(sst.getStatus()) ? "Not Started" : sst.getStatus());
                       String sstStyle = "IN_PROGRESS".equals(sst.getStatus()) ? "bg-accent/15 text-accent" : "bg-border text-textMuted";
                %>
                   <div class="flex items-center justify-between gap-4 p-3 rounded-lg bg-cream/60 border border-border/60">
                     <div><p class="text-sm font-semibold text-textDark"><%= sst.getMainTaskTitle() %></p><p class="text-xs text-textMuted mt-0.5"><%= sst.getCourseName() != null ? sst.getCourseName() : "" %></p></div>
                     <div class="flex items-center gap-3"><span class="text-xs text-textMuted"><%= dl %></span><span class="text-xs <%= sstStyle %> px-2 py-0.5 rounded-full font-medium"><%= sstLabel %></span></div>
                   </div>
                <%   }
                   } else { %><p class="text-xs text-textMuted text-center py-4">No pending tasks.</p><% } %>
              </div>
              <div class="flex gap-3 mt-5 flex-wrap">
                <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="action-btn action-btn-primary">View My Tasks</a>
                <a href="${pageContext.request.contextPath}/study-sessions?role=STUDENT" class="action-btn action-btn-secondary">Record Study Session</a>
              </div>
            </div>

            <!-- Course Progress -->
            <div class="warm-card p-6 fade-in-d2">
              <h2 class="text-base font-bold text-textDark mb-4">Course Progress</h2>
              <div class="space-y-5">
                <% if (enrolledCourses != null && !enrolledCourses.isEmpty()) {
                     for (Course c : enrolledCourses) { %>
                       <div>
                         <div class="flex items-center justify-between mb-1.5"><p class="text-sm font-semibold text-textDark"><%= c.getCourseName() %></p><span class="text-xs font-semibold text-primary"><%= c.getCourseCode() %></span></div>
                         <div class="w-full h-2 bg-border/60 rounded-full overflow-hidden"><div class="h-full bg-primary rounded-full progress-bar" style="--target-width: 60%;"></div></div>
                         <p class="text-xs text-textMuted mt-1.5"><%= c.getSemester() %></p>
                       </div>
                <%   }
                   } else { %><p class="text-xs text-textMuted text-center py-4">No courses enrolled.</p><% } %>
              </div>
            </div>

            <!-- Task Progress Overview -->
            <div class="warm-card p-6 fade-in-d3">
              <h2 class="text-base font-bold text-textDark mb-4">Task Progress Overview</h2>
              <div class="flex items-end justify-between gap-3 h-[150px]">
                <% int completedCnt = pendingTaskCount; int totalCnt = pendingTaskCount + (int)(completionRate * pendingTaskCount / 100);
                   int notStarted = pendingTaskCount; int inProgress = 0; int completed = 0;
                   try {
                       notStarted = taskService.getTasksByStudentId(studentId, null, null, "NOT_STARTED").size();
                       inProgress = taskService.getTasksByStudentId(studentId, null, null, "IN_PROGRESS").size();
                       completed = taskService.getTasksByStudentId(studentId, null, null, "COMPLETED").size();
                       totalCnt = notStarted + inProgress + completed;
                   } catch (Exception ex) {}
                   int maxH = 86;
                   int nsH = totalCnt > 0 ? maxH * notStarted / Math.max(totalCnt, 1) : 0;
                   int ipH = totalCnt > 0 ? maxH * inProgress / Math.max(totalCnt, 1) : 0;
                   int cmH = totalCnt > 0 ? maxH * completed / Math.max(totalCnt, 1) : 0;
                %>
                <div class="flex flex-col items-center flex-1"><div class="w-full rounded-t overflow-hidden flex items-end" style="height: 86px; background: rgba(183, 110, 69, 0.16);"><div class="w-full rounded-t" style="height: <%= nsH %>px; background: #B76E45;"></div></div><span class="text-xs text-textMuted mt-2">待开始</span><span class="text-xs text-textDark font-medium"><%= notStarted %></span></div>
                <div class="flex flex-col items-center flex-1"><div class="w-full rounded-t overflow-hidden flex items-end" style="height: 86px; background: rgba(63, 95, 70, 0.16);"><div class="w-full rounded-t" style="height: <%= ipH %>px; background: #3F5F46;"></div></div><span class="text-xs text-textMuted mt-2">进行中</span><span class="text-xs text-textDark font-medium"><%= inProgress %></span></div>
                <div class="flex flex-col items-center flex-1"><div class="w-full rounded-t overflow-hidden flex items-end" style="height: 86px; background: rgba(63, 95, 70, 0.16);"><div class="w-full rounded-t" style="height: <%= cmH %>px; background: #3F5F46;"></div></div><span class="text-xs text-textMuted mt-2">已完成</span><span class="text-xs text-textDark font-medium"><%= completed %></span></div>
              </div>
            </div>
          </div>

          <!-- Right Column: Deadlines + Quick Actions + Profile -->
          <div class="space-y-6">

            <!-- Profile Summary -->
            <div class="warm-card p-5 fade-in-d1">
              <h3 class="text-sm font-bold text-textDark mb-3">Profile Summary</h3>
              <div class="space-y-2 text-sm">
                <div class="flex justify-between"><span class="text-textMuted">Name</span><span class="text-textDark font-medium"><%= studentFullName %></span></div>
                <div class="flex justify-between"><span class="text-textMuted">Role</span><span class="text-textDark font-medium">Student</span></div>
                <div class="flex justify-between"><span class="text-textMuted">Student ID</span><span class="text-textDark font-medium"><%= session.getAttribute("roleDetail") instanceof com.studypal.model.Student ? ((com.studypal.model.Student)session.getAttribute("roleDetail")).getStudentNo() : "N/A" %></span></div>
                <div class="flex justify-between"><span class="text-textMuted">Joined Courses</span><span class="text-textDark font-medium"><%= enrolledCount %></span></div>
                <div class="flex justify-between"><span class="text-textMuted">Status</span><span class="text-primary font-medium">Verified</span></div>
              </div>
              <div class="mt-4 pt-3 border-t border-border">
                <p class="text-xs text-textMuted mb-2">Learning Flow</p>
                <svg width="100%" height="20" class="opacity-60">
                  <text x="0" y="13" class="font-pixel" font-size="6" fill="#3F5F46">Course</text>
                  <line x1="38" y1="10" x2="50" y2="10" stroke="#3F5F46" stroke-width="1" stroke-dasharray="3 2" style="animation: dash-flow 2s linear infinite;"/>
                  <text x="54" y="13" class="font-pixel" font-size="6" fill="#B76E45">Task</text>
                  <line x1="78" y1="10" x2="90" y2="10" stroke="#B76E45" stroke-width="1" stroke-dasharray="3 2" style="animation: dash-flow 2s linear infinite; animation-delay:0.3s;"/>
                  <text x="94" y="13" class="font-pixel" font-size="6" fill="#3F5F46">Session</text>
                  <line x1="136" y1="10" x2="148" y2="10" stroke="#3F5F46" stroke-width="1" stroke-dasharray="3 2" style="animation: dash-flow 2s linear infinite; animation-delay:0.6s;"/>
                  <text x="152" y="13" class="font-pixel" font-size="6" fill="#B76E45">Dash</text>
                </svg>
              </div>
            </div>

            <!-- Upcoming Deadlines -->
            <div class="warm-card p-5 fade-in-d2">
              <h3 class="text-sm font-bold text-textDark mb-3">Upcoming Deadlines</h3>
              <div class="space-y-3">
                <% if (upcomingDeadlines != null && !upcomingDeadlines.isEmpty()) {
                     for (StudentSubTask sst : upcomingDeadlines) {
                       String dl = sst.getDeadline() != null ? sst.getDeadline().toString().substring(0, 10) : "N/A"; %>
                       <div class="flex items-start gap-3"><span class="w-2 h-2 rounded-full bg-accent mt-1.5 flex-shrink-0"></span><div><p class="text-xs font-semibold text-accent"><%= dl %></p><p class="text-sm text-textDark"><%= sst.getMainTaskTitle() %></p></div></div>
                <%   }
                   } else { %><p class="text-xs text-textMuted text-center py-2">No upcoming deadlines.</p><% } %>
                </div>
              </div>
            </div>

            <!-- Quick Actions -->
            <div class="warm-card p-5 fade-in-d3">
              <h3 class="text-sm font-bold text-textDark mb-3">Quick Actions</h3>
              <div class="space-y-3">
                <a href="${pageContext.request.contextPath}/student-courses.jsp?role=STUDENT" class="block p-3 rounded-lg border border-border/60 hover:border-primary hover:bg-cream/40 transition-all">
                  <p class="text-sm font-semibold text-primary">Join a Course</p>
                  <p class="text-xs text-textMuted mt-0.5">Add a course using a course code from your lecturer.</p>
                </a>
                <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="block p-3 rounded-lg border border-border/60 hover:border-primary hover:bg-cream/40 transition-all">
                  <p class="text-sm font-semibold text-primary">View My Tasks</p>
                  <p class="text-xs text-textMuted mt-0.5">Check task status, subtasks, notes, and planned time.</p>
                </a>
                <a href="${pageContext.request.contextPath}/study-sessions?role=STUDENT" class="block p-3 rounded-lg border border-border/60 hover:border-accent hover:bg-cream/40 transition-all">
                  <p class="text-sm font-semibold text-accent">Record Study Session</p>
                  <p class="text-xs text-textMuted mt-0.5">Save study time and connect it to a course or task.</p>
                </a>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-8 text-center">
        </div>
      </div>
    </main>
  </div>
</div>

</body>
</html>
