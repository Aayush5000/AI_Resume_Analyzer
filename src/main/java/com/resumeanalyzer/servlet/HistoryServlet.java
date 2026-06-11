package com.resumeanalyzer.servlet;

import com.resumeanalyzer.db.DBConnection;
import com.resumeanalyzer.model.ScanResult;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/history")
public class HistoryServlet extends HttpServlet {

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

        // Check for simulated DELETE operation via GET parameter action
        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        
        if ("delete".equalsIgnoreCase(action) && idStr != null) {
            try {
                int scanId = Integer.parseInt(idStr);
                deleteScan(scanId, userId);
                response.sendRedirect(request.getContextPath() + "/history");
                return;
            } catch (NumberFormatException e) {
                System.err.println("Invalid scan ID for deletion: " + idStr);
            }
        }

        List<ScanResult> scanList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM scan_history WHERE user_id = ? ORDER BY scanned_at DESC";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        ScanResult scan = new ScanResult();
                        scan.setId(rs.getInt("id"));
                        scan.setUserId(rs.getInt("user_id"));
                        scan.setJobRole(rs.getString("job_role"));
                        scan.setMatchScore(rs.getDouble("match_score"));
                        scan.setCandidateName(rs.getString("candidate_name"));
                        scan.setCandidateEmail(rs.getString("candidate_email"));
                        scan.setMatchedSkills(rs.getString("matched_skills"));
                        scan.setMissingSkills(rs.getString("missing_skills"));
                        scan.setAiSummary(rs.getString("ai_summary"));
                        scan.setScannedAt(rs.getTimestamp("scanned_at"));
                        
                        scanList.add(scan);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Database error retrieving history scans: " + e.getMessage());
            request.setAttribute("error", "Failed to retrieve historical assessments.");
        }

        request.setAttribute("scanList", scanList);
        request.getRequestDispatcher("/history.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void deleteScan(int scanId, int userId) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "DELETE FROM scan_history WHERE id = ? AND user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, scanId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
                System.out.println("Deleted scan record ID " + scanId + " successfully.");
            }
        } catch (SQLException e) {
            System.err.println("Failed to delete scan record: " + e.getMessage());
        }
    }
}
