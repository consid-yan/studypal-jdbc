package com.studypal.model;

import java.time.LocalDateTime;

public class MainTask {
    private Integer mainTaskId;
    private Integer courseId;
    private String title;
    private String description;
    private LocalDateTime deadline;
    private ImportanceLevel importanceLevel;
    private LocalDateTime createdAt;

    public MainTask() {
        this.importanceLevel = ImportanceLevel.MEDIUM;
    }

    public MainTask(Integer mainTaskId,
                    Integer courseId,
                    String title,
                    String description,
                    LocalDateTime deadline,
                    ImportanceLevel importanceLevel,
                    LocalDateTime createdAt) {
        this.mainTaskId = mainTaskId;
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.deadline = deadline;
        this.importanceLevel = importanceLevel;
        this.createdAt = createdAt;
    }

    public Integer getMainTaskId() {
        return mainTaskId;
    }

    public void setMainTaskId(Integer mainTaskId) {
        this.mainTaskId = mainTaskId;
    }

    public Integer getCourseId() {
        return courseId;
    }

    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
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

    public LocalDateTime getDeadline() {
        return deadline;
    }

    public void setDeadline(LocalDateTime deadline) {
        this.deadline = deadline;
    }

    public ImportanceLevel getImportanceLevel() {
        return importanceLevel;
    }

    public void setImportanceLevel(ImportanceLevel importanceLevel) {
        this.importanceLevel = importanceLevel;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isPersisted() {
        return mainTaskId != null;
    }

    public boolean isCompleted() {
        return false;
    }

    public boolean isCancelled() {
        return false;
    }

    public boolean isActive() {
        return true;
    }
}
