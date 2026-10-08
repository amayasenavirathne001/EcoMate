package com.ecomate.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdateWasteReportRequest(
        @NotBlank @Size(max = 24) String status,
        @NotBlank @Pattern(regexp = "LOW|MEDIUM|HIGH", message = "Priority must be LOW, MEDIUM, or HIGH") String priority,
        @Size(max = 80) String assignedTeam
) {
}
