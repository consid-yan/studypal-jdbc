package com.studypal.model;

import java.sql.Timestamp;

public class StudentSubTask {
    private Long studentSubTaskId;
    private Long studentId;
    private Long templateId;
    private String customTitle;
    private String customDescription;
    private Timestamp customPlannedStartTime;
    private Timestamp customPlannedEndTime;
    private Timestamp completedTime;
    private String status;
    private String notes;

    // 展示用（不持久化）
    private String templateTitle;
    private String templateDescription;
    private String mainTaskTitle;
    private Long mainTaskId;
    private String courseName;
    private String studentName;
    private String studentEmail;
    private int progressPercentage;
    private Timestamp deadline;

    public Long getStudentSubTaskId() { return studentSubTaskId; }
    public void setStudentSubTaskId(Long studentSubTaskId) { this.studentSubTaskId = studentSubTaskId; }

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }

    public Long getTemplateId() { return templateId; }
    public void setTemplateId(Long templateId) { this.templateId = templateId; }

    public String getCustomTitle() { return customTitle; }
    public void setCustomTitle(String customTitle) { this.customTitle = customTitle; }

    public String getCustomDescription() { return customDescription; }
    public void setCustomDescription(String customDescription) { this.customDescription = customDescription; }

    public Timestamp getCustomPlannedStartTime() { return customPlannedStartTime; }
    public void setCustomPlannedStartTime(Timestamp customPlannedStartTime) { this.customPlannedStartTime = customPlannedStartTime; }

    public Timestamp getCustomPlannedEndTime() { return customPlannedEndTime; }
    public void setCustomPlannedEndTime(Timestamp customPlannedEndTime) { this.customPlannedEndTime = customPlannedEndTime; }

    public Timestamp getCompletedTime() { return completedTime; }
    public void setCompletedTime(Timestamp completedTime) { this.completedTime = completedTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getTemplateTitle() { return templateTitle; }
    public void setTemplateTitle(String templateTitle) { this.templateTitle = templateTitle; }
    public String getTemplateDescription() { return templateDescription; }
    public void setTemplateDescription(String templateDescription) { this.templateDescription = templateDescription; }
    public String getMainTaskTitle() { return mainTaskTitle; }
    public void setMainTaskTitle(String mainTaskTitle) { this.mainTaskTitle = mainTaskTitle; }
    public Long getMainTaskId() { return mainTaskId; }
    public void setMainTaskId(Long mainTaskId) { this.mainTaskId = mainTaskId; }
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
    public int getProgressPercentage() { return progressPercentage; }
    public void setProgressPercentage(int progressPercentage) { this.progressPercentage = progressPercentage; }
    public Timestamp getDeadline() { return deadline; }
    public void setDeadline(Timestamp deadline) { this.deadline = deadline; }
}
