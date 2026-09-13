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
public class RecyclingCentreService {

    private final RecyclingCentreRepository recyclingCentreRepository;
    private final MaterialRepository materialRepository;
    private final RecyclingCentreMaterialRepository recyclingCentreMaterialRepository;
    private final UserRepository userRepository;

    public RecyclingCentreService(RecyclingCentreRepository recyclingCentreRepository,
                                  MaterialRepository materialRepository,
                                  RecyclingCentreMaterialRepository recyclingCentreMaterialRepository,
                                  UserRepository userRepository) {
        this.recyclingCentreRepository = recyclingCentreRepository;
        this.materialRepository = materialRepository;
        this.recyclingCentreMaterialRepository = recyclingCentreMaterialRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public RecyclingCentreResponse getMyCentre(String officerEmail) {
        return recyclingCentreRepository.findByOfficerEmailIgnoreCase(officerEmail)
                .map(RecyclingCentreResponse::fromEntity)
                .orElse(null);
    }

    @Transactional(readOnly = true)
    public List<MaterialDto> getAllMasterMaterials() {
        return materialRepository.findAll().stream()
                .map(MaterialDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<MaterialDto> getCentreMaterials(String officerEmail) {
        RecyclingCentre centre = recyclingCentreRepository.findByOfficerEmailIgnoreCase(officerEmail)
                .orElseThrow(() -> new RuntimeException("Centre not found for officer: " + officerEmail));

        List<Material> allMaterials = materialRepository.findAll();
        List<RecyclingCentreMaterial> mappings = recyclingCentreMaterialRepository.findByRecyclingCentreId(centre.getId());

        return allMaterials.stream().map(mat -> {
            Optional<RecyclingCentreMaterial> mapOpt = mappings.stream()
                    .filter(m -> m.getMaterial().getId().equals(mat.getId()))
                    .findFirst();
            boolean isActive = mapOpt.map(RecyclingCentreMaterial::getIsActive).orElse(false);
            return MaterialDto.fromEntityWithStatus(mat, isActive);
        }).collect(Collectors.toList());
    }

    @Transactional
    public RecyclingCentreResponse toggleMaterialStatus(String officerEmail, Long materialId, Boolean isActive) {
        RecyclingCentre centre = recyclingCentreRepository.findByOfficerEmailIgnoreCase(officerEmail)
                .orElseThrow(() -> new RuntimeException("Centre not found for officer: " + officerEmail));

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() -> new RuntimeException("Material not found with id: " + materialId));

        Optional<RecyclingCentreMaterial> existingMapping = recyclingCentreMaterialRepository
                .findByRecyclingCentreIdAndMaterialId(centre.getId(), materialId);

        if (existingMapping.isPresent()) {
            RecyclingCentreMaterial mapping = existingMapping.get();
            mapping.setIsActive(isActive);
            recyclingCentreMaterialRepository.save(mapping);
        } else {
            RecyclingCentreMaterial newMapping = new RecyclingCentreMaterial(centre, material, isActive);
            recyclingCentreMaterialRepository.save(newMapping);
        }

        return getMyCentre(officerEmail);
    }

    @Transactional
    public RecyclingCentreResponse createOrUpdateMyCentre(String officerEmail, RecyclingCentreRequest request) {
        Optional<RecyclingCentre> existingOpt = recyclingCentreRepository.findByOfficerEmailIgnoreCase(officerEmail);
        RecyclingCentre centre;

        if (existingOpt.isPresent()) {
            centre = existingOpt.get();
        } else {
            centre = new RecyclingCentre();
            centre.setOfficerEmail(officerEmail);
            userRepository.findByEmail(officerEmail).ifPresent(centre::setOfficer);
        }

        centre.setName(request.getName());
        centre.setAddress(request.getAddress());
        centre.setCity(request.getCity());
        centre.setContactNumber(request.getContactNumber());
        centre.setEmail(request.getEmail());

        if (request.getOperatingHours() != null) {
            centre.setOperatingHours(request.getOperatingHours());
        }
        if (request.getIsOpen() != null) {
            centre.setIsOpen(request.getIsOpen());
        }
        if (request.getNotes() != null) {
            centre.setNotes(request.getNotes());
        }

        RecyclingCentre saved = recyclingCentreRepository.save(centre);
        return RecyclingCentreResponse.fromEntity(saved);
    }

    @Transactional
    public RecyclingCentreResponse createCentre(RecyclingCentreRequest request, String createdByEmail) {
        String assignedOfficerEmail = request.getEmail() != null && !request.getEmail().isBlank()
                ? request.getEmail().trim()
                : (createdByEmail != null ? createdByEmail : "council@ecomate.lk");

        Optional<RecyclingCentre> existingOpt = recyclingCentreRepository.findByOfficerEmailIgnoreCase(assignedOfficerEmail);
        RecyclingCentre centre = existingOpt.orElseGet(RecyclingCentre::new);

        centre.setName(request.getName());
        centre.setAddress(request.getAddress());
        centre.setCity(request.getCity());
        centre.setContactNumber(request.getContactNumber());
        centre.setEmail(assignedOfficerEmail);
        centre.setOfficerEmail(assignedOfficerEmail);
        userRepository.findByEmail(assignedOfficerEmail).ifPresent(centre::setOfficer);

        if (request.getOperatingHours() != null && !request.getOperatingHours().isBlank()) {
            centre.setOperatingHours(request.getOperatingHours());
        }
        if (request.getIsOpen() != null) {
            centre.setIsOpen(request.getIsOpen());
        }
        if (request.getNotes() != null) {
            centre.setNotes(request.getNotes());
        }

        RecyclingCentre saved = recyclingCentreRepository.save(centre);

        if (request.getAcceptedMaterials() != null && !request.getAcceptedMaterials().isEmpty()) {
            List<Material> allMaterials = materialRepository.findAll();
            for (Material mat : allMaterials) {
                boolean isAccepted = request.getAcceptedMaterials().stream()
                        .anyMatch(accepted -> accepted.equalsIgnoreCase(mat.getName()) || accepted.equalsIgnoreCase(mat.getCategory()));
                Optional<RecyclingCentreMaterial> existingMapping = recyclingCentreMaterialRepository
                        .findByRecyclingCentreIdAndMaterialId(saved.getId(), mat.getId());
                if (existingMapping.isPresent()) {
                    RecyclingCentreMaterial mapping = existingMapping.get();
                    mapping.setIsActive(isAccepted);
                    recyclingCentreMaterialRepository.save(mapping);
                } else {
                    RecyclingCentreMaterial mapping = new RecyclingCentreMaterial(saved, mat, isAccepted);
                    recyclingCentreMaterialRepository.save(mapping);
                }
            }
        }

        return getCentreById(saved.getId());
    }

    @Transactional
    public void deleteCentre(Long id) {
        recyclingCentreMaterialRepository.deleteByRecyclingCentreId(id);
        recyclingCentreRepository.deleteById(id);
    }

    @Transactional
    public RecyclingCentreResponse toggleStatus(String officerEmail, boolean isOpen) {
        RecyclingCentre centre = recyclingCentreRepository.findByOfficerEmailIgnoreCase(officerEmail)
                .orElseThrow(() -> new RuntimeException("No recycling centre found for officer: " + officerEmail));

        centre.setIsOpen(isOpen);
        RecyclingCentre saved = recyclingCentreRepository.save(centre);
        return RecyclingCentreResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<RecyclingCentreResponse> getAllCentres(String query, String materialFilter) {
        List<RecyclingCentre> list = recyclingCentreRepository.findAll();

        return list.stream()
                .filter(c -> {
                    if (query == null || query.isBlank()) return true;
                    String q = query.trim().toLowerCase();
                    return c.getName().toLowerCase().contains(q)
                            || c.getCity().toLowerCase().contains(q)
                            || c.getAddress().toLowerCase().contains(q);
                })
                .map(RecyclingCentreResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public RecyclingCentreResponse getCentreById(Long id) {
        return recyclingCentreRepository.findById(id)
                .map(RecyclingCentreResponse::fromEntity)
                .orElseThrow(() -> new RuntimeException("Recycling centre not found with id: " + id));
    }
}