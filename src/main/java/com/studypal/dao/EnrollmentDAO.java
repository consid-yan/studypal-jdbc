package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.Enrollment;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class EnrollmentDAO {
    public Optional<Enrollment> findById(Integer enrollmentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find enrollment by id.", e);
        }
    }

    public List<Enrollment> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list enrollments.", e);
        }
    }

    public List<Enrollment> findByStudentId(Integer studentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list enrollments for student.", e);
        }
    }

    public void insert(Enrollment enrollment) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert enrollment.", e);
        }
    }

    public boolean update(Enrollment enrollment) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update enrollment.", e);
        }
    }

    public boolean delete(Integer enrollmentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete enrollment.", e);
        }
    }
}
