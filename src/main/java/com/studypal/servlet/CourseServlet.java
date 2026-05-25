package com.studypal.servlet;

import com.studypal.model.Course;
import com.studypal.service.CourseService;
import com.studypal.util.ServletLogUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CourseServlet", urlPatterns = "/courses")
public class CourseServlet extends HttpServlet {
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Course> courses = courseService.listCourses();
        request.setAttribute("courses", courses);
        request.setAttribute("lecturers", courseService.listLecturers());
        request.getRequestDispatcher("/WEB-INF/jsp/course-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {
                handleCreate(request);
            } else if ("update".equals(action)) {
                handleUpdate(request);
            } else if ("delete".equals(action)) {
                handleDelete(request);
            }
        } catch (Exception e) {
            ServletLogUtil.logSystemException(getServletContext(),
                    "Failed to handle CourseServlet POST action: " + action, e);
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/courses");
    }

    private void handleCreate(HttpServletRequest request) {
        Course course = new Course();
        course.setCourseCode(request.getParameter("courseCode"));
        course.setCourseName(request.getParameter("courseName"));
        course.setLecturerId(Integer.valueOf(request.getParameter("lecturerId")));
        course.setSemester(request.getParameter("semester"));
        course.setDescription(emptyToNull(request.getParameter("description")));
        courseService.createCourse(course);
    }

    private void handleUpdate(HttpServletRequest request) {
        Course course = new Course();
        course.setCourseId(Integer.valueOf(request.getParameter("courseId")));
        course.setCourseCode(request.getParameter("courseCode"));
        course.setCourseName(request.getParameter("courseName"));
        course.setLecturerId(Integer.valueOf(request.getParameter("lecturerId")));
        course.setSemester(request.getParameter("semester"));
        course.setDescription(emptyToNull(request.getParameter("description")));
        courseService.updateCourse(course);
    }

    private void handleDelete(HttpServletRequest request) {
        int courseId = Integer.parseInt(request.getParameter("courseId"));
        courseService.deleteCourse(courseId);
    }

    private String emptyToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value;
    }
}
