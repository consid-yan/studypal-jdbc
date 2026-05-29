package com.studypal.service;

import com.studypal.model.*;
import com.studypal.util.DBUtils;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseService {

    // ==================== Administrator Features ====================

    public String createCourse(String courseCode, String courseName, Long lecturerId,
                               String semester, String description) {
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
        return queryCourses(sql);
    }

    public List<Lecturer> getAllLecturers() throws SQLException {
        String sql = "SELECT l.*, u.full_name FROM LECTURER l JOIN USER_ACCOUNT u ON l.lecturer_id = u.user_id ORDER BY u.full_name";
        List<Lecturer> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Lecturer(rs.getLong("lecturer_id"),
                        rs.getString("employee_no"),
                        rs.getString("department"),
                        rs.getString("title"),
                        rs.getString("office"),
                        rs.getString("phone"),
                        rs.getString("full_name")));
            }
        }
        return list;
    }

    // ==================== Statistical Methods ====================

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

    // ==================== Student Features ====================

    /** Student course selection; returns null if successful, otherwise returns an error message */
    public String enrollInCourse(Long studentId, String courseCode) throws SQLException {
        Connection conn = null;
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);

            // 1. Search for courses
            long courseId;
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

            // 2. Check if it is selected
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

            // 3. Insert course registration records
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
        String sql = "SELECT c.*, u.full_name AS lecturer_name, " +
                     "(SELECT COUNT(*) FROM ENROLLMENT ec WHERE ec.course_id = c.course_id) AS enrollment_count " +
                     "FROM COURSE c JOIN ENROLLMENT e ON c.course_id = e.course_id " +
                     "JOIN LECTURER l ON c.lecturer_id = l.lecturer_id " +
                     "JOIN USER_ACCOUNT u ON l.lecturer_id = u.user_id " +
                     "WHERE e.student_id = ? ORDER BY e.enrollment_date DESC";
        return queryCourses(sql, studentId);
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

    // ==================== Instructor Features ====================

    public List<Course> getCoursesByLecturerId(Long lecturerId) throws SQLException {
        String sql = "SELECT c.*, u.full_name AS lecturer_name, " +
                     "(SELECT COUNT(*) FROM ENROLLMENT e WHERE e.course_id = c.course_id) AS enrollment_count " +
                     "FROM COURSE c JOIN USER_ACCOUNT u ON c.lecturer_id = u.user_id " +
                     "WHERE c.lecturer_id = ? ORDER BY c.created_at DESC";
        return queryCourses(sql, lecturerId);
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

    private List<Course> queryCourses(String sql, Object... params) throws SQLException {
        List<Course> list = new ArrayList<>();

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Course(rs.getLong("course_id"),
                            rs.getString("course_code"),
                            rs.getString("course_name"),
                            rs.getLong("lecturer_id"),
                            rs.getString("semester"),
                            rs.getString("description"),
                            rs.getTimestamp("created_at"),
                            rs.getString("lecturer_name"),
                            rs.getInt("enrollment_count")));
                }
            }
        }
        return list;
    }
}
