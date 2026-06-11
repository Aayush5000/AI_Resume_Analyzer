package com.resumeanalyzer.servlet;

import com.resumeanalyzer.db.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Render register registration form JSP
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (username == null || email == null || password == null || 
            username.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Check username uniqueness
            String checkSql = "SELECT id FROM users WHERE username = ? OR email = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, username);
                checkStmt.setString(2, email);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("error", "Username or email is already registered.");
                        request.getRequestDispatcher("/register.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // Insert new user
            String insertSql = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setString(1, username.trim());
                insertStmt.setString(2, email.trim().toLowerCase());
                insertStmt.setString(3, password); // Storing plain text password as per simple auth rule
                insertStmt.executeUpdate();
            }

            // Redirect to login with success message
            request.setAttribute("success", "Registration successful! Please log in.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("Registration failed: " + e.getMessage());
            request.setAttribute("error", "Internal server error. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
