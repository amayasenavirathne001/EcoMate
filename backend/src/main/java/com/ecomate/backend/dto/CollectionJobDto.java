package com.ecomate.backend.dto;

import java.time.LocalDateTime;

public record CollectionJobDto(
    Long id,
    String routeId,
    String title,
    String description,
    String zone,
    LocalDateTime startTime,
    LocalDateTime endTime,
    String status
) {}
