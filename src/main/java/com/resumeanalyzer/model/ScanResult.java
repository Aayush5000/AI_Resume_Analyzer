package com.resumeanalyzer.model;

import java.sql.Timestamp;

public class ScanResult {
    private int id;
    private int userId;
    private String jobRole;
    private double matchScore;
    private String candidateName;
    private String candidateEmail;
    private String matchedSkills;
    private String missingSkills;
    private String aiSummary;
    private Timestamp scannedAt;

    public ScanResult() {}

    public ScanResult(int id, int userId, String jobRole, double matchScore, String candidateName, 
                      String candidateEmail, String matchedSkills, String missingSkills, 
                      String aiSummary, Timestamp scannedAt) {
        this.id = id;
        this.userId = userId;
        this.jobRole = jobRole;
        this.matchScore = matchScore;
        this.candidateName = candidateName;
        this.candidateEmail = candidateEmail;
        this.matchedSkills = matchedSkills;
        this.missingSkills = missingSkills;
        this.aiSummary = aiSummary;
        this.scannedAt = scannedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getJobRole() {
        return jobRole;
    }

    public void setJobRole(String jobRole) {
        this.jobRole = jobRole;
    }

    public double getMatchScore() {
        return matchScore;
    }

    public void setMatchScore(double matchScore) {
        this.matchScore = matchScore;
    }

    public String getCandidateName() {
        return candidateName;
    }

    public void setCandidateName(String candidateName) {
        this.candidateName = candidateName;
    }

    public String getCandidateEmail() {
        return candidateEmail;
    }

    public void setCandidateEmail(String candidateEmail) {
        this.candidateEmail = candidateEmail;
    }

    public String getMatchedSkills() {
        return matchedSkills;
    }

    public void setMatchedSkills(String matchedSkills) {
        this.matchedSkills = matchedSkills;
    }

    public String getMissingSkills() {
        return missingSkills;
    }

    public void setMissingSkills(String missingSkills) {
        this.missingSkills = missingSkills;
    }

    public String getAiSummary() {
        return aiSummary;
    }

    public void setAiSummary(String aiSummary) {
        this.aiSummary = aiSummary;
    }

    public Timestamp getScannedAt() {
        return scannedAt;
    }

    public void setScannedAt(Timestamp scannedAt) {
        this.scannedAt = scannedAt;
    }
}
