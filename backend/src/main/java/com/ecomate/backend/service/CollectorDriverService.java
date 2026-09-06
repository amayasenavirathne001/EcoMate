package com.ecomate.backend.service;

import com.ecomate.backend.dto.CollectorDriverDto;
import com.ecomate.backend.entity.CollectorDriver;
import com.ecomate.backend.entity.EmployeeRole;
import com.ecomate.backend.entity.EmployeeStatus;
import com.ecomate.backend.repository.CollectorDriverRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CollectorDriverService {

    private final CollectorDriverRepository repository;

    public CollectorDriverService(CollectorDriverRepository repository) {
        this.repository = repository;
    }

    public List<CollectorDriverDto> getAllEmployees() {
        return repository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<CollectorDriverDto> getActiveEmployeesByRole(EmployeeRole role) {
        return repository.findByActiveAndRole(true, role).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public CollectorDriverDto getEmployeeById(Long id) {
        CollectorDriver entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id " + id));
        return toDto(entity);
    }

    public CollectorDriverDto getEmployeeByEmployeeId(String employeeId) {
        CollectorDriver entity = repository.findByEmployeeId(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found with employeeId " + employeeId));
        return toDto(entity);
    }

    public CollectorDriverDto createEmployee(CollectorDriverDto dto) {
        if (repository.existsByEmployeeId(dto.employeeId())) {
            throw new RuntimeException("Employee with ID " + dto.employeeId() + " already exists.");
        }
        CollectorDriver entity = new CollectorDriver();
        updateEntityFromDto(entity, dto);
        entity.setActive(true);
        return toDto(repository.save(entity));
    }

    public CollectorDriverDto updateEmployee(Long id, CollectorDriverDto dto) {
        CollectorDriver entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id " + id));
        
        if (!entity.getEmployeeId().equals(dto.employeeId()) && repository.existsByEmployeeId(dto.employeeId())) {
            throw new RuntimeException("Employee with ID " + dto.employeeId() + " already exists.");
        }
        
        updateEntityFromDto(entity, dto);
        return toDto(repository.save(entity));
    }

    public void deactivateEmployee(Long id) {
        CollectorDriver entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id " + id));
        entity.setActive(false);
        entity.setStatus(EmployeeStatus.OFF_DUTY);
        repository.save(entity);
    }

    private void updateEntityFromDto(CollectorDriver entity, CollectorDriverDto dto) {
        entity.setEmployeeId(dto.employeeId());
        entity.setName(dto.name());
        entity.setPhone(dto.phone());
        entity.setRole(EmployeeRole.valueOf(dto.role().toUpperCase()));
        entity.setAssignedZone(dto.assignedZone());
        entity.setShift(dto.shift());
        entity.setStatus(EmployeeStatus.valueOf(dto.status().toUpperCase().replace(" ", "_")));
        entity.setActive(dto.active());
    }

    public CollectorDriverDto toDto(CollectorDriver entity) {
        return new CollectorDriverDto(
            entity.getId(),
            entity.getEmployeeId(),
            entity.getName(),
            entity.getPhone(),
            entity.getRole().name(),
            entity.getAssignedZone(),
            entity.getShift(),
            entity.getStatus().name(),
            entity.isActive()
        );
    }
}
