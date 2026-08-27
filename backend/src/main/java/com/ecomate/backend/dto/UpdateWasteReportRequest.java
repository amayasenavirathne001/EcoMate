package com.ecomate.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateWasteReportRequest(
        @NotBlank @Size(max = 24) String status,
        @NotBlank @Size(max = 16) String priority,
        @Size(max = 80) String assignedTeam
) {
}
