package com.resumeanalyzer.servlet;

import com.resumeanalyzer.db.DBConnection;
import com.resumeanalyzer.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        int totalScans = 0;
        double averageScore = 0.0;
        String bestRole = "None Yet";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch total scans count
            String totalSql = "SELECT COUNT(*) FROM scan_history WHERE user_id = ?";
            try (PreparedStatement totalStmt = conn.prepareStatement(totalSql)) {
                totalStmt.setInt(1, userId);
                try (ResultSet rs = totalStmt.executeQuery()) {
                    if (rs.next()) {
                        totalScans = rs.getInt(1);
                    }
                }
            }

            if (totalScans > 0) {
                // 2. Fetch average suitability score
                String avgSql = "SELECT AVG(match_score) FROM scan_history WHERE user_id = ?";
                try (PreparedStatement avgStmt = conn.prepareStatement(avgSql)) {
                    avgStmt.setInt(1, userId);
                    try (ResultSet rs = avgStmt.executeQuery()) {
                        if (rs.next()) {
                            averageScore = rs.getDouble(1);
                        }
                    }
                }

                // 3. Fetch role with highest suitability score
                String bestSql = "SELECT job_role FROM scan_history WHERE user_id = ? ORDER BY match_score DESC LIMIT 1";
                try (PreparedStatement bestStmt = conn.prepareStatement(bestSql)) {
                    bestStmt.setInt(1, userId);
                    try (ResultSet rs = bestStmt.executeQuery()) {
                        if (rs.next()) {
                            bestRole = rs.getString("job_role");
                        }
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("Dashboard statistics fetching error: " + e.getMessage());
        }

        // Set statistics attributes for JSP rendering
        request.setAttribute("totalScans", totalScans);
        request.setAttribute("averageScore", Math.round(averageScore));
        request.setAttribute("bestRole", bestRole);

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
