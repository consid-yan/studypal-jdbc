package com.studypal.servlet;

import com.studypal.model.MainTask;
import com.studypal.model.SubTask;
import com.studypal.model.TaskStatus;
import com.studypal.service.CourseService;
import com.studypal.service.TaskService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "TaskDetailServlet", urlPatterns = "/task-detail")
public class TaskDetailServlet extends HttpServlet {
    private final TaskService taskService = new TaskService();
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer mainTaskId = parseMainTaskId(request);
        if (mainTaskId == null) {
            response.sendRedirect(request.getContextPath() + "/main-tasks");
            return;
        }

        Optional<MainTask> mainTaskOptional = taskService.findMainTask(mainTaskId);
        if (mainTaskOptional.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/main-tasks");
            return;
        }

        MainTask mainTask = mainTaskOptional.get();
        List<SubTask> subTasks = taskService.listSubTasks(mainTaskId);

        request.setAttribute("mainTask", mainTask);
        request.setAttribute("subTasks", subTasks);
        request.setAttribute("courseName", courseService.findCourse(mainTask.getCourseId())
                .map(course -> course.getCourseName())
                .orElse("-"));
        request.getRequestDispatcher("/WEB-INF/jsp/task-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Integer mainTaskId = parseMainTaskId(request);
        if (mainTaskId == null) {
            response.sendRedirect(request.getContextPath() + "/main-tasks");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("createSubTask".equals(action)) {
                handleCreateSubTask(request, mainTaskId);
            } else if ("updateSubTask".equals(action)) {
                handleUpdateSubTask(request, mainTaskId);
            } else if ("deleteSubTask".equals(action)) {
                handleDeleteSubTask(request);
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/task-detail?id=" + mainTaskId);
    }

    private void handleCreateSubTask(HttpServletRequest request, Integer mainTaskId) {
        SubTask subTask = new SubTask();
        subTask.setMainTaskId(mainTaskId);
        populateSubTaskFromRequest(subTask, request, false);
        taskService.createSubTask(subTask);
    }

    private void handleUpdateSubTask(HttpServletRequest request, Integer mainTaskId) {
        SubTask subTask = new SubTask();
        subTask.setSubTaskId(Integer.valueOf(request.getParameter("subTaskId")));
        subTask.setMainTaskId(mainTaskId);
        populateSubTaskFromRequest(subTask, request, true);
        taskService.updateSubTask(subTask);
    }

    private void handleDeleteSubTask(HttpServletRequest request) {
        int subTaskId = Integer.parseInt(request.getParameter("subTaskId"));
        taskService.deleteSubTask(subTaskId);
    }

    private void populateSubTaskFromRequest(SubTask subTask, HttpServletRequest request,
                                          boolean includeStatus) {
        subTask.setTitle(request.getParameter("title"));
        subTask.setDescription(emptyToNull(request.getParameter("description")));
        subTask.setEstimatedHours(parseEstimatedHours(request.getParameter("estimatedHours")));
        subTask.setPlannedStartTime(parseDateTime(request.getParameter("plannedStartTime")));
        subTask.setPlannedEndTime(parseDateTime(request.getParameter("plannedEndTime")));

        if (includeStatus) {
            String status = request.getParameter("status");
            if (status != null && !status.isBlank()) {
                subTask.setStatus(TaskStatus.valueOf(status));
            }
            subTask.setCompletedTime(parseDateTime(request.getParameter("completedTime")));
        }
    }

    private Integer parseMainTaskId(HttpServletRequest request) {
        String id = request.getParameter("id");
        if (id == null || id.isBlank()) {
            id = request.getParameter("mainTaskId");
        }
        if (id == null || id.isBlank()) {
            return null;
        }
        return Integer.valueOf(id);
    }

    private BigDecimal parseEstimatedHours(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return new BigDecimal(value);
    }

    private LocalDateTime parseDateTime(String value) {
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
