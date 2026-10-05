package com.ecomate.backend.service;

import com.ecomate.backend.entity.Route;
import com.ecomate.backend.repository.RouteRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;


@Service
public class DataSeederService {

  
    private final RouteRepository routeRepository;

    public DataSeederService( RouteRepository routeRepository) {
       
        this.routeRepository = routeRepository;
    }

    @PostConstruct
    @Transactional
    public void seedData() {
         // ONLY SEED IF EMPTY
       
        // Seed Routes
        if (routeRepository.count() == 0) {
            routeRepository.saveAll(List.of(
                new Route("ROUTE-A", "Route A - Greenfield Residential", "Zone A", "Covers primary residential area of Greenfield", "ACTIVE"),
                new Route("ROUTE-B", "Route B - Downtown Commercial", "Zone B", "Commercial district and main street shops", "ACTIVE"),
                new Route("ROUTE-C", "Route C - Westside Industrial", "Zone C", "Industrial park and large facility collection", "ACTIVE")
            ));
        }
    }
}










