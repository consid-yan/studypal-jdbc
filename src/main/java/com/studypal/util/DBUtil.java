package com.studypal.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String DRIVER_CLASS = "com.mysql.cj.jdbc.Driver";
    private static final String URL = getSetting(
            "STUDYPAL_DB_URL",
            "jdbc:mysql://localhost:3306/studypal?useSSL=false&serverTimezone=UTC");
    private static final String USERNAME = getSetting("STUDYPAL_DB_USERNAME", "root");
    private static final String PASSWORD = getSetting("STUDYPAL_DB_PASSWORD", "password");

    static {
        try {
            Class.forName(DRIVER_CLASS);
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBUtil() {
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    private static String getSetting(String name, String defaultValue) {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        return value;
    }
}
