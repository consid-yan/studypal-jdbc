<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - StudyPal</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>
<main class="page">
    <div class="page-header">
        <div class="page-title">
            <h1>Dashboard</h1>
            <p>Legacy `/dashboard` route compatibility; use the three role home pages for the new demo entry.</p>
        </div>
        <div class="toolbar">
            <a class="btn" href="${pageContext.request.contextPath}/student-home.jsp?role=STUDENT">Student Home</a>
            <a class="btn" href="${pageContext.request.contextPath}/lecturer-home.jsp?role=LECTURER">Lecturer Home</a>
            <a class="btn" href="${pageContext.request.contextPath}/admin-home.jsp?role=ADMIN">Admin Home</a>
        </div>
    </div>
    <section class="stat-grid">
        <div class="stat-card"><div class="stat-label">Active Tasks</div><div class="stat-value"><c:out value="${activeTaskCount}"/> / <c:out value="${totalTaskCount}"/></div><div class="stat-hint">MainTask</div></div>
        <div class="stat-card"><div class="stat-label">Today's Planned</div><div class="stat-value"><c:out value="${todaySlotCount}"/></div><div class="stat-hint">SubTask</div></div>
        <div class="stat-card"><div class="stat-label">Planned Hours</div><div class="stat-value"><c:out value="${plannedHours}"/>h</div><div class="stat-hint">from SubTask time windows</div></div>
        <div class="stat-card"><div class="stat-label">Courses</div><div class="stat-value"><c:out value="${courseCount}"/></div><div class="stat-hint">Enrollment</div></div>
    </section>
    <div class="section-header"><h3>Upcoming Deadlines</h3></div>
    <c:choose>
        <c:when test="${empty topTasks}">
            <div class="empty-state">No upcoming MainTask deadlines.</div>
        </c:when>
        <c:otherwise>
            <section class="table-card">
                <table class="data-table">
                    <thead><tr><th>Task</th><th>Course</th><th>Deadline</th><th>Importance</th><th>Priority</th></tr></thead>
                    <tbody>
                    <c:forEach var="task" items="${topTasks}">
                        <tr>
                            <td>
                                <c:choose>
                                    <c:when test="${currentRole == 'LECTURER'}">
                                        <a href="${pageContext.request.contextPath}/lecturer-task-detail.jsp?role=LECTURER&id=${task.mainTaskId}"><c:out value="${task.title}"/></a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/task-detail?role=${currentRole}&id=${task.mainTaskId}"><c:out value="${task.title}"/></a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${courseNameMap[task.courseId]}"/></td>
                            <td><c:out value="${empty task.deadline ? '-' : task.deadline}"/></td>
                            <td><span class="badge badge-importance-${fn:toLowerCase(task.importanceLevel)}"><c:out value="${task.importanceLevel}"/></span></td>
                            <td><c:out value="${taskPriorityMap[task.mainTaskId]}"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </section>
        </c:otherwise>
    </c:choose>
</main>
</body>
</html>
