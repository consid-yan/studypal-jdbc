package com.studypal.dao;

import com.studypal.model.ScheduleSlot;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

public class ScheduleSlotDao {
    public Optional<ScheduleSlot> findById(Integer scheduleSlotId) {
        return Optional.empty();
    }

    public List<ScheduleSlot> findAll() {
        return Collections.emptyList();
    }

    public List<ScheduleSlot> findByStudentId(Integer studentId) {
        return Collections.emptyList();
    }

    public List<ScheduleSlot> findByStudentIdAndDate(Integer studentId, LocalDate slotDate) {
        return Collections.emptyList();
    }

    public void insert(ScheduleSlot scheduleSlot) {
        throw new UnsupportedOperationException("Schedule slots are disabled in the refactored schema.");
    }

    public boolean update(ScheduleSlot scheduleSlot) {
        throw new UnsupportedOperationException("Schedule slots are disabled in the refactored schema.");
    }

    public boolean delete(Integer scheduleSlotId) {
        throw new UnsupportedOperationException("Schedule slots are disabled in the refactored schema.");
    }
}
