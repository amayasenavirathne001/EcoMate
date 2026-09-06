package com.ecomate.backend.dto;

public record AnnouncementDto(
    String title,
    String description,
    String date,
    boolean isNew
) {}
