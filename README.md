# AI Resume Analyzer

An intelligent ATS-based Resume Analysis Web Application built using Java Web Technologies. The system allows users to upload resumes in PDF format, extract content automatically, analyze skills against job requirements, and maintain historical analysis records.

---

## Features

* User Registration & Login Authentication
* Secure Session Management
* Resume PDF Upload
* PDF Text Extraction using Apache PDFBox
* ATS-Based Resume Analysis
* Skill Matching & Missing Skill Detection
* Resume Analysis History Tracking
* MySQL Database Integration
* Responsive Web Interface
* Maven-Based Build Management
* Deployment on Apache Tomcat

---

## Technology Stack

### Frontend

* JSP (JavaServer Pages)
* HTML5
* CSS3
* JavaScript

### Backend

* Java Servlets
* JDBC (Java Database Connectivity)

### Database

* MySQL 8+

### Server

* Apache Tomcat 10+

### Build Tool

* Maven

### Libraries

* Apache PDFBox
* MySQL Connector/J
* Jakarta Servlet API

---

## Project Architecture

MVC (Model-View-Controller) Architecture

```text
User
 ↓
JSP Pages (View)
 ↓
Servlets (Controller)
 ↓
JDBC Layer
 ↓
MySQL Database (Model)
 ↓
Response
 ↓
JSP Pages
```

---

## Modules

### User Management

* User Registration
* User Login
* Session Handling
* Logout Functionality

### Resume Analysis

* Resume Upload
* PDF Parsing
* Text Extraction
* ATS Score Calculation
* Skill Extraction
* Resume Evaluation

### History Management

* Store Previous Analyses
* View Analysis History
* Retrieve Historical Results

---

## Database Schema

### users

| Column     | Type      |
| ---------- | --------- |
| id         | INT       |
| username   | VARCHAR   |
| email      | VARCHAR   |
| password   | VARCHAR   |
| created_at | TIMESTAMP |

### scan_history

| Column          | Type      |
| --------------- | --------- |
| id              | INT       |
| user_id         | INT       |
| filename        | VARCHAR   |
| analysis_result | TEXT      |
| created_at      | TIMESTAMP |

---

## JDBC Workflow

The application follows the standard JDBC process:

1. Import JDBC Packages
2. Load JDBC Driver
3. Establish Database Connection
4. Create Statement / PreparedStatement
5. Execute SQL Query
6. Process Results
7. Close Database Resources

---

## Project Structure

```text
resume-analyzer/
│
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── servlet/
│   │   │   ├── service/
│   │   │   ├── config/
│   │   │   └── model/
│   │
│   │   ├── webapp/
│   │   │   ├── login.jsp
│   │   │   ├── register.jsp
│   │   │   ├── dashboard.jsp
│   │   │   ├── result.jsp
│   │   │   └── history.jsp
│
├── pom.xml
│
└── target/
    └── resume-analyzer.war
```

---

## Installation & Setup

### Prerequisites

* Java JDK 17+
* Maven 3+
* MySQL 8+
* Apache Tomcat 10+

### Clone Repository

```bash
git clone https://github.com/yourusername/ai-resume-analyzer.git
```

### Configure Database

Create database:

```sql
CREATE DATABASE resume_analyzer;
```

Create application user:

```sql
CREATE USER 'resume_user'@'localhost'
IDENTIFIED BY 'resume123';

GRANT ALL PRIVILEGES
ON resume_analyzer.*
TO 'resume_user'@'localhost';

FLUSH PRIVILEGES;
```

### Build Project

```bash
mvn clean package
```

### Deploy Application

Copy generated WAR file:

```text
target/resume-analyzer.war
```

to:

```text
TOMCAT_HOME/webapps/
```

Start Tomcat:

```bash
startup.bat
```

Open:

```text
http://localhost:8080/resume-analyzer/
```

---

## Future Enhancements

* Spring Boot Migration
* BCrypt Password Encryption
* JWT Authentication
* AI Interview Question Generator
* Docker Deployment
* Cloud Hosting
* Admin Dashboard
* Resume Keyword Heatmap
* Email Notifications

---

## Learning Outcomes

This project demonstrates practical implementation of:

* Java Web Development
* JSP & Servlets
* MVC Architecture
* JDBC Connectivity
* MySQL Database Design
* File Upload Handling
* PDF Processing
* Session Management
* Apache Tomcat Deployment
* Maven Build Automation

---

## Author

Aayush Mishra

AI Resume Analyzer – Full Stack Java Web Application

---

## License

This project is developed for educational and learning purposes.
