<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.resumeanalyzer.model.AnalysisResult" %>
<%@ page import="com.resumeanalyzer.model.User" %>
<%
    // Protected route verification
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    User user = (User) sess.getAttribute("user");

    AnalysisResult result = (AnalysisResult) request.getAttribute("result");
    String jobRole = (String) request.getAttribute("jobRole");
    Boolean isRealAI = (Boolean) request.getAttribute("isRealAI");

    if (result == null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    int score = result.getMatchScore();
    // SVG circular calculations
    int radius = 60;
    double circumference = 2 * Math.PI * radius;
    double offset = circumference - ((double) score / 100) * circumference;

    // Score styling color
    String scoreColorClass = "score-rose";
    String strokeColor = "#f43f5e";
    String matchLabel = "Significant Disparity";
    if (score >= 80) {
        scoreColorClass = "score-emerald";
        strokeColor = "#10b981";
        matchLabel = "Exemplary Match";
    } else if (score >= 50) {
        scoreColorClass = "score-amber";
        strokeColor = "#f59e0b";
        matchLabel = "Satisfactory Match";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessment Results - AI Resume Analyzer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <%-- Global header --%>
    <header class="main-header">
        <div class="header-container">
            <div class="brand">
                <div class="brand-logo">
                    <div class="brand-logo-inner"></div>
                </div>
                <div>
                    <h1>AI Resume Analyzer</h1>
                    <p class="brand-subtitle">Professional Grade</p>
                </div>
            </div>

            <nav class="nav-links">
                <a href="<%= request.getContextPath() %>/dashboard" class="nav-link">Dashboard</a>
                <a href="<%= request.getContextPath() %>/history" class="nav-link">History</a>
            </nav>

            <div class="user-control">
                <div class="server-status">
                    <span class="pulse-dot"></span>Server Active
                </div>
                <div class="user-badge">
                    <div class="avatar"><%= user.getUsername().substring(0, 1).toUpperCase() %></div>
                    <span><%= user.getUsername() %></span>
                </div>
                <a href="<%= request.getContextPath() %>/logout" class="btn-logout">
                    <span>🚪</span> Log Out
                </a>
            </div>
        </div>
    </header>

    <%-- Main Board container --%>
    <main class="main-content">
        <%-- Top navigation and metadata header bar --%>
        <div class="results-utility-bar">
            <a href="<%= request.getContextPath() %>/dashboard" class="btn-back">
                ◀ Grade Another Resume
            </a>
            
            <div class="utility-badges">
                <div class="badge-source">
                    <span>✨</span>
                    <%= isRealAI ? "Gemini-Grade Verified" : "Robust Local Scan Mode" %>
                </div>
                <button type="button" class="btn-print" onclick="window.print()">
                    🖨 Print Assessment
                </button>
            </div>
        </div>

        <%-- Grid layout --%>
        <div class="split-layout">
            <%-- Left side: circular score + contact parsed --%>
            <div class="col-left">
                <%-- Circular Gauge card --%>
                <div class="card p-6 text-center flex-column justify-center mb-6">
                    <span class="gauge-card-title">OVERALL SUITABILITY MATCH</span>
                    
                    <div class="gauge-svg-container">
                        <svg width="176" height="176" viewBox="0 0 176 176" class="gauge-rotate">
                            <circle cx="88" cy="88" r="<%= radius %>" stroke="#f1f5f9" stroke-width="8" fill="transparent" />
                            <circle cx="88" cy="88" r="<%= radius %>" stroke="<%= strokeColor %>" stroke-width="8" 
                                    fill="transparent" stroke-dasharray="<%= circumference %>" stroke-dashoffset="<%= offset %>"
                                    stroke-linecap="round" class="gauge-progress" />
                        </svg>
                        <div class="gauge-text">
                            <span class="gauge-percentage"><%= score %>%</span>
                            <span class="gauge-sub">MATCH GRADE</span>
                        </div>
                    </div>

                    <div class="score-label-container">
                        <span class="score-status-badge <%= scoreColorClass %>"><%= matchLabel %></span>
                    </div>

                    <p class="gauge-card-help">Evaluation is checked relative to the standards for **<%= jobRole %>** based on provided experience keywords.</p>
                </div>

                <%-- Contact Extracted Card --%>
                <div class="card p-6">
                    <span class="section-card-title">PARSED CONTACT DETAILS</span>
                    
                    <div class="contacts-list">
                        <div class="contact-item">
                            <div class="contact-icon">👤</div>
                            <div class="contact-details">
                                <span class="contact-label">Suggested Candidate</span>
                                <p class="contact-value"><%= result.getCandidateName() %></p>
                            </div>
                        </div>

                        <div class="contact-item">
                            <div class="contact-icon">✉</div>
                            <div class="contact-details">
                                <span class="contact-label">Verified Email</span>
                                <p class="contact-value text-truncate"><%= result.getCandidateEmail() %></p>
                            </div>
                        </div>

                        <div class="contact-item">
                            <div class="contact-icon">📞</div>
                            <div class="contact-details">
                                <span class="contact-label">Extracted Telephone</span>
                                <p class="contact-value"><%= result.getCandidatePhone() != null ? result.getCandidatePhone() : "No telephone found" %></p>
                            </div>
                        </div>
                    </div>

                    <div class="contact-help-box">
                        <span>ℹ</span>
                        <p>Extracted contact data is parsed by matching standard regulatory formats using text scanner regex routines.</p>
                    </div>
                </div>
            </div>

            <%-- Right side: skills checklist and AI audits --%>
            <div class="col-right">
                <%-- Skills Tag Matrix card --%>
                <div class="card p-6 mb-6">
                    <div class="card-header-block">
                        <h3 class="flex-align-center">🏆 Target Skills Keyword Ledger</h3>
                        <p>Visualizing matched qualifications parsed from candidate resume text against target metrics.</p>
                    </div>

                    <div class="ledger-columns">
                        <%-- Matched Skills --%>
                        <div class="ledger-col ledger-col-green">
                            <div class="ledger-col-header">
                                <span class="ledger-dot dot-green"></span> Matches Found (<%= result.getMatchedSkills().size() %>)
                            </div>
                            <div class="ledger-tags">
                                <% if (result.getMatchedSkills().isEmpty()) { %>
                                    <p class="ledger-empty">None of the target skills were found.</p>
                                <% } else { %>
                                    <% for (String skill : result.getMatchedSkills()) { %>
                                        <span class="tag-badge badge-matched"><%= skill %></span>
                                    <% } %>
                                <% } %>
                            </div>
                        </div>

                        <%-- Missing Skills --%>
                        <div class="ledger-col ledger-col-red">
                            <div class="ledger-col-header">
                                <span class="ledger-dot dot-red"></span> Missing Target Skills (<%= result.getMissingSkills().size() %>)
                            </div>
                            <div class="ledger-tags">
                                <% if (result.getMissingSkills().isEmpty()) { %>
                                    <span class="tag-badge badge-perfect">Perfect Match! All Found</span>
                                <% } else { %>
                                    <% for (String skill : result.getMissingSkills()) { %>
                                        <span class="tag-badge badge-missing"><%= skill %></span>
                                    <% } %>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Qualitative Audit Card --%>
                <div class="card p-6 mb-6">
                    <div class="card-header-block">
                        <h3 class="flex-align-center">📈 AI Resume Audit Assessment</h3>
                        <p>Strategic audit comments powered by LLM semantics parsing.</p>
                    </div>

                    <div class="audit-blocks-list">
                        <%-- Strengths --%>
                        <% if (result.getStrengths() != null && !result.getStrengths().isEmpty()) { %>
                            <div class="audit-block block-green">
                                <div class="audit-block-header">✓ Identified Resume Strengths</div>
                                <ul>
                                    <% for (String strength : result.getStrengths()) { %>
                                        <li><%= strength %></li>
                                    <% } %>
                                </ul>
                            </div>
                        <% } %>

                        <%-- Gaps --%>
                        <% if (result.getGaps() != null && !result.getGaps().isEmpty()) { %>
                            <div class="audit-block block-orange">
                                <div class="audit-block-header">⚠ Identified Technical Gaps</div>
                                <ul>
                                    <% for (String gap : result.getGaps()) { %>
                                        <li><%= gap %></li>
                                    <% } %>
                                </ul>
                            </div>
                        <% } %>

                        <%-- Recommendations --%>
                        <% if (result.getRecommendations() != null && !result.getRecommendations().isEmpty()) { %>
                            <div class="audit-block block-indigo">
                                <div class="audit-block-header">💡 Smart Actionable Improvements</div>
                                <ul>
                                    <% for (String rec : result.getRecommendations()) { %>
                                        <li><%= rec %></li>
                                    <% } %>
                                </ul>
                            </div>
                        <% } %>
                    </div>
                </div>

                <%-- Summary paragraph card --%>
                <div class="card card-dark p-6 mb-6">
                    <div class="card-header-block dark-header">
                        <span class="dark-mini-title">★ AI EVALUATOR EXECUTIVE SUMMARY</span>
                        <h3 class="mt-1">High-Impact Professional Statement Builder</h3>
                    </div>
                    
                    <p class="summary-paragraph">
                        <%= result.getSummary() %>
                    </p>
                </div>

                <%-- Back to dashboard bottom --%>
                <div class="text-center print-hidden">
                    <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-secondary px-8">
                        Analyze Another Document
                    </a>
                </div>
            </div>
        </div>
    </main>

    <%-- Footer --%>
    <footer class="main-footer">
        <span>Powered by Google Gemini 1.5 Flash</span>
        <span>© 2026 Enterprise Resume Intelligence System</span>
    </footer>
</body>
</html>
