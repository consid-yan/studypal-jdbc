package com.studypal.service;

import com.studypal.model.*;
import com.studypal.util.DBUtils;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminService {

    public List<UserAccount> getAllUsers(String roleFilter, String keyword) throws SQLException {
        var sql = new StringBuilder("SELECT * FROM USER_ACCOUNT WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (roleFilter != null && !roleFilter.isEmpty()) {
            sql.append(" AND role = ?");
            params.add(roleFilter);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (username LIKE ? OR email LIKE ? OR full_name LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        sql.append(" ORDER BY created_at DESC");

        List<UserAccount> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++)
                ps.setString(i + 1, (String) params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    var u = new UserAccount();
                    u.setUserId(rs.getLong("user_id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setFullName(rs.getString("full_name"));
                    u.setRole(rs.getString("role"));
                    u.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(u);
                }
            }
        }
        return list;
    }

    public String createAccount(String username, String email, String password,
                                String fullName, String role, String department,
                                String studentNo, String major, String grade) throws SQLException {
        Connection conn = null;
        try {
            conn = DBUtils.getConnection();

            // Check for duplicates
            String checkSql = "SELECT username, email FROM USER_ACCOUNT WHERE username = ? OR email = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        if (username.equals(rs.getString("username")))
                            return "Username already taken.";
                        if (email.equalsIgnoreCase(rs.getString("email")))
                            return "Email already registered.";
                    }
                }
            }

            conn.setAutoCommit(false);

            String sql = "INSERT INTO USER_ACCOUNT (username, email, password_hash, full_name, role) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setString(4, fullName);
                ps.setString(5, role);
                ps.executeUpdate();
                ResultSet rs = ps.getGeneratedKeys();
                if (!rs.next()) { conn.rollback(); return "Failed to create account."; }
                long userId = rs.getLong(1);
                rs.close();

                if ("STUDENT".equals(role)) {
                    String sNo = (studentNo != null && !studentNo.isEmpty()) ? studentNo : "STU" + userId;
                    String m = (major != null) ? major : "Undeclared";
                    String g = (grade != null) ? grade : "Stage 1";
                    String sqlSub = "INSERT INTO STUDENT (student_id, student_no, major, grade) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement ps2 = conn.prepareStatement(sqlSub)) {
                        ps2.setLong(1, userId); ps2.setString(2, sNo);
                        ps2.setString(3, m); ps2.setString(4, g);
                        ps2.executeUpdate();
                    }
                } else if ("LECTURER".equals(role)) {
                    String dept = (department != null) ? department : "General";
                    String sqlSub = "INSERT INTO LECTURER (lecturer_id, employee_no, department) VALUES (?, ?, ?)";
                    try (PreparedStatement ps2 = conn.prepareStatement(sqlSub)) {
                        ps2.setLong(1, userId); ps2.setString(2, "EMP" + userId);
                        ps2.setString(3, dept);
                        ps2.executeUpdate();
                    }
                } else if ("ADMIN".equals(role)) {
                    String dept = (department != null) ? department : "General";
                    String sqlSub = "INSERT INTO ADMIN (admin_id, admin_no, department) VALUES (?, ?, ?)";
                    try (PreparedStatement ps2 = conn.prepareStatement(sqlSub)) {
                        ps2.setLong(1, userId); ps2.setString(2, "ADM" + userId);
                        ps2.setString(3, dept);
                        ps2.executeUpdate();
                    }
                }

                conn.commit();
                return null;
            } catch (SQLException e) {
                conn.rollback(); throw e;
            }
        } finally {
            if (conn != null) { conn.setAutoCommit(true); conn.close(); }
        }
    }

    public String resetPassword(Long userId, String newPassword) {
        String sql = "UPDATE USER_ACCOUNT SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setLong(2, userId);
            ps.executeUpdate();
            return null;
        } catch (SQLException e) {
            return "Failed to reset password: " + e.getMessage();
        }
    }

    public int[] getStats() throws SQLException {
        int totalUsers = 0, studentCount = 0, lecturerCount = 0, adminCount = 0;
        int totalCourses = 0, totalTasks = 0, totalEnrollments = 0;
        try (Connection conn = DBUtils.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT role, COUNT(*) FROM USER_ACCOUNT GROUP BY role");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String r = rs.getString(1); int c = rs.getInt(2);
                    totalUsers += c;
                    if ("STUDENT".equals(r)) studentCount = c;
                    else if ("LECTURER".equals(r)) lecturerCount = c;
                    else if ("ADMIN".equals(r)) adminCount = c;
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM COURSE");
                 ResultSet rs = ps.executeQuery()) { if (rs.next()) totalCourses = rs.getInt(1); }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM MAIN_TASK");
                 ResultSet rs = ps.executeQuery()) { if (rs.next()) totalTasks = rs.getInt(1); }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM ENROLLMENT");
                 ResultSet rs = ps.executeQuery()) { if (rs.next()) totalEnrollments = rs.getInt(1); }
        }
        return new int[]{totalUsers, studentCount, lecturerCount, adminCount, totalCourses, totalTasks, totalEnrollments};
    }
}
