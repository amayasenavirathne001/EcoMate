package com.ecomate.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateResidentWasteReportRequest(
        @NotBlank @Size(max = 80) String issueType,
        @NotBlank @Size(max = 120) String location,
        @Size(max = 80) String wasteCategory,
        @NotBlank @Size(max = 1200) String description,
        Double latitude,
        Double longitude,
        String photoData
) {
}