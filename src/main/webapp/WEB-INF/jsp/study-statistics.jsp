<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.studypal.service.TaskService" %>
<%@ page import="com.studypal.service.CourseService" %>
<%@ page import="com.studypal.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null) { response.sendRedirect(request.getContextPath() + "/auth.jsp"); return; }
    UserAccount cu = (UserAccount) session.getAttribute("user");
    TaskService ts = new TaskService(); CourseService cs = new CourseService();
    int pending = 0, completed = 0; double rate = 0; List<StudentSubTask> upcoming = null;
    List<Course> enrolledC = null;
    try {
        pending = ts.getPendingTaskCount(cu.getUserId());
        rate = ts.getCompletionRate(cu.getUserId());
        List<StudentSubTask> comp = ts.getTasksByStudentId(cu.getUserId(), null, null, "COMPLETED");
        completed = comp != null ? comp.size() : 0;
        upcoming = ts.getUpcomingDeadlines(cu.getUserId(), 3);
        enrolledC = cs.getEnrolledCourses(cu.getUserId());
    } catch (Exception ignored) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Study Statistics</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;700;900&family=Press+Start+2P&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<script>tailwind.config={theme:{extend:{colors:{cream:'#F4EBDD',card:'#FFF9EF',textDark:'#2E241B',textMuted:'#766A5D',primary:'#3F5F46',accent:'#B76E45',border:'#E2D2BD'},fontFamily:{pixel:['"Press Start 2P"','monospace'],sans:['"Inter"','"Noto Sans SC"','sans-serif']}}}}</script>
<style>
@keyframes float-mascot{0%,100%{transform:translateY(0)}50%{transform:translateY(-6px)}}
@keyframes fade-in-up{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
@keyframes progress-fill{from{width:0%}to{width:var(--target-width)}}
.float-mascot{animation:float-mascot 3s ease-in-out infinite}
.fade-in{animation:fade-in-up 0.6s ease-out both}
.fade-in-d1{animation:fade-in-up 0.6s ease-out .1s both}
.fade-in-d2{animation:fade-in-up 0.6s ease-out .2s both}
.fade-in-d3{animation:fade-in-up 0.6s ease-out .3s both}
.fade-in-d4{animation:fade-in-up 0.6s ease-out .4s both}
.progress-bar{animation:progress-fill 1s ease-out 0.5s both}
.warm-card{background:#FFF9EF;border:1px solid #E2D2BD;border-radius:12px;box-shadow:0 2px 8px rgba(46,36,27,.06)}
body{background-color:#F4EBDD;min-height:100vh;overflow-x:hidden}
.sidebar-link{display:flex;align-items:center;gap:10px;padding:10px 16px;border-radius:8px;font-size:14px;color:#766A5D;transition:all .2s}
.sidebar-link:hover{background:#F4EBDD;color:#2E241B}
.sidebar-link.active{background:#3F5F46;color:#fff}
.action-btn{display:inline-flex;align-items:center;justify-content:center;gap:6px;padding:10px 20px;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;transition:all .2s}
.action-btn-primary{background:#3F5F46;color:#fff}
.action-btn-primary:hover{background:#345040;transform:translateY(-1px)}
.action-btn-secondary{background:transparent;color:#3F5F46;border:1px solid #E2D2BD}
.action-btn-secondary:hover{border-color:#3F5F46;background:#F4EBDD}
</style>
</head>
<body class="font-sans text-textDark">
<div class="student-shell flex min-h-screen">
<aside class="student-sidebar fixed top-0 left-0 w-[240px] h-screen bg-card border-r border-border flex flex-col z-40">
<div class="p-5 border-b border-border">
<div class="flex items-center gap-2">
<span class="font-pixel text-[10px] text-primary">StudyPal</span>
<span class="font-pixel text-[10px] text-accent">Campus</span>
</div>
<div class="mt-3 float-mascot"><svg width="28" height="28" viewBox="0 0 14 14" style="image-rendering:pixelated"><rect x="5" y="0" width="4" height="2" fill="#3F5F46"/><rect x="4" y="2" width="6" height="4" fill="#FFF9EF"/><rect x="5" y="3" width="1" height="1" fill="#2E241B"/><rect x="8" y="3" width="1" height="1" fill="#2E241B"/><rect x="6" y="5" width="2" height="1" fill="#B76E45"/><rect x="3" y="6" width="8" height="5" fill="#3F5F46"/><rect x="5" y="11" width="2" height="2" fill="#766A5D"/><rect x="7" y="11" width="2" height="2" fill="#766A5D"/></svg></div>
</div>
<nav class="student-nav flex-1 p-4 space-y-1">
<a href="${pageContext.request.contextPath}/student-home.jsp?role=STUDENT" class="sidebar-link"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="12" height="12" rx="2"/><path d="M2 6h12"/></svg>Dashboard</a>
<a href="${pageContext.request.contextPath}/student-courses.jsp?role=STUDENT" class="sidebar-link"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>My Courses</a>
<a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="sidebar-link"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>My Tasks</a>
<a href="${pageContext.request.contextPath}/task-detail.jsp?role=STUDENT&id=1" class="sidebar-link"><svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>Task Detail</a>
</nav>
</aside>
<div class="student-main ml-[240px] flex-1">
<header class="sticky top-0 z-30 bg-cream/90 backdrop-blur border-b border-border px-8 py-4"><div class="flex items-center justify-between"><div><h1 class="text-xl font-bold text-textDark">Study Statistics</h1><p class="text-sm text-textMuted mt-0.5">Track study sessions and learning progress.</p></div><div class="flex items-center gap-4"><span class="text-xs text-textMuted border border-border rounded-full px-3 py-1">Active Student</span><span class="text-xs text-primary font-semibold border border-primary/30 rounded-full px-3 py-1">Spring 2026</span></div></div></header>
<main class="p-8"><div class="max-w-[1160px] mx-auto">
<div class="study-stats grid grid-cols-4 gap-4 mb-8 fade-in">
<div class="warm-card p-5"><p class="text-xs text-textMuted mb-1">This Week</p><p class="text-2xl font-bold text-primary"><%= pending %></p><p class="text-xs text-textMuted mt-1">Pending tasks</p></div>
<div class="warm-card p-5"><p class="text-xs text-textMuted mb-1">Completed</p><p class="text-2xl font-bold text-accent"><%= completed %></p><p class="text-xs text-textMuted mt-1">Finished sub-tasks</p></div>
<div class="warm-card p-5"><p class="text-xs text-textMuted mb-1">Completion Rate</p><p class="text-2xl font-bold text-primary"><%= (int)rate %>%</p><p class="text-xs text-textMuted mt-1">Overall progress</p></div>
<div class="warm-card p-5"><p class="text-xs text-textMuted mb-1">Courses</p><p class="text-2xl font-bold text-accent"><%= enrolledC != null ? enrolledC.size() : 0 %></p><p class="text-xs text-textMuted mt-1">Enrolled</p></div>
</div>
<div class="detail-grid grid grid-cols-3 gap-6">
<section class="col-span-2 space-y-6">
<div class="warm-card p-6 fade-in-d1"><div class="flex items-center justify-between mb-4"><h2 class="text-base font-bold text-textDark">Upcoming Deadlines</h2></div>
<div class="space-y-3">
<% if (upcoming != null && !upcoming.isEmpty()) {
     for (StudentSubTask sst : upcoming) { %>
       <div class="flex items-start justify-between gap-3 p-3 rounded-xl bg-cream/60 border border-border/60"><div><p class="text-sm font-semibold text-textDark"><%= sst.getMainTaskTitle() %></p><p class="text-xs text-textMuted mt-0.5"><%= sst.getDeadline() != null ? sst.getDeadline().toString().substring(0,16) : "N/A" %></p></div><span class="text-xs <%= "COMPLETED".equals(sst.getStatus()) ? "bg-primary/10 text-primary" : "bg-accent/15 text-accent" %> px-2 py-0.5 rounded-full font-medium"><%= sst.getStatus() %></span></div>
<%   }
   } else { %><p class="text-xs text-textMuted py-4">No upcoming deadlines.</p><% } %>
</div>
</div>
<div class="warm-card p-6 fade-in-d2"><h2 class="text-base font-bold text-textDark mb-4">Course Progress</h2>
<div class="space-y-4">
<% if (enrolledC != null && !enrolledC.isEmpty()) {
     for (Course c : enrolledC) { %>
       <div><div class="flex items-center justify-between mb-1"><span class="text-xs text-textMuted"><%= c.getCourseName() %></span><span class="text-xs font-semibold text-primary"><%= c.getCourseCode() %></span></div><div class="w-full h-2 bg-border/60 rounded-full overflow-hidden"><div class="h-full bg-primary rounded-full" style="width:60%"></div></div></div>
<%   }
   } else { %><p class="text-xs text-textMuted py-4">No courses enrolled.</p><% } %>
</div>
</div>
</section>
<aside class="space-y-6">
<div class="warm-card p-5 fade-in-d2"><h3 class="text-sm font-bold text-textDark mb-4">Task Summary</h3>
<div class="space-y-4">
<div><div class="flex items-center justify-between mb-1"><span class="text-xs text-textMuted">Pending</span><span class="text-xs font-semibold text-primary"><%= pending %></span></div><div class="w-full h-2 bg-border/60 rounded-full overflow-hidden"><div class="h-full bg-primary rounded-full" style="width:<%= pending + completed > 0 ? (pending * 100 / (pending + completed)) : 0 %>%"></div></div></div>
<div><div class="flex items-center justify-between mb-1"><span class="text-xs text-textMuted">Completed</span><span class="text-xs font-semibold text-accent"><%= completed %></span></div><div class="w-full h-2 bg-border/60 rounded-full overflow-hidden"><div class="h-full bg-accent rounded-full" style="width:<%= pending + completed > 0 ? (completed * 100 / (pending + completed)) : 0 %>%"></div></div></div>
</div>
</div>
<div class="warm-card p-5 fade-in-d3"><h3 class="text-sm font-bold text-textDark mb-4">Earliest Deadline</h3>
<% if (upcoming != null && !upcoming.isEmpty()) { StudentSubTask next = upcoming.get(0); %>
<div class="rounded-xl bg-cream border border-border/60 p-4"><p class="text-xs text-accent font-semibold"><%= next.getDeadline() != null ? next.getDeadline().toString().substring(0,16) : "N/A" %></p><p class="text-sm text-textDark font-semibold mt-1"><%= next.getMainTaskTitle() %></p><p class="text-xs text-textMuted mt-1"><%= next.getTemplateTitle() %></p></div>
<% } else { %><p class="text-xs text-textMuted py-4">No deadlines.</p><% } %>
<a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="action-btn action-btn-secondary w-full mt-4">Back to My Tasks</a>
</div>
</aside>
</div>
</div></main>
</div></div>
</body>
</html>
