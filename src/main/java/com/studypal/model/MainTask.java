package com.studypal.model;

import java.sql.Timestamp;

public class MainTask {
    private final Long mainTaskId;
    private final Long courseId;
    private final Long creatorId;
    private String title;
    private String description;
    private final Timestamp deadline;
    private final Integer importanceLevel;
    private final String roleEnum;
    private final Timestamp createdAt;

    // For display purposes only (not persisted to the database)
    private final String courseCode;
    private final String courseName;
    private final String creatorName;
    private final int templateCount;

    public MainTask(Long mainTaskId, Long courseId, Long creatorId, String title, String description,
                    Timestamp deadline, Integer importanceLevel, String roleEnum, Timestamp createdAt) {
        this(mainTaskId, courseId, creatorId, title, description, deadline, importanceLevel, roleEnum,
                createdAt, null, null, null, 0);
    }

    public MainTask(Long mainTaskId, Long courseId, Long creatorId, String title, String description,
                    Timestamp deadline, Integer importanceLevel, String roleEnum, Timestamp createdAt,
                    String courseCode, String courseName, String creatorName, int templateCount) {
        this.mainTaskId = mainTaskId;
        this.courseId = courseId;
        this.creatorId = creatorId;
        this.title = title;
        this.description = description;
        this.deadline = deadline;
        this.importanceLevel = importanceLevel;
        this.roleEnum = roleEnum;
        this.createdAt = createdAt;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.creatorName = creatorName;
        this.templateCount = templateCount;
    }

    public Long getMainTaskId() { return mainTaskId; }

    public Long getCourseId() { return courseId; }

    public Long getCreatorId() { return creatorId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getDeadline() { return deadline; }

    public Integer getImportanceLevel() { return importanceLevel; }

    public String getRoleEnum() { return roleEnum; }

    public Timestamp getCreatedAt() { return createdAt; }

    public String getCourseCode() { return courseCode; }

    public String getCourseName() { return courseName; }

    public String getCreatorName() { return creatorName; }

    public int getTemplateCount() { return templateCount; }
}
