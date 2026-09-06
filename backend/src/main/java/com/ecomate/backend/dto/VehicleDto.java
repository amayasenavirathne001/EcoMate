package com.ecomate.backend.dto;

import java.time.LocalDate;

public record VehicleDto(
    Long id,
    String registrationNumber,
    String vehicleType,
    Double capacity,
    String status,
    LocalDate lastServiceDate,
    LocalDate nextServiceDate,
    boolean active
) {}
