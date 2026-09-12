package com.ecomate.backend.controller;

import com.ecomate.backend.dto.WasteCategoryDto;
import com.ecomate.backend.entity.WasteCategory;
import com.ecomate.backend.repository.WasteCategoryRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
                .map(cat -> new WasteCategoryDto(cat.getId(), cat.getName(), cat.isRecyclable()))
                .collect(Collectors.toList());
        return ResponseEntity.ok(categories);
    }
}
