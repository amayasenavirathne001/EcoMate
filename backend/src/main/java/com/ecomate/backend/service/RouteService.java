package com.ecomate.backend.service;

import com.ecomate.backend.dto.RouteDto;
import com.ecomate.backend.entity.Route;
import com.ecomate.backend.repository.RouteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RouteService {

    private final RouteRepository routeRepository;

    public RouteService(RouteRepository routeRepository) {
        this.routeRepository = routeRepository;
    }

    public List<RouteDto> getAllRoutes() {
        return routeRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public RouteDto getRouteById(Long id) {
        Route route = routeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Route not found with ID: " + id));
        return convertToDto(route);
    }

    @Transactional
    public RouteDto createRoute(RouteDto dto) {
        Route route = new Route();
        route.setRouteCode(dto.getRouteCode());
        route.setRouteName(dto.getRouteName());
        route.setAreaOrZone(dto.getAreaOrZone());
        route.setDescription(dto.getDescription());
        if (dto.getStatus() != null) {
            route.setStatus(dto.getStatus());
        }
        Route saved = routeRepository.save(route);
        return convertToDto(saved);
    }

    @Transactional
    public RouteDto updateRoute(Long id, RouteDto dto) {
        Route route = routeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Route not found with ID: " + id));
        route.setRouteCode(dto.getRouteCode());
        route.setRouteName(dto.getRouteName());
        route.setAreaOrZone(dto.getAreaOrZone());
        route.setDescription(dto.getDescription());
        if (dto.getStatus() != null) {
            route.setStatus(dto.getStatus());
        }
        Route updated = routeRepository.save(route);
        return convertToDto(updated);
    }

    @Transactional
    public RouteDto updateRouteStatus(Long id, String status) {
        Route route = routeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Route not found with ID: " + id));
        route.setStatus(status);
        Route updated = routeRepository.save(route);
        return convertToDto(updated);
    }

    private RouteDto convertToDto(Route route) {
        return new RouteDto(
                route.getId(),
                route.getRouteCode(),
                route.getRouteName(),
                route.getAreaOrZone(),
                route.getDescription(),
                route.getStatus()
        );
    }
}
