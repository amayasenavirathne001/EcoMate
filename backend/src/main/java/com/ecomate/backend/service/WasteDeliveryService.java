package com.ecomate.backend.service;

import com.ecomate.backend.dto.CreateWasteDeliveryRequest;
import com.ecomate.backend.dto.WasteDeliveryDto;
import com.ecomate.backend.entity.RecyclingCenter;
import com.ecomate.backend.entity.WasteDelivery;
import com.ecomate.backend.repository.RecyclingCenterRepository;
import com.ecomate.backend.repository.WasteDeliveryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class WasteDeliveryService {

    private final WasteDeliveryRepository wasteDeliveryRepository;
    private final RecyclingCenterRepository recyclingCenterRepository;

    @Autowired
    private EcoWalletService ecoWalletService;

    public WasteDeliveryService(WasteDeliveryRepository wasteDeliveryRepository,
                                RecyclingCenterRepository recyclingCenterRepository) {
        this.wasteDeliveryRepository = wasteDeliveryRepository;
        this.recyclingCenterRepository = recyclingCenterRepository;
    }

    @Transactional
    public WasteDeliveryDto recordDelivery(String userEmail, CreateWasteDeliveryRequest request) {
        RecyclingCenter center = null;

        if (request.getRecyclingcenterId() != null) {
            center = recyclingCenterRepository.findById(request.getRecyclingcenterId()).orElse(null);
        }

        if (center == null && userEmail != null && !userEmail.isBlank()) {
            center = recyclingCenterRepository.findByOfficerEmailIgnoreCase(userEmail).orElse(null);
        }

        WasteDelivery delivery = new WasteDelivery();
        delivery.setRecyclingCenter(center);
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
        Optional<RecyclingCenter> centerOpt = recyclingCenterRepository.findByOfficerEmailIgnoreCase(userEmail);
        if (centerOpt.isPresent()) {
            return wasteDeliveryRepository.findByRecyclingCenterIdOrderByDateTimeDesc(centerOpt.get().getId())
                    .stream()
                    .map(WasteDeliveryDto::fromEntity)
                    .collect(Collectors.toList());
        }
        return wasteDeliveryRepository.findByDeliveredByContainingIgnoreCaseOrderByDateTimeDesc(userEmail)
                .stream()
                .map(WasteDeliveryDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<WasteDeliveryDto> getDeliveriesForCenter(Long centerId) {
        return wasteDeliveryRepository.findByRecyclingCenterIdOrderByDateTimeDesc(centerId)
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

    @Transactional
    public void updateProcessingStatus(Long deliveryId, String newStatus) {
        WasteDelivery delivery = wasteDeliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new IllegalArgumentException("Delivery not found with id: " + deliveryId));
        
        String oldStatus = delivery.getProcessingStatus();
        delivery.setProcessingStatus(newStatus);
        
        // Award points if status changed to PROCESSED and hasn't been awarded yet
        if ("PROCESSED".equalsIgnoreCase(newStatus) && !"PROCESSED".equalsIgnoreCase(oldStatus) 
            && (delivery.getAwardedPoints() == null || delivery.getAwardedPoints() == 0)) {
            
            int points = calculatePoints(delivery.getMaterialType(), delivery.getWeightKg());
            delivery.setAwardedPoints(points);
            
            String deliveredBy = delivery.getDeliveredBy();
            // Handle "[Resident] user@email.com" or just raw email
            if (deliveredBy != null && !deliveredBy.isBlank()) {
                String email = deliveredBy.replace("[Resident]", "").replace("[Municipal]", "").trim();
                if (!email.isBlank() && email.contains("@")) {
                    ecoWalletService.addPoints(email, points);
                }
            }
        }

        wasteDeliveryRepository.save(delivery);
    }
    
    private int calculatePoints(String materialType, Double weightKg) {
        if (materialType == null || weightKg == null || weightKg <= 0) return 0;
        
        String lower = materialType.toLowerCase();
        double multiplier = 10; // default
        
        if (lower.contains("plastic")) multiplier = 15;
        else if (lower.contains("metal") || lower.contains("aluminum")) multiplier = 25;
        else if (lower.contains("e-waste") || lower.contains("electronic")) multiplier = 30;
        else if (lower.contains("paper") || lower.contains("cardboard")) multiplier = 10;
        else if (lower.contains("glass")) multiplier = 8;
        else if (lower.contains("tetra")) multiplier = 12;
        else if (lower.contains("organic")) multiplier = 5;
        
        return (int) Math.round(weightKg * multiplier);
    }
}
