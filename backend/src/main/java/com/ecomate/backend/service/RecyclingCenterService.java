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

    private final RecyclingCenterRepository RecyclingCenterRepository;
    private final MaterialRepository materialRepository;
    private final RecyclingCenterMaterialRepository RecyclingCenterMaterialRepository;
    private final UserRepository userRepository;

    public RecyclingCenterService(RecyclingCenterRepository RecyclingCenterRepository,
                                  MaterialRepository materialRepository,
                                  RecyclingCenterMaterialRepository RecyclingCenterMaterialRepository,
                                  UserRepository userRepository) {
        this.RecyclingCenterRepository = RecyclingCenterRepository;
        this.materialRepository = materialRepository;
        this.RecyclingCenterMaterialRepository = RecyclingCenterMaterialRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public RecyclingCenterResponse getMyCenter(String officerEmail) {
        return RecyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail)
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
                Optional<RecyclingCenter> CenterOpt = RecyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail);
        if (CenterOpt.isEmpty()) {
            throw new RuntimeException("Center not found");
        }
        RecyclingCenter Center = CenterOpt.get();

        List<Material> allMaterials = materialRepository.findAll();
        List<RecyclingCenterMaterial> mappings = RecyclingCenterMaterialRepository.findByRecyclingCenterId(Center.getId());

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
                Optional<RecyclingCenter> CenterOpt = RecyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail);
        if (CenterOpt.isEmpty()) {
            throw new RuntimeException("Center not found");
        }
        RecyclingCenter Center = CenterOpt.get();

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() -> new RuntimeException("Material not found with id: " + materialId));

        Optional<RecyclingCenterMaterial> existingMapping = RecyclingCenterMaterialRepository
                .findByRecyclingCenterIdAndMaterialId(Center.getId(), materialId);

        if (existingMapping.isPresent()) {
            RecyclingCenterMaterial mapping = existingMapping.get();
            mapping.setIsActive(isActive);
            RecyclingCenterMaterialRepository.save(mapping);
        } else {
            RecyclingCenterMaterial newMapping = new RecyclingCenterMaterial(Center, material, isActive);
            RecyclingCenterMaterialRepository.save(newMapping);
        }

        return getMyCenter(officerEmail);
    }

    @Transactional
    public RecyclingCenterResponse createOrUpdateMyCenter(String officerEmail, RecyclingCenterRequest request) {
        Optional<RecyclingCenter> existingOpt = RecyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail);
        RecyclingCenter Center;

        if (existingOpt.isPresent()) {
            Center = existingOpt.get();
        } else {
            Center = new RecyclingCenter();
            Center.setOfficerEmail(officerEmail);
            userRepository.findByEmail(officerEmail).ifPresent(Center::setOfficer);
        }

        Center.setName(request.getName());
        Center.setAddress(request.getAddress());
        Center.setCity(request.getCity());
        Center.setContactNumber(request.getContactNumber());
        Center.setEmail(request.getEmail());

        if (request.getOperatingHours() != null) {
            Center.setOperatingHours(request.getOperatingHours());
        }
        if (request.getIsOpen() != null) {
            Center.setIsOpen(request.getIsOpen());
        }
        if (request.getNotes() != null) {
            Center.setNotes(request.getNotes());
        }

        RecyclingCenter saved = RecyclingCenterRepository.save(Center);
        return RecyclingCenterResponse.fromEntity(saved);
    }

    @Transactional
    public RecyclingCenterResponse createCenter(RecyclingCenterRequest request, String createdByEmail) {
        String assignedOfficerEmail = request.getEmail() != null && !request.getEmail().isBlank()
                ? request.getEmail().trim()
                : (createdByEmail != null ? createdByEmail : "council@ecomate.lk");

        Optional<RecyclingCenter> existingOpt = RecyclingCenterRepository.findByOfficerEmailIgnoreCase(assignedOfficerEmail);
        RecyclingCenter Center = existingOpt.orElseGet(RecyclingCenter::new);

        Center.setName(request.getName());
        Center.setAddress(request.getAddress());
        Center.setCity(request.getCity());
        Center.setContactNumber(request.getContactNumber());
        Center.setEmail(assignedOfficerEmail);
        Center.setOfficerEmail(assignedOfficerEmail);
        userRepository.findByEmail(assignedOfficerEmail).ifPresent(Center::setOfficer);

        if (request.getOperatingHours() != null && !request.getOperatingHours().isBlank()) {
            Center.setOperatingHours(request.getOperatingHours());
        }
        if (request.getIsOpen() != null) {
            Center.setIsOpen(request.getIsOpen());
        }
        if (request.getNotes() != null) {
            Center.setNotes(request.getNotes());
        }

        RecyclingCenter saved = RecyclingCenterRepository.save(Center);

        if (request.getAcceptedMaterials() != null && !request.getAcceptedMaterials().isEmpty()) {
            List<Material> allMaterials = materialRepository.findAll();
            for (Material mat : allMaterials) {
                boolean isAccepted = request.getAcceptedMaterials().stream()
                        .anyMatch(accepted -> accepted.equalsIgnoreCase(mat.getName()) || accepted.equalsIgnoreCase(mat.getCategory()));
                Optional<RecyclingCenterMaterial> existingMapping = RecyclingCenterMaterialRepository
                        .findByRecyclingCenterIdAndMaterialId(saved.getId(), mat.getId());
                if (existingMapping.isPresent()) {
                    RecyclingCenterMaterial mapping = existingMapping.get();
                    mapping.setIsActive(isAccepted);
                    RecyclingCenterMaterialRepository.save(mapping);
                } else {
                    RecyclingCenterMaterial mapping = new RecyclingCenterMaterial(saved, mat, isAccepted);
                    RecyclingCenterMaterialRepository.save(mapping);
                }
            }
        }

        return getCenterById(saved.getId());
    }

    @Transactional
    public void deleteCenter(Long id) {
        RecyclingCenterMaterialRepository.deleteByRecyclingCenterId(id);
        RecyclingCenterRepository.deleteById(id);
    }

    @Transactional
    public RecyclingCenterResponse toggleStatus(String officerEmail, boolean isOpen) {
        RecyclingCenter Center = RecyclingCenterRepository.findByOfficerEmailIgnoreCase(officerEmail)
                .orElseThrow(() -> new RuntimeException("No recycling Center found for officer: " + officerEmail));

        Center.setIsOpen(isOpen);
        RecyclingCenter saved = RecyclingCenterRepository.save(Center);
        return RecyclingCenterResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<RecyclingCenterResponse> getAllCenters(String query, String materialFilter) {
        List<RecyclingCenter> list = RecyclingCenterRepository.findAll();

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
        return RecyclingCenterRepository.findById(id)
                .map(RecyclingCenterResponse::fromEntity)
                .orElseThrow(() -> new RuntimeException("Recycling Center not found with id: " + id));
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
        return RecyclingCenterRepository.findByAcceptedWasteCategory(categories).stream()
            .map(RecyclingCenterResponse::fromEntity)
            .collect(Collectors.toList());
    }
}




