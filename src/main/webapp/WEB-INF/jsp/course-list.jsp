<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Courses - StudyPal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jsp/common/header.jsp" %>

<main class="page">
    <div class="page-header">
        <h2>Courses</h2>
    </div>

    <c:if test="${not empty message}">
        <div class="alert alert-success"><c:out value="${message}"/></div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-error"><c:out value="${error}"/></div>
    </c:if>

    <c:choose>
        <c:when test="${empty courses}">
            <p class="empty-message">No courses found. Add one below.</p>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                <tr>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Lecturer</th>
                    <th>Semester</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="course" items="${courses}">
                    <tr>
                        <td><c:out value="${course.courseCode}"/></td>
                        <td><c:out value="${course.courseName}"/></td>
                        <td><c:out value="${course.lecturer}"/></td>
                        <td><c:out value="${course.semester}"/></td>
                        <td class="action-cell">
                            <button type="button" class="btn btn-sm edit-btn"
                                    data-id="${course.courseId}"
                                    data-code="<c:out value='${course.courseCode}'/>"
                                    data-name="<c:out value='${course.courseName}'/>"
                                    data-lecturer="<c:out value='${course.lecturer}'/>"
                                    data-semester="<c:out value='${course.semester}'/>">
                                Edit
                            </button>
                            <form method="post" class="inline-form"
                                  action="${pageContext.request.contextPath}/courses">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="courseId" value="${course.courseId}">
                                <button type="submit" class="btn btn-sm btn-danger"
                                        onclick="return confirm('Delete this course?')">
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

    <!-- Add / Edit Course Form -->
    <div class="form-card">
        <h3 id="form-title">Add Course</h3>
        <form method="post" action="${pageContext.request.contextPath}/courses">
            <input type="hidden" id="form-action" name="action" value="create">
            <input type="hidden" id="form-courseId" name="courseId" value="">
            <div class="form-row">
                <div class="form-group">
                    <label for="courseCode">Course Code</label>
                    <input type="text" id="courseCode" name="courseCode"
                           required placeholder="e.g. COMP2013J">
                </div>
                <div class="form-group">
                    <label for="courseName">Course Name</label>
                    <input type="text" id="courseName" name="courseName"
                           required placeholder="e.g. Database Systems">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="lecturer">Lecturer</label>
                    <input type="text" id="lecturer" name="lecturer"
                           placeholder="e.g. Dr. Smith">
                </div>
                <div class="form-group">
                    <label for="semester">Semester</label>
                    <input type="text" id="semester" name="semester"
                           placeholder="e.g. 2025-2026-2">
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" id="form-submit" class="btn btn-primary">Add Course</button>
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
            document.getElementById("form-title").textContent = "Edit Course";
            document.getElementById("form-action").value = "update";
            document.getElementById("form-courseId").value = this.dataset.id;
            document.getElementById("courseCode").value = this.dataset.code;
            document.getElementById("courseName").value = this.dataset.name;
            document.getElementById("lecturer").value = this.dataset.lecturer;
            document.getElementById("semester").value = this.dataset.semester;
            document.getElementById("form-submit").textContent = "Save Changes";
            document.getElementById("form-cancel").style.display = "inline-block";
            document.getElementById("form-title").scrollIntoView({behavior: "smooth"});
        });
    });
});

function resetForm() {
    document.getElementById("form-title").textContent = "Add Course";
    document.getElementById("form-action").value = "create";
    document.getElementById("form-courseId").value = "";
    document.getElementById("courseCode").value = "";
    document.getElementById("courseName").value = "";
    document.getElementById("lecturer").value = "";
    document.getElementById("semester").value = "";
    document.getElementById("form-submit").textContent = "Add Course";
    document.getElementById("form-cancel").style.display = "none";
}
</script>
</body>
</html>
