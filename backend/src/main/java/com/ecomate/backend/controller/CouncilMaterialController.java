package com.ecomate.backend.controller;

import com.ecomate.backend.dto.MaterialDto;
import com.ecomate.backend.entity.Material;
import com.ecomate.backend.repository.MaterialRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/council/materials")
public class CouncilMaterialController {

    private final MaterialRepository materialRepository;

    public CouncilMaterialController(MaterialRepository materialRepository) {
        this.materialRepository = materialRepository;
    }

    // 1. Get all materials for council management
    @GetMapping
    public ResponseEntity<List<MaterialDto>> getAllMaterials() {
        List<MaterialDto> list = materialRepository.findAll().stream()
                .map(MaterialDto::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(list);
    }

    // 2. Add new material to master segregation guide
    @PostMapping
    public ResponseEntity<MaterialDto> addMaterial(@Valid @RequestBody MaterialDto dto) {
        Material material = new Material();
        material.setName(dto.getName());
        material.setCategory(dto.getCategory());
        material.setDescription(dto.getDescription() != null ? dto.getDescription() : "");
        material.setImageUrl(dto.getImageUrl() != null ? dto.getImageUrl() : "");
        material.setBinColor(dto.getBinColor() != null ? dto.getBinColor() : "#2E7D32");
        material.setIsRecyclable(dto.getIsRecyclable() != null ? dto.getIsRecyclable() : true);
        material.setPreparationTips(dto.getPreparationTips() != null ? dto.getPreparationTips() : "");
        material.setCreatedAt(LocalDateTime.now());
        material.setUpdatedAt(LocalDateTime.now());

        Material saved = materialRepository.save(material);
        return ResponseEntity.ok(MaterialDto.fromEntity(saved));
    }

    // 3. Update existing material in master segregation guide
    @PutMapping("/{id}")
    public ResponseEntity<MaterialDto> updateMaterial(@PathVariable Long id, @Valid @RequestBody MaterialDto dto) {
        Material material = materialRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Material not found with id: " + id));

        material.setName(dto.getName());
        material.setCategory(dto.getCategory());
        if (dto.getDescription() != null) material.setDescription(dto.getDescription());
        if (dto.getImageUrl() != null) material.setImageUrl(dto.getImageUrl());
        if (dto.getBinColor() != null) material.setBinColor(dto.getBinColor());
        if (dto.getIsRecyclable() != null) material.setIsRecyclable(dto.getIsRecyclable());
        if (dto.getPreparationTips() != null) material.setPreparationTips(dto.getPreparationTips());
        material.setUpdatedAt(LocalDateTime.now());

        Material saved = materialRepository.save(material);
        return ResponseEntity.ok(MaterialDto.fromEntity(saved));
    }

    // 4. Delete material
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMaterial(@PathVariable Long id) {
        materialRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}