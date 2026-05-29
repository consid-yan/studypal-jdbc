package com.studypal.util;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.*;
import java.util.Properties;

public class DBUtils {

    private static final Properties LOCAL_CONFIG = loadLocalConfig();
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL = config("studypal.db.url", "STUDYPAL_DB_URL",
            "jdbc:mysql://localhost:3306/studypal_db?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8");
    private static final String USER = config("studypal.db.user", "STUDYPAL_DB_USER", "root");
    private static final String PASSWORD = config("studypal.db.password", "STUDYPAL_DB_PASSWORD", "");

    public static final String AI_API_URL = config("studypal.ai.apiUrl", "STUDYPAL_AI_API_URL", "");
    public static final String AI_API_KEY = config("studypal.ai.apiKey", "STUDYPAL_AI_API_KEY", "");
    public static final String AI_MODEL = config("studypal.ai.model", "STUDYPAL_AI_MODEL", "mimo-v2.5-pro");

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    private static String config(String propertyName, String envName, String defaultValue) {
        String propertyValue = System.getProperty(propertyName);
        if (propertyValue != null && !propertyValue.isBlank()) {
            return propertyValue;
        }
        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.isBlank()) {
            return envValue;
        }
        String localValue = LOCAL_CONFIG.getProperty(propertyName);
        if (localValue != null && !localValue.isBlank()) {
            return localValue;
        }
        return defaultValue;
    }

    private static Properties loadLocalConfig() {
        Properties props = new Properties();
        String customConfigPath = System.getProperty("studypal.config");
        if (customConfigPath != null && !customConfigPath.isBlank()) {
            try (InputStream in = Files.newInputStream(Path.of(customConfigPath))) {
                props.load(in);
                return props;
            } catch (IOException ignored) {}
        }

        try (InputStream in = DBUtils.class.getClassLoader()
                .getResourceAsStream("studypal-local.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (IOException ignored) {}
        return props;
    }

    public static void close(ResultSet rs, Statement st, Connection conn) {
        try {
            if (rs != null) rs.close();
        } catch (SQLException ignored) {}
        try {
            if (st != null) st.close();
        } catch (SQLException ignored) {}
        try {
            if (conn != null) conn.close();
        } catch (SQLException ignored) {}
    }

    public static void close(Statement st, Connection conn) {
        close(null, st, conn);
    }
}
