package com.ecomate.backend.controller;

import com.ecomate.backend.dto.AssignmentRequest;
import com.ecomate.backend.dto.CollectorDriverDto;
import com.ecomate.backend.dto.VehicleDto;
import com.ecomate.backend.dto.CollectionJobDto;
import com.ecomate.backend.dto.ResourceAssignmentDto;
import com.ecomate.backend.entity.*;
import com.ecomate.backend.repository.*;
import com.ecomate.backend.service.ResourceAssignmentService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class ResourceAssignmentControllerTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CollectorDriverRepository employeeRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private CollectionJobRepository jobRepository;

    @Autowired
    private ResourceAssignmentRepository assignmentRepository;

    @Autowired
    private ResourceAssignmentService assignmentService;

    private User testAdmin;
    private CollectorDriver driver1;
    private CollectorDriver driver2;
    private CollectorDriver collector1;
    private CollectorDriver collector2;
    private Vehicle vehicle1;
    private Vehicle vehicle2;
    private CollectionJob jobMorning;
    private CollectionJob jobOverlapping;
    private CollectionJob jobAfternoon;

    @BeforeEach
    public void setUp() {
        assignmentRepository.deleteAll();
        jobRepository.deleteAll();
        vehicleRepository.deleteAll();
        employeeRepository.deleteAll();

        // Admin User
        testAdmin = userRepository.findByEmail("admin@ecomate.com")
                .orElseGet(() -> userRepository.save(new User("Admin", "admin@ecomate.com", "pass", Role.COUNCIL_ADMIN)));

        // Drivers & Collectors
        driver1 = employeeRepository.save(new CollectorDriver("EMP-T-01", "Driver One", "0771111111", EmployeeRole.DRIVER, "Zone A", "Morning", EmployeeStatus.AVAILABLE));
        driver2 = employeeRepository.save(new CollectorDriver("EMP-T-02", "Driver Two", "0772222222", EmployeeRole.DRIVER, "Zone B", "Evening", EmployeeStatus.AVAILABLE));
        collector1 = employeeRepository.save(new CollectorDriver("EMP-T-03", "Collector One", "0773333333", EmployeeRole.COLLECTOR, "Zone A", "Morning", EmployeeStatus.AVAILABLE));
        collector2 = employeeRepository.save(new CollectorDriver("EMP-T-04", "Collector Two", "0774444444", EmployeeRole.COLLECTOR, "Zone B", "Evening", EmployeeStatus.AVAILABLE));

        // Vehicles
        vehicle1 = vehicleRepository.save(new Vehicle("WP-TEST-01", "Compactor", 5.0, VehicleStatus.AVAILABLE, LocalDate.now()));
        vehicle2 = vehicleRepository.save(new Vehicle("WP-TEST-02", "Dumper", 3.0, VehicleStatus.AVAILABLE, LocalDate.now()));

        // Jobs
        LocalDateTime baseTime = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
        jobMorning = jobRepository.save(new CollectionJob("R-T01", "Morning Route", "Desc", "Zone A", baseTime.plusHours(8), baseTime.plusHours(11), "SCHEDULED"));
        jobOverlapping = jobRepository.save(new CollectionJob("R-T02", "Overlapping Route", "Desc", "Zone A", baseTime.plusHours(9), baseTime.plusHours(12), "SCHEDULED"));
        jobAfternoon = jobRepository.save(new CollectionJob("R-T03", "Afternoon Route", "Desc", "Zone B", baseTime.plusHours(13), baseTime.plusHours(16), "SCHEDULED"));
    }

    @Test
    public void testCreateAssignment_Success() {
        AssignmentRequest request = new AssignmentRequest(
                jobMorning.getId(),
                vehicle1.getId(),
                driver1.getId(),
                List.of(collector1.getId())
        );

        ResourceAssignmentDto dto = assignmentService.createAssignment(request, "admin@ecomate.com");
        assertNotNull(dto);
        assertEquals("ASSIGNED", dto.status());

        // Verify status updates
        CollectorDriver updatedDriver = employeeRepository.findById(driver1.getId()).orElseThrow();
        assertEquals(EmployeeStatus.ON_DUTY, updatedDriver.getStatus());

        Vehicle updatedVehicle = vehicleRepository.findById(vehicle1.getId()).orElseThrow();
        assertEquals(VehicleStatus.ON_DUTY, updatedVehicle.getStatus());

        CollectionJob updatedJob = jobRepository.findById(jobMorning.getId()).orElseThrow();
        assertEquals("ASSIGNED", updatedJob.getStatus());
    }

    @Test
    public void testCreateAssignment_OverlapFails() {
        // First assignment
        AssignmentRequest request1 = new AssignmentRequest(
                jobMorning.getId(),
                vehicle1.getId(),
                driver1.getId(),
                List.of(collector1.getId())
        );

        assignmentService.createAssignment(request1, "admin@ecomate.com");

        // Try overlapping assignment on driver1 / vehicle1 (both should fail)
        AssignmentRequest overlappingRequest = new AssignmentRequest(
                jobOverlapping.getId(),
                vehicle2.getId(), // different vehicle
                driver1.getId(),  // same driver (already assigned)
                List.of(collector2.getId())
        );

        assertThrows(RuntimeException.class, () -> {
            assignmentService.createAssignment(overlappingRequest, "admin@ecomate.com");
        });
    }

    @Test
    public void testReassignResources_Success() {
        // Create initial assignment
        AssignmentRequest request1 = new AssignmentRequest(
                jobMorning.getId(),
                vehicle1.getId(),
                driver1.getId(),
                List.of(collector1.getId())
        );

        ResourceAssignmentDto dto = assignmentService.createAssignment(request1, "admin@ecomate.com");
        Long assignmentId = dto.id();

        // Reassign to driver2 and vehicle2
        AssignmentRequest reassignRequest = new AssignmentRequest(
                jobMorning.getId(),
                vehicle2.getId(),
                driver2.getId(),
                List.of(collector2.getId())
        );

        ResourceAssignmentDto updatedDto = assignmentService.updateAssignment(assignmentId, reassignRequest, "admin@ecomate.com");
        assertNotNull(updatedDto);

        // Old resources should be AVAILABLE again
        assertEquals(EmployeeStatus.AVAILABLE, employeeRepository.findById(driver1.getId()).orElseThrow().getStatus());
        assertEquals(VehicleStatus.AVAILABLE, vehicleRepository.findById(vehicle1.getId()).orElseThrow().getStatus());

        // New resources should be ON_DUTY
        assertEquals(EmployeeStatus.ON_DUTY, employeeRepository.findById(driver2.getId()).orElseThrow().getStatus());
        assertEquals(VehicleStatus.ON_DUTY, vehicleRepository.findById(vehicle2.getId()).orElseThrow().getStatus());
    }

    @Test
    public void testCompleteAssignment_Success() {
        // Create assignment
        AssignmentRequest request = new AssignmentRequest(
                jobMorning.getId(),
                vehicle1.getId(),
                driver1.getId(),
                List.of(collector1.getId())
        );

        ResourceAssignmentDto dto = assignmentService.createAssignment(request, "admin@ecomate.com");
        Long assignmentId = dto.id();

        // Complete assignment
        assignmentService.completeAssignment(assignmentId);

        // Verify assignment status is COMPLETED
        ResourceAssignment completed = assignmentRepository.findById(assignmentId).orElseThrow();
        assertEquals(AssignmentStatus.COMPLETED, completed.getStatus());

        // Verify resources are AVAILABLE again
        assertEquals(EmployeeStatus.AVAILABLE, employeeRepository.findById(driver1.getId()).orElseThrow().getStatus());
        assertEquals(EmployeeStatus.AVAILABLE, employeeRepository.findById(collector1.getId()).orElseThrow().getStatus());
        assertEquals(VehicleStatus.AVAILABLE, vehicleRepository.findById(vehicle1.getId()).orElseThrow().getStatus());

        // Verify job status is COMPLETED
        assertEquals("COMPLETED", jobRepository.findById(jobMorning.getId()).orElseThrow().getStatus());
    }
}
