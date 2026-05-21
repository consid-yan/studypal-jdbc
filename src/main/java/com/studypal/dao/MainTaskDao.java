package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.MainTask;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class MainTaskDao {
    public Optional<MainTask> findById(Integer mainTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find main task by id.", e);
        }
    }

    public List<MainTask> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list main tasks.", e);
        }
    }

    public List<MainTask> findByStudentId(Integer studentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list main tasks for student.", e);
        }
    }

    public List<MainTask> findByCourseId(Integer courseId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list main tasks for course.", e);
        }
    }

    public void insert(MainTask mainTask) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert main task.", e);
        }
    }

    public boolean update(MainTask mainTask) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update main task.", e);
        }
    }

    public boolean delete(Integer mainTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete main task.", e);
        }
    }
}
