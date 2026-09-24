package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCentre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecyclingCentreRepository extends JpaRepository<RecyclingCentre, Long> {

    Optional<RecyclingCentre> findByOfficerEmailIgnoreCase(String officerEmail);

    Optional<RecyclingCentre> findByOfficerId(Long officerId);

    List<RecyclingCentre> findByCityIgnoreCase(String city);

    List<RecyclingCentre> findByIsOpenTrue();

    @Query("SELECT DISTINCT rc FROM RecyclingCentre rc JOIN rc.centreMaterials cm WHERE LOWER(cm.material.category) IN :categories AND cm.isActive = true")
    List<RecyclingCentre> findByAcceptedWasteCategory(@Param("categories") List<String> categories);
}

