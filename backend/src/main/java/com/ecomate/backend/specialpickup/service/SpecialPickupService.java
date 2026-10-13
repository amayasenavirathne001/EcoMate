
package com.ecomate.backend.specialpickup.service;

import com.ecomate.backend.entity.CollectorDriver;
import com.ecomate.backend.entity.EmployeeRole;
import com.ecomate.backend.entity.EmployeeStatus;
import com.ecomate.backend.entity.User;
import com.ecomate.backend.entity.Vehicle;
import com.ecomate.backend.entity.VehicleStatus;

import com.ecomate.backend.repository.CollectorDriverRepository;
import com.ecomate.backend.repository.UserRepository;
import com.ecomate.backend.repository.VehicleRepository;

import com.ecomate.backend.specialpickup.dto.CreateSpecialPickupRequest;
import com.ecomate.backend.specialpickup.dto.SpecialPickupResponse;
import com.ecomate.backend.specialpickup.entity.SpecialPickup;
import com.ecomate.backend.specialpickup.entity.SpecialPickupJoinRequest;
import com.ecomate.backend.specialpickup.entity.SpecialPickupSchedule;
import com.ecomate.backend.specialpickup.enums.SpecialPickupStatus;
import com.ecomate.backend.specialpickup.repository.SpecialPickupJoinRequestRepository;
import com.ecomate.backend.specialpickup.repository.SpecialPickupRepository;
import com.ecomate.backend.specialpickup.repository.SpecialPickupScheduleRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class SpecialPickupService {

    private final SpecialPickupRepository pickupRepository;
    private final SpecialPickupJoinRequestRepository joinRepository;
    private final UserRepository userRepository;
    private final SpecialPickupScheduleRepository scheduleRepository;
    private final CollectorDriverRepository driverRepository;
    private final VehicleRepository vehicleRepository;

    public SpecialPickupService(
            SpecialPickupRepository pickupRepository,
            SpecialPickupJoinRequestRepository joinRepository,
            UserRepository userRepository,
            SpecialPickupScheduleRepository scheduleRepository,
            CollectorDriverRepository driverRepository,
            VehicleRepository vehicleRepository) {

        this.pickupRepository = pickupRepository;
        this.joinRepository = joinRepository;
        this.userRepository = userRepository;
        this.scheduleRepository = scheduleRepository;
        this.driverRepository = driverRepository;
        this.vehicleRepository = vehicleRepository;
    }

    // =========================================================
    // ADMIN - CREATE PICKUP FROM SCHEDULE
    // =========================================================

    @Transactional
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

        if (request.getPickupDate().getDayOfWeek()
                != schedule.getDayOfWeek()) {

            throw new IllegalArgumentException(
                    "Selected pickup date must be a "
                            + schedule.getDayOfWeek());
        }

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
                request.getTitle() == null
                        || request.getTitle().isBlank()
                        ? "Special Pickup - "
                            + schedule.getRoute().getRouteName()
                        : request.getTitle());

        pickup.setDescription(request.getDescription());

        if (request.getLocation() == null
                || request.getLocation().isBlank()) {

            pickup.setLocation(
                    schedule.getRoute().getAreaOrZone());
        } else {
            pickup.setLocation(request.getLocation());
        }

        pickup.setServiceArea(
                schedule.getRoute().getAreaOrZone());

        pickup.setPickupDate(request.getPickupDate());
        pickup.setStartTime(schedule.getStartTime());
        pickup.setEndTime(schedule.getEndTime());

        Integer minimumHouseholds =
                schedule.getMinHouseholds() != null
                        ? schedule.getMinHouseholds()
                        : 4;

        pickup.setMinHouseholds(minimumHouseholds);
        pickup.setMaxHouseholds(schedule.getMaxHouseholds());
        pickup.setMaxWeightKg(schedule.getMaxWeightKg());
        pickup.setMaxVolumeM3(schedule.getMaxVolumeM3());

        pickup.setAcceptedWasteTypes(
                schedule.getAcceptedWasteTypes());

        pickup.setJoinedHouseholds(0);
        pickup.setCurrentEstimatedWeightKg(0.0);
        pickup.setCurrentEstimatedVolumeM3(0.0);

        LocalDateTime pickupStart =
                LocalDateTime.of(
                        request.getPickupDate(),
                        schedule.getStartTime());

        pickup.setJoinDeadline(
                pickupStart.minusHours(
                        schedule.getJoinDeadlineHours()));

        pickup.setStatus(SpecialPickupStatus.SCHEDULED);
        pickup.setCancellationReason(null);
        pickup.setCreatedBy(adminId);

        return pickupRepository.save(pickup);
    }

    // =========================================================
    // ADMIN - ASSIGN VEHICLE AND DRIVER
    // =========================================================

    @Transactional
    public SpecialPickup assignPickup(
            Long pickupId,
            Long truckId,
            Long driverId) {

        if (truckId == null || driverId == null) {
            throw new IllegalArgumentException(
                    "Vehicle and driver are required");
        }

        SpecialPickup pickup = pickupRepository.findById(pickupId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Special pickup not found"));

        if (pickup.getStatus() != SpecialPickupStatus.SCHEDULED) {
            throw new IllegalArgumentException(
                    "Only scheduled pickups can be assigned");
        }

        int joinedHouseholds =
                pickup.getJoinedHouseholds() != null
                        ? pickup.getJoinedHouseholds()
                        : 0;

        int minimumHouseholds =
                pickup.getMinHouseholds() != null
                        ? pickup.getMinHouseholds()
                        : 4;

        if (joinedHouseholds < minimumHouseholds) {
            int remaining = minimumHouseholds - joinedHouseholds;

            throw new IllegalArgumentException(
                    "Cannot assign vehicle yet. "
                            + "Minimum participation is "
                            + minimumHouseholds
                            + " households. "
                            + remaining
                            + " more household"
                            + (remaining == 1 ? "" : "s")
                            + " required.");
        }

        Vehicle vehicle = vehicleRepository.findById(truckId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Vehicle not found"));

        CollectorDriver driver =
                driverRepository.findById(driverId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Driver not found"));

        if (!vehicle.isActive()) {
            throw new IllegalArgumentException(
                    "Selected vehicle is inactive");
        }

        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new IllegalArgumentException(
                    "Selected vehicle is not available");
        }

        if (!driver.isActive()) {
            throw new IllegalArgumentException(
                    "Selected driver is inactive");
        }

        if (driver.getRole() != EmployeeRole.DRIVER) {
            throw new IllegalArgumentException(
                    "Selected employee is not a driver");
        }

        if (driver.getStatus() != EmployeeStatus.AVAILABLE) {
            throw new IllegalArgumentException(
                    "Selected driver is not available");
        }

        // Prevent overlapping special pickup assignments.
        LocalDateTime requestedStart = LocalDateTime.of(
                pickup.getPickupDate(),
                pickup.getStartTime());

        LocalDateTime requestedEnd = LocalDateTime.of(
                pickup.getPickupDate(),
                pickup.getEndTime());

        // Supports collection windows crossing midnight.
        if (!requestedEnd.isAfter(requestedStart)) {
            requestedEnd = requestedEnd.plusDays(1);
        }

        for (SpecialPickup other : pickupRepository.findAll()) {

            if (other.getId().equals(pickup.getId())) {
                continue;
            }

            if (other.getStatus() != SpecialPickupStatus.ASSIGNED
                    && other.getStatus() != SpecialPickupStatus.IN_PROGRESS) {
                continue;
            }

            if (other.getPickupDate() == null
                    || other.getStartTime() == null
                    || other.getEndTime() == null) {
                continue;
            }

            boolean sameVehicle =
                    truckId.equals(other.getTruckId());

            boolean sameDriver =
                    other.getDriver() != null
                            && driverId.equals(other.getDriver().getId());

            if (!sameVehicle && !sameDriver) {
                continue;
            }

            LocalDateTime otherStart = LocalDateTime.of(
                    other.getPickupDate(),
                    other.getStartTime());

            LocalDateTime otherEnd = LocalDateTime.of(
                    other.getPickupDate(),
                    other.getEndTime());

            if (!otherEnd.isAfter(otherStart)) {
                otherEnd = otherEnd.plusDays(1);
            }

            boolean overlaps =
                    requestedStart.isBefore(otherEnd)
                            && otherStart.isBefore(requestedEnd);

            if (overlaps) {
                throw new IllegalArgumentException(
                        sameVehicle
                                ? "Vehicle is already assigned to another special pickup at this time"
                                : "Driver is already assigned to another special pickup at this time");
            }
        }

        pickup.setTruckId(vehicle.getId());
        pickup.setDriver(driver);
        pickup.setStatus(SpecialPickupStatus.ASSIGNED);
        pickup.setCancellationReason(null);

        return pickupRepository.save(pickup);
    }

    // =========================================================
    // ADMIN - CANCEL PICKUP
    // =========================================================

    @Transactional
    public SpecialPickup cancelPickup(
            Long pickupId,
            String reason) {

        SpecialPickup pickup =
                pickupRepository.findById(pickupId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Special pickup not found"));

        if (pickup.getStatus() == SpecialPickupStatus.COMPLETED) {
            throw new IllegalArgumentException(
                    "Completed pickups cannot be cancelled");
        }

        if (pickup.getStatus() == SpecialPickupStatus.CANCELLED) {
            throw new IllegalArgumentException(
                    "This pickup is already cancelled");
        }

        if (pickup.getStatus() == SpecialPickupStatus.IN_PROGRESS) {
            throw new IllegalArgumentException(
                    "A pickup already in progress cannot be cancelled");
        }

        String cancellationReason = reason;

        if (cancellationReason == null
                || cancellationReason.isBlank()) {

            cancellationReason =
                    "Minimum participation was not reached.";
        }

        pickup.setStatus(SpecialPickupStatus.CANCELLED);
        pickup.setCancellationReason(cancellationReason.trim());

        pickup.setTruckId(null);
        pickup.setDriver(null);

        return pickupRepository.save(pickup);
    }

    // =========================================================
    // RESIDENT - GET AVAILABLE SPECIAL PICKUPS
    // =========================================================

    public List<SpecialPickupResponse> getAvailablePickups(
            String residentEmail) {

        User resident = userRepository.findByEmail(residentEmail)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Resident not found"));

        return pickupRepository.findAll()
                .stream()
                .filter(pickup ->
                        pickup.getStatus() == SpecialPickupStatus.SCHEDULED
                                || pickup.getStatus() == SpecialPickupStatus.CANCELLED
                                || pickup.getStatus() == SpecialPickupStatus.ASSIGNED
                                || pickup.getStatus() == SpecialPickupStatus.IN_PROGRESS
                                || pickup.getStatus() == SpecialPickupStatus.COMPLETED)
                .map(pickup -> toResponse(pickup, resident.getId()))
                .toList();
    }

    // =========================================================
    // RESIDENT - GET ONE SPECIAL PICKUP
    // =========================================================

    public SpecialPickupResponse getPickup(
            Long pickupId,
            String residentEmail) {

        User resident = userRepository.findByEmail(residentEmail)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Resident not found"));

        SpecialPickup pickup = pickupRepository.findById(pickupId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Special pickup not found"));

        return toResponse(pickup, resident.getId());
    }

    // =========================================================
    // CONVERT ENTITY TO RESPONSE
    // =========================================================

    private SpecialPickupResponse toResponse(
            SpecialPickup pickup,
            Long residentId) {

        SpecialPickupResponse response =
                new SpecialPickupResponse();

        response.setId(pickup.getId());
        response.setTitle(pickup.getTitle());
        response.setDescription(pickup.getDescription());
        response.setLocation(pickup.getLocation());
        response.setServiceArea(pickup.getServiceArea());

        response.setPickupDate(pickup.getPickupDate());
        response.setStartTime(pickup.getStartTime());
        response.setEndTime(pickup.getEndTime());
        response.setJoinDeadline(pickup.getJoinDeadline());

        response.setMinHouseholds(pickup.getMinHouseholds());
        response.setMaxHouseholds(pickup.getMaxHouseholds());

        response.setMaxWeightKg(pickup.getMaxWeightKg());
        response.setMaxVolumeM3(pickup.getMaxVolumeM3());

        response.setCurrentEstimatedWeightKg(
                pickup.getCurrentEstimatedWeightKg());

        response.setCurrentEstimatedVolumeM3(
                pickup.getCurrentEstimatedVolumeM3());

        response.setJoinedHouseholds(pickup.getJoinedHouseholds());
        response.setAcceptedWasteTypes(pickup.getAcceptedWasteTypes());

        response.setStatus(
                pickup.getStatus() != null
                        ? pickup.getStatus().name()
                        : null);

        response.setCancellationReason(
                pickup.getCancellationReason());

        Optional<SpecialPickupJoinRequest> joinRequest =
                joinRepository.findBySpecialPickupIdAndResidentId(
                        pickup.getId(),
                        residentId);

        response.setUserJoinStatus(
                joinRequest
                        .map(request -> request.getStatus().name())
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
