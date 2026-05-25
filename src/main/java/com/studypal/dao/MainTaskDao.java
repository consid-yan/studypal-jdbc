package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.ImportanceLevel;
import com.studypal.model.MainTask;
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
            "mt.main_task_id, mt.course_id, mt.title, mt.description, mt.deadline, "
                    + "mt.importance_level, mt.created_at";

    public Optional<MainTask> findById(Integer mainTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM main_task mt WHERE mt.main_task_id = ?";
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
        String sql = "SELECT " + SELECT_COLUMNS + " FROM main_task mt ORDER BY mt.deadline";
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
        String sql = "SELECT DISTINCT " + SELECT_COLUMNS + " FROM main_task mt "
                + "JOIN enrollment e ON mt.course_id = e.course_id "
                + "WHERE e.student_id = ? "
                + "ORDER BY mt.deadline";
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
        String sql = "SELECT " + SELECT_COLUMNS + " FROM main_task mt WHERE mt.course_id = ? "
                + "ORDER BY mt.deadline";
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
                + "(course_id, title, description, deadline, importance_level) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, mainTask.getCourseId());
            statement.setString(2, mainTask.getTitle());
            statement.setString(3, mainTask.getDescription());
            statement.setObject(4, mainTask.getDeadline());
            statement.setString(5, getImportanceLevel(mainTask).name());
            if (statement.executeUpdate() == 0) {
                throw new SQLException("Inserting main task failed, no rows affected.");
            }
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    mainTask.setMainTaskId(generatedKeys.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert main task.", e);
        }
    }

    public boolean update(MainTask mainTask) {
        String sql = "UPDATE main_task SET course_id = ?, title = ?, description = ?, "
                + "deadline = ?, importance_level = ? WHERE main_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, mainTask.getCourseId());
            statement.setString(2, mainTask.getTitle());
            statement.setString(3, mainTask.getDescription());
            statement.setObject(4, mainTask.getDeadline());
            statement.setString(5, getImportanceLevel(mainTask).name());
            statement.setInt(6, mainTask.getMainTaskId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update main task.", e);
        }
    }

    public boolean delete(Integer mainTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                deleteMainTaskChildren(connection, mainTaskId);
                boolean deleted;
                try (PreparedStatement statement =
                             connection.prepareStatement("DELETE FROM main_task WHERE main_task_id = ?")) {
                    statement.setInt(1, mainTaskId);
                    deleted = statement.executeUpdate() > 0;
                }
                connection.commit();
                return deleted;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete main task.", e);
        }
    }

    private void deleteMainTaskChildren(Connection connection, Integer mainTaskId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE ss FROM study_session ss "
                        + "JOIN student_sub_task sst ON ss.student_sub_task_id = sst.student_sub_task_id "
                        + "JOIN sub_task_template st ON sst.template_id = st.template_id "
                        + "WHERE st.main_task_id = ?")) {
            statement.setInt(1, mainTaskId);
            statement.executeUpdate();
        }
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE sst FROM student_sub_task sst "
                        + "JOIN sub_task_template st ON sst.template_id = st.template_id "
                        + "WHERE st.main_task_id = ?")) {
            statement.setInt(1, mainTaskId);
            statement.executeUpdate();
        }
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE FROM sub_task_template WHERE main_task_id = ?")) {
            statement.setInt(1, mainTaskId);
            statement.executeUpdate();
        }
    }

    private MainTask mapMainTask(ResultSet resultSet) throws SQLException {
        MainTask mainTask = new MainTask();
        mainTask.setMainTaskId(resultSet.getInt("main_task_id"));
        mainTask.setCourseId(resultSet.getInt("course_id"));
        mainTask.setTitle(resultSet.getString("title"));
        mainTask.setDescription(resultSet.getString("description"));
        mainTask.setDeadline(resultSet.getObject("deadline", java.time.LocalDateTime.class));
        mainTask.setImportanceLevel(ImportanceLevel.valueOf(resultSet.getString("importance_level")));
        mainTask.setCreatedAt(resultSet.getObject("created_at", java.time.LocalDateTime.class));
        return mainTask;
    }

    private ImportanceLevel getImportanceLevel(MainTask mainTask) {
        return mainTask.getImportanceLevel() == null
                ? ImportanceLevel.MEDIUM
                : mainTask.getImportanceLevel();
    }
}
