package com.studypal.service;

import com.studypal.model.*;
import com.studypal.util.DBUtils;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseService {

    // ==================== 管理员功能 ====================

    public String createCourse(String courseCode, String courseName, Long lecturerId,
                               String semester, String description) throws SQLException {
        String sql = "INSERT INTO COURSE (course_code, course_name, lecturer_id, semester, description) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseCode);
            ps.setString(2, courseName);
            ps.setLong(3, lecturerId);
            ps.setString(4, semester);
            ps.setString(5, description);
            ps.executeUpdate();
            return null;
        } catch (SQLException e) {
            return "Failed to create course: " + e.getMessage();
        }
    }

    public List<Course> getAllCourses() throws SQLException {
        String sql = "SELECT c.*, u.full_name AS lecturer_name, " +
                     "(SELECT COUNT(*) FROM ENROLLMENT e WHERE e.course_id = c.course_id) AS enrollment_count " +
                     "FROM COURSE c JOIN LECTURER l ON c.lecturer_id = l.lecturer_id " +
                     "JOIN USER_ACCOUNT u ON l.lecturer_id = u.user_id ORDER BY c.created_at DESC";
        List<Course> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Course c = new Course();
                c.setCourseId(rs.getLong("course_id"));
                c.setCourseCode(rs.getString("course_code"));
                c.setCourseName(rs.getString("course_name"));
                c.setLecturerId(rs.getLong("lecturer_id"));
                c.setSemester(rs.getString("semester"));
                c.setDescription(rs.getString("description"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                c.setLecturerName(rs.getString("lecturer_name"));
                c.setEnrollmentCount(rs.getInt("enrollment_count"));
                list.add(c);
            }
        }
        return list;
    }

    public List<Lecturer> getAllLecturers() throws SQLException {
        String sql = "SELECT l.*, u.full_name FROM LECTURER l JOIN USER_ACCOUNT u ON l.lecturer_id = u.user_id ORDER BY u.full_name";
        List<Lecturer> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Lecturer l = new Lecturer();
                l.setLecturerId(rs.getLong("lecturer_id"));
                l.setEmployeeNo(rs.getString("employee_no"));
                l.setDepartment(rs.getString("department"));
                l.setTitle(rs.getString("title"));
                l.setOffice(rs.getString("office"));
                l.setPhone(rs.getString("phone"));
                l.setFullName(rs.getString("full_name"));
                list.add(l);
            }
        }
        return list;
    }

    // ==================== 统计方法 ====================

    public int getTotalCourseCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM COURSE";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getTotalLecturerCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM LECTURER";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getTotalEnrollmentCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM ENROLLMENT";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ==================== 学生功能 ====================

    /** 学生选课，返回 null 表示成功，否则返回错误信息 */
    public String enrollInCourse(Long studentId, String courseCode) throws SQLException {
        Connection conn = null;
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);

            // 1. 查找课程
            Long courseId = null;
            String findSql = "SELECT course_id FROM COURSE WHERE course_code = ?";
            try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                ps.setString(1, courseCode);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return "Course code '" + courseCode + "' not found.";
                    }
                    courseId = rs.getLong("course_id");
                }
            }

            // 2. 检查是否已选
            String dupSql = "SELECT COUNT(*) FROM ENROLLMENT WHERE student_id = ? AND course_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(dupSql)) {
                ps.setLong(1, studentId);
                ps.setLong(2, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        conn.rollback();
                        return "Already enrolled in this course.";
                    }
                }
            }

            // 3. 插入选课记录
            String insertSql = "INSERT INTO ENROLLMENT (student_id, course_id) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setLong(1, studentId);
                ps.setLong(2, courseId);
                ps.executeUpdate();
            }

            conn.commit();
            return null;
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            return "Failed to enroll: " + e.getMessage();
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public List<Course> getEnrolledCourses(Long studentId) throws SQLException {
        String sql = "SELECT c.*, u.full_name AS lecturer_name " +
                     "FROM COURSE c JOIN ENROLLMENT e ON c.course_id = e.course_id " +
                     "JOIN LECTURER l ON c.lecturer_id = l.lecturer_id " +
                     "JOIN USER_ACCOUNT u ON l.lecturer_id = u.user_id " +
                     "WHERE e.student_id = ? ORDER BY e.enrollment_date DESC";
        List<Course> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course c = new Course();
                    c.setCourseId(rs.getLong("course_id"));
                    c.setCourseCode(rs.getString("course_code"));
                    c.setCourseName(rs.getString("course_name"));
                    c.setLecturerId(rs.getLong("lecturer_id"));
                    c.setSemester(rs.getString("semester"));
                    c.setDescription(rs.getString("description"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setLecturerName(rs.getString("lecturer_name"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public int getEnrolledCourseCount(Long studentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ENROLLMENT WHERE student_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getActiveTaskCount(Long studentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM STUDENT_SUB_TASK WHERE student_id = ? AND status != 'COMPLETED'";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ==================== 讲师功能 ====================

    public List<Course> getCoursesByLecturerId(Long lecturerId) throws SQLException {
        String sql = "SELECT c.*, (SELECT COUNT(*) FROM ENROLLMENT e WHERE e.course_id = c.course_id) AS enrollment_count " +
                     "FROM COURSE c WHERE c.lecturer_id = ? ORDER BY c.created_at DESC";
        List<Course> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course c = new Course();
                    c.setCourseId(rs.getLong("course_id"));
                    c.setCourseCode(rs.getString("course_code"));
                    c.setCourseName(rs.getString("course_name"));
                    c.setLecturerId(rs.getLong("lecturer_id"));
                    c.setSemester(rs.getString("semester"));
                    c.setDescription(rs.getString("description"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setEnrollmentCount(rs.getInt("enrollment_count"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public int getLecturerCourseCount(Long lecturerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM COURSE WHERE lecturer_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getPublishedTaskCount(Long lecturerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM MAIN_TASK WHERE creator_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getLecturerEnrollmentCount(Long lecturerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ENROLLMENT e JOIN COURSE c ON e.course_id = c.course_id WHERE c.lecturer_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }
}
