package com.studypal.servlet;

import com.studypal.model.MainTask;
import com.studypal.model.SessionType;
import com.studypal.model.StudySession;
import com.studypal.model.SubTask;
import com.studypal.service.StudySessionService;
import com.studypal.service.TaskService;
import com.studypal.util.ServletLogUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "StudySessionServlet", urlPatterns = "/study-sessions")
public class StudySessionServlet extends HttpServlet {
    private static final int DEFAULT_STUDENT_ID = 1;

    private final StudySessionService studySessionService = new StudySessionService();
    private final TaskService taskService = new TaskService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<StudySession> sessions = studySessionService.listStudySessionsForStudent(DEFAULT_STUDENT_ID);
        List<SubTask> subTasks = loadSubTasksForStudent();
        Map<Integer, String> subTaskTitleMap = buildSubTaskTitleMap(subTasks);

        request.setAttribute("sessions", sessions);
        request.setAttribute("subTasks", subTasks);
        request.setAttribute("subTaskTitleMap", subTaskTitleMap);
        request.getRequestDispatcher("/WEB-INF/jsp/study-statistics.jsp").forward(request, response);
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
                    "Failed to handle StudySessionServlet POST action: " + action, e);
            request.setAttribute("error", e.getMessage());
            loadPageData(request);
            request.getRequestDispatcher("/WEB-INF/jsp/study-statistics.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/study-sessions");
    }

    private void handleCreate(HttpServletRequest request) {
        StudySession session = new StudySession();
        session.setStudentId(DEFAULT_STUDENT_ID);
        populateSessionFromRequest(session, request);
        studySessionService.recordStudySession(session);
    }

    private void handleUpdate(HttpServletRequest request) {
        StudySession session = new StudySession();
        session.setStudySessionId(Integer.valueOf(request.getParameter("studySessionId")));
        session.setStudentId(DEFAULT_STUDENT_ID);
        populateSessionFromRequest(session, request);
        studySessionService.updateStudySession(session);
    }

    private void handleDelete(HttpServletRequest request) {
        int studySessionId = Integer.parseInt(request.getParameter("studySessionId"));
        studySessionService.deleteStudySession(studySessionId);
    }

    private void populateSessionFromRequest(StudySession session, HttpServletRequest request) {
        session.setStartTime(LocalDateTime.parse(request.getParameter("startTime")));
        session.setEndTime(parseOptionalDateTime(request.getParameter("endTime")));
        session.setSubTaskId(parseOptionalInteger(request.getParameter("subTaskId")));

        String sessionType = request.getParameter("sessionType");
        if (sessionType != null && !sessionType.isBlank()) {
            session.setSessionType(SessionType.valueOf(sessionType));
        }

        session.setNotes(emptyToNull(request.getParameter("notes")));
    }

    private void loadPageData(HttpServletRequest request) {
        List<StudySession> sessions = studySessionService.listStudySessionsForStudent(DEFAULT_STUDENT_ID);
        List<SubTask> subTasks = loadSubTasksForStudent();
        Map<Integer, String> subTaskTitleMap = buildSubTaskTitleMap(subTasks);

        request.setAttribute("sessions", sessions);
        request.setAttribute("subTasks", subTasks);
        request.setAttribute("subTaskTitleMap", subTaskTitleMap);
    }

    private List<SubTask> loadSubTasksForStudent() {
        List<SubTask> subTasks = new ArrayList<>();
        List<MainTask> mainTasks = taskService.listMainTasksForStudent(DEFAULT_STUDENT_ID);
        for (MainTask mainTask : mainTasks) {
            subTasks.addAll(taskService.listSubTasks(mainTask.getMainTaskId()));
        }
        return subTasks;
    }

    private Map<Integer, String> buildSubTaskTitleMap(List<SubTask> subTasks) {
        Map<Integer, String> subTaskTitleMap = new HashMap<>();
        for (SubTask subTask : subTasks) {
            subTaskTitleMap.put(subTask.getSubTaskId(), subTask.getTitle());
        }
        return subTaskTitleMap;
    }

    private LocalDateTime parseOptionalDateTime(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return LocalDateTime.parse(value);
    }

    private Integer parseOptionalInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return Integer.valueOf(value);
    }

    private String emptyToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value;
    }
}
