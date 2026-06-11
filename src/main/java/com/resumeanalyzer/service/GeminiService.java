package com.resumeanalyzer.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.resumeanalyzer.model.AnalysisResult;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

public class GeminiService {
    // Configure default API key here. Can also be set as an environment variable "GEMINI_API_KEY"
    private static final String API_KEY = "AIzaSyCIiFTD_Md_wKGu3MH2WOgRVRPIbSorimM"; 

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;

    public GeminiService() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(15))
                .build();
        this.objectMapper = new ObjectMapper();
    }

    public AnalysisResult analyze(String resumeText, String jobRole, List<String> targetSkills) throws Exception {
        String apiKey = System.getenv("GEMINI_API_KEY");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = API_KEY;
        }

        if (apiKey == null || apiKey.trim().isEmpty() || apiKey.equals("MY_GEMINI_API_KEY")) {
            throw new IllegalStateException("Gemini API Key is not configured. Please supply a key.");
        }

        // Limit resume text to prevent prompt size issues
        String croppedResume = resumeText.length() > 6000 ? resumeText.substring(0, 6000) : resumeText;

        String prompt = "You are an expert HR recruiter. Analyze this resume text against the target job role and skills. "
                + "Return ONLY valid JSON with this exact structure:\n"
                + "{\n"
                + "  \"candidateName\": \"string\",\n"
                + "  \"candidateEmail\": \"string\",\n"
                + "  \"candidatePhone\": \"string\",\n"
                + "  \"matchScore\": 85,\n"
                + "  \"matchedSkills\": [\"array of strings\"],\n"
                + "  \"missingSkills\": [\"array of strings\"],\n"
                + "  \"strengths\": [\"array of 3 strings\"],\n"
                + "  \"gaps\": [\"array of 3 strings\"],\n"
                + "  \"recommendations\": [\"array of 3 strings\"],\n"
                + "  \"summary\": \"string\"\n"
                + "}\n"
                + "Resume Text:\n" + croppedResume + "\n"
                + "Target Role: " + jobRole + "\n"
                + "Target Skills: " + String.join(", ", targetSkills);

        // Escape prompt for JSON body
        String escapedPrompt = objectMapper.writeValueAsString(prompt);

        // Build the Gemini API payload body
        String jsonPayload = "{"
                + "\"contents\": [{"
                + "  \"parts\": [{"
                + "    \"text\": " + escapedPrompt
                + "  }]"
                + "}],"
                + "\"generationConfig\": {"
                + "  \"responseMimeType\": \"application/json\""
                + "}"
                + "}";

        URI uri = URI.create("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(uri)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .timeout(Duration.ofSeconds(30))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new RuntimeException("Gemini API call failed with status: " + response.statusCode() + ". Body: " + response.body());
        }

        // Parse REST JSON response from Gemini
        JsonNode root = objectMapper.readTree(response.body());
        JsonNode textNode = root.path("candidates").path(0).path("content").path("parts").path(0).path("text");
        
        if (textNode.isMissingNode()) {
            throw new RuntimeException("Could not extract text answer from Gemini API response: " + response.body());
        }

        String rawJsonOutput = textNode.asText().trim();
        
        // Clean markdown code blocks if present
        if (rawJsonOutput.startsWith("```")) {
            rawJsonOutput = rawJsonOutput.replaceAll("^```json\\s*", "")
                                         .replaceAll("^```\\s*", "")
                                         .replaceAll("\\s*```$", "")
                                         .trim();
        }

        // Deserialize standard properties into Java Object
        try {
            return objectMapper.readValue(rawJsonOutput, AnalysisResult.class);
        } catch (Exception e) {
            System.err.println("Jackson deserialization failed. Output raw: " + rawJsonOutput);
            throw new RuntimeException("Failed parsing Gemini JSON matching schema: " + e.getMessage(), e);
        }
    }
}
