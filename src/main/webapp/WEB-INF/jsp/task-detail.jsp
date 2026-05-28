<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
      <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="sidebar-link">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 4h10M3 8h10M3 12h6"/><circle cx="13" cy="12" r="1.5"/></svg>
        My Tasks
      </a>
      <a href="${pageContext.request.contextPath}/task-detail?role=STUDENT&id=1" class="sidebar-link active">
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

  <div class="student-main ml-[240px] flex-1 flex flex-col">
    <header class="sticky top-0 z-30 bg-cream/90 backdrop-blur border-b border-border px-8 py-5">
      <div class="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 class="text-xl font-bold text-textDark">Task Detail</h1>
          <p class="text-sm text-textMuted mt-0.5">Review one MainTask, its SubTask plan, and your own SubTask progress.</p>
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
              <p class="text-xs text-textMuted font-pixel mb-2" style="font-size:8px;">MAINTASK · DATABASE SYSTEMS</p>
              <h2 class="text-2xl font-bold text-textDark">Database Design Project</h2>
              <p class="text-sm text-textMuted mt-2 max-w-[720px]">Complete the project milestones and submit the required materials before the deadline.</p>
            </div>
            <span class="text-xs bg-accent/15 text-accent px-3 py-1 rounded-full font-semibold">VERY_HIGH</span>
          </div>
        </section>

        <div class="detail-stats grid grid-cols-4 gap-5 mb-8 fade-in-d1">
          <div class="warm-card p-5 detail-card">
            <p class="text-xs text-textMuted mb-1">Course</p>
            <p class="text-2xl font-bold text-primary">DB2026</p>
            <p class="text-xs text-textMuted mt-1">Database Systems</p>
          </div>
          <div class="warm-card p-5 detail-card">
            <p class="text-xs text-textMuted mb-1">Deadline</p>
            <p class="text-2xl font-bold text-accent">06-01</p>
            <p class="text-xs text-textMuted mt-1">2026 23:59</p>
          </div>
          <div class="warm-card p-5 detail-card">
            <p class="text-xs text-textMuted mb-1">My Progress</p>
            <p class="text-2xl font-bold text-primary">68%</p>
            <p class="text-xs text-textMuted mt-1">SubTask</p>
          </div>
          <div class="warm-card p-5 detail-card">
            <p class="text-xs text-textMuted mb-1">Planned Time</p>
            <p class="text-2xl font-bold text-accent">3.5h</p>
            <p class="text-xs text-textMuted mt-1">SubTask Plan</p>
          </div>
        </div>

        <div class="detail-grid grid grid-cols-3 gap-6">
          <section class="detail-primary col-span-2 space-y-6">
            <div class="warm-card p-6 fade-in-d2">
              <div class="flex items-center justify-between gap-3 mb-4">
                <h2 class="text-base font-bold text-textDark">SubTask Plan</h2>
                <span class="text-xs text-textMuted">Generated by lecturer MainTask</span>
              </div>
              <div class="space-y-3">
                <div class="p-4 rounded-xl bg-cream border border-border/60">
                  <div class="flex items-start justify-between gap-3">
                    <div>
                      <p class="text-sm font-semibold text-textDark">01 · Confirm requirements and ER diagram</p>
                      <p class="text-xs text-textMuted mt-1">Check entities, foreign keys, role enum, and task ownership.</p>
                    </div>
                    <span class="text-xs text-primary font-semibold">2.0h</span>
                  </div>
                </div>
                <div class="p-4 rounded-xl bg-cream border border-border/60">
                  <div class="flex items-start justify-between gap-3">
                    <div>
                      <p class="text-sm font-semibold text-textDark">02 · Build interface screens</p>
                      <p class="text-xs text-textMuted mt-1">Build student-facing screens and keep the navigation consistent.</p>
                    </div>
                    <span class="text-xs text-accent font-semibold">3.5h</span>
                  </div>
                </div>
                <div class="p-4 rounded-xl bg-cream border border-border/60">
                  <div class="flex items-start justify-between gap-3">
                    <div>
                      <p class="text-sm font-semibold text-textDark">03 · Complete JSP integration</p>
                      <p class="text-xs text-textMuted mt-1">Prepare the task screens and user feedback messages.</p>
                    </div>
                    <span class="text-xs text-primary font-semibold">4.0h</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="warm-card p-6 fade-in-d3">
              <div class="flex items-center justify-between gap-3 mb-4">
                <h2 class="text-base font-bold text-textDark">My SubTask</h2>
                <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="action-btn action-btn-secondary text-xs px-3 py-2">Update Progress</a>
              </div>
              <div class="space-y-4">
                <div>
                  <div class="flex items-center justify-between mb-1">
                    <span class="text-sm font-semibold text-textDark">Confirm requirements and ER diagram</span>
                    <span class="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full font-medium">COMPLETED</span>
                  </div>
                  <div class="h-2 bg-border/60 rounded-full overflow-hidden"><div class="h-full bg-primary rounded-full progress-bar" style="--target-width: 100%;"></div></div>
                  <p class="text-xs text-textMuted mt-2">ER diagram confirmed. MainTask creator and role fields are aligned.</p>
                </div>
                <div>
                  <div class="flex items-center justify-between mb-1">
                    <span class="text-sm font-semibold text-textDark">Build interface screens</span>
                    <span class="text-xs bg-accent/15 text-accent px-2 py-0.5 rounded-full font-medium">IN_PROGRESS</span>
                  </div>
                  <div class="h-2 bg-border/60 rounded-full overflow-hidden"><div class="h-full bg-accent rounded-full progress-bar" style="--target-width: 70%;"></div></div>
                  <p class="text-xs text-textMuted mt-2">Student home, courses, tasks, and detail pages are being unified.</p>
                </div>
              </div>
            </div>
          </section>

          <aside class="space-y-6">
            <section class="warm-card p-5 fade-in-d2">
              <h3 class="text-sm font-bold text-textDark mb-4">Task Status</h3>
              <div class="space-y-3 text-sm">
                <div class="flex justify-between"><span class="text-textMuted">MainTask</span><span class="text-textDark font-medium">Published</span></div>
                <div class="flex justify-between"><span class="text-textMuted">Owner</span><span class="text-textDark font-medium">Dr. Emily Carter</span></div>
                <div class="flex justify-between"><span class="text-textMuted">SubTasks</span><span class="text-textDark font-medium">4</span></div>
                <div class="flex justify-between"><span class="text-textMuted">My Notes</span><span class="text-primary font-medium">Updated</span></div>
              </div>
            </section>

            <section class="warm-card p-5 fade-in-d3">
              <h3 class="text-sm font-bold text-textDark mb-4">SubTask Plan</h3>
              <div class="rounded-xl bg-cream border border-border/60 p-4">
                <p class="text-xs text-accent font-semibold">May 27 · 19:00 - 21:00</p>
                <p class="text-sm text-textDark font-semibold mt-1">ER diagram review</p>
                <p class="text-xs text-textMuted mt-1">Planned 19:00 - 21:00 · completed at May 27 21:00.</p>
              </div>
              <a href="${pageContext.request.contextPath}/sub-tasks?role=STUDENT" class="action-btn action-btn-primary w-full mt-4">Update Progress</a>
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
