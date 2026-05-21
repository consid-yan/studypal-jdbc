<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Detail - StudyPal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<main class="page">
    <p class="back-link">
        <a href="${pageContext.request.contextPath}/main-tasks">&larr; Back to Main Tasks</a>
    </p>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <div class="form-card info-card">
        <div class="page-header">
            <h2><c:out value="${mainTask.title}"/></h2>
            <span class="badge badge-status-${fn:toLowerCase(mainTask.status)}">
                <c:out value="${mainTask.status}"/>
            </span>
        </div>
        <div class="info-grid">
            <div>
                <span class="info-label">Course</span>
                <span class="info-value"><c:out value="${courseName}"/></span>
            </div>
            <div>
                <span class="info-label">Importance</span>
                <span class="badge badge-importance-${fn:toLowerCase(mainTask.importanceLevel)}">
                    <c:out value="${mainTask.importanceLevel}"/>
                </span>
            </div>
            <div>
                <span class="info-label">Deadline</span>
                <span class="info-value">
                    <c:choose>
                        <c:when test="${not empty mainTask.deadline}">
                            <c:out value="${mainTask.deadline}"/>
                        </c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div>
                <span class="info-label">Created</span>
                <span class="info-value">
                    <c:choose>
                        <c:when test="${not empty mainTask.createdAt}">
                            <c:out value="${mainTask.createdAt}"/>
                        </c:when>
                        <c:otherwise>-</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
        <c:if test="${not empty mainTask.description}">
            <div class="info-description">
                <span class="info-label">Description</span>
                <p><c:out value="${mainTask.description}"/></p>
            </div>
        </c:if>
    </div>

    <div class="section-header">
        <h3>Sub Tasks (${fn:length(subTasks)})</h3>
    </div>

    <c:choose>
        <c:when test="${empty subTasks}">
            <p class="empty-message">No sub tasks yet. Add one below.</p>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Title</th>
                    <th>Est. Hours</th>
                    <th>Planned Start</th>
                    <th>Planned End</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="subTask" items="${subTasks}">
                    <tr>
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
                        <td class="action-cell">
                            <button type="button" class="btn btn-sm edit-btn"
                                    data-id="${subTask.subTaskId}"
                                    data-title="<c:out value='${subTask.title}'/>"
                                    data-description="<c:out value='${subTask.description}'/>"
                                    data-estimated-hours="<c:out value='${subTask.estimatedHours}'/>"
                                    data-planned-start="<c:out value='${subTask.plannedStartTime}'/>"
                                    data-planned-end="<c:out value='${subTask.plannedEndTime}'/>"
                                    data-completed-time="<c:out value='${subTask.completedTime}'/>"
                                    data-status="${subTask.status}">
                                Edit
                            </button>
                            <form method="post" class="inline-form"
                                  action="${pageContext.request.contextPath}/task-detail">
                                <input type="hidden" name="id" value="${mainTask.mainTaskId}">
                                <input type="hidden" name="action" value="deleteSubTask">
                                <input type="hidden" name="subTaskId" value="${subTask.subTaskId}">
                                <button type="submit" class="btn btn-sm btn-danger"
                                        onclick="return confirm('Delete this sub task?')">
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
        <h3 id="form-title">Add Sub Task</h3>
        <form method="post" action="${pageContext.request.contextPath}/task-detail">
            <input type="hidden" name="id" value="${mainTask.mainTaskId}">
            <input type="hidden" id="form-action" name="action" value="createSubTask">
            <input type="hidden" id="form-subTaskId" name="subTaskId" value="">
            <div class="form-row">
                <div class="form-group">
                    <label for="title">Title</label>
                    <input type="text" id="title" name="title" required
                           placeholder="e.g. Design database schema">
                </div>
                <div class="form-group">
                    <label for="estimatedHours">Estimated Hours</label>
                    <input type="number" id="estimatedHours" name="estimatedHours"
                           min="0" step="0.25" placeholder="e.g. 4">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description"
                              placeholder="Optional sub task description"></textarea>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="plannedStartTime">Planned Start</label>
                    <input type="datetime-local" id="plannedStartTime" name="plannedStartTime">
                </div>
                <div class="form-group">
                    <label for="plannedEndTime">Planned End</label>
                    <input type="datetime-local" id="plannedEndTime" name="plannedEndTime">
                </div>
                <div class="form-group" id="status-group" style="display:none">
                    <label for="status">Status</label>
                    <select id="status" name="status">
                        <option value="TODO">To Do</option>
                        <option value="IN_PROGRESS">In Progress</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="CANCELLED">Cancelled</option>
                    </select>
                </div>
                <div class="form-group" id="completed-group" style="display:none">
                    <label for="completedTime">Completed Time</label>
                    <input type="datetime-local" id="completedTime" name="completedTime">
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" id="form-submit" class="btn btn-primary">Add Sub Task</button>
                <button type="button" id="form-cancel" class="btn"
                        style="display:none" onclick="resetForm()">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</main>

<script>
function toDatetimeLocal(value) {
    if (!value) {
        return "";
    }
    return value.length >= 16 ? value.slice(0, 16) : value;
}

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".edit-btn").forEach(function (btn) {
        btn.addEventListener("click", function () {
            document.getElementById("form-title").textContent = "Edit Sub Task";
            document.getElementById("form-action").value = "updateSubTask";
            document.getElementById("form-subTaskId").value = this.dataset.id;
            document.getElementById("title").value = this.dataset.title || "";
            document.getElementById("description").value = this.dataset.description || "";
            document.getElementById("estimatedHours").value = this.dataset.estimatedHours || "";
            document.getElementById("plannedStartTime").value =
                toDatetimeLocal(this.dataset.plannedStart);
            document.getElementById("plannedEndTime").value =
                toDatetimeLocal(this.dataset.plannedEnd);
            document.getElementById("completedTime").value =
                toDatetimeLocal(this.dataset.completedTime);
            document.getElementById("status").value = this.dataset.status || "TODO";
            document.getElementById("status-group").style.display = "flex";
            document.getElementById("completed-group").style.display = "flex";
            document.getElementById("form-submit").textContent = "Save Changes";
            document.getElementById("form-cancel").style.display = "inline-block";
            document.getElementById("form-title").scrollIntoView({behavior: "smooth"});
        });
    });
});

function resetForm() {
    document.getElementById("form-title").textContent = "Add Sub Task";
    document.getElementById("form-action").value = "createSubTask";
    document.getElementById("form-subTaskId").value = "";
    document.getElementById("title").value = "";
    document.getElementById("description").value = "";
    document.getElementById("estimatedHours").value = "";
    document.getElementById("plannedStartTime").value = "";
    document.getElementById("plannedEndTime").value = "";
    document.getElementById("completedTime").value = "";
    document.getElementById("status").value = "TODO";
    document.getElementById("status-group").style.display = "none";
    document.getElementById("completed-group").style.display = "none";
    document.getElementById("form-submit").textContent = "Add Sub Task";
    document.getElementById("form-cancel").style.display = "none";
}
</script>
</body>
</html>
