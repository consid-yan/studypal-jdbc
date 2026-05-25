package com.studypal.dao;

import com.studypal.exception.DatabaseException;
import com.studypal.model.User;
import com.studypal.model.UserRole;
import com.studypal.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class UserDao {
    private static final String SELECT_COLUMNS =
            "user_id, username, email, password_hash, full_name, role, created_at";

    public Optional<User> findById(Integer userId) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM user WHERE user_id = ?";
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapUser(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to find user by id.", e);
        }
        return Optional.empty();
    }

    public List<User> findByRole(UserRole role) {
        String sql = "SELECT " + SELECT_COLUMNS + " FROM user WHERE role = ? ORDER BY full_name, username";
        List<User> users = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, role.name());
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    users.add(mapUser(resultSet));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Failed to list users by role.", e);
        }
        return users;
    }

    private User mapUser(ResultSet resultSet) throws SQLException {
        User user = new User();
        user.setUserId(resultSet.getInt("user_id"));
        user.setUsername(resultSet.getString("username"));
        user.setEmail(resultSet.getString("email"));
        user.setPasswordHash(resultSet.getString("password_hash"));
        user.setFullName(resultSet.getString("full_name"));
        user.setRole(UserRole.valueOf(resultSet.getString("role")));
        user.setCreatedAt(resultSet.getObject("created_at", java.time.LocalDateTime.class));
        return user;
    }
}
