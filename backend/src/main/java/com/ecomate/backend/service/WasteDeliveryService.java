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

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private com.ecomate.backend.repository.UserRepository userRepository;

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
        
        String oldStatus = delivery.getProcessingStatus() != null ? delivery.getProcessingStatus().toUpperCase() : "RECEIVED";
        String normalizedNewStatus = newStatus != null ? newStatus.toUpperCase() : oldStatus;

        // Prevent modifying an already PROCESSED delivery
        if ("PROCESSED".equals(oldStatus) && !"PROCESSED".equals(normalizedNewStatus)) {
            throw new IllegalStateException("Delivery is already PROCESSED and cannot be reverted.");
        }

        // Strict forward workflow: RECEIVED -> SORTED -> PROCESSED
        if ("RECEIVED".equals(oldStatus) && "PROCESSED".equals(normalizedNewStatus)) {
            // Force through SORTED first or allow direct jump? Typically allow or require SORTED
            // But definitely cannot revert from SORTED back to RECEIVED
        }
        if ("SORTED".equals(oldStatus) && "RECEIVED".equals(normalizedNewStatus)) {
            throw new IllegalStateException("Cannot revert delivery status from SORTED back to RECEIVED.");
        }

        delivery.setProcessingStatus(normalizedNewStatus);
        
        // Trigger points & notifications whenever status is set/updated to PROCESSED
        if ("PROCESSED".equalsIgnoreCase(normalizedNewStatus) && !"PROCESSED".equalsIgnoreCase(oldStatus)) {
            
            int points = calculatePoints(delivery.getMaterialType(), delivery.getWeightKg());
            if (delivery.getAwardedPoints() == null || delivery.getAwardedPoints() == 0) {
                delivery.setAwardedPoints(points);
            } else {
                points = delivery.getAwardedPoints();
            }
            
            String deliveredBy = delivery.getDeliveredBy();
            System.out.println("DEBUG: Delivery PROCESSED. deliveredBy = " + deliveredBy);
            if (deliveredBy != null && !deliveredBy.isBlank()) {
                // Robust regex extraction for email: supports "[Resident] test@gmail.com", "test@gmail.com", etc.
                java.util.regex.Pattern p = java.util.regex.Pattern.compile("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}");
                java.util.regex.Matcher m = p.matcher(deliveredBy);
                String email = m.find() ? m.group() : deliveredBy.replace("[Resident]", "").replace("[Municipal]", "").trim();
                
                System.out.println("DEBUG: Extracted email for notification: '" + email + "'");
                String centerName = delivery.getRecyclingCenter() != null ? delivery.getRecyclingCenter().getName() : "Recycling Center";

                if (!email.isBlank() && email.contains("@")) {
                    ecoWalletService.addPoints(email, points);

                    // 1. Send notification to the submitter email (Resident or Collector)
                    try {
                        String notifTitle = "Delivery Processed (+" + points + " pts)";
                        String notifMsg = "Your " + delivery.getMaterialType() + " delivery (" 
                                + delivery.getWeightKg() + " kg) has been processed at " + centerName 
                                + ". +" + points + " Eco-Points added to your wallet!";
                        notificationService.createUserNotification(email, notifTitle, notifMsg);
                        System.out.println("DEBUG: Notification successfully created for submitter: " + email);
                    } catch (Exception ex) {
                        System.err.println("Failed to send delivery notification to " + email + ": " + ex.getMessage());
                    }
                }

                // 2. If this delivery came from Municipal (e.g. "[Municipal]"), ALSO notify Municipal Council Admin(s)!
                if (deliveredBy.toUpperCase().contains("[MUNICIPAL]") || deliveredBy.toUpperCase().contains("MUNICIPAL")) {
                    try {
                        java.util.List<com.ecomate.backend.entity.User> councilAdmins = userRepository.findByRole(com.ecomate.backend.entity.Role.COUNCIL_ADMIN);
                        String municipalTitle = "Municipal Drop-off Processed (" + delivery.getMaterialType() + ")";
                        String municipalMsg = "Drop-off batch (" + delivery.getWeightKg() + " kg of " + delivery.getMaterialType() 
                                + ") delivered by " + email + " has been successfully processed at " + centerName + ".";

                        boolean sentToCouncil = false;
                        for (com.ecomate.backend.entity.User admin : councilAdmins) {
                            if (admin.getEmail() != null && !admin.getEmail().isBlank()) {
                                notificationService.createUserNotification(admin.getEmail(), municipalTitle, municipalMsg);
                                System.out.println("DEBUG: Municipal notification sent to Council Admin: " + admin.getEmail());
                                sentToCouncil = true;
                            }
                        }

                        // Fallback guarantee: if no COUNCIL_ADMIN found in DB or empty list, send to standard officer email
                        if (!sentToCouncil) {
                            notificationService.createUserNotification("officer@ecomate.gov", municipalTitle, municipalMsg);
                            System.out.println("DEBUG: Municipal notification sent to default: officer@ecomate.gov");
                        }
                    } catch (Exception ex) {
                        System.err.println("Failed to send municipal council admin notifications: " + ex.getMessage());
                    }
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
