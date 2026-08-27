package com.ecomate.backend.dto;

import com.ecomate.backend.entity.WasteReport;
import java.time.LocalDateTime;

public record WasteReportResponse(
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
    public static WasteReportResponse from(WasteReport report) {
        return new WasteReportResponse(
                report.getId(), report.getReferenceNumber(), report.getIssueType(),
                report.getLocation(), report.getLatitude(), report.getLongitude(),
                report.getWasteCategory(), report.getDescription(),
                report.getPhotoData() != null && !report.getPhotoData().isBlank(),
                report.getStatus(), report.getPriority(), report.getAssignedTeam(),
                report.getReporterEmail(), report.getCreatedAt());
    }
}
