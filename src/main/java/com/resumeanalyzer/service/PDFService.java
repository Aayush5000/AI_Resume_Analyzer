package com.resumeanalyzer.service;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.IOException;
import java.io.InputStream;

public class PDFService {

    public String extractText(InputStream pdfInputStream) throws IOException {
        if (pdfInputStream == null) {
            throw new IllegalArgumentException("PDF InputStream is null");
        }

        try (PDDocument document = PDDocument.load(pdfInputStream)) {
            if (document.isEncrypted()) {
                throw new IOException("Cannot parse encrypted PDF resume.");
            }
            
            PDFTextStripper stripper = new PDFTextStripper();
            String parsedText = stripper.getText(document);
            if (parsedText == null) {
                return "";
            }
            return parsedText.trim();
        }
    }
}
