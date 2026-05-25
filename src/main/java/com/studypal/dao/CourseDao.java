package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.Course;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class CourseDao {
    private static final String SELECT_COLUMNS =
            "c.course_id, c.course_code, c.course_name, c.lecturer_id, "
                    + "lecturer.full_name AS lecturer_name, c.semester, c.description";

    public Optional<Course> findById(Integer courseId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM course c "
                + "JOIN user lecturer ON c.lecturer_id = lecturer.user_id "
                + "WHERE c.course_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, courseId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapCourse(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find course by id.", e);
        }
        return Optional.empty();
    }

    public List<Course> findAll() {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM course c "
                + "JOIN user lecturer ON c.lecturer_id = lecturer.user_id "
                + "ORDER BY c.course_code";
        List<Course> courses = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                courses.add(mapCourse(resultSet));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list courses.", e);
        }
        return courses;
    }

    public List<Course> findByStudentId(Integer studentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM course c "
                + "JOIN user lecturer ON c.lecturer_id = lecturer.user_id "
                + "JOIN enrollment e ON c.course_id = e.course_id "
                + "WHERE e.student_id = ? "
                + "ORDER BY c.course_code";
        List<Course> courses = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    courses.add(mapCourse(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list courses for student.", e);
        }
        return courses;
    }

    public void insert(Course course) {
        String sql = "INSERT INTO course "
                + "(course_code, course_name, lecturer_id, semester, description) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, course.getCourseCode());
            statement.setString(2, course.getCourseName());
            statement.setInt(3, course.getLecturerId());
            statement.setString(4, course.getSemester());
            statement.setString(5, course.getDescription());
            if (statement.executeUpdate() == 0) {
                throw new SQLException("Inserting course failed, no rows affected.");
            }
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    course.setCourseId(generatedKeys.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert course.", e);
        }
    }

    public boolean update(Course course) {
        String sql = "UPDATE course SET course_code = ?, course_name = ?, lecturer_id = ?, "
                + "semester = ?, description = ? WHERE course_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, course.getCourseCode());
            statement.setString(2, course.getCourseName());
            statement.setInt(3, course.getLecturerId());
            statement.setString(4, course.getSemester());
            statement.setString(5, course.getDescription());
            statement.setInt(6, course.getCourseId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update course.", e);
        }
    }

    public boolean delete(Integer courseId) {
        try (Connection connection = DBUtil.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                deleteCourseChildren(connection, courseId);
                boolean deleted;
                try (PreparedStatement statement =
                             connection.prepareStatement("DELETE FROM course WHERE course_id = ?")) {
                    statement.setInt(1, courseId);
                    deleted = statement.executeUpdate() > 0;
                }
                connection.commit();
                return deleted;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete course.", e);
        }
    }

    private void deleteCourseChildren(Connection connection, Integer courseId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE ss FROM study_session ss "
                        + "JOIN student_sub_task sst ON ss.student_sub_task_id = sst.student_sub_task_id "
                        + "JOIN sub_task_template st ON sst.template_id = st.template_id "
                        + "JOIN main_task mt ON st.main_task_id = mt.main_task_id "
                        + "WHERE mt.course_id = ?")) {
            statement.setInt(1, courseId);
            statement.executeUpdate();
        }
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE sst FROM student_sub_task sst "
                        + "JOIN sub_task_template st ON sst.template_id = st.template_id "
                        + "JOIN main_task mt ON st.main_task_id = mt.main_task_id "
                        + "WHERE mt.course_id = ?")) {
            statement.setInt(1, courseId);
            statement.executeUpdate();
        }
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE st FROM sub_task_template st "
                        + "JOIN main_task mt ON st.main_task_id = mt.main_task_id "
                        + "WHERE mt.course_id = ?")) {
            statement.setInt(1, courseId);
            statement.executeUpdate();
        }
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE FROM main_task WHERE course_id = ?")) {
            statement.setInt(1, courseId);
            statement.executeUpdate();
        }
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE FROM enrollment WHERE course_id = ?")) {
            statement.setInt(1, courseId);
            statement.executeUpdate();
        }
    }

    private Course mapCourse(ResultSet resultSet) throws SQLException {
        Course course = new Course();
        course.setCourseId(resultSet.getInt("course_id"));
        course.setCourseCode(resultSet.getString("course_code"));
        course.setCourseName(resultSet.getString("course_name"));
        course.setLecturerId(resultSet.getInt("lecturer_id"));
        course.setLecturerName(resultSet.getString("lecturer_name"));
        course.setSemester(resultSet.getString("semester"));
        course.setDescription(resultSet.getString("description"));
        return course;
    }
}
