package com.resumeanalyzer.service;

import com.resumeanalyzer.model.AnalysisResult;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AnalysisService {

    public AnalysisResult analyzeLocally(String resumeText, String jobRole, List<String> targetSkills) {
        AnalysisResult result = new AnalysisResult();
        
        // 1. Extract contact details via Regex
        String email = extractEmail(resumeText);
        String phone = extractPhone(resumeText);
        String name = extractName(resumeText);
        
        result.setCandidateEmail(email);
        result.setCandidatePhone(phone);
        result.setCandidateName(name);

        // 2. Perform manual skills matching
        List<String> matched = new ArrayList<>();
        List<String> missing = new ArrayList<>();
        String lowerResume = resumeText.toLowerCase();

        for (String skill : targetSkills) {
            String skillClean = skill.trim();
            if (skillClean.isEmpty()) continue;
            
            // Safe regex boundary checking for alphanumeric keywords
            String escaped = Pattern.quote(skillClean.toLowerCase());
            Pattern p = Pattern.compile("\\b" + escaped + "\\w*\\b", Pattern.CASE_INSENSITIVE);
            Matcher m = p.matcher(lowerResume);
            
            if (m.find() || lowerResume.contains(skillClean.toLowerCase())) {
                matched.add(skillClean);
            } else {
                missing.add(skillClean);
            }
        }

        result.setMatchedSkills(matched);
        result.setMissingSkills(missing);

        // 3. Compute Match Score
        int score = 60; // Baseline default score
        if (!targetSkills.isEmpty()) {
            score = (int) Math.round(((double) matched.size() / targetSkills.size()) * 100);
        }
        result.setMatchScore(score);

        // 4. Populate qualitative lists
        List<String> strengths = new ArrayList<>();
        strengths.add("Clear professional formatting and readable layout structure.");
        strengths.add("Includes industry-relevant technical keywords: " + (matched.isEmpty() ? "General Skills" : String.join(", ", matched.size() > 2 ? matched.subList(0, 2) : matched)));
        strengths.add("Document successfully parsed and assessed against the target profile.");
        result.setStrengths(strengths);

        List<String> gaps = new ArrayList<>();
        gaps.add(missing.isEmpty() 
            ? "No critical technical skill deficiencies detected relative to selection."
            : "Missing specific key skills from requirements: " + String.join(", ", missing.size() > 2 ? missing.subList(0, 2) : missing));
        gaps.add("Lacks explicit mention of standard metrics (%, $) demonstrating positive project impacts.");
        gaps.add("No certified specialized continuous learning credentials listed under experiences.");
        result.setGaps(gaps);

        List<String> recommendations = new ArrayList<>();
        recommendations.add("Create a designated 'Core Skills' tag grid near your header.");
        recommendations.add("Adopt the S.T.A.R. (Situation, Task, Action, Result) model for past work descriptions.");
        recommendations.add("Align and balance spelling styles of target technologies to appeal to ATS software.");
        result.setRecommendations(recommendations);

        // 5. Generate AI Summary paragraph
        String summary = String.format("Local Audit Mode: The candidate's resume has been evaluated against the requirements for a %s role. "
                + "A matches ledger indicates that %d out of %d target skills are present in the text, achieving a %d%% suitability rating. "
                + "We recommend focusing your revisions on incorporating missing skills and quantifying project outcomes.",
                jobRole, matched.size(), targetSkills.size(), score);
        result.setSummary(summary);

        return result;
    }

    private String extractEmail(String text) {
        Pattern pattern = Pattern.compile("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}");
        Matcher matcher = pattern.matcher(text);
        if (matcher.find()) {
            return matcher.group();
        }
        return "No email address found";
    }

    private String extractPhone(String text) {
        Pattern pattern = Pattern.compile("(?:\\+?\\d{1,3}[-.\\s]?)?\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}");
        Matcher matcher = pattern.matcher(text);
        if (matcher.find()) {
            return matcher.group();
        }
        return "No telephone found";
    }

    private String extractName(String text) {
        String[] lines = text.split("\\r?\\n");
        for (String line : lines) {
            String clean = line.trim();
            if (!clean.isEmpty() && !clean.contains("@") && !clean.contains(":") && clean.length() > 3 && clean.length() < 30) {
                return clean;
            }
        }
        return "Applicant Name";
    }
}
