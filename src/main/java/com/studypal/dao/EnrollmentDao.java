package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.Enrollment;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class EnrollmentDao {
    private static final String SELECT_COLUMNS =
            "enrollment_id, student_id, course_id, enrollment_date";

    public Optional<Enrollment> findById(Integer enrollmentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM enrollment WHERE enrollment_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, enrollmentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapEnrollment(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find enrollment by id.", e);
        }
        return Optional.empty();
    }

    public List<Enrollment> findAll() {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM enrollment";
        List<Enrollment> enrollments = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                enrollments.add(mapEnrollment(resultSet));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list enrollments.", e);
        }
        return enrollments;
    }

    public List<Enrollment> findByStudentId(Integer studentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM enrollment WHERE student_id = ?";
        List<Enrollment> enrollments = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    enrollments.add(mapEnrollment(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list enrollments for student.", e);
        }
        return enrollments;
    }

    public void insert(Enrollment enrollment) {
        String sql = "INSERT INTO enrollment (student_id, course_id, enrollment_date) VALUES (?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, enrollment.getStudentId());
            statement.setInt(2, enrollment.getCourseId());
            statement.setObject(3, enrollment.getEnrollmentDate());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Inserting enrollment failed, no rows affected.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    enrollment.setEnrollmentId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Inserting enrollment failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert enrollment.", e);
        }
    }

    public boolean update(Enrollment enrollment) {
        String sql = "UPDATE enrollment SET student_id = ?, course_id = ?, enrollment_date = ? "
                + "WHERE enrollment_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, enrollment.getStudentId());
            statement.setInt(2, enrollment.getCourseId());
            statement.setObject(3, enrollment.getEnrollmentDate());
            statement.setInt(4, enrollment.getEnrollmentId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update enrollment.", e);
        }
    }

    public boolean delete(Integer enrollmentId) {
        String sql = "DELETE FROM enrollment WHERE enrollment_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, enrollmentId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete enrollment.", e);
        }
    }

    private Enrollment mapEnrollment(ResultSet resultSet) throws SQLException {
        Enrollment enrollment = new Enrollment();
        enrollment.setEnrollmentId(resultSet.getInt("enrollment_id"));
        enrollment.setStudentId(resultSet.getInt("student_id"));
        enrollment.setCourseId(resultSet.getInt("course_id"));
        enrollment.setEnrollmentDate(resultSet.getObject("enrollment_date", java.time.LocalDate.class));
        return enrollment;
    }
}
