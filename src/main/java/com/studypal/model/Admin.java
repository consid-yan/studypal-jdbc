package com.studypal.model;

public class Admin {
    private Long adminId;
    private String adminNo;
    private String department;
    private String position;

    public Long getAdminId() { return adminId; }
    public void setAdminId(Long id) { adminId = id; }

    public String getAdminNo() { return adminNo; }
    public void setAdminNo(String adminNo) { this.adminNo = adminNo; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
}
