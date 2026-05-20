package com.studypal.service;

import com.studypal.dao.ScheduleSlotDAO;
import com.studypal.exception.ScheduleConflictException;
import com.studypal.exception.ValidationException;
import com.studypal.model.ScheduleSlot;

import java.time.LocalDate;
import java.util.List;

public class ScheduleService {
    private final ScheduleSlotDAO scheduleSlotDAO;

    public ScheduleService() {
        this(new ScheduleSlotDAO());
    }

    public ScheduleService(ScheduleSlotDAO scheduleSlotDAO) {
        this.scheduleSlotDAO = scheduleSlotDAO;
    }

    public List<ScheduleSlot> listSlotsForStudent(Integer studentId) {
        return scheduleSlotDAO.findByStudentId(studentId);
    }

    public List<ScheduleSlot> listSlotsForDate(Integer studentId, LocalDate slotDate) {
        return scheduleSlotDAO.findByStudentIdAndDate(studentId, slotDate);
    }

    public void createSlot(ScheduleSlot newSlot) {
        if (newSlot == null || !newSlot.hasValidTimeRange()) {
            throw new ValidationException("Schedule slot must have a valid start and end time.");
        }
        if (hasConflict(newSlot)) {
            throw new ScheduleConflictException("Schedule slot overlaps with an existing slot.");
        }
        scheduleSlotDAO.insert(newSlot);
    }

    public boolean hasConflict(ScheduleSlot newSlot) {
        List<ScheduleSlot> existingSlots = scheduleSlotDAO.findByStudentIdAndDate(
                newSlot.getStudentId(),
                newSlot.getSlotDate()
        );

        return existingSlots.stream()
                .filter(existing -> !sameSlot(existing, newSlot))
                .anyMatch(newSlot::overlapsWith);
    }

    private boolean sameSlot(ScheduleSlot first, ScheduleSlot second) {
        return first.getScheduleSlotId() != null
                && first.getScheduleSlotId().equals(second.getScheduleSlotId());
    }
}
