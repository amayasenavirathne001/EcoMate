package com.ecomate.backend.dto;

public record ScheduleItemDto(
    String time,
    String zone,
    String type,
    String status
) {}
