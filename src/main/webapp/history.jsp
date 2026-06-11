<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.resumeanalyzer.model.ScanResult" %>
<%@ page import="com.resumeanalyzer.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Protected check
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    User user = (User) sess.getAttribute("user");

    List<ScanResult> scanList = (List<ScanResult>) request.getAttribute("scanList");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d, yyyy - hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historical Scans - AI Resume Analyzer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
    <%-- Global Header --%>
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
                <a href="<%= request.getContextPath() %>/history" class="nav-link active">History</a>
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

    <%-- Main container board --%>
    <main class="main-content">
        <div class="card p-6">
            <div class="history-page-header">
                <div>
                    <h3 class="flex-align-center">📂 Historical Resume Audits</h3>
                    <p>Access previous assessments and corresponding score cards registered under this profile.</p>
                </div>
                <span class="history-counter-badge">
                    Scans: <%= scanList != null ? scanList.size() : 0 %>
                </span>
            </div>

            <% if (scanList == null || scanList.isEmpty()) { %>
                <div class="empty-history-box">
                    <div class="empty-icon">📄</div>
                    <h4>No evaluations registered</h4>
                    <p>Upload and grade a resume in the dashboard panel to begin logging assessment records.</p>
                    <div class="mt-4">
                        <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-primary px-6">
                            Go to Dashboard
                        </a>
                    </div>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="history-table">
                        <thead>
                            <tr>
                                <th>Date Audited</th>
                                <th>Candidate & Role</th>
                                <th class="text-center">Match Grade</th>
                                <th class="text-center">Database Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (ScanResult scan : scanList) { 
                                String dateStr = scan.getScannedAt() != null ? dateFormat.format(scan.getScannedAt()) : "Unknown";
                                double score = scan.getMatchScore();
                                String scoreClass = "score-rose";
                                if (score >= 80) {
                                    scoreClass = "score-emerald";
                                } else if (score >= 50) {
                                    scoreClass = "score-amber";
                                }
                            %>
                                <tr>
                                    <td class="col-date">
                                        <span class="calendar-icon">📅</span> <%= dateStr %>
                                    </td>
                                    
                                    <td class="col-candidate">
                                        <div class="candidate-block">
                                            <span class="candidate-name">👤 <%= scan.getCandidateName() %></span>
                                            <span class="candidate-email"><%= scan.getCandidateEmail() %></span>
                                            <span class="candidate-role">Applied Role: <strong><%= scan.getJobRole() %></strong></span>
                                        </div>
                                    </td>
                                    
                                    <td class="col-score text-center">
                                        <span class="match-badge <%= scoreClass %>">
                                            <%= Math.round(score) %>% Match
                                        </span>
                                    </td>
                                    
                                    <td class="col-actions text-center">
                                        <a href="<%= request.getContextPath() %>/history?action=delete&id=<%= scan.getId() %>" 
                                           class="btn-delete-row"
                                           onclick="return confirm('Are you sure you want to delete this resume evaluation from your local audit ledger?')">
                                            🗑 Delete
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </main>

    <%-- Footer --%>
    <footer class="main-footer">
        <span>Powered by Google Gemini 1.5 Flash</span>
        <span>© 2026 Enterprise Resume Intelligence System</span>
    </footer>
</body>
</html>
