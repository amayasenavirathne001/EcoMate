package com.ecomate.backend.dto;

public record HotspotDto(
    double lat,
    double lng,
    String priority // "HIGH", "MEDIUM", "LOW"
) {}
