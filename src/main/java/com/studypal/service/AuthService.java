package com.studypal.service;

import com.studypal.model.*;
import com.studypal.util.DBUtils;

import java.sql.*;

public class AuthService {

    public UserAccount authenticate(String account, String password) throws SQLException {
        String sql = "SELECT * FROM USER_ACCOUNT WHERE username = ? OR email = ?";
        try (Connection conn = DBUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, account);
            ps.setString(2, account);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    if (password.equals(rs.getString("password_hash"))) {
                        UserAccount u = new UserAccount();
                        u.setUserId(rs.getLong("user_id"));
                        u.setUsername(rs.getString("username"));
                        u.setEmail(rs.getString("email"));
                        u.setPasswordHash(rs.getString("password_hash"));
                        u.setFullName(rs.getString("full_name"));
                        u.setRole(rs.getString("role"));
                        u.setCreatedAt(rs.getTimestamp("created_at"));
                        return u;
                    }
                }
            }
        }
        return null;
    }

    public Lecturer getLecturerDetail(Long userId) throws SQLException {
        String sql = "SELECT * FROM LECTURER WHERE lecturer_id = ?";
        try (Connection conn = DBUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Lecturer l = new Lecturer();
                    l.setLecturerId(rs.getLong("lecturer_id"));
                    l.setEmployeeNo(rs.getString("employee_no"));
                    l.setDepartment(rs.getString("department"));
                    l.setTitle(rs.getString("title"));
                    l.setOffice(rs.getString("office"));
                    l.setPhone(rs.getString("phone"));
                    return l;
                }
            }
        }
        return null;
    }

    public Student getStudentDetail(Long userId) throws SQLException {
        String sql = "SELECT * FROM STUDENT WHERE student_id = ?";
        try (Connection conn = DBUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Student s = new Student();
                    s.setStudentId(rs.getLong("student_id"));
                    s.setStudentNo(rs.getString("student_no"));
                    s.setMajor(rs.getString("major"));
                    s.setGrade(rs.getString("grade"));
                    s.setClassName(rs.getString("class_name"));
                    s.setPhone(rs.getString("phone"));
                    return s;
                }
            }
        }
        return null;
    }

    public Admin getAdminDetail(Long userId) throws SQLException {
        String sql = "SELECT * FROM ADMIN WHERE admin_id = ?";
        try (Connection conn = DBUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Admin a = new Admin();
                    a.setAdminId(rs.getLong("admin_id"));
                    a.setAdminNo(rs.getString("admin_no"));
                    a.setDepartment(rs.getString("department"));
                    a.setPosition(rs.getString("position"));
                    a.setCreatedAt(rs.getTimestamp("created_at"));
                    return a;
                }
            }
        }
        return null;
    }

    /**
     * 注册学生账号。
     * @return null 表示注册成功；非 null 字符串为错误提示信息
     */
    public String registerStudent(String username, String email, String password,
                                  String fullName) throws SQLException {
        Connection conn = null;
        try {
            conn = DBUtils.getConnection();

            // 检查用户名、邮箱是否已存在
            String checkSql = "SELECT username, email FROM USER_ACCOUNT WHERE username = ? OR email = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        if (username.equals(rs.getString("username"))) {
                            return "Username '" + username + "' is already taken.";
                        }
                        if (email.equalsIgnoreCase(rs.getString("email"))) {
                            return "Email '" + email + "' is already registered.";
                        }
                    }
                }
            }

            conn.setAutoCommit(false);

            String sqlUser = "INSERT INTO USER_ACCOUNT (username, email, password_hash, full_name, role) VALUES (?, ?, ?, ?, 'STUDENT')";
            try (PreparedStatement ps = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setString(4, fullName);
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (!rs.next()) {
                    conn.rollback();
                    return "Unable to create account. Please try again.";
                }
                long userId = rs.getLong(1);
                rs.close();

                String studentNo = "STU" + userId;
                String sqlStudent = "INSERT INTO STUDENT (student_id, student_no, major, grade) VALUES (?, ?, 'Undeclared', 'Stage 1')";
                try (PreparedStatement ps2 = conn.prepareStatement(sqlStudent)) {
                    ps2.setLong(1, userId);
                    ps2.setString(2, studentNo);
                    ps2.executeUpdate();
                }

                conn.commit();
                return null; // null = 注册成功，无错误
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
}
