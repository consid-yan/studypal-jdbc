package com.studypal.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;

public class StudySession {
    private Integer studySessionId;
    private Integer studentId;
    private Integer subTaskId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private BigDecimal durationHours;
    private SessionType sessionType;
    private String notes;

    public StudySession() {
        this.sessionType = SessionType.ACTUAL;
    }

    public StudySession(Integer studySessionId, Integer studentId, Integer subTaskId,
                        LocalDateTime startTime, LocalDateTime endTime,
                        BigDecimal durationHours, SessionType sessionType, String notes) {
        this.studySessionId = studySessionId;
        this.studentId = studentId;
        this.subTaskId = subTaskId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.durationHours = durationHours;
        this.sessionType = sessionType;
        this.notes = notes;
    }

    public Integer getStudySessionId() {
        return studySessionId;
    }

    public void setStudySessionId(Integer studySessionId) {
        this.studySessionId = studySessionId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public Integer getSubTaskId() {
        return subTaskId;
    }

    public void setSubTaskId(Integer subTaskId) {
        this.subTaskId = subTaskId;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public BigDecimal getDurationHours() {
        return durationHours;
    }

    public void setDurationHours(BigDecimal durationHours) {
        this.durationHours = durationHours;
    }

    public SessionType getSessionType() {
        return sessionType;
    }

    public void setSessionType(SessionType sessionType) {
        this.sessionType = sessionType;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public boolean hasEnded() {
        return startTime != null && endTime != null && endTime.isAfter(startTime);
    }

    public BigDecimal calculateDurationHours() {
        if (!hasEnded()) {
            return BigDecimal.ZERO;
        }
        long minutes = Duration.between(startTime, endTime).toMinutes();
        return BigDecimal.valueOf(minutes)
                .divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
    }
}
