package com.ecomate.backend.specialpickup.controller;

import com.ecomate.backend.specialpickup.dto.SpecialPickupScheduleRequest;
import com.ecomate.backend.specialpickup.entity.SpecialPickupSchedule;
import com.ecomate.backend.specialpickup.service.SpecialPickupScheduleService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/special-pickup-schedules")
@CrossOrigin(origins = "*")
public class SpecialPickupScheduleController {

    private final SpecialPickupScheduleService scheduleService;

    public SpecialPickupScheduleController(
            SpecialPickupScheduleService scheduleService) {

        this.scheduleService = scheduleService;
    }

    // TEMPORARILY using adminId query parameter.
    // Later we can obtain the logged-in admin from JWT/security.

    @PostMapping
    public ResponseEntity<SpecialPickupSchedule> createSchedule(
            @RequestBody SpecialPickupScheduleRequest request,
            @RequestParam(defaultValue = "1") Long adminId) {

        SpecialPickupSchedule schedule =
                scheduleService.createSchedule(
                        request,
                        adminId
                );

        return ResponseEntity.ok(schedule);
    }

    @GetMapping
    public ResponseEntity<List<SpecialPickupSchedule>>
    getSchedules() {

        return ResponseEntity.ok(
                scheduleService.getActiveSchedules()
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<SpecialPickupSchedule>
    getSchedule(@PathVariable Long id) {

        return ResponseEntity.ok(
                scheduleService.getSchedule(id)
        );
    }

    @PutMapping("/{id}/disable")
    public ResponseEntity<SpecialPickupSchedule>
    disableSchedule(@PathVariable Long id) {

        return ResponseEntity.ok(
                scheduleService.disableSchedule(id)
        );
    }
}