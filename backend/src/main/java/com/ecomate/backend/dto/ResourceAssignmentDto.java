package com.ecomate.backend.dto;

import java.time.LocalDateTime;
import java.util.List;

public record ResourceAssignmentDto(
    Long id,
    CollectionJobDto job,
    VehicleDto vehicle,
    CollectorDriverDto driver,
    List<CollectorDriverDto> collectors,
    String status,
    LocalDateTime assignmentDate,
    LocalDateTime createdTimestamp,
    LocalDateTime updatedTimestamp
) {}
