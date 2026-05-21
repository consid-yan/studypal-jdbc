<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StudyPal Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<main class="page">
    <div class="page-header">
        <h2>Dashboard</h2>
    </div>

    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-label">Active Tasks</div>
            <div class="stat-value"><c:out value="${activeTaskCount}"/> / <c:out value="${totalTaskCount}"/></div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Today's Schedule</div>
            <div class="stat-value"><c:out value="${todaySlotCount}"/> slots</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Study Hours (last 7 days)</div>
            <div class="stat-value"><c:out value="${weeklyStudyHours}"/> h</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Enrolled Courses</div>
            <div class="stat-value"><c:out value="${courseCount}"/> courses</div>
        </div>
    </div>

    <div class="section-header">
        <h3>Upcoming Deadlines</h3>
    </div>

    <c:choose>
        <c:when test="${empty topTasks}">
            <p class="empty-message">No active tasks with upcoming deadlines.</p>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Task Title</th>
                    <th>Course</th>
                    <th>Deadline</th>
                    <th>Importance</th>
                    <th>Priority</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="task" items="${topTasks}">
                    <tr>
                        <td>
                            <a href="${pageContext.request.contextPath}/task-detail?id=${task.mainTaskId}">
                                <c:out value="${task.title}"/>
                            </a>
                        </td>
                        <td><c:out value="${courseNameMap[task.courseId]}"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty task.deadline}">
                                    <c:out value="${task.deadline}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <span class="badge badge-importance-${fn:toLowerCase(task.importanceLevel)}">
                                <c:out value="${task.importanceLevel}"/>
                            </span>
                        </td>
                        <td><c:out value="${taskPriorityMap[task.mainTaskId]}"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</main>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
