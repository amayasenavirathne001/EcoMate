package com.ecomate.backend.dto;

import jakarta.validation.constraints.Size;

public record WasteReportFeedbackRequest(@Size(max = 1200) String feedback) {
}