package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.TaskDependency;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class TaskDependencyDAO {
    public Optional<TaskDependency> findById(Integer dependencyId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find task dependency by id.", e);
        }
    }

    public List<TaskDependency> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list task dependencies.", e);
        }
    }

    public List<TaskDependency> findBySubTaskId(Integer subTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list dependencies for sub-task.", e);
        }
    }

    public void insert(TaskDependency taskDependency) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert task dependency.", e);
        }
    }

    public boolean update(TaskDependency taskDependency) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update task dependency.", e);
        }
    }

    public boolean delete(Integer dependencyId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete task dependency.", e);
        }
    }
}
