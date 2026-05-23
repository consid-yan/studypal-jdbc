package com.studypal.servlet;

import com.studypal.model.ScheduleSlot;
import com.studypal.model.SlotType;
import com.studypal.service.ScheduleService;
import com.studypal.util.ServletLogUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@WebServlet(name = "ScheduleServlet", urlPatterns = "/schedule")
public class ScheduleServlet extends HttpServlet {
    private static final int DEFAULT_STUDENT_ID = 1;

    private final ScheduleService scheduleService = new ScheduleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate selectedDate = parseOptionalDate(request.getParameter("date"));
        List<ScheduleSlot> slots;

        if (selectedDate != null) {
            slots = scheduleService.listSlotsForDate(DEFAULT_STUDENT_ID, selectedDate);
        } else {
            slots = scheduleService.listSlotsForStudent(DEFAULT_STUDENT_ID);
        }

        request.setAttribute("slots", slots);
        request.setAttribute("selectedDate", selectedDate);
        request.getRequestDispatcher("/WEB-INF/jsp/schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        LocalDate filterDate = parseOptionalDate(request.getParameter("filterDate"));

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
                    "Failed to handle ScheduleServlet POST action: " + action, e);
            request.setAttribute("error", e.getMessage());
            if (filterDate == null) {
                filterDate = parseOptionalDate(request.getParameter("slotDate"));
            }
            loadSlotsForRequest(request, filterDate);
            request.getRequestDispatcher("/WEB-INF/jsp/schedule.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(buildRedirectUrl(request, filterDate));
    }

    private void handleCreate(HttpServletRequest request) {
        ScheduleSlot slot = new ScheduleSlot();
        slot.setStudentId(DEFAULT_STUDENT_ID);
        populateSlotFromRequest(slot, request);
        scheduleService.createSlot(slot);
    }

    private void handleUpdate(HttpServletRequest request) {
        ScheduleSlot slot = new ScheduleSlot();
        slot.setScheduleSlotId(Integer.valueOf(request.getParameter("scheduleSlotId")));
        slot.setStudentId(DEFAULT_STUDENT_ID);
        populateSlotFromRequest(slot, request);
        scheduleService.updateSlot(slot);
    }

    private void handleDelete(HttpServletRequest request) {
        int scheduleSlotId = Integer.parseInt(request.getParameter("scheduleSlotId"));
        scheduleService.deleteSlot(scheduleSlotId);
    }

    private void populateSlotFromRequest(ScheduleSlot slot, HttpServletRequest request) {
        slot.setSlotDate(LocalDate.parse(request.getParameter("slotDate")));
        slot.setStartTime(LocalTime.parse(request.getParameter("startTime")));
        slot.setEndTime(LocalTime.parse(request.getParameter("endTime")));

        String slotType = request.getParameter("slotType");
        if (slotType != null && !slotType.isBlank()) {
            slot.setSlotType(SlotType.valueOf(slotType));
        }

        slot.setTitle(emptyToNull(request.getParameter("title")));
    }

    private void loadSlotsForRequest(HttpServletRequest request, LocalDate selectedDate) {
        List<ScheduleSlot> slots;
        if (selectedDate != null) {
            slots = scheduleService.listSlotsForDate(DEFAULT_STUDENT_ID, selectedDate);
        } else {
            slots = scheduleService.listSlotsForStudent(DEFAULT_STUDENT_ID);
        }
        request.setAttribute("slots", slots);
        request.setAttribute("selectedDate", selectedDate);
    }

    private LocalDate parseOptionalDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return LocalDate.parse(value);
    }

    private String buildRedirectUrl(HttpServletRequest request, LocalDate filterDate) {
        String url = request.getContextPath() + "/schedule";
        if (filterDate != null) {
            url += "?date=" + filterDate;
        }
        return url;
    }

    private String emptyToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value;
    }
}
