package com.ecomate.backend.specialpickup.repository;

import com.ecomate.backend.specialpickup.entity.SpecialPickup;
import com.ecomate.backend.specialpickup.enums.SpecialPickupStatus;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface SpecialPickupRepository
        extends JpaRepository<SpecialPickup, Long> {

    List<SpecialPickup> findByServiceAreaAndStatus(
            String serviceArea,
            SpecialPickupStatus status
    );

    List<SpecialPickup> findByStatus(
            SpecialPickupStatus status
    );

    Optional<SpecialPickup> findByScheduleIdAndPickupDate(
            Long scheduleId,
            LocalDate pickupDate
    );
}