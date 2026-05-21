package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.StudySession;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class StudySessionDao {
    public Optional<StudySession> findById(Integer studySessionId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find study session by id.", e);
        }
    }

    public List<StudySession> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list study sessions.", e);
        }
    }

    public List<StudySession> findByStudentId(Integer studentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list study sessions for student.", e);
        }
    }

    public List<StudySession> findBySubTaskId(Integer subTaskId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list study sessions for sub-task.", e);
        }
    }

    public void insert(StudySession studySession) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert study session.", e);
        }
    }

    public boolean update(StudySession studySession) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update study session.", e);
        }
    }

    public boolean delete(Integer studySessionId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete study session.", e);
        }
    }
}
