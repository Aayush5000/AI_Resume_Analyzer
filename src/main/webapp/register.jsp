<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - AI Resume Analyzer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="auth-body">
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <div class="brand-badge text-uppercase">CREATE WORKSPACE</div>
                <h2>Register Profile</h2>
                <p>Set up your professional credentials to begin scanning PDF resumes against fine-grained skills targets.</p>
            </div>
            
            <div class="auth-body-content">
                <%-- Error Banner --%>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-error">
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/register" method="POST" id="auth-form">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <div class="input-wrapper">
                            <span class="input-icon">👤</span>
                            <input type="text" id="username" name="username" placeholder="Choose a username" required autocomplete="username">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <div class="input-wrapper">
                            <span class="input-icon">✉</span>
                            <input type="email" id="email" name="email" placeholder="name@company.com" required autocomplete="email">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">Password</label>
                        <div class="input-wrapper">
                            <span class="input-icon">🔒</span>
                            <input type="password" id="password" name="password" placeholder="••••••••" required autocomplete="new-password">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-full">
                        Register Profile <span>➔</span>
                    </button>
                </form>

                <div class="auth-toggle">
                    <p>Already have an account? <a href="<%= request.getContextPath() %>/login">Sign In</a></p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
