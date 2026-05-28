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
                <a href="${pageContext.request.contextPath}/lecturer-home.jsp?role=LECTURER">教师主页</a>
                <a href="${pageContext.request.contextPath}/lecturer-courses.jsp?role=LECTURER">我教的课程</a>
                <a href="${pageContext.request.contextPath}/main-tasks.jsp?role=LECTURER">发布 MainTask</a>
                <a href="${pageContext.request.contextPath}/lecturer-task-detail.jsp?role=LECTURER&id=1">任务详情</a>
            </c:when>
            <c:when test="${currentRole == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin-home.jsp?role=ADMIN">管理员主页</a>
                <a href="${pageContext.request.contextPath}/admin-users.jsp?role=ADMIN">用户管理</a>
                <a href="${pageContext.request.contextPath}/admin-overview.jsp?role=ADMIN">系统总览</a>
                <a href="${pageContext.request.contextPath}/admin-courses.jsp?role=ADMIN">课程管理</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/student-home.jsp?role=STUDENT">学生主页</a>
                <a href="${pageContext.request.contextPath}/student-courses.jsp?role=STUDENT">我的课程 Course</a>
                <a href="${pageContext.request.contextPath}/sub-tasks.jsp?role=STUDENT">任务进度</a>
                <a href="${pageContext.request.contextPath}/study-statistics.jsp?role=STUDENT">学习记录</a>
            </c:otherwise>
        </c:choose>
        <a href="${pageContext.request.contextPath}/auth.jsp">切换角色</a>
    </nav>
</header>
