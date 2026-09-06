package com.ecomate.backend.repository;

import com.ecomate.backend.entity.CollectionJob;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CollectionJobRepository extends JpaRepository<CollectionJob, Long> {
    List<CollectionJob> findByStatus(String status);
}
