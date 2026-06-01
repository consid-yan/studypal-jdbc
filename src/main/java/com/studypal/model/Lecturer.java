package com.studypal.model;

public class Lecturer {
    private final Long lecturerId;
    private final String employeeNo;
    private final String department;
    private String title;
    private final String office;

    // For display purposes only (not persisted to the database)
    private String fullName;

    public Lecturer(Long lecturerId, String employeeNo, String department, String title, String office) {
        this(lecturerId, employeeNo, department, title, office, null);
    }

    public Lecturer(Long lecturerId, String employeeNo, String department, String title, String office, String fullName) {
        this.lecturerId = lecturerId;
        this.employeeNo = employeeNo;
        this.department = department;
        this.title = title;
        this.office = office;
        this.fullName = fullName;
    }

    public Long getLecturerId() { return lecturerId; }

    public String getEmployeeNo() { return employeeNo; }

    public String getDepartment() { return department; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getOffice() { return office; }

    public String getFullName() { return fullName; }
    public void setFullName(String name) { fullName = name; }
}
