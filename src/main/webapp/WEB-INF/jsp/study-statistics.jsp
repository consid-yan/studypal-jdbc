<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Study Sessions - StudyPal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<main class="page">
    <div class="page-header">
        <h2>Study Sessions</h2>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <c:choose>
        <c:when test="${empty sessions}">
            <p class="empty-message">No study sessions found. Record one below.</p>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Start</th>
                    <th>End</th>
                    <th>Duration</th>
                    <th>Type</th>
                    <th>Sub Task</th>
                    <th>Notes</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="session" items="${sessions}">
                    <tr>
                        <td><c:out value="${session.startTime}"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty session.endTime}">
                                    <c:out value="${session.endTime}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty session.durationHours}">
                                    <c:out value="${session.durationHours}"/> h
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <span class="badge badge-session-${fn:toLowerCase(session.sessionType)}">
                                <c:out value="${session.sessionType}"/>
                            </span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty session.studentSubTaskId}">
                                    <c:out value="${subTaskTitleMap[session.studentSubTaskId]}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="notes-cell">
                            <c:choose>
                                <c:when test="${not empty session.notes}">
                                    <c:out value="${session.notes}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="action-cell">
                            <button type="button" class="btn btn-sm edit-btn"
                                    data-id="${session.studySessionId}"
                                    data-start="<c:out value='${session.startTime}'/>"
                                    data-end="<c:out value='${session.endTime}'/>"
                                    data-type="${session.sessionType}"
                                    data-student-sub-task-id="${session.studentSubTaskId}"
                                    data-notes="<c:out value='${session.notes}'/>">
                                Edit
                            </button>
                            <form method="post" class="inline-form"
                                  action="${pageContext.request.contextPath}/study-sessions">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="studySessionId" value="${session.studySessionId}">
                                <button type="submit" class="btn btn-sm btn-danger"
                                        onclick="return confirm('Delete this study session?')">
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
        <h3 id="form-title">Record Study Session</h3>
        <form method="post" action="${pageContext.request.contextPath}/study-sessions">
            <input type="hidden" id="form-action" name="action" value="create">
            <input type="hidden" id="form-studySessionId" name="studySessionId" value="">
            <div class="form-row">
                <div class="form-group">
                    <label for="startTime">Start Time</label>
                    <input type="datetime-local" id="startTime" name="startTime" required>
                </div>
                <div class="form-group">
                    <label for="endTime">End Time</label>
                    <input type="datetime-local" id="endTime" name="endTime">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="sessionType">Type</label>
                    <select id="sessionType" name="sessionType">
                        <option value="PLANNED">Planned</option>
                        <option value="ACTUAL" selected>Actual</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="studentSubTaskId">Sub Task (optional)</label>
                    <select id="studentSubTaskId" name="studentSubTaskId">
                        <option value="">None (no task)</option>
                        <c:forEach var="subTask" items="${subTasks}">
                            <option value="${subTask.subTaskId}">
                                <c:out value="${subTask.title}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="notes">Notes</label>
                    <textarea id="notes" name="notes"
                              placeholder="Optional notes about this study session"></textarea>
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" id="form-submit" class="btn btn-primary">Record Session</button>
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
            document.getElementById("form-title").textContent = "Edit Study Session";
            document.getElementById("form-action").value = "update";
            document.getElementById("form-studySessionId").value = this.dataset.id;
            document.getElementById("startTime").value = toDatetimeLocal(this.dataset.start);
            document.getElementById("endTime").value = toDatetimeLocal(this.dataset.end);
            document.getElementById("sessionType").value = this.dataset.type || "ACTUAL";
            document.getElementById("studentSubTaskId").value = this.dataset.studentSubTaskId || "";
            document.getElementById("notes").value = this.dataset.notes || "";
            document.getElementById("form-submit").textContent = "Save Changes";
            document.getElementById("form-cancel").style.display = "inline-block";
            document.getElementById("form-title").scrollIntoView({behavior: "smooth"});
        });
    });
});

function resetForm() {
    document.getElementById("form-title").textContent = "Record Study Session";
    document.getElementById("form-action").value = "create";
    document.getElementById("form-studySessionId").value = "";
    document.getElementById("startTime").value = "";
    document.getElementById("endTime").value = "";
    document.getElementById("sessionType").value = "ACTUAL";
    document.getElementById("studentSubTaskId").value = "";
    document.getElementById("notes").value = "";
    document.getElementById("form-submit").textContent = "Record Session";
    document.getElementById("form-cancel").style.display = "none";
}
</script>
</body>
</html>
