<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.resumeanalyzer.model.User" %>
<%
    // Protection session check
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    User user = (User) sess.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - AI Resume Analyzer</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
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
                <a href="<%= request.getContextPath() %>/dashboard" class="nav-link active">Dashboard</a>
                <a href="<%= request.getContextPath() %>/history" class="nav-link">History</a>
            </nav>

            <div class="user-control">
                <div class="server-status">
                    <span class="pulse-dot"></span>Server Active
                </div>
                <div class="user-badge">
                    <div class="avatar"><%= user.getUsername().substring(0, 1).toUpperCase() %></div>
                    <span><%= user.getUsername() %></span>
                    <span class="user-tier">PRO</span>
                </div>
                <a href="<%= request.getContextPath() %>/logout" class="btn-logout" title="Log Out session">
                    <span>🚪</span> Log Out
                </a>
            </div>
        </div>
    </header>

    <%-- Main container --%>
    <main class="main-content">
        <%-- Top statistics grid --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <span class="stat-label">INDEXED AUDIT LOGS</span>
                    <p class="stat-value"><%= request.getAttribute("totalScans") != null ? request.getAttribute("totalScans") : 0 %></p>
                </div>
                <div class="stat-icon-wrapper icon-blue">📂</div>
            </div>

            <div class="stat-card">
                <div class="stat-info">
                    <span class="stat-label">AVERAGE SUITABILITY</span>
                    <p class="stat-value"><%= request.getAttribute("averageScore") != null ? request.getAttribute("averageScore") : 0 %>%</p>
                </div>
                <div class="stat-icon-wrapper icon-green">📈</div>
            </div>

            <div class="stat-card">
                <div class="stat-info">
                    <span class="stat-label">TOP-SUITED ROLE</span>
                    <p class="stat-value text-truncate"><%= request.getAttribute("bestRole") != null ? request.getAttribute("bestRole") : "None Yet" %></p>
                </div>
                <div class="stat-icon-wrapper icon-orange">💼</div>
            </div>
        </div>

        <%-- Alerts --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error mb-6">
                <strong>Error:</strong> <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <%-- Main split panel --%>
        <form action="<%= request.getContextPath() %>/analyze" method="POST" enctype="multipart/form-data" id="analyze-form" class="split-layout">
            <%-- Left column: Role Setup Matrix --%>
            <div class="col-left">
                <div class="card p-6">
                    <div class="card-header-block">
                        <h3>1. Job Target Matrix</h3>
                        <p>Choose an industry career template to auto-fill the standard skill target checklist.</p>
                    </div>

                    <div class="form-group mb-5">
                        <label for="jobRoleSelect">Targeted Professional Role</label>
                        <select name="jobRole" id="jobRoleSelect" class="form-select" onchange="loadPresetSkills()">
                            <!-- 20 Roles -->
                            <option value="Java Full-Stack Developer">Java Full-Stack Developer</option>
                            <option value="Frontend Developer">Frontend Developer</option>
                            <option value="Data Scientist">Data Scientist</option>
                            <option value="Machine Learning Engineer">Machine Learning Engineer</option>
                            <option value="DevOps Engineer">DevOps Engineer</option>
                            <option value="Cybersecurity Analyst">Cybersecurity Analyst</option>
                            <option value="Mobile App Developer (Android)">Mobile App Developer (Android)</option>
                            <option value="Mobile App Developer (iOS)">Mobile App Developer (iOS)</option>
                            <option value="UI/UX Designer">UI/UX Designer</option>
                            <option value="Product Manager">Product Manager</option>
                            <option value="Business Analyst">Business Analyst</option>
                            <option value="Data Engineer">Data Engineer</option>
                            <option value="Cloud Architect (AWS)">Cloud Architect (AWS)</option>
                            <option value="Cloud Architect (Azure)">Cloud Architect (Azure)</option>
                            <option value="QA Automation Engineer">QA Automation Engineer</option>
                            <option value="Database Administrator">Database Administrator</option>
                            <option value="Embedded Systems Engineer">Embedded Systems Engineer</option>
                            <option value="HR & Talent Recruiter">HR & Talent Recruiter</option>
                            <option value="Digital Marketing Specialist">Digital Marketing Specialist</option>
                            <option value="Salesforce Administrator">Salesforce Administrator</option>
                        </select>
                    </div>

                    <%-- Skills keywords tags --%>
                    <div class="skills-block mb-4">
                        <div class="skills-block-header">
                            <label>Target Evaluation Keywords</label>
                            <button type="button" class="btn-text" onclick="restoreDefaultSkills()">↻ Prepopulate Default</button>
                        </div>

                        <%-- Hidden input to store comma-separated skills for servlet --%>
                        <input type="hidden" name="targetSkills" id="skillsHiddenInput">

                        <div class="skills-tag-container" id="skillsTagContainer">
                            <%-- Filled via JS --%>
                        </div>
                    </div>

                    <%-- Add custom keyword --%>
                    <div class="add-skill-bar">
                        <input type="text" id="customSkillInput" placeholder="Add custom keyword (e.g., AWS, Spring Boot)..." onkeydown="handleSkillKeydown(event)">
                        <button type="button" class="btn-dark" onclick="addCustomSkill()">+</button>
                    </div>
                </div>
            </div>

            <%-- Right column: Document Ingestion --%>
            <div class="col-right">
                <div class="card p-6 flex-column justify-between h-full">
                    <div>
                        <div class="flex justify-between items-center mb-5">
                            <div class="card-header-block">
                                <h3>2. Document Ingestion</h3>
                                <p>Upload candidate file or copy raw text content for matching.</p>
                            </div>

                            <%-- Toggle file or paste --%>
                            <div class="toggle-switch">
                                <input type="hidden" name="useTextPaste" id="useTextPasteInput" value="false">
                                <button type="button" id="toggleFileBtn" class="toggle-btn active" onclick="setIngestionMode(false)">📁 PDF File</button>
                                <button type="button" id="togglePasteBtn" class="toggle-btn" onclick="setIngestionMode(true)">✍ Copy-Paste</button>
                            </div>
                        </div>

                        <%-- Ingestion Modes --%>
                        <div id="fileUploadContainer" class="dropzone-area" onclick="triggerFileSelect()">
                            <input type="file" name="resumeFile" id="resumeFileInput" accept="application/pdf" style="display: none;" onchange="handleFileSelected(event)">
                            <div id="dropzoneContent">
                                <div class="dropzone-icon">📤</div>
                                <p class="dropzone-text-blue">Click to upload candidate resume</p>
                                <p class="dropzone-text-gray">or drag and drop PDF file here (Max size 10MB)</p>
                            </div>
                            <div id="fileInfoContent" class="file-info-box" style="display: none;">
                                <div class="file-icon">📄</div>
                                <p class="file-name" id="selectedFileName">resume.pdf</p>
                                <p class="file-meta" id="selectedFileSize">0.0 MB • File Ready</p>
                                <button type="button" class="btn-remove" onclick="removeSelectedFile(event)">Remove File</button>
                            </div>
                        </div>

                        <div id="textPasteContainer" class="paste-area-box" style="display: none;">
                            <label for="resumeTextarea" class="sr-only">Paste Resume Text</label>
                            <textarea name="resumeText" id="resumeTextarea" rows="10" placeholder="Paste your qualifications detail, bio, skills, professional work experience, and educational background directly..."></textarea>
                            <p class="textarea-help">Formatting and layout spacing are parsed automatically.</p>
                        </div>
                    </div>

                    <%-- Run Analysis --%>
                    <div class="mt-6">
                        <button type="submit" class="btn btn-primary btn-full btn-lg" onclick="showLoader()">
                            <span>✨</span> Run AI Analysis
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </main>

    <%-- Processing Loader Overlay --%>
    <div id="loadingOverlay" class="loading-overlay" style="display: none;">
        <div class="loader-box">
            <div class="spinner"></div>
            <h3 class="mt-4">AI Recruiter Evaluation in Progress</h3>
            <p>Parsing file layers, extracting verified contacts, checking matches against target skill taxonomies, and generating professional improvement directions...</p>
            <div class="badge-mono">🔒 Secure Session Verification</div>
        </div>
    </div>

    <%-- Footer --%>
    <footer class="main-footer">
        <span>Powered by Google Gemini 1.5 Flash</span>
        <span>© 2026 Enterprise Resume Intelligence System</span>
    </footer>

    <%-- Presets and Interactive tags javascript --%>
    <script>
        // Preset Skills configuration dictionary
        const PRESETS = {
            "Java Full-Stack Developer": ["Java 17", "Jakarta EE", "Spring Boot", "MySQL", "Maven", "Tomcat", "RESTful APIs", "Hibernate", "JSP", "JUnit"],
            "Frontend Developer": ["HTML5", "CSS3", "JavaScript", "React", "TypeScript", "Vue.js", "Webpack", "Tailwind CSS", "Responsive Design", "Git"],
            "Data Scientist": ["Python", "R", "SQL", "Pandas", "NumPy", "Scikit-Learn", "TensorFlow", "Machine Learning", "Tableau", "Statistics"],
            "Machine Learning Engineer": ["Python", "PyTorch", "TensorFlow", "NLP", "Computer Vision", "Scikit-Learn", "Docker", "Kubernetes", "Model Deployment", "Git"],
            "DevOps Engineer": ["AWS", "Docker", "Kubernetes", "Jenkins", "Terraform", "Linux", "CI/CD", "Nginx", "Bash Scripting", "Prometheus"],
            "Cybersecurity Analyst": ["TCP/IP", "Wireshark", "OWASP Top 10", "Firewalls", "Penetration Testing", "Nessus", "Splunk", "SIEM", "Linux", "Cryptography"],
            "Mobile App Developer (Android)": ["Kotlin", "Java", "Android SDK", "Jetpack Compose", "Retrofit", "Coroutines", "Room Database", "SQLite", "Git", "Google Play"],
            "Mobile App Developer (iOS)": ["Swift", "SwiftUI", "Objective-C", "Cocoa Touch", "Xcode", "CoreData", "RESTful APIs", "Git", "iOS Guidelines", "App Store"],
            "UI/UX Designer": ["Figma", "User Research", "Wireframing", "Interactive Prototyping", "Visual Hierarchy", "Typography", "Design Systems", "Information Architecture", "Adobe Suite"],
            "Product Manager": ["Agile & Scrum", "Product Strategy", "JIRA", "Confluence", "User Stories", "Roadmapping", "Stakeholder Management", "A/B Testing", "Mixpanel"],
            "Business Analyst": ["Requirements Gathering", "UML Diagrams", "SQL", "User Story Mapping", "Jira", "Process Flowcharts", "Advanced Excel", "Tableau"],
            "Data Engineer": ["Apache Spark", "Python", "SQL", "Airflow", "ETL Pipelines", "BigQuery", "Kafka", "Data Modeling", "Hadoop", "Docker"],
            "Cloud Architect (AWS)": ["AWS", "EC2", "S3", "RDS", "CloudFormation", "IAM", "VPC", "Serverless", "Docker"],
            "Cloud Architect (Azure)": ["Azure", "VMs", "Blob Storage", "Azure SQL", "ARM Templates", "Active Directory", "AKS", "Docker", "CI/CD"],
            "QA Automation Engineer": ["Selenium WebDriver", "Cypress", "Java", "Python", "JUnit", "TestNG", "API Testing", "Postman", "Jenkins", "CI/CD"],
            "Database Administrator": ["MySQL", "PostgreSQL", "Oracle DB", "SQL Queries", "Performance Tuning", "Backup & Recovery", "Indexing", "Database Replication", "Security Auditing"],
            "Embedded Systems Engineer": ["C", "C++", "Microcontrollers", "ARM Architecture", "RTOS", "GPIO", "SPI", "I2C", "Device Drivers", "Oscilloscopes"],
            "HR & Talent Recruiter": ["Applicant Tracking Systems (ATS)", "Technical Sourcing", "LinkedIn Recruiter", "Interview Coaching", "Employee Relations", "HR Compliance"],
            "Digital Marketing Specialist": ["Google Analytics", "SEO", "SEM", "Facebook Ads", "Copywriting", "Email Marketing", "Content Strategy", "A/B Testing"],
            "Salesforce Administrator": ["Salesforce CRM", "Flows", "Apex", "SOQL", "Data Security", "Report Builder", "AppExchange", "Service Cloud"]
        };

        let activeSkills = [];

        window.onload = function() {
            // Pre-load default role skills
            loadPresetSkills();
            
            // Drag and drop handlers
            const dropzone = document.getElementById("fileUploadContainer");
            
            ["dragenter", "dragover"].forEach(eventName => {
                dropzone.addEventListener(eventName, highlight, false);
            });

            ["dragleave", "drop"].forEach(eventName => {
                dropzone.addEventListener(eventName, unhighlight, false);
            });

            function highlight(e) {
                e.preventDefault();
                dropzone.classList.add("dragover");
            }

            function unhighlight(e) {
                e.preventDefault();
                dropzone.classList.remove("dragover");
            }

            dropzone.addEventListener("drop", handleDrop, false);

            function handleDrop(e) {
                e.preventDefault();
                const dt = e.dataTransfer;
                const files = dt.files;
                if (files.length > 0) {
                    document.getElementById("resumeFileInput").files = files;
                    updateFileLabel(files[0]);
                }
            }
        };

        function loadPresetSkills() {
            const role = document.getElementById("jobRoleSelect").value;
            activeSkills = [...(PRESETS[role] || [])];
            renderSkillsTags();
        }

        function restoreDefaultSkills() {
            loadPresetSkills();
        }

        function renderSkillsTags() {
            const container = document.getElementById("skillsTagContainer");
            container.innerHTML = "";
            
            activeSkills.forEach((skill, index) => {
                const tag = document.createElement("span");
                tag.className = "skill-badge";
                tag.innerHTML = skill + ` <button type="button" onclick="removeSkill(${index})">×</button>`;
                container.appendChild(tag);
            });

            // Update hidden input string
            document.getElementById("skillsHiddenInput").value = activeSkills.join(",");
        }

        function removeSkill(index) {
            activeSkills.splice(index, 1);
            renderSkillsTags();
        }

        function addCustomSkill() {
            const input = document.getElementById("customSkillInput");
            const value = input.value.trim();
            if (value && !activeSkills.some(s => s.toLowerCase() === value.toLowerCase())) {
                activeSkills.push(value);
                renderSkillsTags();
                input.value = "";
            }
        }

        function handleSkillKeydown(e) {
            if (e.key === "Enter") {
                e.preventDefault();
                addCustomSkill();
            }
        }

        function setIngestionMode(isPaste) {
            document.getElementById("useTextPasteInput").value = isPaste ? "true" : "false";
            
            if (isPaste) {
                document.getElementById("togglePasteBtn").classList.add("active");
                document.getElementById("toggleFileBtn").classList.remove("active");
                document.getElementById("textPasteContainer").style.display = "block";
                document.getElementById("fileUploadContainer").style.display = "none";
            } else {
                document.getElementById("toggleFileBtn").classList.add("active");
                document.getElementById("togglePasteBtn").classList.remove("active");
                document.getElementById("fileUploadContainer").style.display = "flex";
                document.getElementById("textPasteContainer").style.display = "none";
            }
        }

        function triggerFileSelect() {
            const fileInput = document.getElementById("resumeFileInput");
            // Only trigger if no file has been selected (or if user clicks on the vacant area)
            if (fileInput.files.length === 0) {
                fileInput.click();
            }
        }

        function handleFileSelected(e) {
            const file = e.target.files[0];
            if (file) {
                updateFileLabel(file);
            }
        }

        function updateFileLabel(file) {
            if (file.type !== "application/pdf" && !file.name.endsWith(".pdf")) {
                alert("Only PDF files are supported!");
                document.getElementById("resumeFileInput").value = "";
                return;
            }
            
            document.getElementById("dropzoneContent").style.display = "none";
            document.getElementById("fileInfoContent").style.display = "block";
            
            document.getElementById("selectedFileName").innerText = file.name;
            document.getElementById("selectedFileSize").innerText = (file.size / (1024 * 1024)).toFixed(2) + " MB • File Ready";
        }

        function removeSelectedFile(e) {
            e.stopPropagation();
            document.getElementById("resumeFileInput").value = "";
            document.getElementById("dropzoneContent").style.display = "block";
            document.getElementById("fileInfoContent").style.display = "none";
        }

        function showLoader() {
            const usePaste = document.getElementById("useTextPasteInput").value === "true";
            const textarea = document.getElementById("resumeTextarea").value.trim();
            const file = document.getElementById("resumeFileInput").files.length > 0;
            
            if (usePaste && !textarea) return;
            if (!usePaste && !file) return;
            if (activeSkills.length === 0) return;

            document.getElementById("loadingOverlay").style.display = "flex";
        }
    </script>
</body>
</html>
