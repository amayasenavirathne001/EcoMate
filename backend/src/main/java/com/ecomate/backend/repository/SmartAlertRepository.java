package com.ecomate.backend.repository;

import com.ecomate.backend.entity.AlertStatus;
import com.ecomate.backend.entity.AlertType;
import com.ecomate.backend.entity.SmartAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SmartAlertRepository extends JpaRepository<SmartAlert, Long> {
    List<SmartAlert> findByStatus(AlertStatus status);
    List<SmartAlert> findByStatusNot(AlertStatus status);
    Optional<SmartAlert> findByJobIdAndTypeAndStatusNot(Long jobId, AlertType type, AlertStatus status);
}
