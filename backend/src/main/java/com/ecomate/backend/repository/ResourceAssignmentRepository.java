package com.ecomate.backend.repository;

import com.ecomate.backend.entity.AssignmentStatus;
import com.ecomate.backend.entity.ResourceAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

public interface ResourceAssignmentRepository extends JpaRepository<ResourceAssignment, Long> {
    
    @Query("SELECT a FROM ResourceAssignment a WHERE a.status IN :statuses " +
           "AND a.job.startTime < :endTime AND a.job.endTime > :startTime")
    List<ResourceAssignment> findOverlappingAssignments(
        @Param("statuses") List<AssignmentStatus> statuses,
        @Param("startTime") LocalDateTime startTime,
        @Param("endTime") LocalDateTime endTime
    );

    List<ResourceAssignment> findByJobId(Long jobId);

    boolean existsByDriverIdAndStatusIn(Long driverId, List<AssignmentStatus> statuses);
    boolean existsByCollectorsIdAndStatusIn(Long collectorId, List<AssignmentStatus> statuses);
    boolean existsByVehicleIdAndStatusIn(Long vehicleId, List<AssignmentStatus> statuses);
}
