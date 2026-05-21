package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.ImportanceLevel;
import com.studypal.model.MainTask;
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

public class MainTaskDao {
    private static final String SELECT_COLUMNS =
            "main_task_id, student_id, course_id, title, description, deadline, "
                    + "importance_level, status, created_at, updated_at";

    public Optional<MainTask> findById(Integer mainTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM main_task WHERE main_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, mainTaskId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapMainTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find main task by id.", e);
        }
        return Optional.empty();
    }

    public List<MainTask> findAll() {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM main_task";
        List<MainTask> mainTasks = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                mainTasks.add(mapMainTask(resultSet));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list main tasks.", e);
        }
        return mainTasks;
    }

    public List<MainTask> findByStudentId(Integer studentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM main_task WHERE student_id = ?";
        List<MainTask> mainTasks = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    mainTasks.add(mapMainTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list main tasks for student.", e);
        }
        return mainTasks;
    }

    public List<MainTask> findByCourseId(Integer courseId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM main_task WHERE course_id = ?";
        List<MainTask> mainTasks = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, courseId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    mainTasks.add(mapMainTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list main tasks for course.", e);
        }
        return mainTasks;
    }

    public void insert(MainTask mainTask) {
        String sql = "INSERT INTO main_task "
                + "(student_id, course_id, title, description, deadline, importance_level, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, mainTask.getStudentId());
            statement.setInt(2, mainTask.getCourseId());
            statement.setString(3, mainTask.getTitle());
            statement.setString(4, mainTask.getDescription());
            statement.setObject(5, mainTask.getDeadline());
            statement.setString(6, getImportanceLevel(mainTask).name());
            statement.setString(7, getStatus(mainTask).name());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Inserting main task failed, no rows affected.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    mainTask.setMainTaskId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Inserting main task failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert main task.", e);
        }
    }

    public boolean update(MainTask mainTask) {
        String sql = "UPDATE main_task SET student_id = ?, course_id = ?, title = ?, description = ?, "
                + "deadline = ?, importance_level = ?, status = ? WHERE main_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, mainTask.getStudentId());
            statement.setInt(2, mainTask.getCourseId());
            statement.setString(3, mainTask.getTitle());
            statement.setString(4, mainTask.getDescription());
            statement.setObject(5, mainTask.getDeadline());
            statement.setString(6, getImportanceLevel(mainTask).name());
            statement.setString(7, getStatus(mainTask).name());
            statement.setInt(8, mainTask.getMainTaskId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update main task.", e);
        }
    }

    public boolean delete(Integer mainTaskId) {
        String sql = "DELETE FROM main_task WHERE main_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, mainTaskId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete main task.", e);
        }
    }

    private MainTask mapMainTask(ResultSet resultSet) throws SQLException {
        MainTask mainTask = new MainTask();
        mainTask.setMainTaskId(resultSet.getInt("main_task_id"));
        mainTask.setStudentId(resultSet.getInt("student_id"));
        mainTask.setCourseId(resultSet.getInt("course_id"));
        mainTask.setTitle(resultSet.getString("title"));
        mainTask.setDescription(resultSet.getString("description"));
        mainTask.setDeadline(resultSet.getObject("deadline", java.time.LocalDateTime.class));
        mainTask.setImportanceLevel(ImportanceLevel.valueOf(resultSet.getString("importance_level")));
        mainTask.setStatus(TaskStatus.valueOf(resultSet.getString("status")));
        mainTask.setCreatedAt(resultSet.getObject("created_at", java.time.LocalDateTime.class));
        mainTask.setUpdatedAt(resultSet.getObject("updated_at", java.time.LocalDateTime.class));
        return mainTask;
    }

    private ImportanceLevel getImportanceLevel(MainTask mainTask) {
        return mainTask.getImportanceLevel() == null
                ? ImportanceLevel.MEDIUM
                : mainTask.getImportanceLevel();
    }

    private TaskStatus getStatus(MainTask mainTask) {
        return mainTask.getStatus() == null ? TaskStatus.TODO : mainTask.getStatus();
    }
}
