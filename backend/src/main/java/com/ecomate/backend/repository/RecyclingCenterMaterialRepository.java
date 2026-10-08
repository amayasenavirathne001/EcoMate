package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCenterMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

@Repository
public interface RecyclingCenterMaterialRepository extends JpaRepository<RecyclingCenterMaterial, Long> {
    List<RecyclingCenterMaterial> findByRecyclingCenterId(Long centerId);
    
    @Query("SELECT rcm FROM RecyclingCenterMaterial rcm WHERE rcm.recyclingCenter.id = :centerId AND rcm.material.id = :materialId")
    Optional<RecyclingCenterMaterial> findByRecyclingCenterIdAndMaterialId(@Param("centerId") Long centerId, @Param("materialId") Long materialId);
    
    void deleteByRecyclingCenterId(Long centerId);
}


