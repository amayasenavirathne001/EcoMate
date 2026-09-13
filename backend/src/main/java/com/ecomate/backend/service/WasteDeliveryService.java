package com.ecomate.backend.service;

import com.ecomate.backend.dto.CreateWasteDeliveryRequest;
import com.ecomate.backend.dto.WasteDeliveryDto;
import com.ecomate.backend.entity.RecyclingCentre;
import com.ecomate.backend.entity.WasteDelivery;
import com.ecomate.backend.repository.RecyclingCentreRepository;
import com.ecomate.backend.repository.WasteDeliveryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class WasteDeliveryService {

    private final WasteDeliveryRepository wasteDeliveryRepository;
    private final RecyclingCentreRepository recyclingCentreRepository;

    public WasteDeliveryService(WasteDeliveryRepository wasteDeliveryRepository,
                                RecyclingCentreRepository recyclingCentreRepository) {
        this.wasteDeliveryRepository = wasteDeliveryRepository;
        this.recyclingCentreRepository = recyclingCentreRepository;
    }

    @Transactional
    public WasteDeliveryDto recordDelivery(String userEmail, CreateWasteDeliveryRequest request) {
        RecyclingCentre centre = null;

        if (request.getRecyclingCentreId() != null) {
            centre = recyclingCentreRepository.findById(request.getRecyclingCentreId()).orElse(null);
        }

        if (centre == null && userEmail != null && !userEmail.isBlank()) {
            centre = recyclingCentreRepository.findByOfficerEmailIgnoreCase(userEmail).orElse(null);
        }

        WasteDelivery delivery = new WasteDelivery();
        delivery.setRecyclingCentre(centre);
        delivery.setMaterialType(request.getMaterialType());
        delivery.setWeightKg(request.getWeightKg());
        delivery.setDeliveredBy(request.getDeliveredBy());
        delivery.setContactNumber(request.getContactNumber());
        delivery.setDateTime(LocalDateTime.now());
        delivery.setNotes(request.getNotes() != null ? request.getNotes() : "");

        WasteDelivery saved = wasteDeliveryRepository.save(delivery);
        return WasteDeliveryDto.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<WasteDeliveryDto> getDeliveriesForUser(String userEmail) {
        Optional<RecyclingCentre> centreOpt = recyclingCentreRepository.findByOfficerEmailIgnoreCase(userEmail);
        if (centreOpt.isPresent()) {
            return wasteDeliveryRepository.findByRecyclingCentreIdOrderByDateTimeDesc(centreOpt.get().getId())
                    .stream()
                    .map(WasteDeliveryDto::fromEntity)
                    .collect(Collectors.toList());
        }
        return wasteDeliveryRepository.findAllByOrderByDateTimeDesc()
                .stream()
                .map(WasteDeliveryDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<WasteDeliveryDto> getDeliveriesForCentre(Long centreId) {
        return wasteDeliveryRepository.findByRecyclingCentreIdOrderByDateTimeDesc(centreId)
                .stream()
                .map(WasteDeliveryDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<WasteDeliveryDto> getAllDeliveries() {
        return wasteDeliveryRepository.findAllByOrderByDateTimeDesc()
                .stream()
                .map(WasteDeliveryDto::fromEntity)
                .collect(Collectors.toList());
    }
}
