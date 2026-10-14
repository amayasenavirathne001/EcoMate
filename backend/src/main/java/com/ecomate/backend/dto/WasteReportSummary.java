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
                String displayNotes = reviewNotes;
                if (displayNotes == null || displayNotes.isBlank()) {
                        displayNotes = switch (status) {
                                case "IN_REVIEW" -> "Your report is being reviewed by the municipal team.";
                                case "ASSIGNED" -> "Your issue was assigned to " + (assignedTeam == null || assignedTeam.isBlank() ? "a response team" : assignedTeam) + ".";
                                case "RESOLVED" -> "Your issue was resolved by the municipal response team.";
                                case "REJECTED" -> "Your report was reviewed and could not be accepted.";
                                default -> null;
                        };
                }
                return new WasteReportResponse(id, referenceNumber, issueType, location,
                                latitude, longitude, wasteCategory, description, photoData, hasPhoto, status,
                                priority, assignedTeam, displayNotes, resolutionEvidence, hasResolutionEvidence,
                                Boolean.TRUE.equals(reporterConfirmed), reporterFeedback, reporterEmail, createdAt);
        }
}
