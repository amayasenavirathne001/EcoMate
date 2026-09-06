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
        boolean hasPhoto,
        String status,
        String priority,
        String assignedTeam,
        String reporterEmail,
        LocalDateTime createdAt
) {
        public WasteReportResponse toResponse() {
                return new WasteReportResponse(id, referenceNumber, issueType, location,
                                latitude, longitude, wasteCategory, description, hasPhoto, status,
                                priority, assignedTeam, reporterEmail, createdAt);
        }
}
