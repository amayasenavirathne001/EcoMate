package com.ecomate.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateWasteReportRequest(
        @NotBlank @Size(max = 80) String issueType,
        @NotBlank @Size(max = 120) String location,
        Double latitude,
        Double longitude,
        @Size(max = 80) String wasteCategory,
        @NotBlank @Size(max = 1200) String description,
        String photoData
) {
}
