package com.studypal.servlet;

import com.studypal.model.MainTask;
import com.studypal.model.SubTask;
import com.studypal.service.TaskService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "SubTaskServlet", urlPatterns = "/sub-tasks")
public class SubTaskServlet extends HttpServlet {
    private static final int DEFAULT_STUDENT_ID = 1;

    private final TaskService taskService = new TaskService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<MainTask> mainTasks = taskService.listMainTasksForStudent(DEFAULT_STUDENT_ID);

        Map<Integer, String> mainTaskTitleMap = new HashMap<>();
        for (MainTask mainTask : mainTasks) {
            mainTaskTitleMap.put(mainTask.getMainTaskId(), mainTask.getTitle());
        }

        Integer selectedMainTaskId = parseOptionalMainTaskId(request.getParameter("mainTaskId"));
        List<SubTask> subTasks = new ArrayList<>();

        if (selectedMainTaskId != null) {
            subTasks.addAll(taskService.listSubTasks(selectedMainTaskId));
        } else {
            for (MainTask mainTask : mainTasks) {
                subTasks.addAll(taskService.listSubTasks(mainTask.getMainTaskId()));
            }
        }

        request.setAttribute("mainTasks", mainTasks);
        request.setAttribute("mainTaskTitleMap", mainTaskTitleMap);
        request.setAttribute("subTasks", subTasks);
        request.setAttribute("selectedMainTaskId", selectedMainTaskId);
        request.getRequestDispatcher("/WEB-INF/jsp/sub-task-list.jsp").forward(request, response);
    }

    private Integer parseOptionalMainTaskId(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return Integer.valueOf(value);
    }
}
