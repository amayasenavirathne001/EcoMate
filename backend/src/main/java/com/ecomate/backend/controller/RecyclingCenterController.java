package com.ecomate.backend.controller;

import com.ecomate.backend.dto.RecyclingCenterDto;
import com.ecomate.backend.service.RecyclingCenterService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/recycling-centers")
public class RecyclingCenterController {

    private final RecyclingCenterService recyclingCenterService;

    public RecyclingCenterController(RecyclingCenterService recyclingCenterService) {
        this.recyclingCenterService = recyclingCenterService;
    }

    @GetMapping
    public ResponseEntity<List<RecyclingCenterDto>> getAllRecyclingCenters() {
        return ResponseEntity.ok(recyclingCenterService.getAllRecyclingCenters());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RecyclingCenterDto> getRecyclingCenterById(@PathVariable String id) {
        return ResponseEntity.ok(recyclingCenterService.getRecyclingCenterById(id));
    }

    @GetMapping("/by-material/{wasteCategoryId}")
    public ResponseEntity<List<RecyclingCenterDto>> getRecyclingCentersByMaterial(@PathVariable String wasteCategoryId) {
        return ResponseEntity.ok(recyclingCenterService.getRecyclingCentersByMaterial(wasteCategoryId));
    }
}
