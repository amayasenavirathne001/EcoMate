package com.ecomate.backend.controller;

import com.ecomate.backend.dto.MunicipalDashboardResponse;
import com.ecomate.backend.service.MunicipalDashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/municipal")
public class MunicipalDashboardController {

    private final MunicipalDashboardService dashboardService;

    public MunicipalDashboardController(MunicipalDashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/dashboard")
    public ResponseEntity<MunicipalDashboardResponse> getDashboard() {
        MunicipalDashboardResponse data = dashboardService.getDashboardData();
        return ResponseEntity.ok(data);
    }
}
