package com.studypal.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class SubTaskTemplate {
    private Long templateId;
    private Long mainTaskId;
    private String title;
    private String description;
    private BigDecimal estimatedHours;
    private Integer sequenceOrder;
    private Timestamp plannedStart;
    private Timestamp plannedEnd;

    // 展示用（不持久化）
    private int completedCount;
    private int totalStudentCount;

    public Long getTemplateId() { return templateId; }
    public void setTemplateId(Long templateId) { this.templateId = templateId; }

    public Long getMainTaskId() { return mainTaskId; }
    public void setMainTaskId(Long mainTaskId) { this.mainTaskId = mainTaskId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getEstimatedHours() { return estimatedHours; }
    public void setEstimatedHours(BigDecimal estimatedHours) { this.estimatedHours = estimatedHours; }

    public Integer getSequenceOrder() { return sequenceOrder; }
    public void setSequenceOrder(Integer sequenceOrder) { this.sequenceOrder = sequenceOrder; }

    public Timestamp getPlannedStart() { return plannedStart; }
    public void setPlannedStart(Timestamp plannedStart) { this.plannedStart = plannedStart; }

    public Timestamp getPlannedEnd() { return plannedEnd; }
    public void setPlannedEnd(Timestamp plannedEnd) { this.plannedEnd = plannedEnd; }

    public int getCompletedCount() { return completedCount; }
    public void setCompletedCount(int completedCount) { this.completedCount = completedCount; }
    public int getTotalStudentCount() { return totalStudentCount; }
    public void setTotalStudentCount(int totalStudentCount) { this.totalStudentCount = totalStudentCount; }
}
