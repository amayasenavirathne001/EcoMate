package com.ecomate.backend.controller;

import com.ecomate.backend.dto.SmartAlertDto;
import com.ecomate.backend.entity.AlertStatus;
import com.ecomate.backend.service.SmartAlertService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/municipal/alerts")
public class SmartAlertController {

    private final SmartAlertService smartAlertService;

    public SmartAlertController(SmartAlertService smartAlertService) {
        this.smartAlertService = smartAlertService;
    }

    @GetMapping
    public ResponseEntity<List<SmartAlertDto>> getAllAlerts() {
        return ResponseEntity.ok(smartAlertService.getAllAlerts());
    }

    @GetMapping("/active")
    public ResponseEntity<List<SmartAlertDto>> getActiveAlerts() {
        return ResponseEntity.ok(smartAlertService.getActiveAlerts());
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<SmartAlertDto> updateAlertStatus(@PathVariable Long id, @RequestParam AlertStatus status) {
        return ResponseEntity.ok(smartAlertService.updateAlertStatus(id, status));
    }
}
