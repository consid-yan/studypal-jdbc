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
            "sst.student_sub_task_id, sst.student_id, sst.template_id, st.main_task_id, "
                    + "sst.title, sst.description, st.estimated_hours, "
                    + "sst.planned_start_time, sst.planned_end_time, sst.completed_time, sst.status";

    public Optional<SubTask> findById(Integer studentSubTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM student_sub_task sst "
                + "JOIN sub_task_template st ON sst.template_id = st.template_id "
                + "WHERE sst.student_sub_task_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentSubTaskId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapSubTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find student sub-task by id.", e);
        }
        return Optional.empty();
    }

    public List<SubTask> findByStudentId(Integer studentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM student_sub_task sst "
                + "JOIN sub_task_template st ON sst.template_id = st.template_id "
                + "WHERE sst.student_id = ? "
                + "ORDER BY COALESCE(sst.planned_end_time, st.planned_end), st.sequence_order";
        List<SubTask> subTasks = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    subTasks.add(mapSubTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list student sub-tasks.", e);
        }
        return subTasks;
    }

    public List<SubTask> findByStudentIdAndMainTaskId(Integer studentId, Integer mainTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM student_sub_task sst "
                + "JOIN sub_task_template st ON sst.template_id = st.template_id "
                + "WHERE sst.student_id = ? AND st.main_task_id = ? "
                + "ORDER BY st.sequence_order, sst.planned_end_time";
        List<SubTask> subTasks = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);
            statement.setInt(2, mainTaskId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    subTasks.add(mapSubTask(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list student sub-tasks for main task.", e);
        }
        return subTasks;
    }

    public int countPlannedForDate(Integer studentId, java.time.LocalDate date) {
        String sql = "SELECT COUNT(*) FROM student_sub_task "
                + "WHERE student_id = ? "
                + "AND (DATE(planned_start_time) = ? OR DATE(planned_end_time) = ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);
            statement.setObject(2, date);
            statement.setObject(3, date);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to count planned student sub-tasks.", e);
        }
    }

    public void insert(SubTask subTask) {
        try (Connection connection = DBUtil.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                int templateId = insertTemplate(connection, subTask);
                int studentSubTaskId = insertStudentCopy(connection, subTask, templateId);
                subTask.setTemplateId(templateId);
                subTask.setSubTaskId(studentSubTaskId);
                connection.commit();
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert student sub-task.", e);
        }
    }

    public boolean update(SubTask subTask) {
        try (Connection connection = DBUtil.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                Integer templateId = findTemplateId(connection, subTask.getSubTaskId());
                if (templateId == null) {
                    connection.rollback();
                    return false;
                }
                updateTemplate(connection, subTask, templateId);
                boolean updated = updateStudentCopy(connection, subTask);
                connection.commit();
                return updated;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(previousAutoCommit);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update student sub-task.", e);
        }
    }

    public boolean delete(Integer studentSubTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            boolean previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement =
                             connection.prepareStatement("DELETE FROM study_session WHERE student_sub_task_id = ?")) {
                    statement.setInt(1, studentSubTaskId);
                    statement.executeUpdate();
                }
                boolean deleted;
                try (PreparedStatement statement =
                             connection.prepareStatement("DELETE FROM student_sub_task WHERE student_sub_task_id = ?")) {
                    statement.setInt(1, studentSubTaskId);
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
            throw new DatabaseException("Failed to delete student sub-task.", e);
        }
    }

    private int insertTemplate(Connection connection, SubTask subTask) throws SQLException {
        String sql = "INSERT INTO sub_task_template "
                + "(main_task_id, title, description, estimated_hours, sequence_order, planned_start, planned_end) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, subTask.getMainTaskId());
            statement.setString(2, subTask.getTitle());
            statement.setString(3, subTask.getDescription());
            statement.setBigDecimal(4, subTask.getEstimatedHours());
            statement.setInt(5, nextSequenceOrder(connection, subTask.getMainTaskId()));
            statement.setObject(6, subTask.getPlannedStartTime());
            statement.setObject(7, subTask.getPlannedEndTime());
            if (statement.executeUpdate() == 0) {
                throw new SQLException("Inserting sub-task template failed, no rows affected.");
            }
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Inserting sub-task template failed, no ID obtained.");
    }

    private int insertStudentCopy(Connection connection, SubTask subTask, Integer templateId)
            throws SQLException {
        String sql = "INSERT INTO student_sub_task "
                + "(student_id, template_id, title, description, planned_start_time, "
                + "planned_end_time, completed_time, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, subTask.getStudentId());
            statement.setInt(2, templateId);
            statement.setString(3, subTask.getTitle());
            statement.setString(4, subTask.getDescription());
            statement.setObject(5, subTask.getPlannedStartTime());
            statement.setObject(6, subTask.getPlannedEndTime());
            statement.setObject(7, subTask.getCompletedTime());
            statement.setString(8, getStatus(subTask).name());
            if (statement.executeUpdate() == 0) {
                throw new SQLException("Inserting student sub-task failed, no rows affected.");
            }
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Inserting student sub-task failed, no ID obtained.");
    }

    private void updateTemplate(Connection connection, SubTask subTask, Integer templateId)
            throws SQLException {
        String sql = "UPDATE sub_task_template SET main_task_id = ?, title = ?, description = ?, "
                + "estimated_hours = ?, planned_start = ?, planned_end = ? WHERE template_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, subTask.getMainTaskId());
            statement.setString(2, subTask.getTitle());
            statement.setString(3, subTask.getDescription());
            statement.setBigDecimal(4, subTask.getEstimatedHours());
            statement.setObject(5, subTask.getPlannedStartTime());
            statement.setObject(6, subTask.getPlannedEndTime());
            statement.setInt(7, templateId);
            statement.executeUpdate();
        }
    }

    private boolean updateStudentCopy(Connection connection, SubTask subTask) throws SQLException {
        String sql = "UPDATE student_sub_task SET title = ?, description = ?, planned_start_time = ?, "
                + "planned_end_time = ?, completed_time = ?, status = ? WHERE student_sub_task_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, subTask.getTitle());
            statement.setString(2, subTask.getDescription());
            statement.setObject(3, subTask.getPlannedStartTime());
            statement.setObject(4, subTask.getPlannedEndTime());
            statement.setObject(5, subTask.getCompletedTime());
            statement.setString(6, getStatus(subTask).name());
            statement.setInt(7, subTask.getSubTaskId());
            return statement.executeUpdate() > 0;
        }
    }

    private Integer findTemplateId(Connection connection, Integer studentSubTaskId) throws SQLException {
        String sql = "SELECT template_id FROM student_sub_task WHERE student_sub_task_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentSubTaskId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt("template_id") : null;
            }
        }
    }

    private int nextSequenceOrder(Connection connection, Integer mainTaskId) throws SQLException {
        String sql = "SELECT COALESCE(MAX(sequence_order), 0) + 1 FROM sub_task_template WHERE main_task_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, mainTaskId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt(1) : 1;
            }
        }
    }

    private SubTask mapSubTask(ResultSet resultSet) throws SQLException {
        SubTask subTask = new SubTask();
        subTask.setSubTaskId(resultSet.getInt("student_sub_task_id"));
        subTask.setStudentId(resultSet.getInt("student_id"));
        subTask.setTemplateId(resultSet.getInt("template_id"));
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
