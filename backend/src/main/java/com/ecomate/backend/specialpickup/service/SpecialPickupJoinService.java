package com.ecomate.backend.specialpickup.service;

import com.ecomate.backend.entity.User;
import com.ecomate.backend.repository.UserRepository;
import com.ecomate.backend.specialpickup.dto.CapacityCheckResponse;
import com.ecomate.backend.specialpickup.dto.CreateJoinRequest;
import com.ecomate.backend.specialpickup.dto.JoinRequestResponse;
import com.ecomate.backend.specialpickup.entity.SpecialPickup;
import com.ecomate.backend.specialpickup.entity.SpecialPickupJoinRequest;
import com.ecomate.backend.specialpickup.enums.JoinRequestStatus;
import com.ecomate.backend.specialpickup.enums.SpecialPickupStatus;
import com.ecomate.backend.specialpickup.repository.SpecialPickupJoinRequestRepository;
import com.ecomate.backend.specialpickup.repository.SpecialPickupRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SpecialPickupJoinService {

    private final SpecialPickupRepository pickupRepository;
    private final SpecialPickupJoinRequestRepository joinRepository;
    private final UserRepository userRepository;

    public SpecialPickupJoinService(
            SpecialPickupRepository pickupRepository,
            SpecialPickupJoinRequestRepository joinRepository,
            UserRepository userRepository) {

        this.pickupRepository = pickupRepository;
        this.joinRepository = joinRepository;
        this.userRepository = userRepository;
    }

    // =========================================================
    // RESIDENT - JOIN SPECIAL PICKUP
    // =========================================================

    @Transactional
    public JoinRequestResponse createJoinRequest(
            Long pickupId,
            String residentEmail,
            CreateJoinRequest request) {

        // -----------------------------------------------------
        // Find resident
        // -----------------------------------------------------

        User resident = userRepository.findByEmail(residentEmail)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Resident not found"));

        // -----------------------------------------------------
        // Find special pickup
        // -----------------------------------------------------

        SpecialPickup pickup = pickupRepository.findById(pickupId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Special pickup not found"));

        // -----------------------------------------------------
        // Pickup must be ASSIGNED
        // -----------------------------------------------------

        if (pickup.getStatus() != SpecialPickupStatus.ASSIGNED) {
            throw new IllegalArgumentException(
                    "This special pickup is not available for joining");
        }

        // -----------------------------------------------------
        // Check join deadline
        // -----------------------------------------------------

        if (pickup.getJoinDeadline() != null
                && LocalDateTime.now()
                .isAfter(pickup.getJoinDeadline())) {

            throw new IllegalArgumentException(
                    "The joining deadline has passed");
        }

        // -----------------------------------------------------
        // Prevent duplicate join
        // -----------------------------------------------------

        if (joinRepository.existsBySpecialPickupIdAndResidentId(
                pickupId,
                resident.getId())) {

            throw new IllegalArgumentException(
                    "You have already joined or requested to join this pickup");
        }

        // -----------------------------------------------------
        // Validate number of items
        // -----------------------------------------------------

        if (request.getNumberOfItems() == null
                || request.getNumberOfItems() <= 0) {

            throw new IllegalArgumentException(
                    "Number of items must be greater than zero");
        }

        // -----------------------------------------------------
        // Validate waste type
        // -----------------------------------------------------

        if (request.getWasteType() == null
                || request.getWasteType().isBlank()) {

            throw new IllegalArgumentException(
                    "Waste type is required");
        }

        // -----------------------------------------------------
        // Check accepted waste type
        // -----------------------------------------------------

        if (!isWasteTypeAccepted(
                pickup.getAcceptedWasteTypes(),
                request.getWasteType())) {

            throw new IllegalArgumentException(
                    "This waste type is not accepted for this pickup");
        }

        // -----------------------------------------------------
        // Read current capacity
        // -----------------------------------------------------

        double requestedWeight =
                safeDouble(request.getEstimatedWeightKg());

        double requestedVolume =
                safeDouble(request.getEstimatedVolumeM3());

        double currentWeight =
                safeDouble(
                        pickup.getCurrentEstimatedWeightKg());

        double currentVolume =
                safeDouble(
                        pickup.getCurrentEstimatedVolumeM3());

        int currentHouseholds =
                safeInteger(
                        pickup.getJoinedHouseholds());

        double maxWeight =
                safeDouble(
                        pickup.getMaxWeightKg());

        double maxVolume =
                safeDouble(
                        pickup.getMaxVolumeM3());

        int maxHouseholds =
                safeInteger(
                        pickup.getMaxHouseholds());

        // -----------------------------------------------------
        // Household capacity
        // -----------------------------------------------------

        if (maxHouseholds > 0
                && currentHouseholds + 1 > maxHouseholds) {

            throw new IllegalArgumentException(
                    "Maximum household limit has been reached");
        }

        // -----------------------------------------------------
        // Weight capacity
        // -----------------------------------------------------

        if (maxWeight > 0
                && currentWeight + requestedWeight > maxWeight) {

            throw new IllegalArgumentException(
                    "Truck weight capacity would be exceeded");
        }

        // -----------------------------------------------------
        // Volume capacity
        // -----------------------------------------------------

        if (maxVolume > 0
                && currentVolume + requestedVolume > maxVolume) {

            throw new IllegalArgumentException(
                    "Truck volume capacity would be exceeded");
        }

        // -----------------------------------------------------
        // Create join record
        // -----------------------------------------------------

        SpecialPickupJoinRequest joinRequest =
                new SpecialPickupJoinRequest();

        joinRequest.setSpecialPickup(pickup);
        joinRequest.setResidentId(resident.getId());

        joinRequest.setWasteType(
                request.getWasteType());

        joinRequest.setNumberOfItems(
                request.getNumberOfItems());

        joinRequest.setEstimatedSize(
                request.getEstimatedSize());

        joinRequest.setEstimatedWeightKg(
                request.getEstimatedWeightKg());

        joinRequest.setEstimatedVolumeM3(
                request.getEstimatedVolumeM3());

        joinRequest.setPickupAddress(
                request.getPickupAddress());

        joinRequest.setNotes(
                request.getNotes());

        joinRequest.setPhotoUrl(
                request.getPhotoUrl());

        // -----------------------------------------------------
        // AUTO APPROVE
        // -----------------------------------------------------

        joinRequest.setStatus(
                JoinRequestStatus.APPROVED);

        joinRequest.setApprovedAt(
                LocalDateTime.now());

        // -----------------------------------------------------
        // Update pickup capacity
        // -----------------------------------------------------

        pickup.setCurrentEstimatedWeightKg(
                currentWeight + requestedWeight);

        pickup.setCurrentEstimatedVolumeM3(
                currentVolume + requestedVolume);

        pickup.setJoinedHouseholds(
                currentHouseholds + 1);

        // -----------------------------------------------------
        // Automatically mark FULL
        // -----------------------------------------------------

        if (maxHouseholds > 0
                && pickup.getJoinedHouseholds() >= maxHouseholds) {

            pickup.setStatus(
                    SpecialPickupStatus.FULL);
        }

        // -----------------------------------------------------
        // Save pickup + join
        // -----------------------------------------------------

        pickupRepository.save(pickup);

        SpecialPickupJoinRequest saved =
                joinRepository.save(joinRequest);

        return toResponse(saved, resident);
    }

    // =========================================================
    // ADMIN - CAPACITY CHECK
    // Kept for compatibility / viewing capacity
    // =========================================================

    public CapacityCheckResponse checkCapacity(
            Long joinRequestId) {

        SpecialPickupJoinRequest joinRequest =
                joinRepository.findById(joinRequestId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Join request not found"));

        SpecialPickup pickup =
                joinRequest.getSpecialPickup();

        // -----------------------------------------------------
        // Weight
        // -----------------------------------------------------

        double maxWeight =
                safeDouble(
                        pickup.getMaxWeightKg());

        double currentWeight =
                safeDouble(
                        pickup.getCurrentEstimatedWeightKg());

        double requestedWeight =
                safeDouble(
                        joinRequest.getEstimatedWeightKg());

        /*
         * If this join is already approved, its weight has already
         * been added to the pickup totals.
         *
         * Therefore do not add it again when displaying capacity.
         */
        double expectedWeight;

        if (joinRequest.getStatus()
                == JoinRequestStatus.APPROVED) {

            expectedWeight = currentWeight;

        } else {

            expectedWeight =
                    currentWeight + requestedWeight;
        }

        // -----------------------------------------------------
        // Volume
        // -----------------------------------------------------

        double maxVolume =
                safeDouble(
                        pickup.getMaxVolumeM3());

        double currentVolume =
                safeDouble(
                        pickup.getCurrentEstimatedVolumeM3());

        double requestedVolume =
                safeDouble(
                        joinRequest.getEstimatedVolumeM3());

        double expectedVolume;

        if (joinRequest.getStatus()
                == JoinRequestStatus.APPROVED) {

            expectedVolume = currentVolume;

        } else {

            expectedVolume =
                    currentVolume + requestedVolume;
        }

        // -----------------------------------------------------
        // Households
        // -----------------------------------------------------

        int maxHouseholds =
                safeInteger(
                        pickup.getMaxHouseholds());

        int currentHouseholds =
                safeInteger(
                        pickup.getJoinedHouseholds());

        int expectedHouseholds;

        if (joinRequest.getStatus()
                == JoinRequestStatus.APPROVED) {

            expectedHouseholds =
                    currentHouseholds;

        } else {

            expectedHouseholds =
                    currentHouseholds + 1;
        }

        // -----------------------------------------------------
        // Capacity validation
        // -----------------------------------------------------

        boolean weightAvailable =
                maxWeight <= 0
                        || expectedWeight <= maxWeight;

        boolean volumeAvailable =
                maxVolume <= 0
                        || expectedVolume <= maxVolume;

        boolean householdAvailable =
                maxHouseholds <= 0
                        || expectedHouseholds <= maxHouseholds;

        boolean wasteAccepted =
                isWasteTypeAccepted(
                        pickup.getAcceptedWasteTypes(),
                        joinRequest.getWasteType());

        // -----------------------------------------------------
        // Build response
        // -----------------------------------------------------

        CapacityCheckResponse response =
                new CapacityCheckResponse();

        // Weight

        response.setMaxWeightKg(
                maxWeight);

        response.setCurrentWeightKg(
                currentWeight);

        response.setRequestedWeightKg(
                requestedWeight);

        response.setExpectedWeightKg(
                expectedWeight);

        response.setRemainingWeightKg(
                maxWeight <= 0
                        ? 0
                        : Math.max(
                                0,
                                maxWeight - expectedWeight));

        // Volume

        response.setMaxVolumeM3(
                maxVolume);

        response.setCurrentVolumeM3(
                currentVolume);

        response.setRequestedVolumeM3(
                requestedVolume);

        response.setExpectedVolumeM3(
                expectedVolume);

        response.setRemainingVolumeM3(
                maxVolume <= 0
                        ? 0
                        : Math.max(
                                0,
                                maxVolume - expectedVolume));

        // Households

        response.setMaxHouseholds(
                maxHouseholds);

        response.setJoinedHouseholds(
                currentHouseholds);

        response.setExpectedHouseholds(
                expectedHouseholds);

        // Results

        response.setWeightCapacityAvailable(
                weightAvailable);

        response.setVolumeCapacityAvailable(
                volumeAvailable);

        response.setHouseholdCapacityAvailable(
                householdAvailable);

        response.setWasteTypeAccepted(
                wasteAccepted);

        // -----------------------------------------------------
        // Warnings
        // -----------------------------------------------------

        if (!weightAvailable) {
            response.getWarnings().add(
                    "Truck weight capacity would be exceeded");
        }

        if (!volumeAvailable) {
            response.getWarnings().add(
                    "Truck volume capacity would be exceeded");
        }

        if (!householdAvailable) {
            response.getWarnings().add(
                    "Maximum household limit has been reached");
        }

        if (!wasteAccepted) {
            response.getWarnings().add(
                    "Waste type is not accepted for this pickup");
        }

        response.setCanApprove(
                weightAvailable
                        && volumeAvailable
                        && householdAvailable
                        && wasteAccepted);

        return response;
    }

    // =========================================================
    // ADMIN - APPROVE OLD PENDING REQUEST
    //
    // Kept so old PENDING_APPROVAL database records can still
    // be handled. New resident joins are auto-approved.
    // =========================================================

    @Transactional
    public JoinRequestResponse approveJoinRequest(
            Long joinRequestId) {

        SpecialPickupJoinRequest joinRequest =
                joinRepository.findById(joinRequestId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Join request not found"));

        if (joinRequest.getStatus()
                != JoinRequestStatus.PENDING_APPROVAL) {

            throw new IllegalArgumentException(
                    "Only pending requests can be approved");
        }

        CapacityCheckResponse capacity =
                checkCapacity(joinRequestId);

        if (!capacity.isCanApprove()) {

            throw new IllegalArgumentException(
                    "Request cannot be approved: "
                            + String.join(
                                    ", ",
                                    capacity.getWarnings()));
        }

        SpecialPickup pickup =
                joinRequest.getSpecialPickup();

        // -----------------------------------------------------
        // Update capacity
        // -----------------------------------------------------

        pickup.setCurrentEstimatedWeightKg(
                safeDouble(
                        pickup.getCurrentEstimatedWeightKg())
                        +
                        safeDouble(
                                joinRequest.getEstimatedWeightKg()));

        pickup.setCurrentEstimatedVolumeM3(
                safeDouble(
                        pickup.getCurrentEstimatedVolumeM3())
                        +
                        safeDouble(
                                joinRequest.getEstimatedVolumeM3()));

        pickup.setJoinedHouseholds(
                safeInteger(
                        pickup.getJoinedHouseholds()) + 1);

        // -----------------------------------------------------
        // Mark FULL when household limit reached
        // -----------------------------------------------------

        int maxHouseholds =
                safeInteger(
                        pickup.getMaxHouseholds());

        if (maxHouseholds > 0
                && pickup.getJoinedHouseholds() >= maxHouseholds) {

            pickup.setStatus(
                    SpecialPickupStatus.FULL);
        }

        // -----------------------------------------------------
        // Approve
        // -----------------------------------------------------

        joinRequest.setStatus(
                JoinRequestStatus.APPROVED);

        joinRequest.setApprovedAt(
                LocalDateTime.now());

        pickupRepository.save(pickup);

        SpecialPickupJoinRequest saved =
                joinRepository.save(joinRequest);

        User resident =
                userRepository.findById(
                        saved.getResidentId())
                        .orElse(null);

        return toResponse(saved, resident);
    }

    // =========================================================
    // ADMIN - REJECT OLD PENDING REQUEST
    // =========================================================

    @Transactional
    public JoinRequestResponse rejectJoinRequest(
            Long joinRequestId,
            String reason) {

        SpecialPickupJoinRequest joinRequest =
                joinRepository.findById(joinRequestId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Join request not found"));

        if (joinRequest.getStatus()
                != JoinRequestStatus.PENDING_APPROVAL) {

            throw new IllegalArgumentException(
                    "Only pending requests can be rejected");
        }

        joinRequest.setStatus(
                JoinRequestStatus.REJECTED);

        joinRequest.setAdminReason(
                reason);

        SpecialPickupJoinRequest saved =
                joinRepository.save(joinRequest);

        User resident =
                userRepository.findById(
                        saved.getResidentId())
                        .orElse(null);

        return toResponse(saved, resident);
    }

    // =========================================================
    // ADMIN - GET OLD PENDING REQUESTS
    // =========================================================

    public List<JoinRequestResponse> getPendingJoinRequests() {

        return joinRepository
                .findByStatus(
                        JoinRequestStatus.PENDING_APPROVAL)
                .stream()
                .map(request -> {

                    User resident =
                            userRepository
                                    .findById(
                                            request.getResidentId())
                                    .orElse(null);

                    return toResponse(
                            request,
                            resident);
                })
                .toList();
    }

    // =========================================================
    // RESIDENT - GET MY JOINED PICKUPS
    // =========================================================

    public List<JoinRequestResponse> getResidentJoinRequests(
            String residentEmail) {

        User resident =
                userRepository.findByEmail(residentEmail)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Resident not found"));

        return joinRepository
                .findByResidentId(
                        resident.getId())
                .stream()
                .map(request ->
                        toResponse(
                                request,
                                resident))
                .toList();
    }

    // =========================================================
    // CHECK ACCEPTED WASTE TYPE
    // =========================================================

    private boolean isWasteTypeAccepted(
            String acceptedWasteTypes,
            String requestedWasteType) {

        if (acceptedWasteTypes == null
                || acceptedWasteTypes.isBlank()) {

            return true;
        }

        if (requestedWasteType == null
                || requestedWasteType.isBlank()) {

            return false;
        }

        String requested =
                requestedWasteType.trim();

        String[] acceptedTypes =
                acceptedWasteTypes.split(",");

        for (String accepted : acceptedTypes) {

            if (accepted.trim()
                    .equalsIgnoreCase(requested)) {

                return true;
            }
        }

        return false;
    }

    // =========================================================
    // HELPER METHODS
    // =========================================================

    private double safeDouble(Double value) {

        return value == null
                ? 0.0
                : value;
    }

    private int safeInteger(Integer value) {

        return value == null
                ? 0
                : value;
    }

    // =========================================================
    // CONVERT ENTITY TO RESPONSE DTO
    // =========================================================

    private JoinRequestResponse toResponse(
            SpecialPickupJoinRequest request,
            User resident) {

        JoinRequestResponse response =
                new JoinRequestResponse();

        response.setId(
                request.getId());

        if (request.getSpecialPickup() != null) {

            response.setSpecialPickupId(
                    request.getSpecialPickup().getId());

            response.setPickupTitle(
                    request.getSpecialPickup().getTitle());
        }

        response.setResidentId(
                request.getResidentId());

        if (resident != null) {

            response.setResidentName(
                    resident.getName());
        }

        response.setWasteType(
                request.getWasteType());

        response.setNumberOfItems(
                request.getNumberOfItems());

        response.setEstimatedSize(
                request.getEstimatedSize());

        response.setEstimatedWeightKg(
                request.getEstimatedWeightKg());

        response.setEstimatedVolumeM3(
                request.getEstimatedVolumeM3());

        response.setPickupAddress(
                request.getPickupAddress());

        response.setNotes(
                request.getNotes());

        response.setPhotoUrl(
                request.getPhotoUrl());

        if (request.getStatus() != null) {

            response.setStatus(
                    request.getStatus().name());
        }

        response.setAdminReason(
                request.getAdminReason());

        response.setCreatedAt(
                request.getCreatedAt());

        response.setApprovedAt(
                request.getApprovedAt());

        return response;
    }
}