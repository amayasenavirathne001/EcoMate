package com.ecomate.backend.specialpickup.repository;

import com.ecomate.backend.specialpickup.entity.SpecialPickupJoinRequest;
import com.ecomate.backend.specialpickup.enums.JoinRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SpecialPickupJoinRequestRepository extends JpaRepository<SpecialPickupJoinRequest, Long> {
    List<SpecialPickupJoinRequest> findByResidentId(Long residentId);
    List<SpecialPickupJoinRequest> findBySpecialPickupId(Long specialPickupId);
    List<SpecialPickupJoinRequest> findBySpecialPickupIdAndStatus(Long specialPickupId, JoinRequestStatus status);
    List<SpecialPickupJoinRequest> findByStatus(JoinRequestStatus status);
    Optional<SpecialPickupJoinRequest> findBySpecialPickupIdAndResidentId(Long specialPickupId, Long residentId);
    boolean existsBySpecialPickupIdAndResidentId(
        Long specialPickupId,
        Long residentId
    );
}

