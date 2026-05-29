package com.studypal.model;

public class Student {
    private Long studentId;
    private String studentNo;
    private String major;
    private String grade;
    private String className;
    private String phone;

    public Long getStudentId() { return studentId; }
    public void setStudentId(Long id) { studentId = id; }

    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }

    public String getMajor() { return major; }
    public void setMajor(String major) { this.major = major; }

    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public String getClassName() { return className; }
    public void setClassName(String name) { className = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
