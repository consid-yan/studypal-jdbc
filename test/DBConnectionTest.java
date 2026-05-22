package com.studypal.test;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnectionTest {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/studypal?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        String user = "root"; // 替换为你的用户名
        String password = "1234"; // 替换为你的密码

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            System.out.println("✅ 数据库连接成功！");
            conn.close();
        } catch (Exception e) {
            System.out.println("❌ 数据库连接失败：");
            e.printStackTrace();
        }
    }
}