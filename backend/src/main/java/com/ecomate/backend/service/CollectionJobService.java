package com.ecomate.backend.service;

import com.ecomate.backend.dto.CollectionJobDto;
import com.ecomate.backend.entity.CollectionJob;
import com.ecomate.backend.repository.CollectionJobRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CollectionJobService {

    private final CollectionJobRepository repository;

    public CollectionJobService(CollectionJobRepository repository) {
        this.repository = repository;
    }

    public List<CollectionJobDto> getAllJobs() {
        return repository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<CollectionJobDto> getUnassignedJobs() {
        return repository.findByStatus("SCHEDULED").stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public CollectionJobDto getJobById(Long id) {
        CollectionJob entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Job not found with id " + id));
        return toDto(entity);
    }

    public CollectionJobDto createJob(CollectionJobDto dto) {
        CollectionJob entity = new CollectionJob();
        updateEntityFromDto(entity, dto);
        return toDto(repository.save(entity));
    }

    public CollectionJobDto updateJob(Long id, CollectionJobDto dto) {
        CollectionJob entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Job not found with id " + id));
        updateEntityFromDto(entity, dto);
        return toDto(repository.save(entity));
    }

    public void deleteJob(Long id) {
        repository.deleteById(id);
    }

    private void updateEntityFromDto(CollectionJob entity, CollectionJobDto dto) {
        entity.setRouteId(dto.routeId());
        entity.setTitle(dto.title());
        entity.setDescription(dto.description());
        entity.setZone(dto.zone());
        entity.setStartTime(dto.startTime());
        entity.setEndTime(dto.endTime());
        entity.setStatus(dto.status());
    }

    public CollectionJobDto toDto(CollectionJob entity) {
        return new CollectionJobDto(
            entity.getId(),
            entity.getRouteId(),
            entity.getTitle(),
            entity.getDescription(),
            entity.getZone(),
            entity.getStartTime(),
            entity.getEndTime(),
            entity.getStatus()
        );
    }
}
