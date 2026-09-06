package com.ecomate.backend.controller;

import com.ecomate.backend.dto.AssignmentRequest;
import com.ecomate.backend.dto.CollectionJobDto;
import com.ecomate.backend.dto.CollectorDriverDto;
import com.ecomate.backend.dto.ResourceAssignmentDto;
import com.ecomate.backend.dto.VehicleDto;
import com.ecomate.backend.entity.EmployeeRole;
import com.ecomate.backend.service.CollectionJobService;
import com.ecomate.backend.service.CollectorDriverService;
import com.ecomate.backend.service.ResourceAssignmentService;
import com.ecomate.backend.service.VehicleService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/municipal")
public class MunicipalOperationsController {

    private final CollectorDriverService employeeService;
    private final VehicleService vehicleService;
    private final CollectionJobService jobService;
    private final ResourceAssignmentService assignmentService;

    public MunicipalOperationsController(
            CollectorDriverService employeeService,
            VehicleService vehicleService,
            CollectionJobService jobService,
            ResourceAssignmentService assignmentService) {
        this.employeeService = employeeService;
        this.vehicleService = vehicleService;
        this.jobService = jobService;
        this.assignmentService = assignmentService;
    }

    // ================= Employee Management =================

    @GetMapping("/employees")
    public ResponseEntity<List<CollectorDriverDto>> getAllEmployees() {
        return ResponseEntity.ok(employeeService.getAllEmployees());
    }

    @GetMapping("/employees/role/{role}")
    public ResponseEntity<List<CollectorDriverDto>> getEmployeesByRole(@PathVariable String role) {
        EmployeeRole empRole = EmployeeRole.valueOf(role.toUpperCase());
        return ResponseEntity.ok(employeeService.getActiveEmployeesByRole(empRole));
    }

    @PostMapping("/employees")
    public ResponseEntity<CollectorDriverDto> createEmployee(@RequestBody CollectorDriverDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(employeeService.createEmployee(dto));
    }

    @PutMapping("/employees/{id}")
    public ResponseEntity<CollectorDriverDto> updateEmployee(@PathVariable Long id, @RequestBody CollectorDriverDto dto) {
        return ResponseEntity.ok(employeeService.updateEmployee(id, dto));
    }

    @DeleteMapping("/employees/{id}")
    public ResponseEntity<Void> deactivateEmployee(@PathVariable Long id) {
        employeeService.deactivateEmployee(id);
        return ResponseEntity.noContent().build();
    }

    // ================= Vehicle Management =================

    @GetMapping("/vehicles")
    public ResponseEntity<List<VehicleDto>> getAllVehicles() {
        return ResponseEntity.ok(vehicleService.getAllVehicles());
    }

    @PostMapping("/vehicles")
    public ResponseEntity<VehicleDto> createVehicle(@RequestBody VehicleDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(vehicleService.createVehicle(dto));
    }

    @PutMapping("/vehicles/{id}")
    public ResponseEntity<VehicleDto> updateVehicle(@PathVariable Long id, @RequestBody VehicleDto dto) {
        return ResponseEntity.ok(vehicleService.updateVehicle(id, dto));
    }

    @DeleteMapping("/vehicles/{id}")
    public ResponseEntity<Void> deactivateVehicle(@PathVariable Long id) {
        vehicleService.deactivateVehicle(id);
        return ResponseEntity.noContent().build();
    }

    // ================= Collection Jobs Management =================

    @GetMapping("/jobs")
    public ResponseEntity<List<CollectionJobDto>> getAllJobs() {
        return ResponseEntity.ok(jobService.getAllJobs());
    }

    @GetMapping("/jobs/unassigned")
    public ResponseEntity<List<CollectionJobDto>> getUnassignedJobs() {
        return ResponseEntity.ok(jobService.getUnassignedJobs());
    }

    @PostMapping("/jobs")
    public ResponseEntity<CollectionJobDto> createJob(@RequestBody CollectionJobDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(jobService.createJob(dto));
    }

    @PutMapping("/jobs/{id}")
    public ResponseEntity<CollectionJobDto> updateJob(@PathVariable Long id, @RequestBody CollectionJobDto dto) {
        return ResponseEntity.ok(jobService.updateJob(id, dto));
    }

    @DeleteMapping("/jobs/{id}")
    public ResponseEntity<Void> deleteJob(@PathVariable Long id) {
        jobService.deleteJob(id);
        return ResponseEntity.noContent().build();
    }

    // ================= Resource Assignments =================

    @GetMapping("/assignments")
    public ResponseEntity<List<ResourceAssignmentDto>> getAllAssignments() {
        return ResponseEntity.ok(assignmentService.getAllAssignments());
    }

    @PostMapping("/assignments")
    public ResponseEntity<ResourceAssignmentDto> createAssignment(@RequestBody AssignmentRequest request, Principal principal) {
        String officerEmail = principal.getName();
        return ResponseEntity.status(HttpStatus.CREATED).body(assignmentService.createAssignment(request, officerEmail));
    }

    @PutMapping("/assignments/{id}")
    public ResponseEntity<ResourceAssignmentDto> updateAssignment(@PathVariable Long id, @RequestBody AssignmentRequest request, Principal principal) {
        String officerEmail = principal.getName();
        return ResponseEntity.ok(assignmentService.updateAssignment(id, request, officerEmail));
    }

    @DeleteMapping("/assignments/{id}")
    public ResponseEntity<Void> cancelAssignment(@PathVariable Long id) {
        assignmentService.cancelAssignment(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/assignments/{id}/complete")
    public ResponseEntity<Void> completeAssignment(@PathVariable Long id) {
        assignmentService.completeAssignment(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/employees/{id}/assigned")
    public ResponseEntity<Boolean> isEmployeeAssigned(@PathVariable Long id) {
        return ResponseEntity.ok(assignmentService.isEmployeeAssigned(id));
    }

    @GetMapping("/vehicles/{id}/assigned")
    public ResponseEntity<Boolean> isVehicleAssigned(@PathVariable Long id) {
        return ResponseEntity.ok(assignmentService.isVehicleAssigned(id));
    }
}
