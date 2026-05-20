package com.studypal.model;

public class Course {
    private Integer courseId;
    private String courseCode;
    private String courseName;
    private String lecturer;
    private String semester;

    public Course() {
    }

    public Course(Integer courseId, String courseCode, String courseName,
                  String lecturer, String semester) {
        this.courseId = courseId;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.lecturer = lecturer;
        this.semester = semester;
    }

    public Integer getCourseId() {
        return courseId;
    }

    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getLecturer() {
        return lecturer;
    }

    public void setLecturer(String lecturer) {
        this.lecturer = lecturer;
    }

    public String getSemester() {
        return semester;
    }

    public void setSemester(String semester) {
        this.semester = semester;
    }

    public boolean isPersisted() {
        return courseId != null;
    }
}
