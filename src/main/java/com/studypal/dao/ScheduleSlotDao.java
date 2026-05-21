package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.ScheduleSlot;
import com.studypal.model.SlotType;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ScheduleSlotDao {
    private static final String SELECT_COLUMNS =
            "schedule_slot_id, student_id, slot_date, start_time, end_time, slot_type, title";

    public Optional<ScheduleSlot> findById(Integer scheduleSlotId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM schedule_slot WHERE schedule_slot_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, scheduleSlotId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapScheduleSlot(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find schedule slot by id.", e);
        }
        return Optional.empty();
    }

    public List<ScheduleSlot> findAll() {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM schedule_slot";
        List<ScheduleSlot> slots = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                slots.add(mapScheduleSlot(resultSet));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list schedule slots.", e);
        }
        return slots;
    }

    public List<ScheduleSlot> findByStudentId(Integer studentId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM schedule_slot WHERE student_id = ?";
        List<ScheduleSlot> slots = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    slots.add(mapScheduleSlot(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list schedule slots for student.", e);
        }
        return slots;
    }

    public List<ScheduleSlot> findByStudentIdAndDate(Integer studentId, LocalDate slotDate) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM schedule_slot "
                + "WHERE student_id = ? AND slot_date = ?";
        List<ScheduleSlot> slots = new ArrayList<>();

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, studentId);
            statement.setObject(2, slotDate);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    slots.add(mapScheduleSlot(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list schedule slots for date.", e);
        }
        return slots;
    }

    public void insert(ScheduleSlot scheduleSlot) {
        String sql = "INSERT INTO schedule_slot "
                + "(student_id, slot_date, start_time, end_time, slot_type, title) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, scheduleSlot.getStudentId());
            statement.setObject(2, scheduleSlot.getSlotDate());
            statement.setObject(3, scheduleSlot.getStartTime());
            statement.setObject(4, scheduleSlot.getEndTime());
            statement.setString(5, getSlotType(scheduleSlot).name());
            statement.setString(6, scheduleSlot.getTitle());

            int affectedRows = statement.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Inserting schedule slot failed, no rows affected.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    scheduleSlot.setScheduleSlotId(generatedKeys.getInt(1));
                } else {
                    throw new SQLException("Inserting schedule slot failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to insert schedule slot.", e);
        }
    }

    public boolean update(ScheduleSlot scheduleSlot) {
        String sql = "UPDATE schedule_slot SET student_id = ?, slot_date = ?, start_time = ?, "
                + "end_time = ?, slot_type = ?, title = ? WHERE schedule_slot_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, scheduleSlot.getStudentId());
            statement.setObject(2, scheduleSlot.getSlotDate());
            statement.setObject(3, scheduleSlot.getStartTime());
            statement.setObject(4, scheduleSlot.getEndTime());
            statement.setString(5, getSlotType(scheduleSlot).name());
            statement.setString(6, scheduleSlot.getTitle());
            statement.setInt(7, scheduleSlot.getScheduleSlotId());

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to update schedule slot.", e);
        }
    }

    public boolean delete(Integer scheduleSlotId) {
        String sql = "DELETE FROM schedule_slot WHERE schedule_slot_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, scheduleSlotId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Failed to delete schedule slot.", e);
        }
    }

    private ScheduleSlot mapScheduleSlot(ResultSet resultSet) throws SQLException {
        ScheduleSlot slot = new ScheduleSlot();
        slot.setScheduleSlotId(resultSet.getInt("schedule_slot_id"));
        slot.setStudentId(resultSet.getInt("student_id"));
        slot.setSlotDate(resultSet.getObject("slot_date", java.time.LocalDate.class));
        slot.setStartTime(resultSet.getObject("start_time", java.time.LocalTime.class));
        slot.setEndTime(resultSet.getObject("end_time", java.time.LocalTime.class));
        slot.setSlotType(SlotType.valueOf(resultSet.getString("slot_type")));
        slot.setTitle(resultSet.getString("title"));
        return slot;
    }

    private SlotType getSlotType(ScheduleSlot scheduleSlot) {
        return scheduleSlot.getSlotType() == null ? SlotType.FREE : scheduleSlot.getSlotType();
    }
}
