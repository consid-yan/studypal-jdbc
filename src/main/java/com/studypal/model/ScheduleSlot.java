package com.studypal.model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Objects;

public class ScheduleSlot {
    private Integer scheduleSlotId;
    private Integer studentId;
    private LocalDate slotDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private SlotType slotType;
    private String title;

    public ScheduleSlot() {
        this.slotType = SlotType.FREE;
    }

    public ScheduleSlot(Integer scheduleSlotId, Integer studentId, LocalDate slotDate,
                        LocalTime startTime, LocalTime endTime, SlotType slotType,
                        String title) {
        this.scheduleSlotId = scheduleSlotId;
        this.studentId = studentId;
        this.slotDate = slotDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.slotType = slotType;
        this.title = title;
    }

    public Integer getScheduleSlotId() {
        return scheduleSlotId;
    }

    public void setScheduleSlotId(Integer scheduleSlotId) {
        this.scheduleSlotId = scheduleSlotId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public LocalDate getSlotDate() {
        return slotDate;
    }

    public void setSlotDate(LocalDate slotDate) {
        this.slotDate = slotDate;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }

    public SlotType getSlotType() {
        return slotType;
    }

    public void setSlotType(SlotType slotType) {
        this.slotType = slotType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public boolean hasValidTimeRange() {
        return startTime != null && endTime != null && startTime.isBefore(endTime);
    }

    public boolean overlapsWith(ScheduleSlot other) {
        if (other == null || slotDate == null || other.slotDate == null) {
            return false;
        }
        if (!Objects.equals(studentId, other.studentId) || !slotDate.equals(other.slotDate)) {
            return false;
        }
        if (!hasValidTimeRange() || !other.hasValidTimeRange()) {
            return false;
        }
        return startTime.isBefore(other.endTime) && other.startTime.isBefore(endTime);
    }
}
