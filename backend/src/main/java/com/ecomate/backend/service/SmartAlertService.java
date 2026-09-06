package com.ecomate.backend.service;

import com.ecomate.backend.dto.SmartAlertDto;
import com.ecomate.backend.entity.*;
import com.ecomate.backend.repository.CollectionJobRepository;
import com.ecomate.backend.repository.ResourceAssignmentRepository;
import com.ecomate.backend.repository.SmartAlertRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class SmartAlertService {

    private final SmartAlertRepository smartAlertRepository;
    private final CollectionJobRepository collectionJobRepository;
    private final ResourceAssignmentRepository resourceAssignmentRepository;

    public SmartAlertService(SmartAlertRepository smartAlertRepository,
                             CollectionJobRepository collectionJobRepository,
                             ResourceAssignmentRepository resourceAssignmentRepository) {
        this.smartAlertRepository = smartAlertRepository;
        this.collectionJobRepository = collectionJobRepository;
        this.resourceAssignmentRepository = resourceAssignmentRepository;
    }

    @Scheduled(fixedRate = 60000) // Run every 60 seconds
    @Transactional
    public void generateAlerts() {
        List<CollectionJob> activeJobs = collectionJobRepository.findAll();
        LocalDateTime now = LocalDateTime.now();

        for (CollectionJob job : activeJobs) {
            if ("COMPLETED".equals(job.getStatus())) {
                continue;
            }

            // Unassigned Collection: Starts in < 2 hours and not assigned
            if (job.getStartTime().isBefore(now.plusHours(2)) && "SCHEDULED".equals(job.getStatus())) {
                List<ResourceAssignment> assignments = resourceAssignmentRepository.findByJobId(job.getId());
                if (assignments.isEmpty()) {
                    createOrUpdateAlert(job, AlertType.UNASSIGNED_COLLECTION, AlertSeverity.CRITICAL, "Job is unassigned and starts soon.");
                }
            }

            // Trip Not Started: Start time past, status still SCHEDULED
            if (job.getStartTime().isBefore(now) && "SCHEDULED".equals(job.getStatus())) {
                createOrUpdateAlert(job, AlertType.TRIP_NOT_STARTED, AlertSeverity.WARNING, "Job has not started yet.");
            }

            // Missed Collection: End time past, not completed
            if (job.getEndTime().isBefore(now) && !"COMPLETED".equals(job.getStatus())) {
                createOrUpdateAlert(job, AlertType.MISSED_COLLECTION, AlertSeverity.CRITICAL, "Job missed its completion window.");
            }
            
            // Note: FAILED_COLLECTION and ROUTE_LOCATION_ISSUE could be triggered by other explicit events
        }
    }

    private void createOrUpdateAlert(CollectionJob job, AlertType type, AlertSeverity severity, String description) {
        Optional<SmartAlert> existingAlert = smartAlertRepository.findByJobIdAndTypeAndStatusNot(job.getId(), type, AlertStatus.RESOLVED);
        if (existingAlert.isEmpty()) {
            SmartAlert alert = new SmartAlert(type, severity, job.getId(), job.getRouteId(), job.getZone(), description);
            smartAlertRepository.save(alert);
        }
    }

    public List<SmartAlertDto> getAllAlerts() {
        return smartAlertRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<SmartAlertDto> getActiveAlerts() {
        return smartAlertRepository.findByStatusNot(AlertStatus.RESOLVED).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public SmartAlertDto updateAlertStatus(Long id, AlertStatus status) {
        SmartAlert alert = smartAlertRepository.findById(id).orElseThrow(() -> new RuntimeException("Alert not found"));
        alert.setStatus(status);
        return mapToDto(smartAlertRepository.save(alert));
    }

    private SmartAlertDto mapToDto(SmartAlert alert) {
        return new SmartAlertDto(
                alert.getId(),
                alert.getType(),
                alert.getSeverity(),
                alert.getJobId(),
                alert.getRouteId(),
                alert.getZone(),
                alert.getDescription(),
                alert.getCreatedTimestamp(),
                alert.getUpdatedTimestamp(),
                alert.getStatus()
        );
    }
}
