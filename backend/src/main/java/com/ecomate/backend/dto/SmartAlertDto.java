package com.ecomate.backend.dto;

import com.ecomate.backend.entity.AlertSeverity;
import com.ecomate.backend.entity.AlertStatus;
import com.ecomate.backend.entity.AlertType;

import java.time.LocalDateTime;

public class SmartAlertDto {
    private Long id;
    private AlertType type;
    private AlertSeverity severity;
    private Long jobId;
    private String routeId;
    private String zone;
    private String description;
    private LocalDateTime createdTimestamp;
    private LocalDateTime updatedTimestamp;
    private AlertStatus status;

    public SmartAlertDto() {
    }

    public SmartAlertDto(Long id, AlertType type, AlertSeverity severity, Long jobId, String routeId, String zone, String description, LocalDateTime createdTimestamp, LocalDateTime updatedTimestamp, AlertStatus status) {
        this.id = id;
        this.type = type;
        this.severity = severity;
        this.jobId = jobId;
        this.routeId = routeId;
        this.zone = zone;
        this.description = description;
        this.createdTimestamp = createdTimestamp;
        this.updatedTimestamp = updatedTimestamp;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public AlertType getType() {
        return type;
    }

    public void setType(AlertType type) {
        this.type = type;
    }

    public AlertSeverity getSeverity() {
        return severity;
    }

    public void setSeverity(AlertSeverity severity) {
        this.severity = severity;
    }

    public Long getJobId() {
        return jobId;
    }

    public void setJobId(Long jobId) {
        this.jobId = jobId;
    }

    public String getRouteId() {
        return routeId;
    }

    public void setRouteId(String routeId) {
        this.routeId = routeId;
    }

    public String getZone() {
        return zone;
    }

    public void setZone(String zone) {
        this.zone = zone;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedTimestamp() {
        return createdTimestamp;
    }

    public void setCreatedTimestamp(LocalDateTime createdTimestamp) {
        this.createdTimestamp = createdTimestamp;
    }

    public LocalDateTime getUpdatedTimestamp() {
        return updatedTimestamp;
    }

    public void setUpdatedTimestamp(LocalDateTime updatedTimestamp) {
        this.updatedTimestamp = updatedTimestamp;
    }

    public AlertStatus getStatus() {
        return status;
    }

    public void setStatus(AlertStatus status) {
        this.status = status;
    }
}
