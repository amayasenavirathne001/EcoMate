package com.ecomate.backend.service;

import com.ecomate.backend.dto.*;
import com.ecomate.backend.entity.*;
import com.ecomate.backend.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CollectionScheduleService {

    private final CollectionScheduleRepository scheduleRepository;
    private final RouteRepository routeRepository;
    private final WasteCategoryRepository wasteCategoryRepository;
    private final RecyclingCenterRepository recyclingCenterRepository;
    private final RecyclingCenterService recyclingCenterService;

    public CollectionScheduleService(CollectionScheduleRepository scheduleRepository,
                                     RouteRepository routeRepository,
                                     WasteCategoryRepository wasteCategoryRepository,
                                     RecyclingCenterRepository recyclingCenterRepository,
                                     RecyclingCenterService recyclingCenterService) {
        this.scheduleRepository = scheduleRepository;
        this.routeRepository = routeRepository;
        this.wasteCategoryRepository = wasteCategoryRepository;
        this.recyclingCenterRepository = recyclingCenterRepository;
        this.recyclingCenterService = recyclingCenterService;
    }

    public List<CollectionScheduleDto> getAllSchedules() {
        return scheduleRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public CollectionScheduleDto getScheduleById(Long id) {
        CollectionSchedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Schedule not found with ID: " + id));
        return convertToDto(schedule);
    }

    @Transactional
    public CollectionScheduleDto createSchedule(CollectionScheduleDto dto) {
        CollectionSchedule schedule = new CollectionSchedule();
        updateEntityFromDto(schedule, dto);
        CollectionSchedule saved = scheduleRepository.save(schedule);
        return convertToDto(saved);
    }

    @Transactional
    public CollectionScheduleDto updateSchedule(Long id, CollectionScheduleDto dto) {
        CollectionSchedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Schedule not found with ID: " + id));
        updateEntityFromDto(schedule, dto);
        CollectionSchedule updated = scheduleRepository.save(schedule);
        return convertToDto(updated);
    }

    @Transactional
    public CollectionScheduleDto updateScheduleStatus(Long id, String status) {
        CollectionSchedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Schedule not found with ID: " + id));
        schedule.setStatus(status);
        CollectionSchedule updated = scheduleRepository.save(schedule);
        return convertToDto(updated);
    }

    private void updateEntityFromDto(CollectionSchedule schedule, CollectionScheduleDto dto) {
        schedule.setScheduleName(dto.getScheduleName());
        schedule.setAreaOrZone(dto.getAreaOrZone());
        schedule.setCollectionDateOrDay(dto.getCollectionDateOrDay());
        schedule.setStartTime(dto.getStartTime());
        schedule.setEndTime(dto.getEndTime());
        schedule.setFrequency(dto.getFrequency());
        schedule.setDestinationType(dto.getDestinationType());

        if (dto.getStatus() != null) {
            schedule.setStatus(dto.getStatus());
        }
        if (dto.getResourceStatus() != null) {
            schedule.setResourceStatus(dto.getResourceStatus());
        }

        Route route = routeRepository.findById(dto.getRouteId())
                .orElseThrow(() -> new RuntimeException("Route not found with ID: " + dto.getRouteId()));
        schedule.setRoute(route);

        WasteCategory category = wasteCategoryRepository.findById(dto.getWasteCategoryId())
                .orElseThrow(() -> new RuntimeException("Waste category not found with ID: " + dto.getWasteCategoryId()));
        schedule.setWasteCategory(category);

        if ("Recycling Centre".equalsIgnoreCase(dto.getDestinationType()) && dto.getRecyclingCenterId() != null) {
            RecyclingCenter center = recyclingCenterRepository.findById(dto.getRecyclingCenterId())
                    .orElseThrow(() -> new RuntimeException("Recycling Center not found with ID: " + dto.getRecyclingCenterId()));
            schedule.setRecyclingCenter(center);
        } else {
            schedule.setRecyclingCenter(null);
        }
    }

    private CollectionScheduleDto convertToDto(CollectionSchedule schedule) {
        CollectionScheduleDto dto = new CollectionScheduleDto();
        dto.setId(schedule.getId());
        dto.setScheduleName(schedule.getScheduleName());
        dto.setAreaOrZone(schedule.getAreaOrZone());
        dto.setCollectionDateOrDay(schedule.getCollectionDateOrDay());
        dto.setStartTime(schedule.getStartTime());
        dto.setEndTime(schedule.getEndTime());
        dto.setFrequency(schedule.getFrequency());
        dto.setDestinationType(schedule.getDestinationType());
        dto.setStatus(schedule.getStatus());
        dto.setResourceStatus(schedule.getResourceStatus());

        dto.setRouteId(schedule.getRoute().getId());
        dto.setRoute(new RouteDto(
                schedule.getRoute().getId(),
                schedule.getRoute().getRouteCode(),
                schedule.getRoute().getRouteName(),
                schedule.getRoute().getAreaOrZone(),
                schedule.getRoute().getDescription(),
                schedule.getRoute().getStatus()
        ));

        dto.setWasteCategoryId(schedule.getWasteCategory().getId());
        dto.setWasteCategory(new WasteCategoryDto(
                schedule.getWasteCategory().getId(),
                schedule.getWasteCategory().getName(),
                schedule.getWasteCategory().isRecyclable()
        ));

        if (schedule.getRecyclingCenter() != null) {
            dto.setRecyclingCenterId(schedule.getRecyclingCenter().getId());
            dto.setRecyclingCenter(recyclingCenterService.convertToDto(schedule.getRecyclingCenter()));
        }

        return dto;
    }
}
