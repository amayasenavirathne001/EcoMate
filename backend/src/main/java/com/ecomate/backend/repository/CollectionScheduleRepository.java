package com.ecomate.backend.repository;

import com.ecomate.backend.entity.CollectionSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CollectionScheduleRepository extends JpaRepository<CollectionSchedule, Long> {
}
