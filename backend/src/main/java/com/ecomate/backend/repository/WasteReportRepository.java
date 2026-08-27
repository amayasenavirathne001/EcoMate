package com.ecomate.backend.repository;

import com.ecomate.backend.entity.WasteReport;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface WasteReportRepository extends JpaRepository<WasteReport, Long> {
    List<WasteReport> findByReporterEmailOrderByCreatedAtDesc(String reporterEmail);

    List<WasteReport> findAllByOrderByCreatedAtDesc();
}
