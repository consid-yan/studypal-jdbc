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
            "course_id, course_code, course_name, lecturer, semester";

    public Optional<Course> findById(Integer courseId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM course WHERE course_id = ?";
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
        String sql = "SELECT " + SELECT_COLUMNS + " FROM course";
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
        String sql = "SELECT c.course_id, c.course_code, c.course_name, c.lecturer, c.semester "
                + "FROM course c "
                + "JOIN enrollment e ON c.course_id = e.course_id "
                + "WHERE e.student_id = ?";
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
        String sql = "INSERT INTO course (course_code, course_name, lecturer, semester) VALUES (?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, course.getCourseCode());
            statement.setString(2, course.getCourseName());
            statement.setString(3, course.getLecturer());
            statement.setString(4, course.getSemester());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Inserting course failed, no rows affected.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    course.setCourseId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Inserting course failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert course.", e);
        }
    }

    public boolean update(Course course) {
        String sql = "UPDATE course SET course_code = ?, course_name = ?, lecturer = ?, semester = ? "
                + "WHERE course_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, course.getCourseCode());
            statement.setString(2, course.getCourseName());
            statement.setString(3, course.getLecturer());
            statement.setString(4, course.getSemester());
            statement.setInt(5, course.getCourseId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update course.", e);
        }
    }

    public boolean delete(Integer courseId) {
        String sql = "DELETE FROM course WHERE course_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, courseId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete course.", e);
        }
    }

    private Course mapCourse(ResultSet resultSet) throws SQLException {
        Course course = new Course();
        course.setCourseId(resultSet.getInt("course_id"));
        course.setCourseCode(resultSet.getString("course_code"));
        course.setCourseName(resultSet.getString("course_name"));
        course.setLecturer(resultSet.getString("lecturer"));
        course.setSemester(resultSet.getString("semester"));
        return course;
    }
}
