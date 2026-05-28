package com.studypal.model;

import java.sql.Timestamp;

public class MainTask {
    private Long mainTaskId;
    private Long courseId;
    private Long creatorId;
    private String title;
    private String description;
    private Timestamp deadline;
    private Integer importanceLevel;
    private String roleEnum;
    private Timestamp createdAt;

    // 展示用（不持久化）
    private String courseCode;
    private String courseName;
    private String creatorName;
    private int templateCount;

    public Long getMainTaskId() { return mainTaskId; }
    public void setMainTaskId(Long mainTaskId) { this.mainTaskId = mainTaskId; }

    public Long getCourseId() { return courseId; }
    public void setCourseId(Long courseId) { this.courseId = courseId; }

    public Long getCreatorId() { return creatorId; }
    public void setCreatorId(Long creatorId) { this.creatorId = creatorId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getDeadline() { return deadline; }
    public void setDeadline(Timestamp deadline) { this.deadline = deadline; }

    public Integer getImportanceLevel() { return importanceLevel; }
    public void setImportanceLevel(Integer importanceLevel) { this.importanceLevel = importanceLevel; }

    public String getRoleEnum() { return roleEnum; }
    public void setRoleEnum(String roleEnum) { this.roleEnum = roleEnum; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }
    public int getTemplateCount() { return templateCount; }
    public void setTemplateCount(int templateCount) { this.templateCount = templateCount; }
}
