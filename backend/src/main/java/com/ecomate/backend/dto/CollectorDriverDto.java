package com.ecomate.backend.dto;

public record CollectorDriverDto(
    Long id,
    String employeeId,
    String name,
    String phone,
    String role,
    String assignedZone,
    String shift,
    String status,
    boolean active
) {}
