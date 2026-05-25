package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.SessionType;
import com.studypal.model.StudySession;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class StudySessionDao {
    private static final String SELECT_COLUMNS =
            "study_session_id, student_id, student_sub_task_id, start_time, end_time, "
                    + "duration_hours, session_type, notes";

    public Optional<StudySession> findById(Integer studySessionId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM study_session WHERE study_session_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studySessionId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapStudySession(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find study session by id.", e);
        }
        return Optional.empty();
    }

    public List<StudySession> findByStudentId(Integer studentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM study_session "
                + "WHERE student_id = ? ORDER BY start_time DESC";
        List<StudySession> sessions = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    sessions.add(mapStudySession(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list study sessions for student.", e);
        }
        return sessions;
    }

    public List<StudySession> findByStudentSubTaskId(Integer studentSubTaskId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM study_session "
                + "WHERE student_sub_task_id = ? ORDER BY start_time DESC";
        List<StudySession> sessions = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentSubTaskId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    sessions.add(mapStudySession(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list study sessions for student sub-task.", e);
        }
        return sessions;
    }

    public void insert(StudySession studySession) {
        updateDurationIfEnded(studySession);
        String sql = "INSERT INTO study_session "
                + "(student_id, student_sub_task_id, start_time, end_time, duration_hours, session_type, notes) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, studySession.getStudentId());
            setNullableInteger(statement, 2, studySession.getStudentSubTaskId());
            statement.setObject(3, studySession.getStartTime());
            statement.setObject(4, studySession.getEndTime());
            statement.setBigDecimal(5, studySession.getDurationHours());
            statement.setString(6, getSessionType(studySession).name());
            statement.setString(7, studySession.getNotes());
            if (statement.executeUpdate() == 0) {
                throw new SQLException("Inserting study session failed, no rows affected.");
            }
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    studySession.setStudySessionId(generatedKeys.getInt(1));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert study session.", e);
        }
    }

    public boolean update(StudySession studySession) {
        updateDurationIfEnded(studySession);
        String sql = "UPDATE study_session SET student_id = ?, student_sub_task_id = ?, "
                + "start_time = ?, end_time = ?, duration_hours = ?, session_type = ?, notes = ? "
                + "WHERE study_session_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studySession.getStudentId());
            setNullableInteger(statement, 2, studySession.getStudentSubTaskId());
            statement.setObject(3, studySession.getStartTime());
            statement.setObject(4, studySession.getEndTime());
            statement.setBigDecimal(5, studySession.getDurationHours());
            statement.setString(6, getSessionType(studySession).name());
            statement.setString(7, studySession.getNotes());
            statement.setInt(8, studySession.getStudySessionId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update study session.", e);
        }
    }

    public boolean delete(Integer studySessionId) {
        String sql = "DELETE FROM study_session WHERE study_session_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studySessionId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete study session.", e);
        }
    }

    private StudySession mapStudySession(ResultSet resultSet) throws SQLException {
        StudySession session = new StudySession();
        session.setStudySessionId(resultSet.getInt("study_session_id"));
        session.setStudentId(resultSet.getInt("student_id"));
        session.setStudentSubTaskId(getNullableInteger(resultSet, "student_sub_task_id"));
        session.setStartTime(resultSet.getObject("start_time", java.time.LocalDateTime.class));
        session.setEndTime(resultSet.getObject("end_time", java.time.LocalDateTime.class));
        session.setDurationHours(resultSet.getBigDecimal("duration_hours"));
        session.setSessionType(SessionType.valueOf(resultSet.getString("session_type")));
        session.setNotes(resultSet.getString("notes"));
        return session;
    }

    private void updateDurationIfEnded(StudySession studySession) {
        if (studySession.getDurationHours() == null && studySession.hasEnded()) {
            studySession.setDurationHours(studySession.calculateDurationHours());
        }
    }

    private SessionType getSessionType(StudySession studySession) {
        return studySession.getSessionType() == null
                ? SessionType.ACTUAL
                : studySession.getSessionType();
    }

    private void setNullableInteger(PreparedStatement statement, int parameterIndex, Integer value)
            throws SQLException {
        if (value == null) {
            statement.setNull(parameterIndex, Types.INTEGER);
        } else {
            statement.setInt(parameterIndex, value);
        }
    }

    private Integer getNullableInteger(ResultSet resultSet, String columnName) throws SQLException {
        int value = resultSet.getInt(columnName);
        return resultSet.wasNull() ? null : value;
    }
}
