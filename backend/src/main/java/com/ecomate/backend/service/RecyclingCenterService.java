package com.ecomate.backend.service;

import com.ecomate.backend.dto.RecyclingCenterDto;
import com.ecomate.backend.entity.RecyclingCenter;
import com.ecomate.backend.entity.WasteCategory;
import com.ecomate.backend.repository.RecyclingCenterRepository;
import com.ecomate.backend.repository.WasteCategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RecyclingCenterService {

    private final RecyclingCenterRepository recyclingCenterRepository;
    private final WasteCategoryRepository wasteCategoryRepository;

    public RecyclingCenterService(RecyclingCenterRepository recyclingCenterRepository, WasteCategoryRepository wasteCategoryRepository) {
        this.recyclingCenterRepository = recyclingCenterRepository;
        this.wasteCategoryRepository = wasteCategoryRepository;
    }

    public List<RecyclingCenterDto> getAllRecyclingCenters() {
        return recyclingCenterRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public RecyclingCenterDto getRecyclingCenterById(String id) {
        RecyclingCenter center = recyclingCenterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Recycling Center not found with ID: " + id));
        return convertToDto(center);
    }

    public List<RecyclingCenterDto> getRecyclingCentersByMaterial(String wasteCategoryId) {
        WasteCategory category = wasteCategoryRepository.findById(wasteCategoryId)
                .orElseThrow(() -> new RuntimeException("Waste category not found: " + wasteCategoryId));

        final String categoryName = category.getName().toLowerCase(); // e.g. "plastics", "paper & cardboard", "glass" etc.

        return recyclingCenterRepository.findAll().stream()
                .filter(centre -> centre.getAcceptedMaterials().stream()
                        .anyMatch(material -> {
                            String m = material.toLowerCase();
                            // Match plastics, paper, cardboard, glass, metals, organic/compost, e-waste, electronics
                            if (categoryName.contains("plastic") && m.contains("plastic")) return true;
                            if (categoryName.contains("paper") && (m.contains("paper") || m.contains("cardboard"))) return true;
                            if (categoryName.contains("cardboard") && (m.contains("paper") || m.contains("cardboard"))) return true;
                            if (categoryName.contains("glass") && m.contains("glass")) return true;
                            if (categoryName.contains("metal") && (m.contains("metal") || m.contains("can") || m.contains("aluminum") || m.contains("tin"))) return true;
                            if (categoryName.contains("organic") && (m.contains("organic") || m.contains("compost") || m.contains("food") || m.contains("leaf") || m.contains("leaves") || m.contains("grass"))) return true;
                            if (categoryName.contains("e-waste") && (m.contains("e-waste") || m.contains("electronic") || m.contains("phone") || m.contains("computer"))) return true;
                            if (categoryName.contains("electronics") && (m.contains("e-waste") || m.contains("electronic") || m.contains("phone") || m.contains("computer"))) return true;
                            return m.contains(categoryName) || categoryName.contains(m);
                        })
                )
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public RecyclingCenterDto convertToDto(RecyclingCenter center) {
        return new RecyclingCenterDto(
                center.getId(),
                center.getName(),
                center.getAddress(),
                center.getCity(),
                center.getDistanceKm(),
                center.getContactNumber(),
                center.getEmail(),
                center.getOperatingHours(),
                center.isOpen(),
                center.getAcceptedMaterials(),
                center.getNotes()
        );
    }
}
