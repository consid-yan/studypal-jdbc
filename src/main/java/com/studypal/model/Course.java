package com.studypal.model;

import java.sql.Timestamp;

public class Course {
    private final Long courseId;
    private final String courseCode;
    private final String courseName;
    private final Long lecturerId;
    private String semester;
    private String description;
    private final Timestamp createdAt;

    // For display purposes only (not persisted to the database)
    private final String lecturerName;
    private final int enrollmentCount;

    public Course(Long courseId, String courseCode, String courseName, Long lecturerId, String semester,
                  String description, Timestamp createdAt) {
        this(courseId, courseCode, courseName, lecturerId, semester, description, createdAt, null, 0);
    }

    public Course(Long courseId, String courseCode, String courseName, Long lecturerId, String semester,
                  String description, Timestamp createdAt, String lecturerName, int enrollmentCount) {
        this.courseId = courseId;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.lecturerId = lecturerId;
        this.semester = semester;
        this.description = description;
        this.createdAt = createdAt;
        this.lecturerName = lecturerName;
        this.enrollmentCount = enrollmentCount;
    }

    public Long getCourseId() { return courseId; }

    public String getCourseCode() { return courseCode; }

    public String getCourseName() { return courseName; }

    public Long getLecturerId() { return lecturerId; }

    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }

    public String getLecturerName() { return lecturerName; }

    public int getEnrollmentCount() { return enrollmentCount; }
}
