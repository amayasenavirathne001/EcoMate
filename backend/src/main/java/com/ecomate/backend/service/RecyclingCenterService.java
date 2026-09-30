package com.ecomate.backend.service;

import com.ecomate.backend.dto.*;
import com.ecomate.backend.entity.*;
import com.ecomate.backend.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class RecyclingCenterService {

    private final RecyclingCenterRepository recyclingCenterRepository;
    private final MaterialRepository materialRepository;
    private final RecyclingCenterMaterialRepository recyclingCenterMaterialRepository;
    private final UserRepository userRepository;

    public RecyclingCenterService(RecyclingCenterRepository recyclingCenterRepository,
                                  MaterialRepository materialRepository,
                                  RecyclingCenterMaterialRepository recyclingCenterMaterialRepository,
                                  UserRepository userRepository) {
        this.recyclingCenterRepository = recyclingCenterRepository;
        this.materialRepository = materialRepository;
        this.recyclingCenterMaterialRepository = recyclingCenterMaterialRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public RecyclingCenterResponse getMyCenter(String officerEmail) {
        return recyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail)
                .map(RecyclingCenterResponse::fromEntity)
                .orElse(null);
    }

    @Transactional(readOnly = true)
    public List<MaterialDto> getAllMasterMaterials() {
        return materialRepository.findAll().stream()
                .map(MaterialDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<MaterialDto> getCenterMaterials(String officerEmail) {
        Optional<RecyclingCenter> centerOpt = recyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail);
        if (centerOpt.isEmpty()) {
            return java.util.Collections.emptyList();
        }
        RecyclingCenter center = centerOpt.get();

        List<Material> allMaterials = materialRepository.findAll();
        List<RecyclingCenterMaterial> mappings = recyclingCenterMaterialRepository.findByRecyclingCenterId(center.getId());

        return allMaterials.stream().map(mat -> {
            Optional<RecyclingCenterMaterial> mapOpt = mappings.stream()
                    .filter(m -> m.getMaterial().getId().equals(mat.getId()))
                    .findFirst();
            boolean isActive = mapOpt.map(RecyclingCenterMaterial::getIsActive).orElse(false);
            return MaterialDto.fromEntityWithStatus(mat, isActive);
        }).collect(Collectors.toList());
    }

    @Transactional
    public RecyclingCenterResponse toggleMaterialStatus(String officerEmail, Long materialId, Boolean isActive) {
                Optional<RecyclingCenter> centerOpt = recyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail);
        if (centerOpt.isEmpty()) { throw new RuntimeException("center not found"); }
        RecyclingCenter center = centerOpt.get();

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() -> new RuntimeException("Material not found with id: " + materialId));

        Optional<RecyclingCenterMaterial> existingMapping = recyclingCenterMaterialRepository
                .findByRecyclingCenterIdAndMaterialId(center.getId(), materialId);

        if (existingMapping.isPresent()) {
            RecyclingCenterMaterial mapping = existingMapping.get();
            mapping.setIsActive(isActive);
            recyclingCenterMaterialRepository.save(mapping);
        } else {
            RecyclingCenterMaterial newMapping = new RecyclingCenterMaterial(center, material, isActive);
            recyclingCenterMaterialRepository.save(newMapping);
        }

        return getMyCenter(officerEmail);
    }

    @Transactional
    public RecyclingCenterResponse createOrUpdateMyCenter(String officerEmail, RecyclingCenterRequest request) {
        Optional<RecyclingCenter> existingOpt = recyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail);
        RecyclingCenter center;

        if (existingOpt.isPresent()) {
            center = existingOpt.get();
        } else {
            center = new RecyclingCenter();
            center.setOfficerEmail(officerEmail);
            userRepository.findByEmail(officerEmail).ifPresent(center::setOfficer);
        }

        center.setName(request.getName());
        center.setAddress(request.getAddress());
        center.setCity(request.getCity());
        center.setContactNumber(request.getContactNumber());
        center.setEmail(request.getEmail());

        if (request.getOperatingHours() != null) {
            center.setOperatingHours(request.getOperatingHours());
        }
        if (request.getIsOpen() != null) {
            center.setIsOpen(request.getIsOpen());
        }
                if (request.getNotes() != null) {
            center.setNotes(request.getNotes());
        }
        if (request.getLatitude() != null) {
            center.setLatitude(request.getLatitude());
        }
        if (request.getLongitude() != null) {
            center.setLongitude(request.getLongitude());
        }

        RecyclingCenter saved = recyclingCenterRepository.save(center);
        return RecyclingCenterResponse.fromEntity(saved);
    }

    @Transactional
    public RecyclingCenterResponse createCenter(RecyclingCenterRequest request, String createdByEmail) {
        String assignedOfficerEmail = request.getEmail() != null && !request.getEmail().isBlank()
                ? request.getEmail().trim()
                : (createdByEmail != null ? createdByEmail : "council@ecomate.lk");

        Optional<RecyclingCenter> existingOpt = recyclingCenterRepository.findByOfficerEmailIgnoreCase(assignedOfficerEmail);
        RecyclingCenter center = existingOpt.orElseGet(RecyclingCenter::new);

        center.setName(request.getName());
        center.setAddress(request.getAddress());
        center.setCity(request.getCity());
        center.setContactNumber(request.getContactNumber());
        center.setEmail(assignedOfficerEmail);
        center.setOfficerEmail(assignedOfficerEmail);
        userRepository.findByEmail(assignedOfficerEmail).ifPresent(center::setOfficer);

        if (request.getOperatingHours() != null && !request.getOperatingHours().isBlank()) {
            center.setOperatingHours(request.getOperatingHours());
        }
        if (request.getIsOpen() != null) {
            center.setIsOpen(request.getIsOpen());
        }
                if (request.getNotes() != null) {
            center.setNotes(request.getNotes());
        }
        if (request.getLatitude() != null) {
            center.setLatitude(request.getLatitude());
        }
        if (request.getLongitude() != null) {
            center.setLongitude(request.getLongitude());
        }

        RecyclingCenter saved = recyclingCenterRepository.saveAndFlush(center);
        System.out.println("DEBUG: saved center ID = " + saved.getId());

        if (request.getAcceptedMaterials() != null && !request.getAcceptedMaterials().isEmpty()) {
            List<Material> allMaterials = materialRepository.findAll();
            for (Material mat : allMaterials) {
                System.out.println("DEBUG: mat ID = " + mat.getId());
                boolean isAccepted = request.getAcceptedMaterials().stream()
                        .anyMatch(accepted -> accepted.equalsIgnoreCase(mat.getName()) || accepted.equalsIgnoreCase(mat.getCategory()));
                Optional<RecyclingCenterMaterial> existingMapping = recyclingCenterMaterialRepository
                        .findByRecyclingCenterIdAndMaterialId(saved.getId(), mat.getId());
                if (existingMapping.isPresent()) {
                    RecyclingCenterMaterial mapping = existingMapping.get();
                    mapping.setIsActive(isAccepted);
                    recyclingCenterMaterialRepository.save(mapping);
                } else {
                    RecyclingCenterMaterial mapping = new RecyclingCenterMaterial(saved, mat, isAccepted);
                    recyclingCenterMaterialRepository.save(mapping);
                }
            }
        }

        return getCenterById(saved.getId());
    }

    @Transactional
    public void deleteCenter(Long id) {
        RecyclingCenter center = recyclingCenterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Recycling center not found with id: " + id));
        center.setIsDeleted(true);
        recyclingCenterRepository.save(center);
    }

    @Transactional
    public RecyclingCenterResponse toggleStatus(String officerEmail, boolean isOpen) {
        RecyclingCenter center = recyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail)
                .orElseThrow(() -> new RuntimeException("No recycling center found for officer: " + officerEmail));

        center.setIsOpen(isOpen);
        RecyclingCenter saved = recyclingCenterRepository.save(center);
        return RecyclingCenterResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<RecyclingCenterResponse> getAllCenters(String query, String materialFilter) {
        List<RecyclingCenter> list = recyclingCenterRepository.findByIsDeletedFalse();

        return list.stream()
                .filter(c -> {
                    if (query == null || query.isBlank()) return true;
                    String q = query.trim().toLowerCase();
                    return c.getName().toLowerCase().contains(q)
                            || c.getCity().toLowerCase().contains(q)
                            || c.getAddress().toLowerCase().contains(q);
                })
                .map(RecyclingCenterResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public RecyclingCenterResponse getCenterById(Long id) {
        return recyclingCenterRepository.findById(id)
                .map(RecyclingCenterResponse::fromEntity)
                .orElseThrow(() -> new RuntimeException("Recycling center not found with id: " + id));
    }

    @Transactional(readOnly = true)
    public List<RecyclingCenterResponse> getCentersByMaterial(String wasteCategoryId) {
        java.util.List<String> categories = new java.util.ArrayList<>();
        switch(wasteCategoryId.toLowerCase()) {
            case "plastics": categories.add("plastics"); break;
            case "glass": categories.add("glass"); break;
            case "paper": categories.add("paper & cardboard"); break;
            case "metals": categories.add("metals"); categories.add("scrap metal"); break;
            case "organic": categories.add("organic"); break;
            case "e_waste": categories.add("e-waste"); break;
            case "hazardous": categories.add("hazardous"); break;
            default: categories.add(wasteCategoryId.toLowerCase());
        }
        return recyclingCenterRepository.findByAcceptedWasteCategory(categories).stream()
            .map(RecyclingCenterResponse::fromEntity)
            .collect(Collectors.toList());
    }
}
















