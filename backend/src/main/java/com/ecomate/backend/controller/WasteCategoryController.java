package com.ecomate.backend.controller;

import com.ecomate.backend.dto.WasteCategoryDto;
import com.ecomate.backend.entity.WasteCategory;
import com.ecomate.backend.repository.WasteCategoryRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/waste-categories")
public class WasteCategoryController {

    private final WasteCategoryRepository wasteCategoryRepository;

    public WasteCategoryController(WasteCategoryRepository wasteCategoryRepository) {
        this.wasteCategoryRepository = wasteCategoryRepository;
    }

    @GetMapping
    public ResponseEntity<List<WasteCategoryDto>> getAllCategories() {
        List<WasteCategoryDto> categories = wasteCategoryRepository.findAll().stream()
                .map(cat -> {
                    WasteCategoryDto dto = new WasteCategoryDto();
                    dto.setId(cat.getId());
                    dto.setName(cat.getName());
                    dto.setRecyclable(cat.isRecyclable());
                    dto.setDescription(cat.getDescription());
                    dto.setBinColor(cat.getBinColor());
                    dto.setBinColorName(cat.getBinColorName());
                    dto.setIcon(cat.getIcon());
                    dto.setCommonItems(cat.getCommonItems());
                    dto.setPreparationSteps(cat.getPreparationSteps());
                    dto.setDos(cat.getDos());
                    dto.setDonts(cat.getDonts());
                    return dto;
                })
                .collect(Collectors.toList());
        return ResponseEntity.ok(categories);
    }
    @Transactional
    @PutMapping("/{id}")
    public ResponseEntity<WasteCategoryDto> updateCategory(@PathVariable String id, @RequestBody WasteCategoryDto dto) {
        return wasteCategoryRepository.findById(id)
                .map(cat -> {
                    // Update main fields
                    cat.setName(dto.getName());
                    cat.setRecyclable(dto.isRecyclable() != null ? dto.isRecyclable() : false);
                    cat.setDescription(dto.getDescription());
                    cat.setBinColor(dto.getBinColor());
                    cat.setBinColorName(dto.getBinColorName());
                    cat.setIcon(dto.getIcon());
                    
                    // Update collections
                    cat.setCommonItems(dto.getCommonItems());
                    cat.setPreparationSteps(dto.getPreparationSteps());
                    cat.setDos(dto.getDos());
                    cat.setDonts(dto.getDonts());
                    
                    WasteCategory savedCat = wasteCategoryRepository.save(cat);
                    
                    WasteCategoryDto updatedDto = new WasteCategoryDto();
                    updatedDto.setId(savedCat.getId());
                    updatedDto.setName(savedCat.getName());
                    updatedDto.setRecyclable(savedCat.isRecyclable());
                    updatedDto.setDescription(savedCat.getDescription());
                    updatedDto.setBinColor(savedCat.getBinColor());
                    updatedDto.setBinColorName(savedCat.getBinColorName());
                    updatedDto.setIcon(savedCat.getIcon());
                    updatedDto.setCommonItems(savedCat.getCommonItems());
                    updatedDto.setPreparationSteps(savedCat.getPreparationSteps());
                    updatedDto.setDos(savedCat.getDos());
                    updatedDto.setDonts(savedCat.getDonts());
                    return ResponseEntity.ok(updatedDto);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @org.springframework.web.bind.annotation.PostMapping
    public ResponseEntity<WasteCategoryDto> createCategory(@RequestBody WasteCategoryDto dto) {
        String newId = dto.getId() != null && !dto.getId().trim().isEmpty() 
            ? dto.getId() 
            : dto.getName().toLowerCase().replaceAll("[^a-z0-9]", "_");
            
        if(wasteCategoryRepository.existsById(newId)) {
            return ResponseEntity.badRequest().build();
        }
        
        WasteCategory cat = new WasteCategory();
        cat.setId(newId);
        cat.setName(dto.getName());
        cat.setRecyclable(dto.isRecyclable() != null ? dto.isRecyclable() : false);
        cat.setDescription(dto.getDescription());
        cat.setBinColor(dto.getBinColor());
        cat.setBinColorName(dto.getBinColorName());
        cat.setIcon(dto.getIcon());
        cat.setCommonItems(dto.getCommonItems());
        cat.setPreparationSteps(dto.getPreparationSteps());
        cat.setDos(dto.getDos());
        cat.setDonts(dto.getDonts());
        
        WasteCategory savedCat = wasteCategoryRepository.save(cat);
        dto.setId(savedCat.getId());
        return ResponseEntity.ok(dto);
    }

    @org.springframework.web.bind.annotation.DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable String id) {
        if(!wasteCategoryRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        wasteCategoryRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}





