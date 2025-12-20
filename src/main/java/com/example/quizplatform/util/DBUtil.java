package com.example.quizplatform.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    private static final String URL =
            "jdbc:mysql://localhost:3306/quiz_platform?useSSL=false&serverTimezone=UTC";

    private static final String USERNAME = "root";

    // Set this as environment variable DB_PASSWORD
    private static final String PASSWORD = System.getenv("password");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    // Optional test method
    public static void testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("✅ Database connection successful");
        } catch (SQLException e) {
            System.err.println("❌ Database connection failed");
            e.printStackTrace();
        }
    }
}
