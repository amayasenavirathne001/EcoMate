package com.ecomate.backend.repository;

import com.ecomate.backend.entity.CollectorDriver;
import com.ecomate.backend.entity.EmployeeRole;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CollectorDriverRepository extends JpaRepository<CollectorDriver, Long> {
    Optional<CollectorDriver> findByEmployeeId(String employeeId);
    boolean existsByEmployeeId(String employeeId);
    List<CollectorDriver> findByActive(boolean active);
    List<CollectorDriver> findByActiveAndRole(boolean active, EmployeeRole role);
}
