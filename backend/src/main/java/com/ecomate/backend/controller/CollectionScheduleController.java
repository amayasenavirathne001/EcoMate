package com.ecomate.backend.controller;

import com.ecomate.backend.dto.CollectionScheduleDto;
import com.ecomate.backend.service.CollectionScheduleService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/collection-schedules")
public class CollectionScheduleController {

    private final CollectionScheduleService scheduleService;

    public CollectionScheduleController(CollectionScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @GetMapping
    public ResponseEntity<List<CollectionScheduleDto>> getAllSchedules() {
        return ResponseEntity.ok(scheduleService.getAllSchedules());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CollectionScheduleDto> getScheduleById(@PathVariable Long id) {
        return ResponseEntity.ok(scheduleService.getScheduleById(id));
    }

    @PostMapping
    public ResponseEntity<CollectionScheduleDto> createSchedule(@RequestBody CollectionScheduleDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(scheduleService.createSchedule(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CollectionScheduleDto> updateSchedule(@PathVariable Long id, @RequestBody CollectionScheduleDto dto) {
        return ResponseEntity.ok(scheduleService.updateSchedule(id, dto));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<CollectionScheduleDto> updateScheduleStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String status = body.get("status");
        return ResponseEntity.ok(scheduleService.updateScheduleStatus(id, status));
    }
}
