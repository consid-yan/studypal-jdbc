<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal My Courses</title>
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

.filter-chip {
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid #E2D2BD;
  color: #766A5D;
  background: transparent;
}
.filter-chip:hover {
  border-color: #3F5F46;
  color: #3F5F46;
}
.filter-chip.active {
  background: #3F5F46;
  color: #fff;
  border-color: #3F5F46;
}

.course-card {
  transition: transform 0.2s, box-shadow 0.2s;
}
.course-card:hover {
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
  .course-stats,
  .course-grid {
    grid-template-columns: 1fr;
  }
  .course-toolbar,
  .course-join-row {
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
      <!-- Pixel mascot -->
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
      <a href="${pageContext.request.contextPath}/student-courses.jsp?role=STUDENT" class="sidebar-link active">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 3h12v10H2z"/><path d="M5 1v4"/></svg>
        My Courses
      </a>
      <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>
        My Tasks
      </a>
      <a href="${pageContext.request.contextPath}/study-sessions?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="8" cy="8" r="6"/><path d="M8 4v4l3 2"/></svg>
        Study Sessions
      </a>
      <a href="${pageContext.request.contextPath}/task-detail?role=STUDENT&id=1" class="sidebar-link">
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
          <h1 class="text-xl font-bold text-textDark">My Courses</h1>
          <p class="text-sm text-textMuted mt-0.5">Manage enrolled courses, join new classes, and track course progress in one place.</p>
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
        <div class="course-stats grid grid-cols-4 gap-5 mb-8 fade-in">
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Enrolled Courses</p>
            <p class="text-2xl font-bold text-primary">4</p>
            <p class="text-xs text-textMuted mt-1">Active learning spaces</p>
          </div>
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Active Tasks</p>
            <p class="text-2xl font-bold text-accent">12</p>
            <p class="text-xs text-textMuted mt-1">Across all courses</p>
          </div>
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Average Progress</p>
            <p class="text-2xl font-bold text-primary">76%</p>
            <p class="text-xs text-textMuted mt-1">Overall completion</p>
          </div>
          <div class="warm-card p-5 stat-card">
            <p class="text-xs text-textMuted mb-1">Study Hours</p>
            <p class="text-2xl font-bold text-accent">38.5h</p>
            <p class="text-xs text-textMuted mt-1">Recorded this month</p>
          </div>
        </div>

        <!-- Join Course Panel -->
        <div class="warm-card p-6 mb-6 fade-in-d1">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <h2 class="text-base font-bold text-textDark mb-1">Join a Course</h2>
              <p class="text-sm text-textMuted mb-4">Enter a course code provided by your lecturer to join a new class.</p>
              <div class="course-join-row flex items-center gap-3">
                <input type="text" placeholder="e.g. COMP2009J" class="px-4 py-2.5 rounded-lg border border-border bg-cream/40 text-sm text-textDark placeholder:text-textMuted/60 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 w-[240px]">
                <button class="action-btn action-btn-primary" data-confirm="Confirm joining this course? StudentSubTask records will be generated after enrollment.">Join Course</button>
                <button class="action-btn action-btn-secondary">Cancel</button>
              </div>
              <p class="text-xs text-textMuted mt-3">Your role is detected automatically after login. No manual role selection is required.</p>
            </div>
            <!-- Pixel book icon -->
            <div class="float-char ml-4">
              <svg width="36" height="36" viewBox="0 0 18 18" style="image-rendering: pixelated;">
                <rect x="3" y="2" width="12" height="14" fill="#3F5F46"/>
                <rect x="4" y="3" width="10" height="12" fill="#FFF9EF"/>
                <rect x="5" y="5" width="8" height="1" fill="#E2D2BD"/>
                <rect x="5" y="7" width="6" height="1" fill="#E2D2BD"/>
                <rect x="5" y="9" width="7" height="1" fill="#E2D2BD"/>
                <rect x="5" y="11" width="5" height="1" fill="#E2D2BD"/>
                <rect x="3" y="2" width="1" height="14" fill="#B76E45"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- Search and Filter -->
        <div class="course-toolbar flex items-center justify-between mb-6 fade-in-d2">
          <div class="flex items-center gap-3">
            <div class="relative">
              <svg width="16" height="16" fill="none" stroke="#766A5D" stroke-width="2" class="absolute left-3 top-1/2 -translate-y-1/2"><circle cx="7" cy="7" r="5"/><path d="M11 11l3 3"/></svg>
              <input type="text" placeholder="Search courses" class="pl-9 pr-4 py-2 rounded-lg border border-border bg-card text-sm text-textDark placeholder:text-textMuted/60 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 w-[220px]">
            </div>
            <div class="flex items-center gap-2">
              <span class="filter-chip active">All</span>
              <span class="filter-chip">In Progress</span>
              <span class="filter-chip">Completed</span>
              <span class="filter-chip">Archived</span>
            </div>
          </div>
          <select class="px-3 py-2 rounded-lg border border-border bg-card text-sm text-textMuted focus:outline-none focus:border-primary">
            <option>Recently Updated</option>
            <option>Progress</option>
            <option>Course Name</option>
          </select>
        </div>

        <!-- Course Cards -->
        <div class="course-grid grid grid-cols-2 gap-5 mb-6">

          <!-- Database Systems -->
          <div class="warm-card p-5 course-card fade-in-d2">
            <div class="flex items-start justify-between mb-3">
              <div>
                <h3 class="text-sm font-bold text-textDark">Database Systems</h3>
                <p class="text-xs text-textMuted mt-0.5 font-pixel" style="font-size:8px;">COMP2026J</p>
              </div>
              <span class="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full font-medium">In Progress</span>
            </div>
            <div class="space-y-2 mb-4">
              <div class="flex justify-between text-xs"><span class="text-textMuted">Lecturer</span><span class="text-textDark">Dr. Emily Carter</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Active Tasks</span><span class="text-textDark">4</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Next Deadline</span><span class="text-accent font-medium">June 12, 2026</span></div>
            </div>
            <div class="mb-4">
              <div class="flex items-center justify-between mb-1">
                <span class="text-xs text-textMuted">Progress</span>
                <span class="text-xs font-semibold text-primary">82%</span>
              </div>
              <div class="w-full h-2 bg-border/60 rounded-full overflow-hidden">
                <div class="h-full bg-primary rounded-full progress-bar" style="--target-width: 82%;"></div>
              </div>
            </div>
            <div class="flex gap-2">
              <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="action-btn action-btn-primary text-xs px-3 py-2">View Tasks</a>
              <a href="${pageContext.request.contextPath}/task-detail?role=STUDENT&id=1" class="action-btn action-btn-secondary text-xs px-3 py-2">Course Detail</a>
            </div>
          </div>

          <!-- Computer Networks -->
          <div class="warm-card p-5 course-card fade-in-d2">
            <div class="flex items-start justify-between mb-3">
              <div>
                <h3 class="text-sm font-bold text-textDark">Computer Networks</h3>
                <p class="text-xs text-textMuted mt-0.5 font-pixel" style="font-size:8px;">COMP2009J</p>
              </div>
              <span class="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full font-medium">In Progress</span>
            </div>
            <div class="space-y-2 mb-4">
              <div class="flex justify-between text-xs"><span class="text-textMuted">Lecturer</span><span class="text-textDark">Prof. Daniel Hughes</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Active Tasks</span><span class="text-textDark">3</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Next Deadline</span><span class="text-accent font-medium">June 18, 2026</span></div>
            </div>
            <div class="mb-4">
              <div class="flex items-center justify-between mb-1">
                <span class="text-xs text-textMuted">Progress</span>
                <span class="text-xs font-semibold text-accent">64%</span>
              </div>
              <div class="w-full h-2 bg-border/60 rounded-full overflow-hidden">
                <div class="h-full bg-accent rounded-full progress-bar" style="--target-width: 64%;"></div>
              </div>
            </div>
            <div class="flex gap-2">
              <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="action-btn action-btn-primary text-xs px-3 py-2">View Tasks</a>
              <a href="${pageContext.request.contextPath}/task-detail?role=STUDENT&id=1" class="action-btn action-btn-secondary text-xs px-3 py-2">Course Detail</a>
            </div>
          </div>

          <!-- Discrete Mathematics -->
          <div class="warm-card p-5 course-card fade-in-d3">
            <div class="flex items-start justify-between mb-3">
              <div>
                <h3 class="text-sm font-bold text-textDark">Discrete Mathematics</h3>
                <p class="text-xs text-textMuted mt-0.5 font-pixel" style="font-size:8px;">MATH1015</p>
              </div>
              <span class="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full font-medium">In Progress</span>
            </div>
            <div class="space-y-2 mb-4">
              <div class="flex justify-between text-xs"><span class="text-textMuted">Lecturer</span><span class="text-textDark">Dr. Sarah Bennett</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Active Tasks</span><span class="text-textDark">2</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Next Deadline</span><span class="text-accent font-medium">June 20, 2026</span></div>
            </div>
            <div class="mb-4">
              <div class="flex items-center justify-between mb-1">
                <span class="text-xs text-textMuted">Progress</span>
                <span class="text-xs font-semibold text-primary">71%</span>
              </div>
              <div class="w-full h-2 bg-border/60 rounded-full overflow-hidden">
                <div class="h-full bg-primary rounded-full progress-bar" style="--target-width: 71%;"></div>
              </div>
            </div>
            <div class="flex gap-2">
              <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="action-btn action-btn-primary text-xs px-3 py-2">View Tasks</a>
              <a href="${pageContext.request.contextPath}/task-detail?role=STUDENT&id=1" class="action-btn action-btn-secondary text-xs px-3 py-2">Course Detail</a>
            </div>
          </div>

          <!-- Academic English -->
          <div class="warm-card p-5 course-card fade-in-d3">
            <div class="flex items-start justify-between mb-3">
              <div>
                <h3 class="text-sm font-bold text-textDark">Academic English</h3>
                <p class="text-xs text-textMuted mt-0.5 font-pixel" style="font-size:8px;">ENG1008</p>
              </div>
              <span class="text-xs bg-border text-textMuted px-2 py-0.5 rounded-full font-medium">Completed</span>
            </div>
            <div class="space-y-2 mb-4">
              <div class="flex justify-between text-xs"><span class="text-textMuted">Lecturer</span><span class="text-textDark">Ms. Laura Wilson</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Active Tasks</span><span class="text-textDark">0</span></div>
              <div class="flex justify-between text-xs"><span class="text-textMuted">Next Deadline</span><span class="text-textMuted">No pending deadline</span></div>
            </div>
            <div class="mb-4">
              <div class="flex items-center justify-between mb-1">
                <span class="text-xs text-textMuted">Progress</span>
                <span class="text-xs font-semibold text-primary">100%</span>
              </div>
              <div class="w-full h-2 bg-border/60 rounded-full overflow-hidden">
                <div class="h-full bg-primary rounded-full progress-bar" style="--target-width: 100%;"></div>
              </div>
            </div>
            <div class="flex gap-2">
              <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="action-btn action-btn-primary text-xs px-3 py-2">View Tasks</a>
              <a href="${pageContext.request.contextPath}/task-detail?role=STUDENT&id=1" class="action-btn action-btn-secondary text-xs px-3 py-2">Course Detail</a>
            </div>
          </div>

        </div>

        <!-- Empty State -->
        <div class="warm-card p-6 fade-in-d4 opacity-60 border-dashed">
          <div class="flex items-center gap-4">
            <svg width="32" height="32" viewBox="0 0 16 16" style="image-rendering: pixelated;" class="flex-shrink-0">
              <rect x="3" y="3" width="10" height="10" fill="#E2D2BD"/>
              <rect x="7" y="5" width="2" height="4" fill="#766A5D"/>
              <rect x="7" y="10" width="2" height="2" fill="#766A5D"/>
            </svg>
            <div>
              <p class="text-sm font-semibold text-textDark">No courses found</p>
              <p class="text-xs text-textMuted mt-0.5">Try a different keyword or join a course with a valid course code.</p>
            </div>
            <button class="action-btn action-btn-secondary text-xs px-3 py-2 ml-auto">Clear Search</button>
          </div>
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
