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

    // For display purposes only (not persisted to the database)
    private int completedCount;
    private int totalStudentCount;

    public Long getTemplateId() { return templateId; }
    public void setTemplateId(Long id) { templateId = id; }

    public Long getMainTaskId() { return mainTaskId; }
    public void setMainTaskId(Long id) { mainTaskId = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getEstimatedHours() { return estimatedHours; }
    public void setEstimatedHours(BigDecimal hours) { estimatedHours = hours; }

    public Integer getSequenceOrder() { return sequenceOrder; }
    public void setSequenceOrder(Integer order) { sequenceOrder = order; }

    public Timestamp getPlannedStart() { return plannedStart; }
    public void setPlannedStart(Timestamp start) { plannedStart = start; }

    public Timestamp getPlannedEnd() { return plannedEnd; }
    public void setPlannedEnd(Timestamp end) { plannedEnd = end; }

    public int getCompletedCount() { return completedCount; }
    public void setCompletedCount(int count) { completedCount = count; }
    public int getTotalStudentCount() { return totalStudentCount; }
    public void setTotalStudentCount(int totalStudent) { totalStudentCount = totalStudent; }
}
