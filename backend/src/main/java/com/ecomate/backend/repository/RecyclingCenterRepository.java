package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCenter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecyclingCenterRepository extends JpaRepository<RecyclingCenter, Long> {

    Optional<RecyclingCenter> findByOfficerEmailIgnoreCase(String officerEmail);

    Optional<RecyclingCenter> findByOfficerId(Long officerId);

    List<RecyclingCenter> findByCityIgnoreCase(String city);

    List<RecyclingCenter> findByIsOpenTrue();

    @Query("SELECT DISTINCT rc FROM RecyclingCenter rc JOIN rc.centerMaterials cm WHERE LOWER(cm.material.category) IN :categories AND cm.isActive = true")
    List<RecyclingCenter> findByAcceptedWasteCategory(@Param("categories") List<String> categories);
}



