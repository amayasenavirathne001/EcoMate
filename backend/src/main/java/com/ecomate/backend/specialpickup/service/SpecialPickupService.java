package com.ecomate.backend.specialpickup.service;

import com.ecomate.backend.entity.User;
import com.ecomate.backend.repository.UserRepository;
import com.ecomate.backend.specialpickup.dto.SpecialPickupResponse;
import com.ecomate.backend.specialpickup.entity.SpecialPickup;
import com.ecomate.backend.specialpickup.entity.SpecialPickupJoinRequest;
import com.ecomate.backend.specialpickup.repository.SpecialPickupJoinRequestRepository;
import com.ecomate.backend.specialpickup.repository.SpecialPickupRepository;
import com.ecomate.backend.specialpickup.enums.SpecialPickupStatus;
import org.springframework.stereotype.Service;
import com.ecomate.backend.specialpickup.dto.CreateSpecialPickupRequest;
import com.ecomate.backend.specialpickup.entity.SpecialPickupSchedule;
import com.ecomate.backend.specialpickup.enums.SpecialPickupStatus;
import com.ecomate.backend.specialpickup.repository.SpecialPickupScheduleRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class SpecialPickupService {

    private final SpecialPickupRepository pickupRepository;
    private final SpecialPickupJoinRequestRepository joinRepository;
    private final UserRepository userRepository;
    private final SpecialPickupScheduleRepository scheduleRepository;
    
   public SpecialPickupService(
        SpecialPickupRepository pickupRepository,
        SpecialPickupJoinRequestRepository joinRepository,
        UserRepository userRepository,
        SpecialPickupScheduleRepository scheduleRepository) {

    this.pickupRepository = pickupRepository;
    this.joinRepository = joinRepository;
    this.userRepository = userRepository;
    this.scheduleRepository = scheduleRepository;
}

   public SpecialPickup createPickupFromSchedule(
        CreateSpecialPickupRequest request,
        Long adminId) {

    if (request.getScheduleId() == null) {
        throw new IllegalArgumentException(
                "Schedule is required");
    }

    if (request.getPickupDate() == null) {
        throw new IllegalArgumentException(
                "Pickup date is required");
    }

    SpecialPickupSchedule schedule =
            scheduleRepository.findById(request.getScheduleId())
                    .orElseThrow(() ->
                            new IllegalArgumentException(
                                    "Special pickup schedule not found"));

    if (!Boolean.TRUE.equals(schedule.getActive())) {
        throw new IllegalArgumentException(
                "This special pickup schedule is inactive");
    }

    // Make sure the selected date matches the schedule day.
    // Example: FRIDAY schedule -> selected date must be a Friday.
    if (request.getPickupDate().getDayOfWeek()
            != schedule.getDayOfWeek()) {

        throw new IllegalArgumentException(
                "Selected pickup date must be a "
                        + schedule.getDayOfWeek());
    }

    // Prevent duplicate pickups for the same schedule/date.
    if (pickupRepository
            .findByScheduleIdAndPickupDate(
                    schedule.getId(),
                    request.getPickupDate())
            .isPresent()) {

        throw new IllegalArgumentException(
                "A special pickup already exists for this schedule and date");
    }

    SpecialPickup pickup = new SpecialPickup();

    pickup.setSchedule(schedule);

    pickup.setTitle(
            request.getTitle() == null ||
            request.getTitle().isBlank()
                    ? "Special Pickup - "
                        + schedule.getRoute().getRouteName()
                    : request.getTitle());

    pickup.setDescription(request.getDescription());
    pickup.setLocation(request.getLocation());

    // Automatically get service area from route.
    pickup.setServiceArea(
            schedule.getRoute().getAreaOrZone());

    pickup.setPickupDate(
            request.getPickupDate());

    // Automatically copy times.
    pickup.setStartTime(
            schedule.getStartTime());

    pickup.setEndTime(
            schedule.getEndTime());

    // Automatically copy capacity.
    pickup.setMaxHouseholds(
            schedule.getMaxHouseholds());

    pickup.setMaxWeightKg(
            schedule.getMaxWeightKg());

    pickup.setMaxVolumeM3(
            schedule.getMaxVolumeM3());

    pickup.setAcceptedWasteTypes(
            schedule.getAcceptedWasteTypes());

    // New pickup starts empty.
    pickup.setJoinedHouseholds(0);
    pickup.setCurrentEstimatedWeightKg(0.0);
    pickup.setCurrentEstimatedVolumeM3(0.0);

    // Calculate deadline automatically.
    LocalDateTime pickupStart =
            LocalDateTime.of(
                    request.getPickupDate(),
                    schedule.getStartTime());

    pickup.setJoinDeadline(
            pickupStart.minusHours(
                    schedule.getJoinDeadlineHours()));

    pickup.setStatus(
            SpecialPickupStatus.SCHEDULED);

    pickup.setCreatedBy(adminId);

    return pickupRepository.save(pickup);
  }
  public SpecialPickup assignPickup(
        Long pickupId,
        Long truckId) {

    if (truckId == null) {
        throw new IllegalArgumentException(
                "Truck is required");
    }

    SpecialPickup pickup =
            pickupRepository.findById(pickupId)
                    .orElseThrow(() ->
                            new IllegalArgumentException(
                                    "Special pickup not found"));

    if (pickup.getStatus()
            != SpecialPickupStatus.SCHEDULED) {

        throw new IllegalArgumentException(
                "Only scheduled pickups can be assigned");
    }

    pickup.setTruckId(truckId);

    pickup.setStatus(
            SpecialPickupStatus.ASSIGNED);

    return pickupRepository.save(pickup);
}
    // =========================================================
    // GET AVAILABLE SPECIAL PICKUPS
    // =========================================================

    public List<SpecialPickupResponse> getAvailablePickups(
            String residentEmail) {

        User resident = userRepository.findByEmail(residentEmail)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Resident not found"));

        return pickupRepository
                .findByStatus(SpecialPickupStatus.ASSIGNED)
                .stream()
                .map(pickup ->
                        toResponse(pickup, resident.getId()))
                .toList();
    }

    // =========================================================
    // GET ONE SPECIAL PICKUP
    // =========================================================

    public SpecialPickupResponse getPickup(
            Long pickupId,
            String residentEmail) {

        User resident = userRepository.findByEmail(residentEmail)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Resident not found"));

        SpecialPickup pickup =
                pickupRepository.findById(pickupId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Special pickup not found"));

        return toResponse(
                pickup,
                resident.getId());
    }

    // =========================================================
    // CONVERT ENTITY TO RESPONSE
    // =========================================================

    private SpecialPickupResponse toResponse(
            SpecialPickup pickup,
            Long residentId) {

        SpecialPickupResponse response =
                new SpecialPickupResponse();

        response.setId(
                pickup.getId());

        response.setTitle(
                pickup.getTitle());

        response.setDescription(
                pickup.getDescription());

        response.setLocation(
                pickup.getLocation());

        response.setServiceArea(
                pickup.getServiceArea());

        response.setPickupDate(
                pickup.getPickupDate());

        response.setStartTime(
                pickup.getStartTime());

        response.setEndTime(
                pickup.getEndTime());

        response.setJoinDeadline(
                pickup.getJoinDeadline());

        response.setMaxHouseholds(
                pickup.getMaxHouseholds());

        response.setMaxWeightKg(
                pickup.getMaxWeightKg());

        response.setMaxVolumeM3(
                pickup.getMaxVolumeM3());

        response.setCurrentEstimatedWeightKg(
                pickup.getCurrentEstimatedWeightKg());

        response.setCurrentEstimatedVolumeM3(
                pickup.getCurrentEstimatedVolumeM3());

        response.setJoinedHouseholds(
                pickup.getJoinedHouseholds());

        response.setAcceptedWasteTypes(
                pickup.getAcceptedWasteTypes());

     response.setStatus(
        pickup.getStatus() != null
                ? pickup.getStatus().name()
                : null);

        // Check whether this resident already requested
        // to join this special pickup.
        Optional<SpecialPickupJoinRequest> joinRequest =
                joinRepository
                        .findBySpecialPickupIdAndResidentId(
                                pickup.getId(),
                                residentId);

        response.setUserJoinStatus(
                joinRequest
                        .map(request ->
                                request.getStatus().name())
                        .orElse(null));

        return response;
    }
        // =========================================================
    // ADMIN - GET ALL SPECIAL PICKUPS
    // =========================================================

    public List<SpecialPickup> getAllSpecialPickups() {
        return pickupRepository.findAll();
    }

}