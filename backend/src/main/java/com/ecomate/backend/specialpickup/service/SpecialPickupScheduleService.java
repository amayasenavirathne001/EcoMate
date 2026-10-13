package com.ecomate.backend.specialpickup.service;

import com.ecomate.backend.entity.Route;
import com.ecomate.backend.repository.RouteRepository;
import com.ecomate.backend.specialpickup.dto.SpecialPickupScheduleRequest;
import com.ecomate.backend.specialpickup.entity.SpecialPickupSchedule;
import com.ecomate.backend.specialpickup.repository.SpecialPickupScheduleRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SpecialPickupScheduleService {

    private final SpecialPickupScheduleRepository scheduleRepository;
    private final RouteRepository routeRepository;

    public SpecialPickupScheduleService(
            SpecialPickupScheduleRepository scheduleRepository,
            RouteRepository routeRepository) {

        this.scheduleRepository = scheduleRepository;
        this.routeRepository = routeRepository;
    }

    // =========================================================
    // CREATE SCHEDULE
    // =========================================================

    @Transactional
    public SpecialPickupSchedule createSchedule(
            SpecialPickupScheduleRequest request,
            Long adminId) {

        validateRequest(request);

        Route route = routeRepository.findById(request.getRouteId())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Route not found with id: "
                                        + request.getRouteId()
                        )
                );

        // Prevent two active schedules for the same route/day.
        scheduleRepository
                .findByRouteIdAndDayOfWeekAndActiveTrue(
                        request.getRouteId(),
                        request.getDayOfWeek()
                )
                .ifPresent(existing -> {
                    throw new IllegalArgumentException(
                            "An active special pickup schedule already exists "
                                    + "for this route and day"
                    );
                });

        SpecialPickupSchedule schedule =
                new SpecialPickupSchedule();

        schedule.setRoute(route);
        schedule.setDayOfWeek(request.getDayOfWeek());
        schedule.setStartTime(request.getStartTime());
        schedule.setEndTime(request.getEndTime());

        // Minimum participation.
        // Use 4 as the default if the frontend does not send a value yet.
        schedule.setMinHouseholds(
                request.getMinHouseholds() != null
                        ? request.getMinHouseholds()
                        : 4
        );

        schedule.setMaxHouseholds(
                request.getMaxHouseholds());

        schedule.setMaxWeightKg(
                request.getMaxWeightKg());

        schedule.setMaxVolumeM3(
                request.getMaxVolumeM3());

        schedule.setJoinDeadlineHours(
                request.getJoinDeadlineHours());

        schedule.setAcceptedWasteTypes(
                request.getAcceptedWasteTypes());

        schedule.setActive(true);
        schedule.setCreatedBy(adminId);

        return scheduleRepository.save(schedule);
    }

    // =========================================================
    // GET ALL ACTIVE SCHEDULES
    // =========================================================

    public List<SpecialPickupSchedule> getActiveSchedules() {
        return scheduleRepository.findByActiveTrue();
    }

    // =========================================================
    // GET ONE
    // =========================================================

    public SpecialPickupSchedule getSchedule(Long id) {

        return scheduleRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Special pickup schedule not found"
                        )
                );
    }

    // =========================================================
    // DISABLE SCHEDULE
    // =========================================================

    @Transactional
    public SpecialPickupSchedule disableSchedule(Long id) {

        SpecialPickupSchedule schedule =
                getSchedule(id);

        schedule.setActive(false);

        return scheduleRepository.save(schedule);
    }

    // =========================================================
    // VALIDATION
    // =========================================================

    private void validateRequest(
            SpecialPickupScheduleRequest request) {

        if (request.getRouteId() == null) {
            throw new IllegalArgumentException(
                    "Route is required");
        }

        if (request.getDayOfWeek() == null) {
            throw new IllegalArgumentException(
                    "Pickup day is required");
        }

        if (request.getStartTime() == null ||
                request.getEndTime() == null) {

            throw new IllegalArgumentException(
                    "Start time and end time are required");
        }

        if (!request.getEndTime()
                .isAfter(request.getStartTime())) {

            throw new IllegalArgumentException(
                    "End time must be after start time");
        }

        if (request.getMaxHouseholds() == null ||
                request.getMaxHouseholds() <= 0) {

            throw new IllegalArgumentException(
                    "Maximum households must be greater than 0");
        }

        // If minimum is supplied, validate it.
        // If not supplied, createSchedule() defaults it to 4.
        if (request.getMinHouseholds() != null) {

            if (request.getMinHouseholds() <= 0) {
                throw new IllegalArgumentException(
                        "Minimum households must be greater than 0");
            }

            if (request.getMinHouseholds() >
                    request.getMaxHouseholds()) {

                throw new IllegalArgumentException(
                        "Minimum households cannot be greater than maximum households");
            }
        } else if (request.getMaxHouseholds() < 4) {

            // Default minimum is 4, so maximum cannot be below 4.
            throw new IllegalArgumentException(
                    "Maximum households must be at least 4 when minimum households is not provided");
        }

        if (request.getMaxWeightKg() == null ||
                request.getMaxWeightKg() <= 0) {

            throw new IllegalArgumentException(
                    "Maximum weight must be greater than 0");
        }

        if (request.getMaxVolumeM3() == null ||
                request.getMaxVolumeM3() <= 0) {

            throw new IllegalArgumentException(
                    "Maximum volume must be greater than 0");
        }

        if (request.getJoinDeadlineHours() == null ||
                request.getJoinDeadlineHours() <= 0) {

            throw new IllegalArgumentException(
                    "Join deadline hours must be greater than 0");
        }

        if (request.getAcceptedWasteTypes() == null ||
                request.getAcceptedWasteTypes().isBlank()) {

            throw new IllegalArgumentException(
                    "At least one accepted waste type is required");
        }
    }
}