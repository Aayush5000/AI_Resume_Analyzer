<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - AI Resume Analyzer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="auth-body">
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <div class="brand-badge">SECURE SESSION</div>
                <h2>AI Resume Analyzer</h2>
                <p>Standard Enterprise Matcher. Check resume scores, parse custom qualifications, and receive tailored AI improvements.</p>
            </div>
            
            <div class="auth-body-content">
                <%-- Error and Success Alert Banners --%>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-error">
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success">
                        <%= request.getAttribute("success") %>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/login" method="POST" id="auth-form">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <div class="input-wrapper">
                            <span class="input-icon">👤</span>
                            <input type="text" id="username" name="username" placeholder="Enter your username" required autocomplete="username">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <div class="input-wrapper">
                            <span class="input-icon">🔒</span>
                            <input type="password" id="password" name="password" placeholder="••••••••" required autocomplete="current-password">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-full">
                        Log In <span>➔</span>
                    </button>
                </form>

                <div class="auth-toggle">
                    <p>Need a workspace account? <a href="<%= request.getContextPath() %>/register">Register</a></p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
