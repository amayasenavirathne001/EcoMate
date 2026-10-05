package com.ecomate.backend.service;

import com.ecomate.backend.dto.CreateWasteDeliveryRequest;
import com.ecomate.backend.dto.WasteDeliveryDto;
import com.ecomate.backend.entity.RecyclingCenter;
import com.ecomate.backend.entity.WasteDelivery;
import com.ecomate.backend.repository.RecyclingCenterRepository;
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
    private final RecyclingCenterRepository RecyclingCenterRepository;

    public WasteDeliveryService(WasteDeliveryRepository wasteDeliveryRepository,
                                RecyclingCenterRepository RecyclingCenterRepository) {
        this.wasteDeliveryRepository = wasteDeliveryRepository;
        this.RecyclingCenterRepository = RecyclingCenterRepository;
    }

    @Transactional
    public WasteDeliveryDto recordDelivery(String userEmail, CreateWasteDeliveryRequest request) {
        RecyclingCenter Center = null;

        if (request.getRecyclingCenterId() != null) {
            Center = RecyclingCenterRepository.findById(request.getRecyclingCenterId()).orElse(null);
        }

        if (Center == null && userEmail != null && !userEmail.isBlank()) {
            Center = RecyclingCenterRepository.findByOfficerEmailIgnoreCase(userEmail).orElse(null);
        }

        WasteDelivery delivery = new WasteDelivery();
        delivery.setRecyclingCenter(Center);
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
        Optional<RecyclingCenter> CenterOpt = RecyclingCenterRepository.findByOfficerEmailIgnoreCase(userEmail);
        if (CenterOpt.isPresent()) {
            return wasteDeliveryRepository.findByRecyclingCenterIdOrderByDateTimeDesc(CenterOpt.get().getId())
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
    public List<WasteDeliveryDto> getDeliveriesForCenter(Long CenterId) {
        return wasteDeliveryRepository.findByRecyclingCenterIdOrderByDateTimeDesc(CenterId)
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
    public void updateProcessingStatus(Long deliveryId, String newStatus) {
        WasteDelivery delivery = wasteDeliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new IllegalArgumentException("Delivery not found with id: " + deliveryId));
        delivery.setProcessingStatus(newStatus);
        wasteDeliveryRepository.save(delivery);
    }
}

