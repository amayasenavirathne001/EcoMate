package com.ecomate.backend.service;

import com.ecomate.backend.dto.VehicleDto;
import com.ecomate.backend.entity.Vehicle;
import com.ecomate.backend.entity.VehicleStatus;
import com.ecomate.backend.repository.VehicleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class VehicleService {

    private final VehicleRepository repository;

    public VehicleService(VehicleRepository repository) {
        this.repository = repository;
    }

    public List<VehicleDto> getAllVehicles() {
        return repository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<VehicleDto> getActiveVehicles() {
        return repository.findByActive(true).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public VehicleDto getVehicleById(Long id) {
        Vehicle entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found with id " + id));
        return toDto(entity);
    }

    public VehicleDto createVehicle(VehicleDto dto) {
        if (repository.existsByRegistrationNumber(dto.registrationNumber())) {
            throw new RuntimeException("Vehicle with registration number " + dto.registrationNumber() + " already exists.");
        }
        Vehicle entity = new Vehicle();
        updateEntityFromDto(entity, dto);
        entity.setActive(true);
        return toDto(repository.save(entity));
    }

    public VehicleDto updateVehicle(Long id, VehicleDto dto) {
        Vehicle entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found with id " + id));

        if (!entity.getRegistrationNumber().equals(dto.registrationNumber()) && repository.existsByRegistrationNumber(dto.registrationNumber())) {
            throw new RuntimeException("Vehicle with registration number " + dto.registrationNumber() + " already exists.");
        }

        updateEntityFromDto(entity, dto);
        return toDto(repository.save(entity));
    }

    public void deactivateVehicle(Long id) {
        Vehicle entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found with id " + id));
        entity.setActive(false);
        entity.setStatus(VehicleStatus.INACTIVE);
        repository.save(entity);
    }

    private void updateEntityFromDto(Vehicle entity, VehicleDto dto) {
        entity.setRegistrationNumber(dto.registrationNumber());
        entity.setVehicleType(dto.vehicleType());
        entity.setCapacity(dto.capacity());
        entity.setStatus(VehicleStatus.valueOf(dto.status().toUpperCase().replace(" ", "_")));
        entity.setLastServiceDate(dto.lastServiceDate());
        entity.setNextServiceDate(dto.nextServiceDate());
        entity.setActive(dto.active());
    }

    public VehicleDto toDto(Vehicle entity) {
        return new VehicleDto(
            entity.getId(),
            entity.getRegistrationNumber(),
            entity.getVehicleType(),
            entity.getCapacity(),
            entity.getStatus().name(),
            entity.getLastServiceDate(),
            entity.getNextServiceDate(),
            entity.isActive()
        );
    }
}
