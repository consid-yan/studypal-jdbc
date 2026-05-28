package com.studypal.util;

import java.sql.*;

public class DBUtils {

    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/studypal_db?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    // AI API 配置（由用户填写）
    public static final String AI_API_URL = "https://token-plan-ams.xiaomimimo.com/v1";
    public static final String AI_API_KEY = "tp-eup9lsxegea2l09kb7xo0yrtidcli6aub99m9skan3beq35v";
    public static final String AI_MODEL = "mimo-v2.5-pro";

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
