package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.TaskDependency;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class TaskDependencyDao {
    private static final String SELECT_COLUMNS =
            "dependency_id, sub_task_id, depends_on_sub_task_id";

    public Optional<TaskDependency> findById(Integer dependencyId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM task_dependency WHERE dependency_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, dependencyId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapTaskDependency(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find task dependency by id.", e);
        }
        return Optional.empty();
    }

    public List<TaskDependency> findAll() {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM task_dependency";
        List<TaskDependency> dependencies = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                dependencies.add(mapTaskDependency(resultSet));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list task dependencies.", e);
        }
        return dependencies;
    }

    public List<TaskDependency> findBySubTaskId(Integer subTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM task_dependency WHERE sub_task_id = ?";
        List<TaskDependency> dependencies = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, subTaskId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    dependencies.add(mapTaskDependency(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list dependencies for sub-task.", e);
        }
        return dependencies;
    }

    public void insert(TaskDependency taskDependency) {
        if (taskDependency != null && taskDependency.isSelfDependency()) {
            throw new IllegalArgumentException("A sub-task cannot depend on itself.");
        }

        String sql = "INSERT INTO task_dependency (sub_task_id, depends_on_sub_task_id) VALUES (?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, taskDependency.getSubTaskId());
            statement.setInt(2, taskDependency.getDependsOnSubTaskId());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Inserting task dependency failed, no rows affected.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    taskDependency.setDependencyId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Inserting task dependency failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert task dependency.", e);
        }
    }

    public boolean update(TaskDependency taskDependency) {
        if (taskDependency != null && taskDependency.isSelfDependency()) {
            throw new IllegalArgumentException("A sub-task cannot depend on itself.");
        }

        String sql = "UPDATE task_dependency SET sub_task_id = ?, depends_on_sub_task_id = ? "
                + "WHERE dependency_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, taskDependency.getSubTaskId());
            statement.setInt(2, taskDependency.getDependsOnSubTaskId());
            statement.setInt(3, taskDependency.getDependencyId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update task dependency.", e);
        }
    }

    public boolean delete(Integer dependencyId) {
        String sql = "DELETE FROM task_dependency WHERE dependency_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, dependencyId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete task dependency.", e);
        }
    }

    private TaskDependency mapTaskDependency(ResultSet resultSet) throws SQLException {
        TaskDependency dependency = new TaskDependency();
        dependency.setDependencyId(resultSet.getInt("dependency_id"));
        dependency.setSubTaskId(resultSet.getInt("sub_task_id"));
        dependency.setDependsOnSubTaskId(resultSet.getInt("depends_on_sub_task_id"));
        return dependency;
    }
}
