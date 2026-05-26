package com.studypal.model;

import java.time.LocalDateTime;

public class StudentSubTask {
    private Integer studentSubTaskId;
    private Integer studentId;
    private Integer templateId;
    private String customTitle;
    private String customDescription;
    private LocalDateTime customPlannedStartTime;
    private LocalDateTime customPlannedEndTime;
    private LocalDateTime completedTime;
    private TaskStatus status;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public StudentSubTask() {
        this.status = TaskStatus.TODO;
    }

    public Integer getStudentSubTaskId() {
        return studentSubTaskId;
    }

    public void setStudentSubTaskId(Integer studentSubTaskId) {
        this.studentSubTaskId = studentSubTaskId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public Integer getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Integer templateId) {
        this.templateId = templateId;
    }

    public String getTitle() {
        return customTitle;
    }

    public void setTitle(String title) {
        this.customTitle = title;
    }

    public String getDescription() {
        return customDescription;
    }

    public void setDescription(String description) {
        this.customDescription = description;
    }

    public LocalDateTime getPlannedStartTime() {
        return customPlannedStartTime;
    }

    public void setPlannedStartTime(LocalDateTime plannedStartTime) {
        this.customPlannedStartTime = plannedStartTime;
    }

    public LocalDateTime getPlannedEndTime() {
        return customPlannedEndTime;
    }

    public void setPlannedEndTime(LocalDateTime plannedEndTime) {
        this.customPlannedEndTime = plannedEndTime;
    }

    public String getCustomTitle() {
        return customTitle;
    }

    public void setCustomTitle(String customTitle) {
        this.customTitle = customTitle;
    }

    public String getCustomDescription() {
        return customDescription;
    }

    public void setCustomDescription(String customDescription) {
        this.customDescription = customDescription;
    }

    public LocalDateTime getCustomPlannedStartTime() {
        return customPlannedStartTime;
    }

    public void setCustomPlannedStartTime(LocalDateTime customPlannedStartTime) {
        this.customPlannedStartTime = customPlannedStartTime;
    }

    public LocalDateTime getCustomPlannedEndTime() {
        return customPlannedEndTime;
    }

    public void setCustomPlannedEndTime(LocalDateTime customPlannedEndTime) {
        this.customPlannedEndTime = customPlannedEndTime;
    }

    public LocalDateTime getCompletedTime() {
        return completedTime;
    }

    public void setCompletedTime(LocalDateTime completedTime) {
        this.completedTime = completedTime;
    }

    public TaskStatus getStatus() {
        return status;
    }

    public void setStatus(TaskStatus status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
