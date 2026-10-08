package com.ecomate.backend.specialpickup.repository;

import com.ecomate.backend.specialpickup.entity.SpecialPickupSchedule;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.DayOfWeek;
import java.util.List;
import java.util.Optional;

@Repository
public interface SpecialPickupScheduleRepository
        extends JpaRepository<SpecialPickupSchedule, Long> {

    List<SpecialPickupSchedule> findByActiveTrue();

    List<SpecialPickupSchedule>
    findByRouteIdAndActiveTrue(Long routeId);

    Optional<SpecialPickupSchedule>
    findByRouteIdAndDayOfWeekAndActiveTrue(
            Long routeId,
            DayOfWeek dayOfWeek
    );
}