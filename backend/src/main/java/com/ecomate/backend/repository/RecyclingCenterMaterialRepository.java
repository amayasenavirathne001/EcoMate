package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCenterMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecyclingCenterMaterialRepository extends JpaRepository<RecyclingCenterMaterial, Long> {
    List<RecyclingCenterMaterial> findByRecyclingCenterId(Long centerId);
    Optional<RecyclingCenterMaterial> findByRecyclingCenterIdAndMaterialId(Long centerId, Long materialId);
    void deleteByRecyclingCenterId(Long centerId);
}


