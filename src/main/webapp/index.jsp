<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudyPal Campus Console</title>
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
        sans: ['"Noto Sans SC"', '"Inter"', 'sans-serif'],
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
@keyframes progress-bar {
  0% { width: 0%; }
  100% { width: 76%; }
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
@keyframes card-move {
  0%, 100% { transform: translateX(0) translateY(0); opacity: 0.7; }
  50% { transform: translateX(12px) translateY(-4px); opacity: 1; }
}

.float-char { animation: float-char 6s ease-in-out infinite; }
.blink-eyes { animation: blink-eyes 3s ease-in-out infinite; }
.float-label { animation: float-label 4s ease-in-out infinite; }
.card-move { animation: card-move 4s ease-in-out infinite; }
.fade-in { animation: fade-in-up 0.6s ease-out both; }

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
  height: 100vh;
  overflow: hidden;
}
</style>
</head>
<body class="font-sans text-textDark paper-texture">

<!-- Top Navigation -->
<nav class="fixed top-0 left-0 w-full h-14 flex items-center justify-between px-8 z-50 bg-cream/90 backdrop-blur border-b border-border">
  <div class="flex items-center gap-2">
    <span class="font-pixel text-[10px] text-primary">StudyPal</span>
    <span class="font-pixel text-[10px] text-accent">Campus</span>
  </div>
  <div class="hidden md:flex items-center gap-8 text-sm text-textMuted">
    <a href="#" class="hover:text-primary transition-colors">Features</a>
    <a href="#roles" class="hover:text-primary transition-colors">Roles</a>
    <a href="#" class="hover:text-primary transition-colors">Dashboard Preview</a>
  </div>
  <a href="${pageContext.request.contextPath}/auth.jsp" class="text-sm text-textMuted border border-border rounded-full px-4 py-1.5 hover:border-primary hover:text-primary transition-colors">登录 / 注册</a>
</nav>

<!-- Single-screen Hero -->
<main class="h-screen flex flex-col pt-14">
  <!-- Floating labels background -->
  <div class="absolute inset-0 overflow-hidden pointer-events-none">
    <span class="absolute top-[18%] left-[5%] font-pixel text-[9px] text-primary/20 float-label" style="animation-delay: 0s;">Course</span>
    <span class="absolute top-[25%] right-[8%] font-pixel text-[9px] text-accent/20 float-label" style="animation-delay: 0.8s;">MainTask</span>
    <span class="absolute bottom-[35%] left-[10%] font-pixel text-[9px] text-primary/15 float-label" style="animation-delay: 1.6s;">SubTask</span>
    <span class="absolute top-[55%] right-[5%] font-pixel text-[9px] text-accent/15 float-label" style="animation-delay: 2.4s;">StudySession</span>
    <span class="absolute bottom-[22%] right-[15%] font-pixel text-[9px] text-primary/20 float-label" style="animation-delay: 3.2s;">Dashboard</span>
  </div>

  <!-- Hero Content -->
  <div class="flex-1 flex items-center justify-center px-8 relative">
    <div class="w-full max-w-7xl grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">

      <!-- Left: Title + Value Prop + CTA -->
      <div class="flex flex-col items-start gap-5 z-10">
        <p class="font-pixel text-[8px] text-textMuted/70 tracking-widest">STUDENT INFORMATION MANAGEMENT SYSTEM</p>
        <h1 class="font-pixel text-xl md:text-3xl leading-relaxed text-primary">
          StudyPal Campus Console
        </h1>
        <p class="text-base md:text-lg text-textMuted leading-relaxed max-w-md">
          让<span class="text-primary font-semibold">学生</span>、<span class="text-accent font-semibold">教师</span>和<span class="text-textDark font-semibold">管理员</span>在同一个清晰的系统里完成课程、任务和学习进度管理。
        </p>
        <p class="text-sm text-textMuted/80 max-w-md">
          A calm and structured information system for courses, tasks, study sessions, and role-based dashboards.
        </p>

        <!-- CTA Button -->
        <a href="${pageContext.request.contextPath}/auth.jsp" class="inline-block px-10 py-4 rounded-full font-bold text-lg text-white bg-primary hover:bg-primary/90 hover:scale-105 transition-all duration-200 mt-2 shadow-lg shadow-primary/20" style="text-decoration: none;">
          进入系统 / Enter System
        </a>
        <a href="#roles" class="text-sm text-accent hover:text-accent/80 transition-colors underline underline-offset-4">了解角色 / View Roles</a>
      </div>

      <!-- Right: Dashboard Mockup with floating characters -->
      <div class="relative hidden lg:flex items-center justify-center">
        <!-- Floating pixel characters -->
        <div class="absolute -top-4 -left-4 float-char" style="animation-delay: 0s;">
          <svg width="36" height="36" viewBox="0 0 12 12" style="image-rendering: pixelated;">
            <rect x="4" y="0" width="4" height="2" fill="#B76E45"/>
            <rect x="3" y="2" width="6" height="4" fill="#B76E45"/>
            <rect x="5" y="3" width="1" height="1" fill="#2E241B" class="blink-eyes"/>
            <rect x="7" y="3" width="1" height="1" fill="#2E241B" class="blink-eyes"/>
            <rect x="2" y="6" width="8" height="3" fill="#B76E45" opacity="0.6"/>
            <rect x="4" y="9" width="1" height="2" fill="#B76E45"/>
            <rect x="7" y="9" width="1" height="2" fill="#B76E45"/>
          </svg>
          <span class="font-pixel text-[7px] text-accent/70 block text-center mt-1">Lecturer</span>
        </div>
        <div class="absolute -bottom-2 -left-8 float-char" style="animation-delay: 2s;">
          <svg width="36" height="36" viewBox="0 0 12 12" style="image-rendering: pixelated;">
            <rect x="4" y="0" width="4" height="2" fill="#3F5F46"/>
            <rect x="3" y="2" width="6" height="4" fill="#3F5F46"/>
            <rect x="5" y="3" width="1" height="1" fill="#F4EBDD" class="blink-eyes"/>
            <rect x="7" y="3" width="1" height="1" fill="#F4EBDD" class="blink-eyes"/>
            <rect x="2" y="6" width="8" height="3" fill="#3F5F46" opacity="0.6"/>
            <rect x="4" y="9" width="1" height="2" fill="#3F5F46"/>
            <rect x="7" y="9" width="1" height="2" fill="#3F5F46"/>
          </svg>
          <span class="font-pixel text-[7px] text-primary/70 block text-center mt-1">Student</span>
        </div>
        <div class="absolute top-2 -right-6 float-char" style="animation-delay: 4s;">
          <svg width="36" height="36" viewBox="0 0 12 12" style="image-rendering: pixelated;">
            <rect x="4" y="0" width="4" height="2" fill="#766A5D"/>
            <rect x="3" y="2" width="6" height="4" fill="#766A5D"/>
            <rect x="5" y="3" width="1" height="1" fill="#F4EBDD" class="blink-eyes"/>
            <rect x="7" y="3" width="1" height="1" fill="#F4EBDD" class="blink-eyes"/>
            <rect x="2" y="6" width="8" height="3" fill="#766A5D" opacity="0.5"/>
            <rect x="4" y="9" width="1" height="2" fill="#766A5D" opacity="0.7"/>
            <rect x="7" y="9" width="1" height="2" fill="#766A5D" opacity="0.7"/>
          </svg>
          <span class="font-pixel text-[7px] text-textMuted/60 block text-center mt-1">Admin</span>
        </div>

        <!-- Animated task card moving from Lecturer to Student -->
        <div class="absolute top-1/2 -left-2 card-move" style="animation-delay: 1s;">
          <div class="bg-accent/10 border border-accent/30 rounded px-2 py-1">
            <span class="font-pixel text-[6px] text-accent/80">Task</span>
          </div>
        </div>

        <!-- Dashboard mockup -->
        <div class="warm-card p-5 w-full max-w-sm relative">
          <!-- Animated connection line SVG -->
          <svg class="absolute -left-12 top-1/2 -translate-y-1/2 w-12 h-32 opacity-30" viewBox="0 0 48 128">
            <path d="M48 20 L24 40 L24 88 L48 108" fill="none" stroke="#3F5F46" stroke-width="1" stroke-dasharray="4 3" style="animation: dash-flow 2s linear infinite;"/>
          </svg>

          <!-- Mini role cards inside mockup -->
          <div class="space-y-3" id="roles">
            <div class="flex items-center gap-3 bg-primary/5 border border-primary/10 rounded-lg px-3 py-2">
              <span class="w-2 h-2 rounded-full bg-primary"></span>
              <span class="text-xs text-textDark/80">Student — Learning progress and task completion</span>
            </div>
            <div class="flex items-center gap-3 bg-accent/5 border border-accent/10 rounded-lg px-3 py-2">
              <span class="w-2 h-2 rounded-full bg-accent"></span>
              <span class="text-xs text-textDark/80">Lecturer — Course and Task Release</span>
            </div>
            <div class="flex items-center gap-3 bg-textMuted/5 border border-textMuted/10 rounded-lg px-3 py-2">
              <span class="w-2 h-2 rounded-full bg-textMuted"></span>
              <span class="text-xs text-textDark/80">Admin — System Overview and Data Status</span>
            </div>
          </div>

          <!-- Progress bar -->
          <div class="mt-4 pt-3 border-t border-border">
            <div class="flex items-center justify-between mb-1">
              <span class="text-[10px] text-textMuted">Completion Rate</span>
              <span class="font-pixel text-[8px] text-primary">76%</span>
            </div>
            <div class="w-full h-2 bg-primary/10 rounded-full overflow-hidden">
              <div class="h-full bg-primary rounded-full" style="width: 76%; animation: progress-bar 2s ease-out forwards;"></div>
            </div>
          </div>

          <!-- Workflow line inside mockup -->
          <div class="mt-3 pt-3 border-t border-border">
            <div class="flex items-center gap-1 overflow-hidden">
              <span class="font-pixel text-[6px] text-accent/70 whitespace-nowrap">MainTask</span>
              <svg width="12" height="6" class="opacity-40 flex-shrink-0"><line x1="0" y1="3" x2="12" y2="3" stroke="#B76E45" stroke-width="1" stroke-dasharray="2 1" style="animation: dash-flow 1s linear infinite;"/></svg>
              <span class="font-pixel text-[6px] text-primary/70 whitespace-nowrap">SubTask</span>
              <svg width="12" height="6" class="opacity-40 flex-shrink-0"><line x1="0" y1="3" x2="12" y2="3" stroke="#3F5F46" stroke-width="1" stroke-dasharray="2 1" style="animation: dash-flow 1s linear infinite; animation-delay:0.3s;"/></svg>
              <span class="font-pixel text-[6px] text-accent/70 whitespace-nowrap">Session</span>
              <svg width="12" height="6" class="opacity-40 flex-shrink-0"><line x1="0" y1="3" x2="12" y2="3" stroke="#B76E45" stroke-width="1" stroke-dasharray="2 1" style="animation: dash-flow 1s linear infinite; animation-delay:0.6s;"/></svg>
              <span class="font-pixel text-[6px] text-primary/70 whitespace-nowrap">Dashboard</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Bottom Stat Cards -->
  <div class="flex-shrink-0 pb-6 px-8">
    <div class="max-w-7xl mx-auto grid grid-cols-4 gap-4 max-w-lg lg:max-w-xl mx-auto">
      <div class="warm-card px-4 py-3 text-center">
        <div class="text-xs text-textDark font-semibold">Course Management</div>
        <div class="text-xs text-textMuted mt-0.5">Create and enroll courses</div>
      </div>
      <div class="warm-card px-4 py-3 text-center">
        <div class="text-xs text-textDark font-semibold">Task Tracking</div>
        <div class="text-xs text-textMuted mt-0.5">Publish and complete tasks</div>
      </div>
      <div class="warm-card px-4 py-3 text-center">
        <div class="text-xs text-textDark font-semibold">Progress Dashboard</div>
        <div class="text-xs text-textMuted mt-0.5">Real-time statistics</div>
      </div>
      <div class="warm-card px-4 py-3 text-center">
        <div class="text-xs text-textDark font-semibold">Role-Based Access</div>
        <div class="text-xs text-textMuted mt-0.5">Student / Lecturer / Admin</div>
      </div>
    </div>
  </div>
</main>

</body>
</html>
