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

    private final RecyclingCenterService RecyclingCenterService;

    public RecyclingCenterController(RecyclingCenterService RecyclingCenterService) {
        this.RecyclingCenterService = RecyclingCenterService;
    }

    // 1. Get logged-in officer's Center
    @GetMapping("/my-Center")
    public ResponseEntity<RecyclingCenterResponse> getMyCenter(Authentication authentication) {
        String officerEmail = authentication.getName();
        RecyclingCenterResponse Center = RecyclingCenterService.getMyCenter(officerEmail);
        if (Center == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(Center);
    }

    // 2. Get master materials with is_active flag for logged-in officer's Center
    @GetMapping("/my-Center/materials")
    public ResponseEntity<List<MaterialDto>> getMyCenterMaterials(Authentication authentication) {
        String officerEmail = authentication.getName();
        List<MaterialDto> materials = RecyclingCenterService.getCenterMaterials(officerEmail);
        return ResponseEntity.ok(materials);
    }

    // 3. Toggle single material is_active (1 or 0) for logged-in officer's Center
    @PutMapping("/my-Center/materials/toggle")
    public ResponseEntity<RecyclingCenterResponse> toggleMaterial(
            Authentication authentication,
            @RequestBody CenterMaterialToggleRequest request) {
        String officerEmail = authentication.getName();
        RecyclingCenterResponse response = RecyclingCenterService.toggleMaterialStatus(
                officerEmail, request.getMaterialId(), request.getIsActive());
        return ResponseEntity.ok(response);
    }

    // 4. Create or Update logged-in officer's Center profile
    @PutMapping("/my-Center")
    public ResponseEntity<RecyclingCenterResponse> createOrUpdateMyCenter(
            Authentication authentication,
            @Valid @RequestBody RecyclingCenterRequest request) {
        String officerEmail = authentication.getName();
        RecyclingCenterResponse updated = RecyclingCenterService.createOrUpdateMyCenter(officerEmail, request);
        return ResponseEntity.ok(updated);
    }

    // 5. Toggle Open/Closed status
    @PatchMapping("/my-Center/status")
    public ResponseEntity<RecyclingCenterResponse> toggleStatus(
            Authentication authentication,
            @RequestBody Map<String, Boolean> statusPayload) {
        String officerEmail = authentication.getName();
        boolean isOpen = statusPayload.getOrDefault("isOpen", true);
        RecyclingCenterResponse updated = RecyclingCenterService.toggleStatus(officerEmail, isOpen);
        return ResponseEntity.ok(updated);
    }

    // 6. Public endpoint: All master materials (for Waste Segregation Guide)
    @GetMapping("/public/materials")
    public ResponseEntity<List<MaterialDto>> getPublicMaterials() {
        List<MaterialDto> materials = RecyclingCenterService.getAllMasterMaterials();
        return ResponseEntity.ok(materials);
    }

    // 7. Public endpoint: Search nearby Centers
    @GetMapping("/public/Centers")
    public ResponseEntity<List<RecyclingCenterResponse>> getPublicCenters(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String material) {
        List<RecyclingCenterResponse> Centers = RecyclingCenterService.getAllCenters(query, material);
        return ResponseEntity.ok(Centers);
    }

    // 8. Public endpoint: View specific Center
    @GetMapping("/public/Centers/{id}")
    public ResponseEntity<RecyclingCenterResponse> getCenterById(@PathVariable Long id) {
        RecyclingCenterResponse Center = RecyclingCenterService.getCenterById(id);
        return ResponseEntity.ok(Center);
    }

    // 9. Register a new recycling Center (e.g. from Municipal Dashboard or Officer)
    @PostMapping("/Centers")
    public ResponseEntity<RecyclingCenterResponse> createCenter(
            Authentication authentication,
            @Valid @RequestBody RecyclingCenterRequest request) {
        String email = authentication != null ? authentication.getName() : null;
        RecyclingCenterResponse created = RecyclingCenterService.createCenter(request, email);
        return ResponseEntity.ok(created);
    }

    // 10. Delete a recycling Center
    @DeleteMapping("/Centers/{id}")
    public ResponseEntity<Void> deleteCenter(@PathVariable Long id) {
        RecyclingCenterService.deleteCenter(id);
        return ResponseEntity.noContent().build();
    }
    @GetMapping("/Centers/by-material/{wasteCategoryId}")
    public ResponseEntity<List<RecyclingCenterResponse>> getCentersByMaterial(@PathVariable String wasteCategoryId) {
        List<RecyclingCenterResponse> Centers = RecyclingCenterService.getCentersByMaterial(wasteCategoryId);
        return ResponseEntity.ok(Centers);
    }
}

