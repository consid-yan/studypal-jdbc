package com.studypal.servlet;

import com.studypal.model.Course;
import com.studypal.model.ImportanceLevel;
import com.studypal.model.MainTask;
import com.studypal.model.TaskStatus;
import com.studypal.service.CourseService;
import com.studypal.service.TaskService;
import com.studypal.util.ServletLogUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MainTaskServlet", urlPatterns = "/main-tasks")
public class MainTaskServlet extends HttpServlet {
    private static final int DEFAULT_STUDENT_ID = 1;

    private final TaskService taskService = new TaskService();
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<MainTask> mainTasks = taskService.listMainTasksForStudent(DEFAULT_STUDENT_ID);
        List<Course> courses = courseService.listCoursesForStudent(DEFAULT_STUDENT_ID);

        Map<Integer, String> courseNameMap = new HashMap<>();
        for (Course course : courses) {
            courseNameMap.put(course.getCourseId(), course.getCourseName());
        }

        request.setAttribute("mainTasks", mainTasks);
        request.setAttribute("courses", courses);
        request.setAttribute("courseNameMap", courseNameMap);
        request.getRequestDispatcher("/WEB-INF/jsp/main-task-list.jsp").forward(request, response);
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
                    "Failed to handle MainTaskServlet POST action: " + action, e);
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/main-tasks");
    }

    private void handleCreate(HttpServletRequest request) {
        MainTask mainTask = new MainTask();
        mainTask.setStudentId(DEFAULT_STUDENT_ID);
        populateMainTaskFromRequest(mainTask, request, false);
        taskService.createMainTask(mainTask);
    }

    private void handleUpdate(HttpServletRequest request) {
        MainTask mainTask = new MainTask();
        mainTask.setMainTaskId(Integer.valueOf(request.getParameter("mainTaskId")));
        mainTask.setStudentId(DEFAULT_STUDENT_ID);
        populateMainTaskFromRequest(mainTask, request, true);
        taskService.updateMainTask(mainTask);
    }

    private void handleDelete(HttpServletRequest request) {
        int mainTaskId = Integer.parseInt(request.getParameter("mainTaskId"));
        taskService.deleteMainTask(mainTaskId);
    }

    private void populateMainTaskFromRequest(MainTask mainTask, HttpServletRequest request,
                                           boolean includeStatus) {
        mainTask.setTitle(request.getParameter("title"));
        mainTask.setDescription(emptyToNull(request.getParameter("description")));
        mainTask.setCourseId(Integer.valueOf(request.getParameter("courseId")));
        mainTask.setDeadline(parseDeadline(request.getParameter("deadline")));

        String importanceLevel = request.getParameter("importanceLevel");
        if (importanceLevel != null && !importanceLevel.isBlank()) {
            mainTask.setImportanceLevel(ImportanceLevel.valueOf(importanceLevel));
        }

        if (includeStatus) {
            String status = request.getParameter("status");
            if (status != null && !status.isBlank()) {
                mainTask.setStatus(TaskStatus.valueOf(status));
            }
        }
    }

    private LocalDateTime parseDeadline(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return LocalDateTime.parse(value);
    }

    private String emptyToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value;
    }
}
