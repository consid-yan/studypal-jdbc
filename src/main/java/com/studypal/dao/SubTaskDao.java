package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.SubTask;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class SubTaskDAO {
    public Optional<SubTask> findById(Integer subTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find sub-task by id.", e);
        }
    }

    public List<SubTask> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list sub-tasks.", e);
        }
    }

    public List<SubTask> findByMainTaskId(Integer mainTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list sub-tasks for main task.", e);
        }
    }

    public void insert(SubTask subTask) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert sub-task.", e);
        }
    }

    public boolean update(SubTask subTask) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update sub-task.", e);
        }
    }

    public boolean delete(Integer subTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete sub-task.", e);
        }
    }
}
