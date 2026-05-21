package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.SubTask;
import com.studypal.model.TaskStatus;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class SubTaskDao {
    private static final String SELECT_COLUMNS =
            "sub_task_id, main_task_id, title, description, estimated_hours, "
                    + "planned_start_time, planned_end_time, completed_time, status";

    public Optional<SubTask> findById(Integer subTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM sub_task WHERE sub_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, subTaskId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapSubTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find sub-task by id.", e);
        }
        return Optional.empty();
    }

    public List<SubTask> findAll() {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM sub_task";
        List<SubTask> subTasks = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                subTasks.add(mapSubTask(resultSet));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list sub-tasks.", e);
        }
        return subTasks;
    }

    public List<SubTask> findByMainTaskId(Integer mainTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM sub_task WHERE main_task_id = ?";
        List<SubTask> subTasks = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, mainTaskId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    subTasks.add(mapSubTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list sub-tasks for main task.", e);
        }
        return subTasks;
    }

    public void insert(SubTask subTask) {
        String sql = "INSERT INTO sub_task "
                + "(main_task_id, title, description, estimated_hours, planned_start_time, "
                + "planned_end_time, completed_time, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, subTask.getMainTaskId());
            statement.setString(2, subTask.getTitle());
            statement.setString(3, subTask.getDescription());
            statement.setBigDecimal(4, subTask.getEstimatedHours());
            statement.setObject(5, subTask.getPlannedStartTime());
            statement.setObject(6, subTask.getPlannedEndTime());
            statement.setObject(7, subTask.getCompletedTime());
            statement.setString(8, getStatus(subTask).name());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Inserting sub-task failed, no rows affected.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    subTask.setSubTaskId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Inserting sub-task failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert sub-task.", e);
        }
    }

    public boolean update(SubTask subTask) {
        String sql = "UPDATE sub_task SET main_task_id = ?, title = ?, description = ?, "
                + "estimated_hours = ?, planned_start_time = ?, planned_end_time = ?, "
                + "completed_time = ?, status = ? WHERE sub_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, subTask.getMainTaskId());
            statement.setString(2, subTask.getTitle());
            statement.setString(3, subTask.getDescription());
            statement.setBigDecimal(4, subTask.getEstimatedHours());
            statement.setObject(5, subTask.getPlannedStartTime());
            statement.setObject(6, subTask.getPlannedEndTime());
            statement.setObject(7, subTask.getCompletedTime());
            statement.setString(8, getStatus(subTask).name());
            statement.setInt(9, subTask.getSubTaskId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update sub-task.", e);
        }
    }

    public boolean delete(Integer subTaskId) {
        String sql = "DELETE FROM sub_task WHERE sub_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, subTaskId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete sub-task.", e);
        }
    }

    private SubTask mapSubTask(ResultSet resultSet) throws SQLException {
        SubTask subTask = new SubTask();
        subTask.setSubTaskId(resultSet.getInt("sub_task_id"));
        subTask.setMainTaskId(resultSet.getInt("main_task_id"));
        subTask.setTitle(resultSet.getString("title"));
        subTask.setDescription(resultSet.getString("description"));
        subTask.setEstimatedHours(resultSet.getBigDecimal("estimated_hours"));
        subTask.setPlannedStartTime(resultSet.getObject("planned_start_time", java.time.LocalDateTime.class));
        subTask.setPlannedEndTime(resultSet.getObject("planned_end_time", java.time.LocalDateTime.class));
        subTask.setCompletedTime(resultSet.getObject("completed_time", java.time.LocalDateTime.class));
        subTask.setStatus(TaskStatus.valueOf(resultSet.getString("status")));
        return subTask;
    }

    private TaskStatus getStatus(SubTask subTask) {
        return subTask.getStatus() == null ? TaskStatus.TODO : subTask.getStatus();
    }
}
