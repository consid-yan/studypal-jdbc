package com.studypal.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class SubTask {
    private Integer subTaskId;
    private Integer mainTaskId;
    private String title;
    private String description;
    private BigDecimal estimatedHours;
    private LocalDateTime plannedStartTime;
    private LocalDateTime plannedEndTime;
    private LocalDateTime completedTime;
    private TaskStatus status;

    public SubTask() {
        this.status = TaskStatus.TODO;
    }

    public SubTask(Integer subTaskId, Integer mainTaskId, String title, String description,
                   BigDecimal estimatedHours, LocalDateTime plannedStartTime,
                   LocalDateTime plannedEndTime, LocalDateTime completedTime,
                   TaskStatus status) {
        this.subTaskId = subTaskId;
        this.mainTaskId = mainTaskId;
        this.title = title;
        this.description = description;
        this.estimatedHours = estimatedHours;
        this.plannedStartTime = plannedStartTime;
        this.plannedEndTime = plannedEndTime;
        this.completedTime = completedTime;
        this.status = status;
    }

    public Integer getSubTaskId() {
        return subTaskId;
    }

    public void setSubTaskId(Integer subTaskId) {
        this.subTaskId = subTaskId;
    }

    public Integer getMainTaskId() {
        return mainTaskId;
    }

    public void setMainTaskId(Integer mainTaskId) {
        this.mainTaskId = mainTaskId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getEstimatedHours() {
        return estimatedHours;
    }

    public void setEstimatedHours(BigDecimal estimatedHours) {
        this.estimatedHours = estimatedHours;
    }

    public LocalDateTime getPlannedStartTime() {
        return plannedStartTime;
    }

    public void setPlannedStartTime(LocalDateTime plannedStartTime) {
        this.plannedStartTime = plannedStartTime;
    }

    public LocalDateTime getPlannedEndTime() {
        return plannedEndTime;
    }

    public void setPlannedEndTime(LocalDateTime plannedEndTime) {
        this.plannedEndTime = plannedEndTime;
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

    public boolean isPersisted() {
        return subTaskId != null;
    }

    public boolean isCompleted() {
        return status == TaskStatus.COMPLETED;
    }
}
