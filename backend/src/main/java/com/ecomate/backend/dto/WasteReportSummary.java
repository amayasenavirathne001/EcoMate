package com.ecomate.backend.dto;

import java.time.LocalDateTime;

public record WasteReportSummary(
        Long id,
        String referenceNumber,
        String issueType,
        String location,
        Double latitude,
        Double longitude,
        String wasteCategory,
        String description,
        String photoData,
        boolean hasPhoto,
        String status,
        String priority,
        String assignedTeam,
        String reviewNotes,
        String resolutionEvidence,
        boolean hasResolutionEvidence,
        Boolean reporterConfirmed,
        String reporterFeedback,
        String reporterEmail,
        LocalDateTime createdAt
) {
        public WasteReportResponse toResponse() {
                return new WasteReportResponse(id, referenceNumber, issueType, location,
                                latitude, longitude, wasteCategory, description, photoData, hasPhoto, status,
                                priority, assignedTeam, reviewNotes, resolutionEvidence, hasResolutionEvidence,
                                Boolean.TRUE.equals(reporterConfirmed), reporterFeedback, reporterEmail, createdAt);
        }
}
