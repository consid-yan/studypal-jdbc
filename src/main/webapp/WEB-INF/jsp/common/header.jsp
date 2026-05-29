<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="currentRole" value="${param.role}"/>
<c:if test="${empty currentRole and not empty currentUser}">
    <c:set var="currentRole" value="${currentUser.role}"/>
</c:if>
<c:if test="${empty currentRole}">
    <c:set var="currentRole" value="STUDENT"/>
</c:if>
<header class="app-header">
    <a class="brand" href="${pageContext.request.contextPath}/index.jsp">
        <strong>StudyPal</strong>
        <span>
            <c:choose>
                <c:when test="${currentRole == 'LECTURER'}">Lecturer Workspace</c:when>
                <c:when test="${currentRole == 'ADMIN'}">Admin Workspace</c:when>
                <c:otherwise>Student Workspace</c:otherwise>
            </c:choose>
        </span>
    </a>
    <nav>
        <c:choose>
            <c:when test="${currentRole == 'LECTURER'}">
                <a href="${pageContext.request.contextPath}/lecturer-home.jsp?role=LECTURER">Lecturer Home</a>
                <a href="${pageContext.request.contextPath}/lecturer-courses.jsp?role=LECTURER">My Courses</a>
                <a href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER">Publish MainTask</a>
                <a href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER">Task List</a>
            </c:when>
            <c:when test="${currentRole == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin-home.jsp?role=ADMIN">Admin Home</a>
                <a href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN">User Management</a>
                <a href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN">System Overview</a>
                <a href="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN">Course Management</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/student-home.jsp?role=STUDENT">Student Home</a>
                <a href="${pageContext.request.contextPath}/student-courses.jsp?role=STUDENT">My Courses</a>
                <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT">Task Progress</a>
                <a href="${pageContext.request.contextPath}/study-statistics.jsp?role=STUDENT">Study Records</a>
            </c:otherwise>
        </c:choose>
        <a href="${pageContext.request.contextPath}/auth.jsp">Switch Role</a>
    </nav>
</header>
