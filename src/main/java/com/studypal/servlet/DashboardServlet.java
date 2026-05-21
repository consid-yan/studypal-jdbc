package com.studypal.servlet;

import com.studypal.model.Course;
import com.studypal.model.MainTask;
import com.studypal.model.SessionType;
import com.studypal.model.StudySession;
import com.studypal.service.CourseService;
import com.studypal.service.PriorityService;
import com.studypal.service.ScheduleService;
import com.studypal.service.StudySessionService;
import com.studypal.service.TaskService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "DashboardServlet", urlPatterns = "/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final int DEFAULT_STUDENT_ID = 1;
    private static final int TOP_TASK_LIMIT = 5;

    private final TaskService taskService = new TaskService();
    private final ScheduleService scheduleService = new ScheduleService();
    private final StudySessionService studySessionService = new StudySessionService();
    private final CourseService courseService = new CourseService();
    private final PriorityService priorityService = new PriorityService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<MainTask> mainTasks = taskService.listMainTasksForStudent(DEFAULT_STUDENT_ID);
        List<Course> courses = courseService.listCoursesForStudent(DEFAULT_STUDENT_ID);

        int totalTaskCount = mainTasks.size();
        int activeTaskCount = (int) mainTasks.stream().filter(MainTask::isActive).count();
        int todaySlotCount = scheduleService.listSlotsForDate(DEFAULT_STUDENT_ID, LocalDate.now()).size();
        int courseCount = courses.size();
        BigDecimal weeklyStudyHours = calculateWeeklyStudyHours();

        Map<Integer, String> courseNameMap = new HashMap<>();
        for (Course course : courses) {
            courseNameMap.put(course.getCourseId(), course.getCourseName());
        }

        Map<Integer, Double> taskPriorityMap = new HashMap<>();
        List<MainTask> topTasks = mainTasks.stream()
                .filter(MainTask::isActive)
                .sorted(Comparator.comparingDouble(
                        (MainTask task) -> priorityService.calculateForMainTask(task)).reversed())
                .limit(TOP_TASK_LIMIT)
                .peek(task -> taskPriorityMap.put(task.getMainTaskId(),
                        priorityService.calculateForMainTask(task)))
                .collect(Collectors.toList());

        request.setAttribute("activeTaskCount", activeTaskCount);
        request.setAttribute("totalTaskCount", totalTaskCount);
        request.setAttribute("todaySlotCount", todaySlotCount);
        request.setAttribute("weeklyStudyHours", weeklyStudyHours);
        request.setAttribute("courseCount", courseCount);
        request.setAttribute("topTasks", topTasks);
        request.setAttribute("taskPriorityMap", taskPriorityMap);
        request.setAttribute("courseNameMap", courseNameMap);
        request.getRequestDispatcher("/WEB-INF/jsp/dashboard.jsp").forward(request, response);
    }

    private BigDecimal calculateWeeklyStudyHours() {
        LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
        BigDecimal total = BigDecimal.ZERO;

        List<StudySession> sessions = studySessionService.listStudySessionsForStudent(DEFAULT_STUDENT_ID);
        for (StudySession session : sessions) {
            if (session.getSessionType() != SessionType.ACTUAL) {
                continue;
            }
            if (session.getStartTime() == null || session.getStartTime().isBefore(sevenDaysAgo)) {
                continue;
            }
            if (session.getDurationHours() != null) {
                total = total.add(session.getDurationHours());
            }
        }

        return total.setScale(2, RoundingMode.HALF_UP);
    }
}
