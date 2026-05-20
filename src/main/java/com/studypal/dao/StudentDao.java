package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.Student;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class StudentDAO {
    public Optional<Student> findById(Integer studentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find student by id.", e);
        }
    }

    public List<Student> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list students.", e);
        }
    }

    public void insert(Student student) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert student.", e);
        }
    }

    public boolean update(Student student) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update student.", e);
        }
    }

    public boolean delete(Integer studentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete student.", e);
        }
    }
}
