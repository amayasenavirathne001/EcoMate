package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCenterMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecyclingCenterMaterialRepository extends JpaRepository<RecyclingCenterMaterial, Long> {
    List<RecyclingCenterMaterial> findByRecyclingCenterId(Long CenterId);
    Optional<RecyclingCenterMaterial> findByRecyclingCenterIdAndMaterialId(Long CenterId, Long materialId);
    void deleteByRecyclingCenterId(Long CenterId);
}
