package com.resumeanalyzer.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {
    private static final String SERVER_URL = "jdbc:mysql://localhost:3306/?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String DB_URL = "jdbc:mysql://localhost:3306/resume_analyzer?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "resume_user";
    private static final String PASS = "resume123";

    static {
        try {
            // Load MySQL Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            initializeDatabase();
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver class not found: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, USER, PASS);
    }

    private static void initializeDatabase() {
        System.out.println("Initializing MySQL Database and Schema...");
        try (Connection conn = DriverManager.getConnection(SERVER_URL, USER, PASS);
                Statement stmt = conn.createStatement()) {

            // Create database
            stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS resume_analyzer");

            // Select database
            stmt.executeUpdate("USE resume_analyzer");

            // Create users table
            String createUsersTable = "CREATE TABLE IF NOT EXISTS users ("
                    + "id INT PRIMARY KEY AUTO_INCREMENT, "
                    + "username VARCHAR(100) UNIQUE NOT NULL, "
                    + "email VARCHAR(150) UNIQUE NOT NULL, "
                    + "password VARCHAR(255) NOT NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
            stmt.executeUpdate(createUsersTable);

            // Create scan_history table
            String createScanHistoryTable = "CREATE TABLE IF NOT EXISTS scan_history ("
                    + "id INT PRIMARY KEY AUTO_INCREMENT, "
                    + "user_id INT NOT NULL, "
                    + "job_role VARCHAR(200), "
                    + "match_score DOUBLE, "
                    + "candidate_name VARCHAR(200), "
                    + "candidate_email VARCHAR(200), "
                    + "matched_skills TEXT, "
                    + "missing_skills TEXT, "
                    + "ai_summary TEXT, "
                    + "scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
            stmt.executeUpdate(createScanHistoryTable);

            System.out.println("Database and schema initialized successfully!");
        } catch (SQLException e) {
            System.err.println("Failed to initialize database: " + e.getMessage());
        }
    }
}
