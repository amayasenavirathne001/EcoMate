package com.ecomate.backend.repository;

import com.ecomate.backend.entity.WasteDelivery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WasteDeliveryRepository extends JpaRepository<WasteDelivery, Long> {

    List<WasteDelivery> findByRecyclingCentreIdOrderByDateTimeDesc(Long recyclingCentreId);

    List<WasteDelivery> findAllByOrderByDateTimeDesc();
}
