package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.Student;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class StudentDao {
    private static final String SELECT_COLUMNS =
            "student_id, username, email, password_hash, full_name";

    public Optional<Student> findById(Integer studentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM student WHERE student_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapStudent(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find student by id.", e);
        }
        return Optional.empty();
    }

    public List<Student> findAll() {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM student";
        List<Student> students = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                students.add(mapStudent(resultSet));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list students.", e);
        }
        return students;
    }

    public void insert(Student student) {
        String sql = "INSERT INTO student (username, email, password_hash, full_name) VALUES (?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, student.getUsername());
            statement.setString(2, student.getEmail());
            statement.setString(3, student.getPasswordHash());
            statement.setString(4, student.getFullName());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Inserting student failed, no rows affected.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    student.setStudentId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Inserting student failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert student.", e);
        }
    }

    public boolean update(Student student) {
        String sql = "UPDATE student SET username = ?, email = ?, password_hash = ?, full_name = ? "
                + "WHERE student_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, student.getUsername());
            statement.setString(2, student.getEmail());
            statement.setString(3, student.getPasswordHash());
            statement.setString(4, student.getFullName());
            statement.setInt(5, student.getStudentId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update student.", e);
        }
    }

    public boolean delete(Integer studentId) {
        String sql = "DELETE FROM student WHERE student_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete student.", e);
        }
    }

    private Student mapStudent(ResultSet resultSet) throws SQLException {
        Student student = new Student();
        student.setStudentId(resultSet.getInt("student_id"));
        student.setUsername(resultSet.getString("username"));
        student.setEmail(resultSet.getString("email"));
        student.setPasswordHash(resultSet.getString("password_hash"));
        student.setFullName(resultSet.getString("full_name"));
        return student;
    }
}
