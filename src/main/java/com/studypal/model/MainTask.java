package com.studypal.model;

import java.time.LocalDateTime;

public class MainTask {
    private Integer mainTaskId;
    private Integer studentId;
    private Integer courseId;
    private String title;
    private String description;
    private LocalDateTime deadline;
    private ImportanceLevel importanceLevel;
    private TaskStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public MainTask() {
        this.importanceLevel = ImportanceLevel.MEDIUM;
        this.status = TaskStatus.TODO;
    }

    public MainTask(Integer mainTaskId,
                    Integer studentId,
                    Integer courseId,
                    String title,
                    String description,
                    LocalDateTime deadline,
                    ImportanceLevel importanceLevel,
                    TaskStatus status,
                    LocalDateTime createdAt,
                    LocalDateTime updatedAt) {
        this.mainTaskId = mainTaskId;
        this.studentId = studentId;
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.deadline = deadline;
        this.importanceLevel = importanceLevel;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Integer getMainTaskId() {
        return mainTaskId;
    }

    public void setMainTaskId(Integer mainTaskId) {
        this.mainTaskId = mainTaskId;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
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

    public TaskStatus getStatus() {
        return status;
    }

    public void setStatus(TaskStatus status) {
        this.status = status;
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

    public boolean isPersisted() {
        return mainTaskId != null;
    }

    public boolean isCompleted() {
        return status == TaskStatus.COMPLETED;
    }

    public boolean isCancelled() {
        return status == TaskStatus.CANCELLED;
    }

    public boolean isActive() {
        return status == TaskStatus.TODO || status == TaskStatus.IN_PROGRESS;
    }
}
