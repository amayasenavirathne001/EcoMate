package com.ecomate.backend.service;

import com.ecomate.backend.dto.ResourceAssignmentDto;
import com.ecomate.backend.dto.AssignmentRequest;
import com.ecomate.backend.dto.CollectorDriverDto;
import com.ecomate.backend.dto.VehicleDto;
import com.ecomate.backend.dto.CollectionJobDto;
import com.ecomate.backend.entity.*;
import com.ecomate.backend.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional
public class ResourceAssignmentService {

    private final ResourceAssignmentRepository repository;
    private final CollectionJobRepository jobRepository;
    private final VehicleRepository vehicleRepository;
    private final CollectorDriverRepository employeeRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    // We inject services to convert to DTOs cleanly
    private final CollectorDriverService employeeService;
    private final VehicleService vehicleService;
    private final CollectionJobService jobService;

    public ResourceAssignmentService(
            ResourceAssignmentRepository repository,
            CollectionJobRepository jobRepository,
            VehicleRepository vehicleRepository,
            CollectorDriverRepository employeeRepository,
            UserRepository userRepository,
            NotificationService notificationService,
            CollectorDriverService employeeService,
            VehicleService vehicleService,
            CollectionJobService jobService) {
        this.repository = repository;
        this.jobRepository = jobRepository;
        this.vehicleRepository = vehicleRepository;
        this.employeeRepository = employeeRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
        this.employeeService = employeeService;
        this.vehicleService = vehicleService;
        this.jobService = jobService;
    }

    public List<ResourceAssignmentDto> getAllAssignments() {
        return repository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ResourceAssignmentDto getAssignmentById(Long id) {
        ResourceAssignment entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assignment not found with id " + id));
        return toDto(entity);
    }

    public ResourceAssignmentDto createAssignment(AssignmentRequest request, String officerEmail) {
        CollectionJob job = jobRepository.findById(request.jobId())
                .orElseThrow(() -> new RuntimeException("Job not found with id " + request.jobId()));
        Vehicle vehicle = vehicleRepository.findById(request.vehicleId())
                .orElseThrow(() -> new RuntimeException("Vehicle not found with id " + request.vehicleId()));
        CollectorDriver driver = employeeRepository.findById(request.driverId())
                .orElseThrow(() -> new RuntimeException("Driver not found with id " + request.driverId()));
        User officer = userRepository.findByEmail(officerEmail)
                .orElseThrow(() -> new RuntimeException("Officer user not found with email " + officerEmail));

        // Validate driver role
        if (driver.getRole() != EmployeeRole.DRIVER) {
            throw new RuntimeException("Employee " + driver.getName() + " is not a driver.");
        }

        // Validate collectors
        Set<CollectorDriver> collectors = new HashSet<>();
        for (Long colId : request.collectorIds()) {
            CollectorDriver col = employeeRepository.findById(colId)
                    .orElseThrow(() -> new RuntimeException("Collector not found with id " + colId));
            if (col.getRole() != EmployeeRole.COLLECTOR) {
                throw new RuntimeException("Employee " + col.getName() + " is not a collector.");
            }
            collectors.add(col);
        }

        // Validation 1: Status checks
        if (driver.getStatus() != EmployeeStatus.AVAILABLE) {
            throw new RuntimeException("Driver " + driver.getName() + " is currently " + driver.getStatus() + " (not Available).");
        }
        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new RuntimeException("Vehicle " + vehicle.getRegistrationNumber() + " is currently " + vehicle.getStatus() + " (not Available).");
        }
        for (CollectorDriver col : collectors) {
            if (col.getStatus() != EmployeeStatus.AVAILABLE) {
                throw new RuntimeException("Collector " + col.getName() + " is currently " + col.getStatus() + " (not Available).");
            }
        }

        // Validation 2: Overlap check
        validateOverlap(null, job, vehicle, driver, collectors);

        // Perform assignment
        ResourceAssignment assignment = new ResourceAssignment();
        assignment.setJob(job);
        assignment.setVehicle(vehicle);
        assignment.setDriver(driver);
        assignment.setCollectors(collectors);
        assignment.setAssignedOfficer(officer);
        assignment.setStatus(AssignmentStatus.ASSIGNED);
        assignment.setAssignmentDate(LocalDateTime.now());

        // Update statuses to ON_DUTY
        driver.setStatus(EmployeeStatus.ON_DUTY);
        vehicle.setStatus(VehicleStatus.ON_DUTY);
        for (CollectorDriver col : collectors) {
            col.setStatus(EmployeeStatus.ON_DUTY);
        }
        job.setStatus("ASSIGNED");

        employeeRepository.save(driver);
        vehicleRepository.save(vehicle);
        employeeRepository.saveAll(collectors);
        jobRepository.save(job);

        ResourceAssignment saved = repository.save(assignment);

        // Send notifications
        sendAssignmentNotifications(saved);

        return toDto(saved);
    }

    public ResourceAssignmentDto updateAssignment(Long id, AssignmentRequest request, String officerEmail) {
        ResourceAssignment assignment = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assignment not found with id " + id));
        CollectionJob job = jobRepository.findById(request.jobId())
                .orElseThrow(() -> new RuntimeException("Job not found with id " + request.jobId()));
        Vehicle newVehicle = vehicleRepository.findById(request.vehicleId())
                .orElseThrow(() -> new RuntimeException("Vehicle not found with id " + request.vehicleId()));
        CollectorDriver newDriver = employeeRepository.findById(request.driverId())
                .orElseThrow(() -> new RuntimeException("Driver not found with id " + request.driverId()));
        User officer = userRepository.findByEmail(officerEmail)
                .orElseThrow(() -> new RuntimeException("Officer user not found with email " + officerEmail));

        if (newDriver.getRole() != EmployeeRole.DRIVER) {
            throw new RuntimeException("Employee " + newDriver.getName() + " is not a driver.");
        }

        Set<CollectorDriver> newCollectors = new HashSet<>();
        for (Long colId : request.collectorIds()) {
            CollectorDriver col = employeeRepository.findById(colId)
                    .orElseThrow(() -> new RuntimeException("Collector not found with id " + colId));
            if (col.getRole() != EmployeeRole.COLLECTOR) {
                throw new RuntimeException("Employee " + col.getName() + " is not a collector.");
            }
            newCollectors.add(col);
        }

        // Validate Status for CHANGED/NEW resources only
        if (!assignment.getDriver().getId().equals(newDriver.getId()) && newDriver.getStatus() != EmployeeStatus.AVAILABLE) {
            throw new RuntimeException("Driver " + newDriver.getName() + " is currently " + newDriver.getStatus() + " (not Available).");
        }
        if (!assignment.getVehicle().getId().equals(newVehicle.getId()) && newVehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new RuntimeException("Vehicle " + newVehicle.getRegistrationNumber() + " is currently " + newVehicle.getStatus() + " (not Available).");
        }
        for (CollectorDriver col : newCollectors) {
            if (!assignment.getCollectors().contains(col) && col.getStatus() != EmployeeStatus.AVAILABLE) {
                throw new RuntimeException("Collector " + col.getName() + " is currently " + col.getStatus() + " (not Available).");
            }
        }

        // Overlap Check (excluding current assignment ID)
        validateOverlap(id, job, newVehicle, newDriver, newCollectors);

        // Reset previous resources' statuses
        CollectorDriver oldDriver = assignment.getDriver();
        if (!oldDriver.getId().equals(newDriver.getId())) {
            oldDriver.setStatus(EmployeeStatus.AVAILABLE);
            employeeRepository.save(oldDriver);
        }
        Vehicle oldVehicle = assignment.getVehicle();
        if (!oldVehicle.getId().equals(newVehicle.getId())) {
            oldVehicle.setStatus(VehicleStatus.AVAILABLE);
            vehicleRepository.save(oldVehicle);
        }
        for (CollectorDriver oldCol : assignment.getCollectors()) {
            if (!newCollectors.contains(oldCol)) {
                oldCol.setStatus(EmployeeStatus.AVAILABLE);
                employeeRepository.save(oldCol);
            }
        }

        // Apply new resources and update to ON_DUTY
        newDriver.setStatus(EmployeeStatus.ON_DUTY);
        newVehicle.setStatus(VehicleStatus.ON_DUTY);
        for (CollectorDriver col : newCollectors) {
            col.setStatus(EmployeeStatus.ON_DUTY);
        }

        employeeRepository.save(newDriver);
        vehicleRepository.save(newVehicle);
        employeeRepository.saveAll(newCollectors);

        assignment.setJob(job);
        assignment.setVehicle(newVehicle);
        assignment.setDriver(newDriver);
        assignment.setCollectors(newCollectors);
        assignment.setAssignedOfficer(officer);
        assignment.setStatus(AssignmentStatus.ASSIGNED);

        ResourceAssignment saved = repository.save(assignment);

        // Send reassignment notifications
        sendAssignmentNotifications(saved);

        return toDto(saved);
    }

    public void cancelAssignment(Long id) {
        ResourceAssignment assignment = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assignment not found with id " + id));

        // Set status to CANCELLED
        assignment.setStatus(AssignmentStatus.CANCELLED);
        repository.save(assignment);

        // Reset statuses of resources
        CollectorDriver driver = assignment.getDriver();
        driver.setStatus(EmployeeStatus.AVAILABLE);
        employeeRepository.save(driver);

        Vehicle vehicle = assignment.getVehicle();
        vehicle.setStatus(VehicleStatus.AVAILABLE);
        vehicleRepository.save(vehicle);

        for (CollectorDriver col : assignment.getCollectors()) {
            col.setStatus(EmployeeStatus.AVAILABLE);
            employeeRepository.save(col);
        }

        CollectionJob job = assignment.getJob();
        job.setStatus("SCHEDULED");
        jobRepository.save(job);
    }

    private void validateOverlap(Long excludeAssignmentId, CollectionJob job, Vehicle vehicle, CollectorDriver driver, Set<CollectorDriver> collectors) {
        List<AssignmentStatus> activeStatuses = List.of(AssignmentStatus.ASSIGNED, AssignmentStatus.IN_PROGRESS);
        List<ResourceAssignment> overlaps = repository.findOverlappingAssignments(activeStatuses, job.getStartTime(), job.getEndTime());

        for (ResourceAssignment a : overlaps) {
            if (excludeAssignmentId != null && a.getId().equals(excludeAssignmentId)) {
                continue;
            }

            // Driver check
            if (a.getDriver().getId().equals(driver.getId())) {
                throw new RuntimeException("Driver " + driver.getName() + " is already assigned to an overlapping route: " + a.getJob().getRouteId() + " (" + a.getJob().getTitle() + ")");
            }

            // Vehicle check
            if (a.getVehicle().getId().equals(vehicle.getId())) {
                throw new RuntimeException("Vehicle " + vehicle.getRegistrationNumber() + " is already assigned to an overlapping route: " + a.getJob().getRouteId() + " (" + a.getJob().getTitle() + ")");
            }

            // Collectors check
            for (CollectorDriver col : collectors) {
                if (a.getCollectors().stream().anyMatch(c -> c.getId().equals(col.getId()))) {
                    throw new RuntimeException("Collector " + col.getName() + " is already assigned to an overlapping route: " + a.getJob().getRouteId() + " (" + a.getJob().getTitle() + ")");
                }
            }
        }
    }

    private void sendAssignmentNotifications(ResourceAssignment assignment) {
        CollectionJob job = assignment.getJob();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy 'at' hh:mm a");
        String timeStr = job.getStartTime().format(formatter) + " - " + job.getEndTime().format(formatter);
        String msg = String.format("Job assigned: Route %s (%s). Scheduled for: %s. Zone: %s. Vehicle: %s.",
                job.getRouteId(), job.getTitle(), timeStr, job.getZone(), assignment.getVehicle().getRegistrationNumber());

        // Notify Driver
        notificationService.createNotification(assignment.getDriver().getEmployeeId(), "New Assignment: Route " + job.getRouteId(), msg);

        // Notify Collectors
        for (CollectorDriver col : assignment.getCollectors()) {
            notificationService.createNotification(col.getEmployeeId(), "New Assignment: Route " + job.getRouteId(), msg);
        }
    }

    public void completeAssignment(Long id) {
        ResourceAssignment assignment = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assignment not found with id " + id));

        assignment.setStatus(AssignmentStatus.COMPLETED);
        repository.save(assignment);

        // Reset statuses of resources to AVAILABLE
        CollectorDriver driver = assignment.getDriver();
        driver.setStatus(EmployeeStatus.AVAILABLE);
        employeeRepository.save(driver);

        Vehicle vehicle = assignment.getVehicle();
        vehicle.setStatus(VehicleStatus.AVAILABLE);
        vehicleRepository.save(vehicle);

        for (CollectorDriver col : assignment.getCollectors()) {
            col.setStatus(EmployeeStatus.AVAILABLE);
            employeeRepository.save(col);
        }

        CollectionJob job = assignment.getJob();
        job.setStatus("COMPLETED");
        jobRepository.save(job);
    }

    public boolean isEmployeeAssigned(Long employeeId) {
        List<AssignmentStatus> activeStatuses = List.of(AssignmentStatus.ASSIGNED, AssignmentStatus.IN_PROGRESS);
        return repository.existsByDriverIdAndStatusIn(employeeId, activeStatuses) ||
               repository.existsByCollectorsIdAndStatusIn(employeeId, activeStatuses);
    }

    public boolean isVehicleAssigned(Long vehicleId) {
        List<AssignmentStatus> activeStatuses = List.of(AssignmentStatus.ASSIGNED, AssignmentStatus.IN_PROGRESS);
        return repository.existsByVehicleIdAndStatusIn(vehicleId, activeStatuses);
    }

    public ResourceAssignmentDto toDto(ResourceAssignment entity) {
        List<CollectorDriverDto> colDtos = entity.getCollectors().stream()
                .map(employeeService::toDto)
                .collect(Collectors.toList());

        return new ResourceAssignmentDto(
                entity.getId(),
                jobService.toDto(entity.getJob()),
                vehicleService.toDto(entity.getVehicle()),
                employeeService.toDto(entity.getDriver()),
                colDtos,
                entity.getStatus().name(),
                entity.getAssignmentDate(),
                entity.getCreatedTimestamp(),
                entity.getUpdatedTimestamp()
        );
    }
}
