<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StudyPal Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<header class="app-header">
    <h1>StudyPal</h1>
    <nav>
        <a href="${pageContext.request.contextPath}/courses">Courses</a>
        <a href="${pageContext.request.contextPath}/main-tasks">Main Tasks</a>
        <a href="${pageContext.request.contextPath}/sub-tasks">Sub Tasks</a>
        <a href="${pageContext.request.contextPath}/schedule">Schedule</a>
        <a href="${pageContext.request.contextPath}/study-sessions">Study Sessions</a>
    </nav>
</header>
<main class="page">
    <h2>Dashboard</h2>
    <p>Dashboard summary placeholders will be connected to services and DAOs later.</p>
</main>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
