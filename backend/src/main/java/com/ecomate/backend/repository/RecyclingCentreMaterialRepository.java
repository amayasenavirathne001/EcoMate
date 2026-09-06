package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCentreMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecyclingCentreMaterialRepository extends JpaRepository<RecyclingCentreMaterial, Long> {
    List<RecyclingCentreMaterial> findByRecyclingCentreId(Long centreId);
    Optional<RecyclingCentreMaterial> findByRecyclingCentreIdAndMaterialId(Long centreId, Long materialId);
}