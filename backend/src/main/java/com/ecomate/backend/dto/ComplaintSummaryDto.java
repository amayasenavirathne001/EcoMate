package com.ecomate.backend.dto;

public record ComplaintSummaryDto(
    String title,
    String location,
    String priority,
    String timeAgo
) {}
