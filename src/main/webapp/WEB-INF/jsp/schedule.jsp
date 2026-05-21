<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Schedule - StudyPal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<main class="page">
    <div class="page-header">
        <h2>Schedule</h2>
        <form method="get" action="${pageContext.request.contextPath}/schedule" class="filter-form">
            <label for="filterDate">Date</label>
            <input type="date" id="filterDate" name="date"
                   value="${selectedDate}">
            <button type="submit" class="btn btn-sm">Filter</button>
            <a class="btn btn-sm" href="${pageContext.request.contextPath}/schedule">Show All</a>
        </form>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <c:choose>
        <c:when test="${empty slots}">
            <p class="empty-message">No schedule slots found. Add one below.</p>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Date</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Type</th>
                    <th>Title</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="slot" items="${slots}">
                    <tr>
                        <td><c:out value="${slot.slotDate}"/></td>
                        <td><c:out value="${slot.startTime}"/></td>
                        <td><c:out value="${slot.endTime}"/></td>
                        <td>
                            <span class="badge badge-slot-${fn:toLowerCase(slot.slotType)}">
                                <c:out value="${slot.slotType}"/>
                            </span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty slot.title}">
                                    <c:out value="${slot.title}"/>
                                </c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="action-cell">
                            <button type="button" class="btn btn-sm edit-btn"
                                    data-id="${slot.scheduleSlotId}"
                                    data-date="<c:out value='${slot.slotDate}'/>"
                                    data-start="<c:out value='${slot.startTime}'/>"
                                    data-end="<c:out value='${slot.endTime}'/>"
                                    data-type="${slot.slotType}"
                                    data-title="<c:out value='${slot.title}'/>">
                                Edit
                            </button>
                            <form method="post" class="inline-form"
                                  action="${pageContext.request.contextPath}/schedule">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="scheduleSlotId" value="${slot.scheduleSlotId}">
                                <c:if test="${not empty selectedDate}">
                                    <input type="hidden" name="filterDate" value="${selectedDate}">
                                </c:if>
                                <button type="submit" class="btn btn-sm btn-danger"
                                        onclick="return confirm('Delete this schedule slot?')">
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
        <h3 id="form-title">Add Schedule Slot</h3>
        <form method="post" action="${pageContext.request.contextPath}/schedule">
            <input type="hidden" id="form-action" name="action" value="create">
            <input type="hidden" id="form-scheduleSlotId" name="scheduleSlotId" value="">
            <c:if test="${not empty selectedDate}">
                <input type="hidden" name="filterDate" value="${selectedDate}">
            </c:if>
            <div class="form-row">
                <div class="form-group">
                    <label for="slotDate">Date</label>
                    <input type="date" id="slotDate" name="slotDate" required>
                </div>
                <div class="form-group">
                    <label for="startTime">Start Time</label>
                    <input type="time" id="startTime" name="startTime" required>
                </div>
                <div class="form-group">
                    <label for="endTime">End Time</label>
                    <input type="time" id="endTime" name="endTime" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="slotType">Type</label>
                    <select id="slotType" name="slotType">
                        <option value="CLASS">Class</option>
                        <option value="FREE" selected>Free</option>
                        <option value="UNAVAILABLE">Unavailable</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="title">Title</label>
                    <input type="text" id="title" name="title"
                           placeholder="e.g. Database lecture">
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" id="form-submit" class="btn btn-primary">Add Slot</button>
                <button type="button" id="form-cancel" class="btn"
                        style="display:none" onclick="resetForm()">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</main>

<script>
function toTimeInput(value) {
    if (!value) {
        return "";
    }
    return value.length >= 5 ? value.slice(0, 5) : value;
}

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".edit-btn").forEach(function (btn) {
        btn.addEventListener("click", function () {
            document.getElementById("form-title").textContent = "Edit Schedule Slot";
            document.getElementById("form-action").value = "update";
            document.getElementById("form-scheduleSlotId").value = this.dataset.id;
            document.getElementById("slotDate").value = this.dataset.date || "";
            document.getElementById("startTime").value = toTimeInput(this.dataset.start);
            document.getElementById("endTime").value = toTimeInput(this.dataset.end);
            document.getElementById("slotType").value = this.dataset.type || "FREE";
            document.getElementById("title").value = this.dataset.title || "";
            document.getElementById("form-submit").textContent = "Save Changes";
            document.getElementById("form-cancel").style.display = "inline-block";
            document.getElementById("form-title").scrollIntoView({behavior: "smooth"});
        });
    });
});

function resetForm() {
    document.getElementById("form-title").textContent = "Add Schedule Slot";
    document.getElementById("form-action").value = "create";
    document.getElementById("form-scheduleSlotId").value = "";
    document.getElementById("slotDate").value = "";
    document.getElementById("startTime").value = "";
    document.getElementById("endTime").value = "";
    document.getElementById("slotType").value = "FREE";
    document.getElementById("title").value = "";
    document.getElementById("form-submit").textContent = "Add Slot";
    document.getElementById("form-cancel").style.display = "none";
}
</script>
</body>
</html>
