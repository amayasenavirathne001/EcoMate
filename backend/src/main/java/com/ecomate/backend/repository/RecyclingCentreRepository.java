package com.ecomate.backend.repository;

import com.ecomate.backend.entity.RecyclingCentre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecyclingCentreRepository extends JpaRepository<RecyclingCentre, Long> {

    Optional<RecyclingCentre> findByOfficerEmailIgnoreCase(String officerEmail);

    Optional<RecyclingCentre> findByOfficerId(Long officerId);

    List<RecyclingCentre> findByCityIgnoreCase(String city);

    List<RecyclingCentre> findByIsOpenTrue();
}