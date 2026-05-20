package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.Course;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class CourseDAO {
    public Optional<Course> findById(Integer courseId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find course by id.", e);
        }
    }

    public List<Course> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list courses.", e);
        }
    }

    public List<Course> findByStudentId(Integer studentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list courses for student.", e);
        }
    }

    public void insert(Course course) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert course.", e);
        }
    }

    public boolean update(Course course) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update course.", e);
        }
    }

    public boolean delete(Integer courseId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete course.", e);
        }
    }
}
