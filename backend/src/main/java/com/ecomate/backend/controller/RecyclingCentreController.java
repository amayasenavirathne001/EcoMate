package com.ecomate.backend.controller;

import com.ecomate.backend.dto.*;
import com.ecomate.backend.service.RecyclingCentreService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recycling")
public class RecyclingCentreController {

    private final RecyclingCentreService recyclingCentreService;

    public RecyclingCentreController(RecyclingCentreService recyclingCentreService) {
        this.recyclingCentreService = recyclingCentreService;
    }

    // 1. Get logged-in officer's centre
    @GetMapping("/my-centre")
    public ResponseEntity<RecyclingCentreResponse> getMyCentre(Authentication authentication) {
        String officerEmail = authentication.getName();
        RecyclingCentreResponse centre = recyclingCentreService.getMyCentre(officerEmail);
        if (centre == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(centre);
    }

    // 2. Get master materials with is_active flag for logged-in officer's centre
    @GetMapping("/my-centre/materials")
    public ResponseEntity<List<MaterialDto>> getMyCentreMaterials(Authentication authentication) {
        String officerEmail = authentication.getName();
        List<MaterialDto> materials = recyclingCentreService.getCentreMaterials(officerEmail);
        return ResponseEntity.ok(materials);
    }

    // 3. Toggle single material is_active (1 or 0) for logged-in officer's centre
    @PutMapping("/my-centre/materials/toggle")
    public ResponseEntity<RecyclingCentreResponse> toggleMaterial(
            Authentication authentication,
            @RequestBody CentreMaterialToggleRequest request) {
        String officerEmail = authentication.getName();
        RecyclingCentreResponse response = recyclingCentreService.toggleMaterialStatus(
                officerEmail, request.getMaterialId(), request.getIsActive());
        return ResponseEntity.ok(response);
    }

    // 4. Create or Update logged-in officer's centre profile
    @PutMapping("/my-centre")
    public ResponseEntity<RecyclingCentreResponse> createOrUpdateMyCentre(
            Authentication authentication,
            @Valid @RequestBody RecyclingCentreRequest request) {
        String officerEmail = authentication.getName();
        RecyclingCentreResponse updated = recyclingCentreService.createOrUpdateMyCentre(officerEmail, request);
        return ResponseEntity.ok(updated);
    }

    // 5. Toggle Open/Closed status
    @PatchMapping("/my-centre/status")
    public ResponseEntity<RecyclingCentreResponse> toggleStatus(
            Authentication authentication,
            @RequestBody Map<String, Boolean> statusPayload) {
        String officerEmail = authentication.getName();
        boolean isOpen = statusPayload.getOrDefault("isOpen", true);
        RecyclingCentreResponse updated = recyclingCentreService.toggleStatus(officerEmail, isOpen);
        return ResponseEntity.ok(updated);
    }

    // 6. Public endpoint: All master materials (for Waste Segregation Guide)
    @GetMapping("/public/materials")
    public ResponseEntity<List<MaterialDto>> getPublicMaterials() {
        List<MaterialDto> materials = recyclingCentreService.getAllMasterMaterials();
        return ResponseEntity.ok(materials);
    }

    // 7. Public endpoint: Search nearby centres
    @GetMapping("/public/centres")
    public ResponseEntity<List<RecyclingCentreResponse>> getPublicCentres(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String material) {
        List<RecyclingCentreResponse> centres = recyclingCentreService.getAllCentres(query, material);
        return ResponseEntity.ok(centres);
    }

    // 8. Public endpoint: View specific centre
    @GetMapping("/public/centres/{id}")
    public ResponseEntity<RecyclingCentreResponse> getCentreById(@PathVariable Long id) {
        RecyclingCentreResponse centre = recyclingCentreService.getCentreById(id);
        return ResponseEntity.ok(centre);
    }
}