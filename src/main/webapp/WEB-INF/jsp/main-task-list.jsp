<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Main Tasks - StudyPal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<main class="page">
    <div class="page-header">
        <h2>Main Tasks</h2>
    </div>

    <c:if test="${not empty message}">
        <div class="alert alert-success"><c:out value="${message}"/></div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <c:choose>
        <c:when test="${empty mainTasks}">
            <p class="empty-message">No main tasks found. Add one below.</p>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Title</th>
                    <th>Course</th>
                    <th>Deadline</th>
                    <th>Importance</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="task" items="${mainTasks}">
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
                        <td class="action-cell">
                            <button type="button" class="btn btn-sm edit-btn"
                                    data-id="${task.mainTaskId}"
                                    data-title="<c:out value='${task.title}'/>"
                                    data-description="<c:out value='${task.description}'/>"
                                    data-course-id="${task.courseId}"
                                    data-deadline="<c:out value='${task.deadline}'/>"
                                    data-importance="${task.importanceLevel}">
                                Edit
                            </button>
                            <form method="post" class="inline-form"
                                  action="${pageContext.request.contextPath}/main-tasks">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="mainTaskId" value="${task.mainTaskId}">
                                <button type="submit" class="btn btn-sm btn-danger"
                                        onclick="return confirm('Delete this main task?')">
                                    Delete
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>

    <div class="form-card">
        <h3 id="form-title">Add Main Task</h3>
        <form method="post" action="${pageContext.request.contextPath}/main-tasks">
            <input type="hidden" id="form-action" name="action" value="create">
            <input type="hidden" id="form-mainTaskId" name="mainTaskId" value="">
            <div class="form-row">
                <div class="form-group">
                    <label for="title">Title</label>
                    <input type="text" id="title" name="title" required
                           placeholder="e.g. Database Coursework">
                </div>
                <div class="form-group">
                    <label for="courseId">Course</label>
                    <select id="courseId" name="courseId" required>
                        <option value="">Select a course</option>
                        <c:forEach var="course" items="${courses}">
                            <option value="${course.courseId}">
                                <c:out value="${course.courseCode}"/> -
                                <c:out value="${course.courseName}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description"
                              placeholder="Optional task description"></textarea>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="deadline">Deadline</label>
                    <input type="datetime-local" id="deadline" name="deadline">
                </div>
                <div class="form-group">
                    <label for="importanceLevel">Importance</label>
                    <select id="importanceLevel" name="importanceLevel">
                        <option value="VERY_LOW">Very Low</option>
                        <option value="LOW">Low</option>
                        <option value="MEDIUM" selected>Medium</option>
                        <option value="HIGH">High</option>
                        <option value="VERY_HIGH">Very High</option>
                    </select>
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" id="form-submit" class="btn btn-primary">Add Task</button>
                <button type="button" id="form-cancel" class="btn"
                        style="display:none" onclick="resetForm()">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</main>

<script>
document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".edit-btn").forEach(function (btn) {
        btn.addEventListener("click", function () {
            document.getElementById("form-title").textContent = "Edit Main Task";
            document.getElementById("form-action").value = "update";
            document.getElementById("form-mainTaskId").value = this.dataset.id;
            document.getElementById("title").value = this.dataset.title || "";
            document.getElementById("description").value = this.dataset.description || "";
            document.getElementById("courseId").value = this.dataset.courseId || "";
            document.getElementById("deadline").value = this.dataset.deadline || "";
            document.getElementById("importanceLevel").value = this.dataset.importance || "MEDIUM";
            document.getElementById("form-submit").textContent = "Save Changes";
            document.getElementById("form-cancel").style.display = "inline-block";
            document.getElementById("form-title").scrollIntoView({behavior: "smooth"});
        });
    });
});

function resetForm() {
    document.getElementById("form-title").textContent = "Add Main Task";
    document.getElementById("form-action").value = "create";
    document.getElementById("form-mainTaskId").value = "";
    document.getElementById("title").value = "";
    document.getElementById("description").value = "";
    document.getElementById("courseId").value = "";
    document.getElementById("deadline").value = "";
    document.getElementById("importanceLevel").value = "MEDIUM";
    document.getElementById("form-submit").textContent = "Add Task";
    document.getElementById("form-cancel").style.display = "none";
}
</script>
</body>
</html>
