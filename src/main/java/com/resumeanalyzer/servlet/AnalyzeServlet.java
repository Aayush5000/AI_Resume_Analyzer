package com.resumeanalyzer.servlet;

import com.resumeanalyzer.db.DBConnection;
import com.resumeanalyzer.model.AnalysisResult;
import com.resumeanalyzer.model.User;
import com.resumeanalyzer.service.AnalysisService;
import com.resumeanalyzer.service.GeminiService;
import com.resumeanalyzer.service.PDFService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet("/analyze")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB threshold
        maxFileSize = 1024 * 1024 * 10,       // 10MB max file size
        maxRequestSize = 1024 * 1024 * 50     // 50MB max request size
)
public class AnalyzeServlet extends HttpServlet {

    private final PDFService pdfService;
    private final GeminiService geminiService;
    private final AnalysisService analysisService;

    public AnalyzeServlet() {
        this.pdfService = new PDFService();
        this.geminiService = new GeminiService();
        this.analysisService = new AnalysisService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        // 1. Read string parameters
        String jobRole = request.getParameter("jobRole");
        String skillsInput = request.getParameter("targetSkills");
        String resumeText = request.getParameter("resumeText");
        String useTextPasteStr = request.getParameter("useTextPaste");
        boolean useTextPaste = "true".equalsIgnoreCase(useTextPasteStr);

        if (jobRole == null || jobRole.trim().isEmpty()) {
            jobRole = "Custom Candidate Matching";
        }

        List<String> targetSkills = new ArrayList<>();
        if (skillsInput != null && !skillsInput.trim().isEmpty()) {
            String[] split = skillsInput.split(",");
            for (String s : split) {
                if (!s.trim().isEmpty()) {
                    targetSkills.add(s.trim());
                }
            }
        }

        // 2. Extract resume text from PDF OR Copy Paste
        String parsedResumeText = "";
        
        if (useTextPaste) {
            if (resumeText != null) {
                parsedResumeText = resumeText.trim();
            }
        } else {
            try {
                Part filePart = request.getPart("resumeFile");
                if (filePart != null && filePart.getSize() > 0) {
                    try (InputStream is = filePart.getInputStream()) {
                        parsedResumeText = pdfService.extractText(is);
                    }
                }
            } catch (Exception e) {
                request.setAttribute("error", "Failed to extract text from PDF: " + e.getMessage());
                request.getRequestDispatcher("/dashboard").forward(request, response);
                return;
            }
        }

        if (parsedResumeText.isEmpty()) {
            request.setAttribute("error", "No resume content detected. Please upload a readable PDF or paste text.");
            request.getRequestDispatcher("/dashboard").forward(request, response);
            return;
        }

        if (targetSkills.isEmpty()) {
            request.setAttribute("error", "Please configure at least one target skill evaluation tag.");
            request.getRequestDispatcher("/dashboard").forward(request, response);
            return;
        }

        // 3. Process analysis using Gemini with graceful local matching fallback
        AnalysisResult analysisResult = null;
        boolean isRealAI = false;

        try {
            // Attempt Gemini API Connection
            analysisResult = geminiService.analyze(parsedResumeText, jobRole, targetSkills);
            isRealAI = true;
        } catch (Exception e) {
            System.err.println("Gemini analysis encountered an issue. Transitioning to local evaluation: " + e.getMessage());
            // Safe fallback local evaluation
            analysisResult = analysisService.analyzeLocally(parsedResumeText, jobRole, targetSkills);
            isRealAI = false;
        }

        // 4. Save results in MySQL database
        try (Connection conn = DBConnection.getConnection()) {
            String insertSql = "INSERT INTO scan_history ("
                    + "user_id, job_role, match_score, candidate_name, candidate_email, "
                    + "matched_skills, missing_skills, ai_summary"
                    + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                stmt.setInt(1, userId);
                stmt.setString(2, jobRole);
                stmt.setDouble(3, analysisResult.getMatchScore());
                stmt.setString(4, analysisResult.getCandidateName());
                stmt.setString(5, analysisResult.getCandidateEmail());
                stmt.setString(6, String.join(",", analysisResult.getMatchedSkills()));
                stmt.setString(7, String.join(",", analysisResult.getMissingSkills()));
                stmt.setString(8, analysisResult.getSummary());
                
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            System.err.println("Failed to log scan results to database: " + e.getMessage());
        }

        // Pass variables to view
        request.setAttribute("result", analysisResult);
        request.setAttribute("jobRole", jobRole);
        request.setAttribute("isRealAI", isRealAI);

        request.getRequestDispatcher("/result.jsp").forward(request, response);
    }
}
