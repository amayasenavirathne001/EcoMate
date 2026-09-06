package com.ecomate.backend.dto;

import java.time.LocalDateTime;

public record NotificationDto(
    Long id,
    String employeeId,
    String title,
    String message,
    LocalDateTime dateTime,
    boolean read
) {}
