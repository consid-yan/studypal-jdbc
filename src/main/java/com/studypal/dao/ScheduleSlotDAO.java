package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.ScheduleSlot;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ScheduleSlotDAO {
    public Optional<ScheduleSlot> findById(Integer scheduleSlotId) {
        try (Connection connection = DBUtil.getConnection()) {
            return Optional.empty();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find schedule slot by id.", e);
        }
    }

    public List<ScheduleSlot> findAll() {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list schedule slots.", e);
        }
    }

    public List<ScheduleSlot> findByStudentId(Integer studentId) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list schedule slots for student.", e);
        }
    }

    public List<ScheduleSlot> findByStudentIdAndDate(Integer studentId, LocalDate slotDate) {
        try (Connection connection = DBUtil.getConnection()) {
            return new ArrayList<>();
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list schedule slots for date.", e);
        }
    }

    public void insert(ScheduleSlot scheduleSlot) {
        try (Connection connection = DBUtil.getConnection()) {
            // TODO: add INSERT SQL.
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert schedule slot.", e);
        }
    }

    public boolean update(ScheduleSlot scheduleSlot) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update schedule slot.", e);
        }
    }

    public boolean delete(Integer scheduleSlotId) {
        try (Connection connection = DBUtil.getConnection()) {
            return false;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete schedule slot.", e);
        }
    }
}
