package com.studypal.model;

import java.time.LocalDateTime;

public class Student {
    private Integer studentId;
    private String username;
    private String email;
    private String passwordHash;
    private String fullName;

    public Student() {
    }

    public Student(Integer studentId, String username, String email, String passwordHash,
                   String fullName) {
        this.studentId = studentId;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
    }

    public Integer getStudentId() {
        return studentId;
    }

    public void setStudentId(Integer studentId) {
        this.studentId = studentId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public boolean isPersisted() {
        return studentId != null;
    }
}
