package com.studypal.model;

public class CourseProgress {
    private final Long courseId;
    private final String courseCode;
    private final String courseName;
    private final String semester;
    private final String lecturerName;
    private final int totalSteps;
    private final int completedSteps;

    public CourseProgress(Long courseId, String courseCode, String courseName,
                          String semester, String lecturerName,
                          int totalSteps, int completedSteps) {
        this.courseId = courseId;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.semester = semester;
        this.lecturerName = lecturerName;
        this.totalSteps = totalSteps;
        this.completedSteps = completedSteps;
    }

    public Long getCourseId() { return courseId; }

    public String getCourseCode() { return courseCode; }

    public String getCourseName() { return courseName; }

    public String getSemester() { return semester; }

    public String getLecturerName() { return lecturerName; }

    public int getTotalSteps() { return totalSteps; }

    public int getCompletedSteps() { return completedSteps; }

    public int getPendingSteps() { return Math.max(totalSteps - completedSteps, 0); }

    public int getCompletionPercentage() {
        return totalSteps > 0 ? (int) Math.round(completedSteps * 100.0 / totalSteps) : 0;
    }
}
