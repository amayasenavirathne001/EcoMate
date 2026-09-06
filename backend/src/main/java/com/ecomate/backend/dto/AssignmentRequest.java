package com.ecomate.backend.dto;

import java.util.List;

public record AssignmentRequest(
    Long jobId,
    Long vehicleId,
    Long driverId,
    List<Long> collectorIds
) {}
