package com.ecomate.backend.controller;

import com.ecomate.backend.dto.*;
import com.ecomate.backend.service.RecyclingCenterService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recycling")
public class RecyclingCenterController {

    private final RecyclingCenterService recyclingCenterService;

    public RecyclingCenterController(RecyclingCenterService recyclingCenterService) {
        this.recyclingCenterService = recyclingCenterService;
    }

    // 1. Get logged-in officer's Center
    @GetMapping("/my-center")
    public ResponseEntity<RecyclingCenterResponse> getMyCenter(Authentication authentication) {
        String officerEmail = authentication.getName();
        RecyclingCenterResponse center = recyclingCenterService.getMyCenter(officerEmail);
        if (center == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(center);
    }

    // 2. Get master materials with is_active flag for logged-in officer's Center
    @GetMapping("/my-center/materials")
    public ResponseEntity<List<MaterialDto>> getMyCenterMaterials(Authentication authentication) {
        String officerEmail = authentication.getName();
        List<MaterialDto> materials = recyclingCenterService.getCenterMaterials(officerEmail);
        return ResponseEntity.ok(materials);
    }

    // 3. Toggle single material is_active (1 or 0) for logged-in officer's Center
    @PutMapping("/my-center/materials/toggle")
    public ResponseEntity<RecyclingCenterResponse> toggleMaterial(
            Authentication authentication,
            @RequestBody CenterMaterialToggleRequest request) {
        String officerEmail = authentication.getName();
        RecyclingCenterResponse response = recyclingCenterService.toggleMaterialStatus(
                officerEmail, request.getMaterialId(), request.getIsActive());
        return ResponseEntity.ok(response);
    }

    // 4. Create or Update logged-in officer's Center profile
    @PutMapping("/my-center")
    public ResponseEntity<RecyclingCenterResponse> createOrUpdateMyCenter(
            Authentication authentication,
            @Valid @RequestBody RecyclingCenterRequest request) {
        String officerEmail = authentication.getName();
        RecyclingCenterResponse updated = recyclingCenterService.createOrUpdateMyCenter(officerEmail, request);
        return ResponseEntity.ok(updated);
    }

    // 5. Toggle Open/Closed status
    @PatchMapping("/my-center/status")
    public ResponseEntity<RecyclingCenterResponse> toggleStatus(
            Authentication authentication,
            @RequestBody Map<String, Boolean> statusPayload) {
        String officerEmail = authentication.getName();
        boolean isOpen = statusPayload.getOrDefault("isOpen", true);
        RecyclingCenterResponse updated = recyclingCenterService.toggleStatus(officerEmail, isOpen);
        return ResponseEntity.ok(updated);
    }

    // 6. Public endpoint: All master materials (for Waste Segregation Guide)
    @GetMapping("/public/materials")
    public ResponseEntity<List<MaterialDto>> getPublicMaterials() {
        List<MaterialDto> materials = recyclingCenterService.getAllMasterMaterials();
        return ResponseEntity.ok(materials);
    }

    // 7. Public endpoint: Search nearby Centers
    @GetMapping("/public/centers")
    public ResponseEntity<List<RecyclingCenterResponse>> getPublicCenters(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String material) {
        List<RecyclingCenterResponse> centers = recyclingCenterService.getAllCenters(query, material);
        return ResponseEntity.ok(centers);
    }

    // 8. Public endpoint: View specific Center
    @GetMapping("/public/centers/{id}")
    public ResponseEntity<RecyclingCenterResponse> getCenterById(@PathVariable Long id) {
        RecyclingCenterResponse center = recyclingCenterService.getCenterById(id);
        return ResponseEntity.ok(center);
    }

    // 9. Register a new recycling Center (e.g. from Municipal Dashboard or Officer)
    @PostMapping("/centers")
    public ResponseEntity<RecyclingCenterResponse> createCenter(
            Authentication authentication,
            @Valid @RequestBody RecyclingCenterRequest request) {
        String email = authentication != null ? authentication.getName() : null;
        RecyclingCenterResponse created = recyclingCenterService.createCenter(request, email);
        return ResponseEntity.ok(created);
    }

    // 10. Delete a recycling Center
    @DeleteMapping("/centers/{id}")
    public ResponseEntity<Void> deleteCenter(@PathVariable Long id) {
        recyclingCenterService.deleteCenter(id);
        return ResponseEntity.noContent().build();
    }
    @GetMapping("/centers/by-material/{wasteCategoryId}")
    public ResponseEntity<List<RecyclingCenterResponse>> getCentersByMaterial(@PathVariable String wasteCategoryId) {
        List<RecyclingCenterResponse> centers = recyclingCenterService.getCentersByMaterial(wasteCategoryId);
        return ResponseEntity.ok(centers);
    }
}




