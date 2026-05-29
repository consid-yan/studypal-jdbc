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
    if (!"STUDENT".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/states.jsp?state=no-permission");
        return;
    }
    Long studentId = currentUser.getUserId();
    String taskIdStr = request.getParameter("id");
    Long taskId = null;
    try { taskId = Long.parseLong(taskIdStr); } catch (Exception ignored) {}

    TaskService taskService = new TaskService();
    String error = null;
    MainTask mainTask = null;
    List<SubTaskTemplate> templates = null;
    List<StudentSubTask> mySubTasks = null;
    double myProgress = 0.0;
    int templateCount = 0;

    if (taskId != null) {
        try {
            String genResult = taskService.ensureStudentSubTasksExist(studentId, taskId);
            if (genResult != null) error = genResult;
            mainTask = taskService.getMainTaskById(taskId);
            templates = taskService.getTemplatesByMainTaskId(taskId);
            mySubTasks = taskService.getStudentSubTasksByMainTask(studentId, taskId);
            if (mySubTasks != null && !mySubTasks.isEmpty()) {
                int completed = 0;
                for (StudentSubTask sst : mySubTasks) {
                    if ("COMPLETED".equals(sst.getStatus())) completed++;
                }
                myProgress = (completed * 100.0) / mySubTasks.size();
            }
            templateCount = (templates != null) ? templates.size() : 0;
        } catch (Exception e) {
            error = "Failed to load task: " + e.getMessage();
        }
    }
    String impLabel = "";
    if (mainTask != null && mainTask.getImportanceLevel() != null) {
        switch (mainTask.getImportanceLevel()) {
            case 1: impLabel = "LOW"; break; case 2: impLabel = "MEDIUM"; break;
            case 3: impLabel = "HIGH"; break; case 4: impLabel = "VERY_HIGH"; break;
            case 5: impLabel = "CRITICAL"; break; default: impLabel = "MEDIUM";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Task Detail</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;700;900&family=Press+Start+2P&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<script>
tailwind.config = {
  theme: {
    extend: {
      colors: {
        cream: '#F4EBDD',
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
@keyframes float-mascot { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-6px); } }
@keyframes fade-in-up { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }
@keyframes progress-fill { from { width: 0%; } to { width: var(--target-width); } }
.float-mascot { animation: float-mascot 3s ease-in-out infinite; }
.fade-in { animation: fade-in-up 0.6s ease-out both; }
.fade-in-d1 { animation: fade-in-up 0.6s ease-out 0.1s both; }
.fade-in-d2 { animation: fade-in-up 0.6s ease-out 0.2s both; }
.fade-in-d3 { animation: fade-in-up 0.6s ease-out 0.3s both; }
.fade-in-d4 { animation: fade-in-up 0.6s ease-out 0.4s both; }
.progress-bar { animation: progress-fill 1s ease-out 0.2s both; }
.warm-card {
  background: #FFF9EF;
  border: 1px solid #E2D2BD;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(46, 36, 27, 0.06);
}
.paper-texture {
  background-image: url("data:image/svg+xml,%3Csvg width='40' height='40' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='40' height='40' filter='url(%23n)' opacity='0.015'/%3E%3C/svg%3E");
}
body { background-color: #F4EBDD; min-height: 100vh; overflow-x: hidden; }
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
.sidebar-link:hover { background: #F4EBDD; color: #2E241B; }
.sidebar-link.active { background: #3F5F46; color: #fff; }
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
.action-btn-primary { background: #3F5F46; color: #fff; }
.action-btn-primary:hover { background: #345040; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(63, 95, 70, 0.25); }
.action-btn-secondary { background: transparent; color: #3F5F46; border: 1px solid #E2D2BD; }
.action-btn-secondary:hover { border-color: #3F5F46; background: #F4EBDD; }
.detail-card { transition: transform 0.2s, box-shadow 0.2s; }
.detail-card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(46, 36, 27, 0.1); }
@media (max-width: 960px) {
  .student-shell { flex-direction: column; }
  .student-sidebar { position: static; width: 100%; height: auto; }
  .student-main { margin-left: 0; }
  .student-nav { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .detail-stats,
  .detail-grid { grid-template-columns: 1fr; }
  .detail-primary { grid-column: span 1 / span 1; }
}
</style>
</head>
<body class="font-sans text-textDark paper-texture">

<div class="student-shell flex min-h-screen">
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
      <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>
        My Tasks
      </a>
      <a href="${pageContext.request.contextPath}/study-statistics.jsp?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="8" r="6"/><path d="M8 4v4l3 2"/></svg>
        Study Sessions
      </a>
      <% if (taskId != null) { %>
        <a href="${pageContext.request.contextPath}/task-detail.jsp?role=STUDENT&id=<%= taskId %>" class="sidebar-link active">
          <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>
          Task Detail
        </a>
      <% } else { %>
        <span class="sidebar-link opacity-60 cursor-not-allowed" title="请从具体任务进入详情">
          <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 2h8v12H4z"/><path d="M6 5h4M6 8h4M6 11h2"/></svg>
          Task Detail
        </span>
      <% } %>
    </nav>

    <div class="p-4 border-t border-border">
      <a href="${pageContext.request.contextPath}/auth.jsp" class="sidebar-link text-accent hover:text-accent/80">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 14H3a1 1 0 01-1-1V3a1 1 0 011-1h3M10 11l4-3-4-3M14 8H7"/></svg>
        Log out
      </a>
    </div>
  </aside>

  <div class="student-main ml-[240px] flex-1 flex flex-col">
    <header class="sticky top-0 z-30 bg-cream/90 backdrop-blur border-b border-border px-8 py-5">
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 class="text-xl font-bold text-textDark">Task Detail</h1>
          <p class="text-sm text-textMuted mt-0.5">Review one MainTask, its SubTaskTemplate plan, and your own StudentSubTask progress.</p>
        </div>
        <div class="flex items-center gap-4">
          <span class="text-xs text-textMuted border border-border rounded-full px-3 py-1">Active Student</span>
          <span class="text-xs text-primary font-semibold border border-primary/30 rounded-full px-3 py-1">Spring 2026</span>
        </div>
      </div>
    </header>

    <main class="flex-1 p-8">
      <div class="max-w-[1160px] mx-auto">
        <section class="warm-card p-6 mb-6 fade-in">
          <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
              <p class="text-xs text-textMuted font-pixel mb-2" style="font-size:8px;">MAINTASK · <%= mainTask != null && mainTask.getCourseName() != null ? mainTask.getCourseName() : "Personal Task" %></p>
              <h2 class="text-2xl font-bold text-textDark"><%= mainTask != null ? mainTask.getTitle() : "N/A" %></h2>
              <p class="text-sm text-textMuted mt-2 max-w-[720px]"><%= mainTask != null && mainTask.getDescription() != null ? mainTask.getDescription() : "" %></p>
            </div>
            <span class="text-xs bg-accent/15 text-accent px-3 py-1 rounded-full font-semibold"><%= impLabel %></span>
          </div>
          <% if (error != null) { %>
            <div class="mt-4 p-3 rounded-lg text-sm font-semibold bg-red-50 text-red-700 border border-red-200"><%= error %></div>
          <% } %>
        </section>

        <div class="detail-stats grid grid-cols-3 gap-5 mb-8 fade-in-d1">
          <div class="warm-card p-5 detail-card">
            <p class="text-xs text-textMuted mb-1">Course</p>
            <p class="text-2xl font-bold text-primary"><%= mainTask != null && mainTask.getCourseCode() != null ? mainTask.getCourseCode() : "N/A" %></p>
            <p class="text-xs text-textMuted mt-1"><%= mainTask != null && mainTask.getCourseName() != null ? mainTask.getCourseName() : "N/A" %></p>
          </div>
          <div class="warm-card p-5 detail-card">
            <p class="text-xs text-textMuted mb-1">Deadline</p>
            <p class="text-2xl font-bold text-accent"><%= mainTask != null && mainTask.getDeadline() != null ? mainTask.getDeadline().toString().substring(0, 16) : "N/A" %></p>
            <p class="text-xs text-textMuted mt-1">yyyy-MM-dd HH:mm</p>
          </div>
          <div class="warm-card p-5 detail-card">
            <p class="text-xs text-textMuted mb-1">My Progress</p>
            <p class="text-2xl font-bold text-primary"><%= (int)myProgress %>%</p>
            <p class="text-xs text-textMuted mt-1">SubTask completion</p>
          </div>
        </div>

        <div class="detail-grid grid grid-cols-3 gap-6">
          <section class="detail-primary col-span-2 space-y-6">
            <div class="warm-card p-6 fade-in-d2">
              <div class="flex items-center justify-between gap-3 mb-4">
                <h2 class="text-base font-bold text-textDark">SubTaskTemplate Plan</h2>
                <span class="text-xs text-textMuted">Generated by lecturer MainTask</span>
              </div>
              <div class="space-y-3">
                <% if (templates != null && !templates.isEmpty()) {
                     int seq = 1;
                     for (SubTaskTemplate t : templates) { %>
                       <div class="p-4 rounded-xl bg-cream border border-border/60">
                         <div class="flex items-start justify-between gap-3">
                           <div>
                             <p class="text-sm font-semibold text-textDark"><%= String.format("%02d", seq) %> · <%= t.getTitle() %></p>
                             <p class="text-xs text-textMuted mt-1"><%= t.getDescription() != null ? t.getDescription() : "" %></p>
                           </div>
                           <span class="text-xs text-primary font-semibold"><%= t.getEstimatedHours() != null ? t.getEstimatedHours() + "h" : "" %></span>
                         </div>
                       </div>
                <%     seq++;
                     }
                   } else { %>
                     <p class="text-xs text-textMuted text-center py-4">No templates defined for this task.</p>
                <% } %>
              </div>
            </div>

            <div class="warm-card p-6 fade-in-d3">
              <div class="flex items-center justify-between gap-3 mb-4">
                <h2 class="text-base font-bold text-textDark">My StudentSubTask</h2>
                <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT" class="action-btn action-btn-secondary text-xs px-3 py-2">Update Progress</a>
              </div>
              <div class="space-y-4">
                <% if (mySubTasks != null && !mySubTasks.isEmpty()) {
                     for (StudentSubTask sst : mySubTasks) {
                       String sstStatus = sst.getStatus();
                       String sstStatusClass = "COMPLETED".equals(sstStatus) ? "bg-primary/10 text-primary" : ("IN_PROGRESS".equals(sstStatus) ? "bg-accent/15 text-accent" : "bg-border text-textMuted");
                       int barPct = "COMPLETED".equals(sstStatus) ? 100 : ("IN_PROGRESS".equals(sstStatus) ? 70 : 0);
                       String barColor = "COMPLETED".equals(sstStatus) ? "bg-primary" : "bg-accent";
                %>
                   <div>
                     <div class="flex items-center justify-between mb-1">
                       <span class="text-sm font-semibold text-textDark"><%= sst.getTemplateTitle() %></span>
                       <span class="text-xs <%= sstStatusClass %> px-2 py-0.5 rounded-full font-medium"><%= sstStatus %></span>
                     </div>
                     <div class="h-2 bg-border/60 rounded-full overflow-hidden"><div class="h-full <%= barColor %> rounded-full progress-bar" style="--target-width: <%= barPct %>%;"></div></div>
                     <p class="text-xs text-textMuted mt-2"><%= sst.getNotes() != null ? sst.getNotes() : "" %></p>
                   </div>
                <%   }
                   } else { %>
                     <p class="text-xs text-textMuted text-center py-4">No sub-tasks generated yet.</p>
                <% } %>
              </div>
            </div>
          </section>

          <aside class="space-y-6">
            <section class="warm-card p-5 fade-in-d2">
              <h3 class="text-sm font-bold text-textDark mb-4">Task Status</h3>
              <div class="space-y-3 text-sm">
                <div class="flex justify-between"><span class="text-textMuted">MainTask</span><span class="text-textDark font-medium"><%= mainTask != null ? mainTask.getRoleEnum() : "N/A" %></span></div>
                <div class="flex justify-between"><span class="text-textMuted">Owner</span><span class="text-textDark font-medium"><%= mainTask != null && mainTask.getCreatorName() != null ? mainTask.getCreatorName() : "N/A" %></span></div>
                <div class="flex justify-between"><span class="text-textMuted">Templates</span><span class="text-textDark font-medium"><%= templateCount %></span></div>
                <div class="flex justify-between"><span class="text-textMuted">My SubTasks</span><span class="text-primary font-medium"><%= mySubTasks != null ? mySubTasks.size() : 0 %></span></div>
              </div>
            </section>
          </aside>
        </div>

        <div class="mt-8 text-center fade-in-d4">
        </div>
      </div>
    </main>
  </div>
</div>
</body>
</html>
