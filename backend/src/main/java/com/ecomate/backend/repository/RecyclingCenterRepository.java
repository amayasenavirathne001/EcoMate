package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCenter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RecyclingCenterRepository extends JpaRepository<RecyclingCenter, String> {
}
