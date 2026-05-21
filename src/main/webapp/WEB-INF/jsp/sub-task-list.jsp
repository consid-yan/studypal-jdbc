<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sub Tasks - StudyPal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<main class="page">
    <div class="page-header">
        <h2>Sub Tasks</h2>
        <form method="get" action="${pageContext.request.contextPath}/sub-tasks" class="filter-form">
            <label for="mainTaskId">Filter by Main Task</label>
            <select id="mainTaskId" name="mainTaskId" onchange="this.form.submit()">
                <option value="">All Main Tasks</option>
                <c:forEach var="mainTask" items="${mainTasks}">
                    <option value="${mainTask.mainTaskId}"
                            <c:if test="${selectedMainTaskId == mainTask.mainTaskId}">selected</c:if>>
                        <c:out value="${mainTask.title}"/>
                    </option>
                </c:forEach>
            </select>
        </form>
    </div>

    <c:choose>
        <c:when test="${empty subTasks}">
            <p class="empty-message">No sub tasks found.</p>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Main Task</th>
                    <th>Title</th>
                    <th>Est. Hours</th>
                    <th>Planned Start</th>
                    <th>Planned End</th>
                    <th>Status</th>
                    <th>Detail</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="subTask" items="${subTasks}">
                    <tr>
                        <td>
                            <a href="${pageContext.request.contextPath}/task-detail?id=${subTask.mainTaskId}">
                                <c:out value="${mainTaskTitleMap[subTask.mainTaskId]}"/>
                            </a>
                        </td>
                        <td><c:out value="${subTask.title}"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty subTask.estimatedHours}">
                                    <c:out value="${subTask.estimatedHours}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty subTask.plannedStartTime}">
                                    <c:out value="${subTask.plannedStartTime}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty subTask.plannedEndTime}">
                                    <c:out value="${subTask.plannedEndTime}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <span class="badge badge-status-${fn:toLowerCase(subTask.status)}">
                                <c:out value="${subTask.status}"/>
                            </span>
                        </td>
                        <td>
                            <a class="btn btn-sm"
                               href="${pageContext.request.contextPath}/task-detail?id=${subTask.mainTaskId}">
                                View
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</main>
</body>
</html>
